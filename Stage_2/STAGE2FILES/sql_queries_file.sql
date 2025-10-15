-- =====================================
-- SELECT QUERIES
-- =====================================

-- 1. Show each merchant with total number of transactions and total revenue
SELECT 
    m.MerchantName,
    COUNT(t.TransactionID) AS TotalTransactions,
    SUM(t.Amount) AS TotalRevenue
FROM Merchant m
LEFT JOIN Transaction t ON m.MerchantID = t.MerchantID
GROUP BY m.MerchantID, m.MerchantName
ORDER BY TotalRevenue DESC;

-- 2. Show all pending transactions with customer and merchant details
SELECT 
    t.TransactionID,
    c.Name AS CustomerName,
    m.MerchantName,
    t.Amount,
    t.Currency,
    t.TransactionDate
FROM Transaction t
JOIN Customer c ON t.CustomerID = c.CustomerID
JOIN Merchant m ON t.MerchantID = m.MerchantID
WHERE t.Status = 'Pending'
ORDER BY t.TransactionDate DESC;

-- 3. Show accounts with their clearing houses
SELECT 
    ch.Name AS ClearingHouse,
    a.BankName,
    a.AccountNumber,
    a.AccountType
FROM Account a
JOIN ClearingHouse ch ON a.ClearingHouseID = ch.ClearingHouseID
ORDER BY ch.Name, a.BankName;

-- 4. Show payment methods with transaction statistics
SELECT 
    pm.Type AS PaymentMethodType,
    COUNT(t.TransactionID) AS TransactionCount,
    AVG(t.Amount) AS AvgAmount,
    MIN(t.Amount) AS MinAmount,
    MAX(t.Amount) AS MaxAmount
FROM PaymentMethod pm
LEFT JOIN Transaction t ON pm.PaymentMethodID = t.PaymentMethodID
WHERE t.Amount IS NOT NULL
GROUP BY pm.PaymentMethodID, pm.Type
ORDER BY AvgAmount DESC;

-- =====================================
-- BEGIN AND ROLLBACK
-- =====================================

BEGIN;
ROLLBACK;

-- =====================================
-- UPDATE QUERIES
-- =====================================

-- Before Update 1: View transactions ordered by settlement date
SELECT TransactionID, Status, SettlementDate
FROM Transaction
ORDER BY SettlementDate DESC;

-- Update 1: Mark all pending transactions as completed when settlement date has passed
UPDATE Transaction
SET Status = 'Completed'
WHERE SettlementDate < CURRENT_DATE 
AND Status = 'Pending';

-- After Update 1: Verify updated transaction statuses
SELECT TransactionID, Status, SettlementDate
FROM Transaction
ORDER BY SettlementDate DESC;

-- Before Update 2: View all customers
SELECT CustomerID, Name, Email, MinimalDetails, DateCreated
FROM Customer
ORDER BY DateCreated;

-- Update 2: Mark customers created over a year ago as loyal
UPDATE Customer
SET MinimalDetails = 'Loyal Customer'
WHERE DateCreated < CURRENT_DATE - INTERVAL '1 year';

-- After Update 2: Verify updated customer details
SELECT CustomerID, Name, Email, MinimalDetails, DateCreated
FROM Customer
ORDER BY DateCreated;

-- =====================================
-- DELETE QUERIES
-- =====================================

-- Before Delete 1: View failed transactions
SELECT TransactionID, Status, TransactionDate
FROM Transaction
WHERE Status = 'Failed'
ORDER BY TransactionDate;

-- Delete 1: Remove all failed transactions
DELETE FROM Transaction
WHERE Status = 'Failed';

-- After Delete 1: Verify removal of failed transactions
SELECT TransactionID, Status, TransactionDate
FROM Transaction
WHERE Status = 'Failed'
ORDER BY TransactionDate;

-- Before Delete 2: View unused payment methods
SELECT PaymentMethodID, Type, Description, AccountID
FROM PaymentMethod
WHERE PaymentMethodID NOT IN (
    SELECT DISTINCT PaymentMethodID
    FROM Transaction
    WHERE PaymentMethodID IS NOT NULL
)
ORDER BY PaymentMethodID;

-- Delete 2: Remove unused payment methods
DELETE FROM PaymentMethod
WHERE PaymentMethodID NOT IN (
    SELECT DISTINCT PaymentMethodID
    FROM Transaction
    WHERE PaymentMethodID IS NOT NULL
);

-- After Delete 2: Verify removal of unused payment methods
SELECT PaymentMethodID, Type, Description, AccountID
FROM PaymentMethod
WHERE PaymentMethodID NOT IN (
    SELECT DISTINCT PaymentMethodID
    FROM Transaction
    WHERE PaymentMethodID IS NOT NULL
)
ORDER BY PaymentMethodID;