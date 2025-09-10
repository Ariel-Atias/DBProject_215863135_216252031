-- Queries.sql
-- Select:
-- 1. All transactions above 500, including customer and merchant details
SELECT c.Name, m.MerchantName, t.Amount, t.Currency, t.TransactionDate
FROM Transaction t
JOIN Customer c ON t.CustomerID = c.CustomerID
JOIN Merchant m ON t.MerchantID = m.MerchantID
WHERE t.Amount > 500
ORDER BY t.TransactionDate DESC;

-- 2. Average transaction amounts per currency
SELECT t.Currency, AVG(t.Amount) AS avgAmount, COUNT(*) AS transactionCount
FROM Transaction t
GROUP BY t.Currency
ORDER BY avgAmount DESC;

-- 3. Customers with transactions above 1000 in the last year
SELECT c.Name, c.Email, SUM(t.Amount) AS totalAmount
FROM Customer c
JOIN Transaction t ON c.CustomerID = t.CustomerID
WHERE t.TransactionDate >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY c.CustomerID
HAVING SUM(t.Amount) > 1000;

-- 4. Bank accounts with more than two payment methods
SELECT a.BankName, a.AccountNumber, COUNT(pm.PaymentMethodID) AS paymentMethodCount
FROM Account a
JOIN PaymentMethod pm ON a.AccountID = pm.AccountID
GROUP BY a.AccountID
HAVING COUNT(pm.PaymentMethodID) > 2;

-- 5. Transaction count per currency
SELECT Currency, COUNT(*) AS cnt
FROM Transaction
GROUP BY Currency
ORDER BY cnt DESC;

-- Delete:
-- 1. Delete cancelled transactions
DELETE FROM Transaction
WHERE Status = 'Cancelled';

-- 2. Delete failed transactions
DELETE FROM Transaction
WHERE Status = 'Failed';

-- Update:
-- 1. Update transactions from 'Pending' to 'Completed'
UPDATE Transaction
SET Status = 'Completed'
WHERE Status = 'Pending';

-- 2. Update transaction currency from EUR to ILS
UPDATE Transaction
SET Currency = 'ILS'
WHERE Currency = 'EUR';
