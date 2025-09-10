-- ParamsQueries.sql - Parametrized Queries

-- Query 1: Show all transactions for a specific customer by name
-- Business Question: "Show me all transactions for customer 'John Doe'"
-- Parameter: Customer Name
SELECT t.TransactionID, t.Amount, t.Currency, t.TransactionDate, t.Status,
       m.MerchantName, pm.Type AS PaymentType
FROM Transaction t
JOIN Customer c ON t.CustomerID = c.CustomerID
JOIN Merchant m ON t.MerchantID = m.MerchantID
JOIN PaymentMethod pm ON t.PaymentMethodID = pm.PaymentMethodID
WHERE c.Name = ? -- Parameter: Customer Name (e.g., 'John Doe')
ORDER BY t.TransactionDate DESC;

-- Query 2: Show transactions within a date range and minimum amount
-- Business Question: "Show me all transactions between two dates with amount above threshold"
-- Parameters: Start Date, End Date, Minimum Amount
SELECT c.Name AS CustomerName, m.MerchantName, t.Amount, t.Currency, 
       t.TransactionDate, t.Status
FROM Transaction t
JOIN Customer c ON t.CustomerID = c.CustomerID
JOIN Merchant m ON t.MerchantID = m.MerchantID
WHERE t.TransactionDate BETWEEN ? AND ? -- Parameters: Start Date, End Date
  AND t.Amount >= ? -- Parameter: Minimum Amount
ORDER BY t.Amount DESC;

-- Query 3: Merchant transaction summary for specific currency
-- Business Question: "Give me transaction summary for merchant 'Amazon' in USD currency"
-- Parameters: Merchant Name, Currency
SELECT m.MerchantName, m.Address,
       COUNT(t.TransactionID) AS TotalTransactions,
       SUM(t.Amount) AS TotalAmount,
       AVG(t.Amount) AS AverageAmount,
       MAX(t.Amount) AS HighestTransaction,
       MIN(t.Amount) AS LowestTransaction
FROM Merchant m
JOIN Transaction t ON m.MerchantID = t.MerchantID
WHERE m.MerchantName = ? -- Parameter: Merchant Name (e.g., 'Amazon')
  AND t.Currency = ? -- Parameter: Currency (e.g., 'USD')
GROUP BY m.MerchantID, m.MerchantName, m.Address;

-- Query 4: Payment methods usage by bank and account type
-- Business Question: "Show payment method usage for specific bank and account type"
-- Parameters: Bank Name, Account Type
SELECT a.BankName, a.AccountType, pm.Type AS PaymentMethodType,
       COUNT(t.TransactionID) AS TransactionCount,
       SUM(t.Amount) AS TotalVolume,
       ch.Name AS ClearingHouse
FROM Account a
JOIN PaymentMethod pm ON a.AccountID = pm.AccountID
JOIN Transaction t ON pm.PaymentMethodID = t.PaymentMethodID
JOIN ClearingHouse ch ON a.ClearingHouseID = ch.ClearingHouseID
WHERE a.BankName = ? -- Parameter: Bank Name (e.g., 'Bank Hapoalim')
  AND a.AccountType = ? -- Parameter: Account Type (e.g., 'Checking')
GROUP BY a.BankName, a.AccountType, pm.Type, ch.Name
ORDER BY TransactionCount DESC;

-- Example parameter values for testing:
-- Query 1: Customer Name = 'John Smith', 'Sarah Johnson', 'Mike Brown'
-- Query 2: Start Date = '2024-01-01', End Date = '2024-12-31', Min Amount = 100
-- Query 3: Merchant Name = 'Amazon', 'Walmart', 'Target'; Currency = 'USD', 'EUR', 'ILS'
-- Query 4: Bank Name = 'Bank Hapoalim', 'Bank Leumi'; Account Type = 'Checking', 'Savings'
