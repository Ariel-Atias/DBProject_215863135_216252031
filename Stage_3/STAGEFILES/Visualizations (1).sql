-- ===============================================
-- Stage 3 - Visualizations (queries to feed pgAdmin Graph Visualiser)
-- Views are defined in Views.sql (v_merchant_summary, v_clearing_summary).
-- ===============================================

-- A) Top-10 merchants by total amount (Bar Chart)
-- In pgAdmin Graph Visualiser:
--   Type: Bar, X: merchantname, Y: total_amount
SELECT merchantname, total_amount
FROM v_merchant_summary
ORDER BY total_amount DESC
LIMIT 10;

-- B) Transaction share by clearing house (Pie Chart)
-- In pgAdmin Graph Visualiser:
--   Type: Pie, Label: clearinghouse_name, Value: txn_count
SELECT clearinghouse_name, txn_count
FROM v_clearing_summary
ORDER BY txn_count DESC;
