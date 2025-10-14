-- ===============================================
-- Stage 3 - Views
-- These views are analytics-friendly and safe for read access.
-- If your table is actually named "Transaction" (quoted),
-- replace payment_transaction with "Transaction" here as well.
-- ===============================================

-- A) Recent transactions (last 30 days relative to dataset max date)
CREATE OR REPLACE VIEW v_recent_txn_30d AS
SELECT
  t.transactionid,
  t.transactiondate,
  t.settlementdate,
  t.amount,
  t.currency,
  t.status,
  c.customerid,
  c.name AS customer_name,
  m.merchantid,
  m.merchantname
FROM payment_transaction t
JOIN customer  c ON c.customerid  = t.customerid
JOIN merchant  m ON m.merchantid  = t.merchantid
WHERE t.transactiondate >= (
  SELECT MAX(transactiondate) FROM payment_transaction
) - INTERVAL '30 days';

-- B) Merchant totals (include merchants with zero activity)
CREATE OR REPLACE VIEW v_merchant_summary AS
SELECT
  m.merchantid,
  m.merchantname,
  COUNT(t.transactionid)      AS txn_count,
  COALESCE(SUM(t.amount), 0)  AS total_amount
FROM merchant m
LEFT JOIN payment_transaction t ON t.merchantid = m.merchantid
GROUP BY m.merchantid, m.merchantname;

-- C) Payment method usage / performance
CREATE OR REPLACE VIEW v_paymentmethod_usage AS
SELECT
  pm.paymentmethodid,
  pm.type AS payment_type,
  COUNT(t.transactionid)      AS txn_count,
  COALESCE(SUM(t.amount), 0)  AS total_amount
FROM paymentmethod pm
LEFT JOIN payment_transaction t ON t.paymentmethodid = pm.paymentmethodid
GROUP BY pm.paymentmethodid, pm.type;

-- D) Transaction status control with CHECK OPTION (allowed statuses only)
-- Adjust the allowed list to match your enum/domain.
CREATE OR REPLACE VIEW v_txn_status AS
SELECT transactionid, status
FROM payment_transaction
WHERE status IN ('Pending','Authorized','Cleared','Completed','Failed','Cancelled','Refunded')
WITH CHECK OPTION;

-- E) Clearing-house summary (used by visualizations)
CREATE OR REPLACE VIEW v_clearing_summary AS
SELECT
  ch.name AS clearinghouse_name,
  COUNT(t.transactionid)      AS txn_count,
  COALESCE(SUM(t.amount), 0)  AS total_amount
FROM clearinghouse ch
LEFT JOIN account a           ON a.clearinghouseid = ch.clearinghouseid
LEFT JOIN paymentmethod pm    ON pm.accountid      = a.accountid
LEFT JOIN payment_transaction t ON t.paymentmethodid = pm.paymentmethodid
GROUP BY ch.name;

-- (Optional) Example usages (commented):
-- SELECT * FROM v_recent_txn_30d ORDER BY transactiondate DESC LIMIT 20;
-- SELECT merchantid, merchantname, txn_count, total_amount FROM v_merchant_summary ORDER BY total_amount DESC LIMIT 10;
-- SELECT paymentmethodid, payment_type, txn_count, total_amount FROM v_paymentmethod_usage ORDER BY txn_count DESC;
-- SELECT * FROM v_txn_status ORDER BY transactionid DESC LIMIT 20;
-- SELECT * FROM v_clearing_summary ORDER BY txn_count DESC;
