-- ===============================================
-- Stage 3 - Queries (Advanced Analytics)
-- If your table is actually named "Transaction" (quoted),
-- replace payment_transaction with "Transaction" in this file.
-- ===============================================

-- Q1: Recent transactions per customer (last 7 days relative to dataset max date)
SELECT
  c.customerid,
  c.name AS customer_name,
  t.transactionid,
  t.amount,
  t.currency,
  t.status,
  t.transactiondate,
  m.merchantname
FROM customer c
JOIN payment_transaction t ON t.customerid = c.customerid
JOIN merchant m           ON m.merchantid  = t.merchantid
WHERE t.transactiondate >= (
  SELECT MAX(transactiondate) FROM payment_transaction
) - INTERVAL '7 days'
ORDER BY c.customerid, t.transactiondate DESC;

-- Q2: Top-10 merchants by total amount
SELECT
  m.merchantid,
  m.merchantname,
  COUNT(*)      AS txn_count,
  SUM(t.amount) AS total_amount
FROM merchant m
JOIN payment_transaction t
  ON t.merchantid = m.merchantid
GROUP BY m.merchantid, m.merchantname
ORDER BY total_amount DESC
LIMIT 10;

-- Q3: Distribution by clearing house
SELECT
  ch.clearinghouseid,
  ch.name AS clearing_house,
  COUNT(t.transactionid) AS txn_count,
  SUM(t.amount)          AS total_amount
FROM payment_transaction t
JOIN paymentmethod pm ON pm.paymentmethodid = t.paymentmethodid
JOIN account a        ON a.accountid        = pm.accountid
JOIN clearinghouse ch ON ch.clearinghouseid = a.clearinghouseid
GROUP BY ch.clearinghouseid, ch.name
ORDER BY txn_count DESC;
