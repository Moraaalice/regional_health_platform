-- Placeholder schema for Phase 2 (Aiven MySQL + Secrets Manager + migrations +
-- health endpoints). This is NOT the Assignment-1 schema — there is no A1 repo
-- to migrate from yet (see README). Reconcile with the real schema once it
-- exists; until then this is enough to prove the pipe end-to-end: seed rows,
-- row-count evidence, and a query for /readyz to run against.

CREATE TABLE IF NOT EXISTS patients (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  national_id VARCHAR(20)  NOT NULL UNIQUE,
  full_name   VARCHAR(120) NOT NULL,
  date_of_birth DATE       NOT NULL,
  phone       VARCHAR(20)  NOT NULL,
  region      VARCHAR(60)  NOT NULL,
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
