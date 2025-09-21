// cube/conf/cube.js
/** Minimal Cube Core config.
 * Most connection settings (TRINO host/port/catalog/schema, API secret)
 * are taken from environment variables you already set in docker-compose.
 */
module.exports = {
  // Use the same secret you set via CUBEJS_API_SECRET env var
  apiSecret: process.env.CUBEJS_API_SECRET,

  // Disable anonymous telemetry (optional)
  telemetry: false,

  // Keep the dev Playground enabled only when you set CUBEJS_DEV_MODE=true
  // (no extra setting needed here)
};
