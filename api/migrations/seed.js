'use strict';

// Seeds the patients table. Row count is a documented variable (ASSIGNMENT.md
// C2), not hardcoded — set PATIENT_COUNT to override the default 10,000.
//
// Usage: node migrations/seed.js
// Prereq: node migrations/migrate.js (table must exist)

require('dotenv').config();

const mysql = require('mysql2/promise');
const { loadDbCredentials } = require('../secrets');

const PATIENT_COUNT = Number(process.env.PATIENT_COUNT || 10000);
const BATCH_SIZE = Number(process.env.SEED_BATCH_SIZE || 500);

const FIRST_NAMES = ['Amina', 'Brian', 'Cynthia', 'David', 'Esther', 'Felix', 'Grace', 'Hassan', 'Irene', 'James'];
const LAST_NAMES = ['Otieno', 'Mwangi', 'Kamau', 'Achieng', 'Njoroge', 'Wanjiru', 'Kiptoo', 'Wafula', 'Njeri', 'Omondi'];
const REGIONS = ['Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret', 'Machakos', 'Nyeri', 'Kakamega'];

function randomDob() {
  const start = new Date(1940, 0, 1).getTime();
  const end = new Date(2024, 0, 1).getTime();
  return new Date(start + Math.random() * (end - start)).toISOString().slice(0, 10);
}

function randomPhone() {
  return `+2547${String(Math.floor(10000000 + Math.random() * 89999999))}`;
}

function generatePatient(index) {
  const first = FIRST_NAMES[Math.floor(Math.random() * FIRST_NAMES.length)];
  const last = LAST_NAMES[Math.floor(Math.random() * LAST_NAMES.length)];
  return [
    `${(10000000 + index).toString()}`, // national_id, index-derived so it's unique
    `${first} ${last}`,
    randomDob(),
    randomPhone(),
    REGIONS[Math.floor(Math.random() * REGIONS.length)],
  ];
}

async function main() {
  const creds = await loadDbCredentials();
  const conn = await mysql.createConnection({
    host: creds.host,
    port: creds.port,
    user: creds.username,
    password: creds.password,
    database: creds.dbname,
  });

  await conn.query('TRUNCATE TABLE patients');

  for (let start = 0; start < PATIENT_COUNT; start += BATCH_SIZE) {
    const size = Math.min(BATCH_SIZE, PATIENT_COUNT - start);
    const rows = Array.from({ length: size }, (_, i) => generatePatient(start + i));
    await conn.query(
      'INSERT INTO patients (national_id, full_name, date_of_birth, phone, region) VALUES ?',
      [rows]
    );
    console.log(`[seed] inserted ${start + size}/${PATIENT_COUNT}`);
  }

  const [[{ count }]] = await conn.query('SELECT COUNT(*) AS count FROM patients');
  console.log(`[seed] done — ${count} rows in patients`);

  await conn.end();
}

main().catch((err) => {
  console.error('[seed] failed:', err);
  process.exit(1);
});
