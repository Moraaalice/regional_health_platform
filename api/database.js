'use strict';

const mysql = require('mysql2/promise');
const { loadDbCredentials } = require('./secrets');

let pool = null;
let initError = null;

const READY_CHECK_TIMEOUT_MS = Number(process.env.READY_CHECK_TIMEOUT_MS || 1500);

async function initPool() {
  try {
    const creds = await loadDbCredentials();
    pool = mysql.createPool({
      host: creds.host,
      port: creds.port,
      user: creds.username,
      password: creds.password,
      database: creds.dbname,
      connectionLimit: Number(process.env.DB_POOL_SIZE || 10),
      waitForConnections: true,
      queueLimit: 0,
    });
    initError = null;
  } catch (err) {
    pool = null;
    initError = err;
    throw err;
  }
  return pool;
}

function getPool() {
  if (!pool) throw new Error('DB pool not initialized — call initPool() first');
  return pool;
}

// Used by /readyz. A short SELECT 1 catches all three failure modes C4 cares
// about: no pool (secret never resolved), the DB is unreachable, and a
// saturated pool (every connection busy, no free slot to run the probe) —
// each surfaces as either a rejection or the timeout race below.
async function checkReady() {
  if (initError) {
    return { ready: false, reason: `secret_unresolved: ${initError.message}` };
  }
  if (!pool) {
    return { ready: false, reason: 'pool_not_initialized' };
  }

  const timeout = new Promise((resolve) =>
    setTimeout(() => resolve({ timedOut: true }), READY_CHECK_TIMEOUT_MS)
  );

  try {
    const result = await Promise.race([
      pool.query('SELECT 1').then(() => ({ timedOut: false })),
      timeout,
    ]);

    if (result.timedOut) {
      return { ready: false, reason: 'pool_saturated_or_unreachable' };
    }
    return { ready: true, reason: null };
  } catch (err) {
    return { ready: false, reason: `db_unreachable: ${err.code || err.message}` };
  }
}

module.exports = { initPool, getPool, checkReady };
