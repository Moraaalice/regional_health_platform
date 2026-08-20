'use strict';

// Creates the database (aiven_database was removed from the Terraform
// provider in v4 — see terraform/modules/data/main.tf) and applies every
// *.sql file in this directory, in filename order.
//
// Usage: node migrations/migrate.js
// Reads the same DB_SECRET_ARN / MYSQL_* env vars as the app (via secrets.js)
// so this runs identically in CI and locally.

require('dotenv').config();

const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const { loadDbCredentials } = require('../secrets');

async function main() {
  const creds = await loadDbCredentials();

  // Connect without selecting a database first — it may not exist yet.
  const admin = await mysql.createConnection({
    host: creds.host,
    port: creds.port,
    user: creds.username,
    password: creds.password,
    multipleStatements: true,
  });

  await admin.query(
    `CREATE DATABASE IF NOT EXISTS \`${creds.dbname}\` CHARACTER SET utf8mb4`
  );
  await admin.end();

  const conn = await mysql.createConnection({
    host: creds.host,
    port: creds.port,
    user: creds.username,
    password: creds.password,
    database: creds.dbname,
    multipleStatements: true,
  });

  const files = fs
    .readdirSync(__dirname)
    .filter((f) => f.endsWith('.sql'))
    .sort();

  for (const file of files) {
    const sql = fs.readFileSync(path.join(__dirname, file), 'utf8');
    console.log(`[migrate] applying ${file}`);
    await conn.query(sql);
  }

  await conn.end();
  console.log(`[migrate] done — ${files.length} file(s) applied to ${creds.dbname}`);
}

main().catch((err) => {
  console.error('[migrate] failed:', err);
  process.exit(1);
});
