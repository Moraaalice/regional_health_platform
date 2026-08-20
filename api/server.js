'use strict';

require('dotenv').config();

const express = require('express');
const { initPool, checkReady } = require('./database');
const { getSecretSource } = require('./secrets');

const app = express();
const PORT = Number(process.env.PORT || 3000);

// Process is alive — no DB dependency. nginx does not gate on this.
app.get('/healthz', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

// nginx's upstream health check. 503 when the DB is unreachable, the pool is
// saturated, or the secret never resolved — see database.js:checkReady().
app.get('/readyz', async (_req, res) => {
  const { ready, reason } = await checkReady();
  res.status(ready ? 200 : 503).json({ ready, reason });
});

// Proves creds came from Secrets Manager without ever exposing the secret
// itself — checked by `make verify` (C8).
app.get('/debug/secret-source', (_req, res) => {
  res.status(200).json(getSecretSource());
});

async function start() {
  try {
    await initPool();
  } catch (err) {
    // Don't crash the process — /readyz reports 503 until this is fixed,
    // which is exactly the flip C4's evidence needs to show.
    console.error(`[boot] DB pool init failed: ${err.message}`);
  }

  app.listen(PORT, () => {
    console.log(`[boot] listening on :${PORT}`);
  });
}

start();

module.exports = app;
