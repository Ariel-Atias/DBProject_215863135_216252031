/* 

==========================================
Prepared Statement Example – Customer Transactions
==========================================

This SQL file demonstrates how to use a prepared statement
to retrieve all transactions for a specific customer within a date range.

Steps:
1. Create the prepared statement
2. Execute it with parameters (CustomerID, StartDate, EndDate)
3. Review the results
4. Deallocate the statement
*/

-- Step 1: Create the prepared statement
PREPARE customer_transactions(int, date, date) AS
SELECT 
    t.transactionid,           -- Unique ID of each transaction
    t.transactiondate,         -- Date when the transaction occurred
    t.amount,                  -- Amount of money in the transaction
    t.currency,                -- Currency type (e.g., USD, EUR)
    t.status,                  -- Transaction status (Settled, Cleared, Failed, etc.)
    t.settlementdate,          -- Date when the transaction was settled
    m.merchantname             -- Name of the merchant
FROM 
    transaction t
JOIN 
    merchant m ON t.merchantid = m.merchantid
WHERE 
    t.customerid = $1          -- Parameter placeholder for customer ID
AND 
    t.transactiondate BETWEEN $2 AND $3  -- Parameter placeholders for date range
ORDER BY 
    t.transactiondate DESC;    -- Show most recent transactions first

-- Step 2: Execute the prepared statement for specific customers
EXECUTE customer_transactions(301, '2025-01-01', '2025-12-31');
-- Returned all transactions for customer 301 within 2025, including amounts, dates, and merchant names.

EXECUTE customer_transactions(303, '2025-01-01', '2025-12-31');
-- Returned all transactions for customer 303 within 2025. Both 301 and 303 returned valid transactions.

-- Step 3: Deallocate the prepared statement
DEALLOCATE customer_transactions;


/* 

==========================================
Prepared Statement Example – Merchant High Value Transactions
==========================================

This SQL file demonstrates how to use a prepared statement
to retrieve all transactions for a specific merchant
that are above a certain amount.

Steps:
1. Create the prepared statement
2. Execute it with parameters (MerchantID, MinAmount)
3. Review the results
4. Deallocate the statement
*/

-- Step 1: Create the prepared statement
PREPARE merchant_high_value (INT, NUMERIC) AS
SELECT 
    t.TransactionID,           -- Unique ID of each transaction
    c.Name AS CustomerName,    -- Name of the customer
    t.Amount,                  -- Amount of money in the transaction
    t.Currency,                -- Currency type (e.g., USD, EUR)
    t.TransactionDate,         -- Date when the transaction occurred
    t.Status                   -- Transaction status (Settled, Cleared, Failed, etc.)
FROM 
    Transaction t
JOIN 
    Customer c ON t.CustomerID = c.CustomerID
WHERE 
    t.MerchantID = $1          -- Parameter placeholder for merchant ID
AND 
    t.Amount >= $2             -- Parameter placeholder for minimum amount
ORDER BY 
    t.Amount DESC;             -- Show highest amounts first

-- Step 2: Execute the prepared statement for a specific merchant
EXECUTE merchant_high_value(1, 50);  -- Coffee Shop Inc
-- Returned all transactions for merchant 1 above 50 USD.

EXECUTE merchant_high_value(3, 100); -- Retail Store Co
-- Returned all transactions for merchant 3 above 100 USD.

-- Step 3: Deallocate the prepared statement
DEALLOCATE merchant_high_value;


/* 

==========================================
Prepared Statement Example – Customer Transaction Summary
==========================================

This SQL file demonstrates how to use a prepared statement
to retrieve an aggregated summary of all transactions
for a specific customer.

Steps:
1. Create the prepared statement
2. Execute it with parameter (CustomerID)
3. Review the results
4. Deallocate the statement
*/

-- Step 1: Create the prepared statement
PREPARE customer_summary(INT) AS
SELECT 
    c.CustomerID,                              -- Unique ID of the customer
    c.Name AS CustomerName,                     -- Name of the customer
    COUNT(t.TransactionID) AS TotalTransactions, -- Total number of transactions
    COALESCE(SUM(t.Amount), 0) AS TotalAmount, -- Total amount of all transactions
    COUNT(CASE WHEN t.Status = 'Settled' THEN 1 END) AS SettledCount, -- Number of settled transactions
    COUNT(CASE WHEN t.Status = 'Cleared' THEN 1 END) AS ClearedCount, -- Number of cleared transactions
    COUNT(CASE WHEN t.Status = 'Failed' THEN 1 END) AS FailedCount    -- Number of failed transactions
FROM 
    Customer c
LEFT JOIN 
    Transaction t ON c.CustomerID = t.CustomerID
WHERE 
    c.CustomerID = $1                           -- Parameter placeholder for customer ID
GROUP BY 
    c.CustomerID, c.Name;

-- Step 2: Execute the prepared statement for specific customers
EXECUTE customer_summary(301);  -- CustomerID 301
-- Returned a summary for customer 301 with total transactions, amount, and counts by status.

EXECUTE customer_summary(303);  -- CustomerID 303
-- Returned a summary for customer 303. Both 301 and 303 returned valid summaries.

-- Step 3: Deallocate the prepared statement
DEALLOCATE customer_summary;


/* 

==========================================
Prepared Statement Example – Customer Payment Method Summary
==========================================

This SQL file demonstrates how to use a prepared statement
to retrieve an aggregated summary of transactions
for a specific customer by payment method.

Steps:
1. Create the prepared statement
2. Execute it with parameters (CustomerID, PaymentMethod)
3. Review the results
4. Deallocate the statement
*/

-- Step 1: Create the prepared statement
PREPARE customer_payment_method_summary(INT, TEXT) AS
SELECT 
    pm.Type AS PaymentMethod,                    -- Type of payment method (e.g., Debit Card, Wire Transfer)
    pm.Description,                              -- Description of the payment method
    COUNT(t.TransactionID) AS UsageCount,       -- Total number of transactions using this method
    SUM(t.Amount) AS TotalSpent,                -- Total amount spent using this method
    AVG(t.Amount) AS AvgTransactionAmount       -- Average transaction amount
FROM 
    Transaction t
JOIN 
    PaymentMethod pm ON t.PaymentMethodID = pm.PaymentMethodID
WHERE 
    t.CustomerID = $1                            -- Parameter placeholder for customer ID
AND 
    pm.Type = $2                                 -- Parameter placeholder for payment method type
GROUP BY 
    pm.PaymentMethodID, pm.Type, pm.Description;

-- Step 2: Execute the prepared statement for specific customers and payment methods
EXECUTE customer_payment_method_summary(301, 'Wire Transfer');
-- Returned no rows because customer 301 had no transactions with the exact payment method 'Wire Transfer'.

EXECUTE customer_payment_method_summary(303, 'Debit Card');
-- Returned valid rows for customer 303 using Debit Card:
-- UsageCount=438, TotalSpent=1613602, AvgTransactionAmount≈3684.

-- Step 3: Deallocate the prepared statement
DEALLOCATE customer_payment_method_summary;


-- Additional explanation for Customer Payment Method selection
-- Before executing, we ran a SELECT to check which payment methods exist per customer:
SELECT 
    t.CustomerID,
    pm.Type AS PaymentMethod,
    pm.Description,
    COUNT(t.TransactionID) AS UsageCount,
    SUM(t.Amount) AS TotalSpent,
    AVG(t.Amount) AS AvgTransactionAmount
FROM Transaction t
JOIN PaymentMethod pm ON t.PaymentMethodID = pm.PaymentMethodID
WHERE t.CustomerID IN (301, 303)
GROUP BY t.CustomerID, pm.Type, pm.Description
ORDER BY t.CustomerID, UsageCount DESC;
-- From this, we observed:
-- Customer 301 had no valid matching transactions for 'Wire Transfer' (hence no rows returned).
-- Customer 303 had valid transactions with 'Debit Card', which is why the EXECUTE returned results.
-- This SELECT step allowed us to pick the correct values for the prepared statement parameters (CustomerID and PaymentMethod).