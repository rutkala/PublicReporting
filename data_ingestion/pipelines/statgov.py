# statgov.py
# Scrape DBW bulk category pages and upload ZIPs to MinIO *per category* (incremental, overwrite enabled).

import os
import re
import sys
import json
import time
import argparse
import hashlib
from urllib.parse import urlparse, unquote

import requests
import s3fs
from playwright.sync_api import sync_playwright

# ---------- Site ----------
HOST = "https://dbw.stat.gov.pl"
PAGE_TMPL = HOST + "/pl/katalog/bulk/{id}"
UA = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/122.0 Safari/537.36"
)
DL_HEADERS = {"User-Agent": UA}

# Regexes handle both / and \ separators
ZIP_RE_ABS = re.compile(r"https?://dbw\.stat\.gov\.pl[\\/]+bulk_new[\\/][^\s\"'<>]+?\.zip", re.I)
ZIP_RE_REL = re.compile(r"[\\/]+bulk_new[\\/][^\s\"'<>]+?\.zip", re.I)

# ---------- MinIO (env) ----------
BUCKET = os.getenv("MINIO_BUCKET_NAME")
ENDPOINT = os.getenv("MINIO_SERVER_URL")
PREFIX = os.getenv("STATGOV_PREFIX", "files/statgov/data/")
MANIFEST_KEY = os.getenv("STATGOV_MANIFEST", "files/statgov/_manifests/manifest.jsonl")

# ---------- Helpers ----------
def normalize_zip_url(u: str) -> str:
    u = (u or "").strip().replace("\\", "/")
    if not u:
        return u
    if u.startswith("/"):
        return HOST + u
    if u.lower().startswith("http"):
        return u
    if "bulk_new" in u:
        if not u.startswith("/"):
            u = "/" + u
        return HOST + u
    return u


def filename_from_url(url: str) -> str:
    return unquote(os.path.basename(urlparse(url).path)) or "file.zip"


def extract_category_from_filename(fn: str) -> str:
    head = fn.split("_", 1)[0]
    return head if head.isdigit() else "unknown"


def s3fs_client():
    return s3fs.S3FileSystem(
        key=os.getenv("AWS_ACCESS_KEY_ID"),
        secret=os.getenv("AWS_SECRET_ACCESS_KEY"),
        client_kwargs={"endpoint_url": ENDPOINT},
    )


def s3_mkdirs(fs: s3fs.S3FileSystem, key: str):
    parent = os.path.dirname(f"/{BUCKET}/{key}")
    if parent and not fs.exists(parent):
        fs.makedirs(parent, exist_ok=True)


def stream_to_minio(fs: s3fs.S3FileSystem, key: str, resp: requests.Response) -> tuple[int, str]:
    s3_mkdirs(fs, key)
    md5 = hashlib.md5()
    total = 0
    with fs.open(
        f"/{BUCKET}/{key}",
        "wb",
        s3_additional_kwargs={"ContentType": "application/zip"},
    ) as f:
        for chunk in resp.iter_content(chunk_size=1024 * 1024):
            if not chunk:
                continue
            f.write(chunk)
            md5.update(chunk)
            total += len(chunk)
    return total, md5.hexdigest()


def append_manifest(fs: s3fs.S3FileSystem, record: dict):
    s3_mkdirs(fs, MANIFEST_KEY)
    with fs.open(f"/{BUCKET}/{MANIFEST_KEY}", "ab") as f:
        f.write((json.dumps(record, ensure_ascii=False) + "\n").encode("utf-8"))


def download_response(url: str, timeout: int = 300) -> requests.Response:
    r = requests.get(url, headers=DL_HEADERS, stream=True, timeout=timeout)
    r.raise_for_status()
    return r

# ---------- Upload one batch ----------
def ingest_zip_urls(zip_urls: list[str], fs: s3fs.S3FileSystem | None, dry_run: bool, seen_urls: set[str]):
    """
    Upload a list of ZIP URLs immediately (overwrite existing).
    Deduplicate by seen_urls so we don't re-upload across categories.
    """
    created_fs_here = False
    if not dry_run and fs is None:
        fs = s3fs_client()
        created_fs_here = True

    for url in sorted(set(zip_urls)):
        url = normalize_zip_url(url)
        if url in seen_urls:
            # Already handled in a previous category
            continue
        seen_urls.add(url)

        fn = filename_from_url(url)
        cat = extract_category_from_filename(fn)
        key = f"{PREFIX}{cat}/{fn}"

        print(f"⬇️  {url}", flush=True)

        if dry_run:
            print(f"[DRY] would upload -> s3://{BUCKET}/{key}", flush=True)
            continue

        # Overwrite existing
        if fs.exists(f"/{BUCKET}/{key}"):
            print(f"↩️  removing old file: s3://{BUCKET}/{key}", flush=True)
            fs.rm(f"/{BUCKET}/{key}")

        try:
            resp = download_response(url)
            size, md5 = stream_to_minio(fs, key, resp)
        except Exception as e:
            print(f"❌  failed: {url} -> {e}", flush=True)
            continue

        append_manifest(
            fs,
            {
                "source_url": url,
                "bucket": BUCKET,
                "key": key,
                "size_bytes": size,
                "md5": md5,
                "filename": fn,
                "category": cat,
            },
        )
        print(f"✅  uploaded: s3://{BUCKET}/{key}  ({size} bytes, md5={md5})", flush=True)

    # created_fs_here is unused; s3fs does not require explicit close

# ---------- Scrape + ingest per category ----------
def process_categories_incremental(
    id_start: int,
    id_end: int,
    sleep: float,
    debug: bool,
    dry_run: bool,
):
    seen_urls: set[str] = set()
    fs = None if dry_run else s3fs_client()

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True, args=["--no-sandbox", "--disable-dev-shm-usage"])
        ctx = browser.new_context(user_agent=UA, locale="pl-PL")
        page = ctx.new_page()
        page.set_default_timeout(15000)

        # Capture lazy network links
        req_captured: list[str] = []

        def on_request(req):
            u = req.url
            if "bulk_new" in u and u.lower().endswith(".zip"):
                req_captured.append(u)

        page.on("request", on_request)

        for cat_id in range(id_start, id_end + 1):
            url = PAGE_TMPL.format(id=cat_id)
            print(f"\n—— Category {cat_id} | {url}", flush=True)

            try:
                page.goto(url, wait_until="networkidle")
            except Exception:
                # Fallback to domcontentloaded for slow pages
                try:
                    page.goto(url, wait_until="domcontentloaded", timeout=15000)
                except Exception as e2:
                    print(f"⚠️  navigation failed: {e2}", flush=True)
                    time.sleep(sleep)
                    continue

            # Light wait for meaningful content
            for sel in ("text=ZIP (CSV)", "table", "main"):
                try:
                    page.wait_for_selector(sel, timeout=5000)
                    break
                except Exception:
                    continue

            # Collect ZIP URLs for *this* category
            zips = set()

            # 1) Full HTML regex
            html = page.content()
            if debug:
                print(f"   [dbg] html size={len(html)}", flush=True)
            for m in ZIP_RE_ABS.findall(html):
                zips.add(normalize_zip_url(m))
            for m in ZIP_RE_REL.findall(html):
                zips.add(normalize_zip_url(m))

            # 2) <main> HTML regex
            try:
                main_html = page.locator("main").first.inner_html(timeout=3000)
                for m in ZIP_RE_ABS.findall(main_html):
                    zips.add(normalize_zip_url(m))
                for m in ZIP_RE_REL.findall(main_html):
                    zips.add(normalize_zip_url(m))
            except Exception:
                pass

            # 3) All anchors
            try:
                anchors = page.locator("a").all()
                for a in anchors:
                    try:
                        href = a.get_attribute("href") or ""
                        if "bulk_new" in href or ZIP_RE_REL.search(href or ""):
                            zips.add(normalize_zip_url(href))
                    except Exception:
                        pass
            except Exception:
                pass

            # 4) Click "ZIP (CSV)" to trigger lazy requests (captured via on_request)
            try:
                btns = page.locator("text=ZIP (CSV)")
                n = btns.count()
                for i in range(n):
                    try:
                        btns.nth(i).click()
                        page.wait_for_timeout(300)
                    except Exception:
                        pass
            except Exception:
                pass

            # Merge captured network URLs for this page
            if req_captured:
                for u in req_captured:
                    zips.add(normalize_zip_url(u))
                req_captured.clear()

            zips = {u for u in zips if u.lower().endswith(".zip")}

            if not zips:
                print("   (no ZIP links found)", flush=True)
            else:
                for u in sorted(zips):
                    print("   ZIP:", u, flush=True)

                # ⬇️ Incremental upload per category
                ingest_zip_urls(sorted(zips), fs, dry_run, seen_urls)

            time.sleep(sleep)

        browser.close()

# ---------- Wrapper for Dagster ----------
def run_statgov(
    id_start: int = 1,
    id_end: int = 2000,
    sleep: float = 0.5,
    debug: bool = False,
    dry_run: bool = False,
):
    """Entry point for Dagster (or CLI)."""
    print(f"🔎 Scanning categories {id_start}..{id_end} (incremental upload)", flush=True)
    process_categories_incremental(id_start, id_end, sleep, debug, dry_run)
    print("\n✅ Done.", flush=True)

# ---------- CLI ----------
def parse_args():
    ap = argparse.ArgumentParser(
        description="Incremental import of DBW bulk ZIPs into MinIO (Playwright rendering)."
    )
    ap.add_argument("--id-start", type=int, default=1, help="First category id (inclusive)")
    ap.add_argument("--id-end", type=int, default=2000, help="Last category id (inclusive)")
    ap.add_argument("--sleep", type=float, default=0.5, help="Delay between pages (seconds)")
    ap.add_argument("--dry-run", action="store_true", help="Only list discovered URLs; do not upload")
    ap.add_argument("--debug", action="store_true", help="Debug prints while scraping")
    return ap.parse_args()


def main():
    args = parse_args()
    run_statgov(
        id_start=args.id_start,
        id_end=args.id_end,
        sleep=args.sleep,
        debug=args.debug,
        dry_run=args.dry_run,
    )


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nInterrupted.", flush=True)
        sys.exit(1)
