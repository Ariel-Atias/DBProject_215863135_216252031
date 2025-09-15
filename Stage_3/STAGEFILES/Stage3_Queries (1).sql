-- ===============================================
-- Stage 3: Additional Queries (Stage3_Queries.sql)
-- Payment Clearing System Database
-- 3 additional queries with 2-3 table joins
-- ===============================================

-- Enable timing for all queries
\timing

-- ===============================================
-- ADDITIONAL QUERY 1: Customer Payment Preferences Analysis
-- ===============================================
-- Business need: Analyze customer payment method preferences across different merchants
-- This query uses 4-table join to understand payment behavior patterns

SELECT 
    c.Name AS customer_name,
    c.Email,
    pm.Type AS preferred_payment_type,
    pm.Description AS payment_description,
    COUNT(t.TransactionID) AS usage_frequency,
    AVG(t.Amount) AS avg_transaction_amount,
    SUM(t.Amount) AS total_spent,
    STRING_AGG(DISTINCT m.MerchantName, ', ' ORDER BY m.MerchantName) AS merchants_used,
    COUNT(DISTINCT m.MerchantID) AS merchant_count,
    MAX(t.TransactionDate) AS last_used_date
FROM Customer c
JOIN Transaction t ON c.CustomerID = t.CustomerID
JOIN PaymentMethod pm ON t.PaymentMethodID = pm.PaymentMethodID
JOIN Merchant m ON t.MerchantID = m.MerchantID
WHERE t.Status = 'completed'
    AND t.TransactionDate >= CURRENT_DATE - INTERVAL '120 days'
GROUP BY c.CustomerID, c.Name, c.Email, pm.PaymentMethodID, pm.Type, pm.Description
HAVING COUNT(t.TransactionID) >= 2
ORDER BY usage_frequency DESC, total_spent DESC
LIMIT 15;

-- ===============================================
-- ADDITIONAL QUERY 2: Merchant-Bank-ClearingHouse Performance Matrix
-- ===============================================
-- Business need: Evaluate the performance of different clearing house networks for merchants
-- This query uses 5-table join to analyze the complete payment processing chain

SELECT 
    m.MerchantName,
    m.Address AS merchant_location,
    a.BankName,
    a.AccountType,
    ch.Name AS clearing_house_name,
    ch.NetworkType,
    COUNT(t.TransactionID) AS total_transactions,
    SUM(CASE WHEN t.Status = 'completed' THEN t.Amount ELSE 0 END) AS successful_volume,
    SUM(CASE WHEN t.Status = 'failed' THEN t.Amount ELSE 0 END) AS failed_volume,
    ROUND(AVG(EXTRACT(DAYS FROM (t.SettlementDate - t.TransactionDate))), 2) AS avg_settlement_days,
    ROUND(
        (COUNT(CASE WHEN t.Status = 'completed' THEN 1 END) * 100.0 / 
         GREATEST(COUNT(t.TransactionID), 1)), 2
    ) AS success_rate_percent,
    COUNT(DISTINCT t.Currency) AS currencies_processed
FROM Merchant m
JOIN Transaction t ON m.MerchantID = t.MerchantID
JOIN PaymentMethod pm ON t.PaymentMethodID = pm.PaymentMethodID
JOIN Account a ON pm.AccountID = a.AccountID
JOIN ClearingHouse ch ON a.ClearingHouseID = ch.ClearingHouseID
WHERE t.TransactionDate >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY m.MerchantID, m.MerchantName, m.Address, a.AccountID, a.BankName, 
         a.AccountType, ch.ClearingHouseID, ch.Name, ch.NetworkType
HAVING COUNT(t.TransactionID) > 1
ORDER BY success_rate_percent DESC, successful_volume DESC;

-- ===============================================
-- ADDITIONAL QUERY 3: Currency Distribution Across Payment Networks (UPDATE Query)
-- ===============================================
-- Business need: Update transaction records to flag international transactions
-- This query uses 3-table join to identify and flag cross-border payments

-- First, add a flag column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'transaction' AND column_name = 'international_flag') THEN
        ALTER TABLE Transaction ADD COLUMN international_flag BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- Update query with 3-table join
UPDATE Transaction 
SET international_flag = TRUE
FROM PaymentMethod pm
JOIN Account a ON pm.AccountID = a.AccountID
JOIN ClearingHouse ch ON a.ClearingHouseID = ch.ClearingHouseID
WHERE Transaction.PaymentMethodID = pm.PaymentMethodID
    AND Transaction.Currency NOT IN ('USD')
    AND ch.NetworkType IN ('SWIFT', 'SEPA')
    AND Transaction.Amount > 1000
    AND Transaction.Status = 'completed';

-- Query to verify the update results
SELECT 
    t.Currency,
    ch.NetworkType,
    COUNT(t.TransactionID) AS total_transactions,
    COUNT(CASE WHEN t.international_flag = TRUE THEN 1 END) AS flagged_international,
    SUM(t.Amount) AS total_volume,
    AVG(t.Amount) AS avg_amount,
    STRING_AGG(DISTINCT m.MerchantName, ', ') AS involved_merchants
FROM Transaction t
JOIN PaymentMethod pm ON t.PaymentMethodID = pm.PaymentMethodID
JOIN Account a ON pm.AccountID = a.AccountID
JOIN ClearingHouse ch ON a.ClearingHouseID = ch.ClearingHouseID
JOIN Merchant m ON t.MerchantID = m.MerchantID
WHERE t.TransactionDate >= CURRENT_DATE - INTERVAL '60 days'
GROUP BY t.Currency, ch.NetworkType
ORDER BY total_volume DESC;

-- ===============================================
-- PERFORMANCE ANALYSIS FOR NEW QUERIES
-- ===============================================

-- Analyze query 1 performance
EXPLAIN ANALYZE 
SELECT 
    c.Name,
    pm.Type,
    COUNT(t.TransactionID) AS frequency
FROM Customer c
JOIN Transaction t ON c.CustomerID = t.CustomerID
JOIN PaymentMethod pm ON t.PaymentMethodID = pm.PaymentMethodID
WHERE t.Status = 'completed'
GROUP BY c.CustomerID, c.Name, pm.Type
LIMIT 10;

-- Analyze query 2 performance
EXPLAIN ANALYZE
SELECT 
    m.MerchantName,
    ch.NetworkType,
    COUNT(t.TransactionID) AS transactions
FROM Merchant m
JOIN Transaction t ON m.MerchantID = t.MerchantID
JOIN PaymentMethod pm ON t.PaymentMethodID = pm.PaymentMethodID
JOIN Account a ON pm.AccountID = a.AccountID
JOIN ClearingHouse ch ON a.ClearingHouseID = ch.ClearingHouseID
GROUP BY m.MerchantID, m.MerchantName, ch.NetworkType
LIMIT 5;
