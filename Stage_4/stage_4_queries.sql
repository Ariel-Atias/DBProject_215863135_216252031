-- -----------------------------------------------
-- STAGE 4 SQL SCRIPT — INTEGRATION & ADVANCED QUERIES
-- -----------------------------------------------

-- 🔗 1. FDW CONNECTION SETUP
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER airline_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'Ticketing_backup', port '5432');

CREATE USER MAPPING FOR postgres
SERVER airline_server
OPTIONS (user 'postgres', password 'your_password');

CREATE SCHEMA airline_fdw;
IMPORT FOREIGN SCHEMA public
FROM SERVER airline_server
INTO airline_fdw;

SELECT foreign_table_schema, foreign_table_name
FROM information_schema.foreign_tables
ORDER BY 1,2;

-- -----------------------------------------------
-- 👥 2. VIEW 1 — v_customer_flight_payments
-- -----------------------------------------------
CREATE OR REPLACE VIEW v_customer_flight_payments AS
SELECT
  c.customerid,
  c.name AS customer_name,
  t.transactionid,
  t.amount,
  t.currency,
  t.status,
  l.ticket_id,
  tp.event_id,
  tp.price AS ticket_price,
  tp.tax AS ticket_tax
FROM transaction t
JOIN customer c ON c.customerid = t.customerid
JOIN flight_payment_link l ON l.transactionid = t.transactionid
JOIN airline_fdw.ticket_pricing tp ON tp.ticket_id = l.ticket_id;

-- Test
SELECT * FROM v_customer_flight_payments ORDER BY amount DESC LIMIT 10;

-- Update simulation (rollback)
BEGIN;
UPDATE airline_fdw.ticket_pricing tp
SET price = price + 5
WHERE tp.ticket_id IN (
  SELECT DISTINCT ticket_id FROM v_customer_flight_payments WHERE amount >= 10000
);
SELECT COUNT(*) AS rows_affected FROM airline_fdw.ticket_pricing tp WHERE tp.ticket_id IN (
  SELECT DISTINCT ticket_id FROM v_customer_flight_payments WHERE amount >= 10000
);
ROLLBACK;

-- -----------------------------------------------
-- 🧾 3. VIEW 2 — v_event_sales
-- -----------------------------------------------
CREATE OR REPLACE VIEW v_event_sales AS
SELECT
  tp.event_id,
  COUNT(DISTINCT l.transactionid) AS txn_count,
  COUNT(DISTINCT tp.customer_id) AS unique_customers,
  SUM(t.amount) AS total_payment_amount,
  AVG(tp.price)::numeric(12,2) AS avg_ticket_price,
  AVG(tp.tax)::numeric(12,2) AS avg_tax
FROM airline_fdw.ticket_pricing tp
JOIN flight_payment_link l ON l.ticket_id = tp.ticket_id
JOIN transaction t ON t.transactionid = l.transactionid
GROUP BY tp.event_id;

-- Test
SELECT * FROM v_event_sales ORDER BY total_payment_amount DESC, txn_count DESC LIMIT 10;

-- Discount simulation (rollback)
BEGIN;
UPDATE airline_fdw.ticket_pricing tp
SET price = ROUND(price * 0.95, 2)
WHERE tp.event_id IN (
  SELECT event_id FROM v_event_sales WHERE txn_count < 50
);
SELECT COUNT(*) AS rows_affected
FROM airline_fdw.ticket_pricing tp
WHERE tp.event_id IN (
  SELECT event_id FROM v_event_sales WHERE txn_count < 50
);
ROLLBACK;

-- Invalid operation test
INSERT INTO v_event_sales (event_id, txn_count) VALUES (9999, 1);

-- -----------------------------------------------
-- 📊 4. EXTENDED QUERIES & TIMING TESTS
-- -----------------------------------------------

-- A1 — High-Value Settled/Cleared Payments
EXPLAIN ANALYZE
SELECT customerid, customer_name, transactionid, amount, currency, status,
  ticket_id, event_id, ticket_price, ticket_tax
FROM v_customer_flight_payments
WHERE status IN ('Settled','Cleared') AND amount >= 10000
ORDER BY amount DESC LIMIT 25;

-- A2 — Normalize Failed → Cancelled
EXPLAIN ANALYZE
UPDATE transaction t
SET status = 'Cancelled'
WHERE t.transactionid IN (
  SELECT transactionid FROM v_customer_flight_payments WHERE status = 'Failed'
);

-- B1 — Underperforming but Expensive Events
EXPLAIN ANALYZE
SELECT event_id, txn_count, unique_customers, total_payment_amount,
  avg_ticket_price, avg_tax
FROM v_event_sales
WHERE txn_count < 50 AND avg_ticket_price > 150
ORDER BY avg_ticket_price DESC, txn_count ASC LIMIT 20;

-- B2 — Apply 10% Discount on FDW
EXPLAIN ANALYZE
UPDATE airline_fdw.ticket_pricing tp
SET price = ROUND(price * 0.90, 2)
WHERE tp.event_id IN (
  SELECT event_id FROM v_event_sales
  WHERE txn_count < 50 AND avg_ticket_price > 150
);

-- -----------------------------------------------
-- ✅ END OF STAGE 4 SCRIPT
-- -----------------------------------------------