-- ===============================================
-- Stage 3: Views Creation and Management (Views.sql)
-- Payment Clearing System Database
-- 4 views for different user groups with manipulations
-- ===============================================

-- Enable timing for all operations
\timing

-- ===============================================
-- VIEW 1: Customer Service Representative View
-- ===============================================
-- Purpose: Provides customer service reps with comprehensive customer information
-- User Group: Customer Service Representatives

CREATE OR REPLACE VIEW CustomerServiceView AS
SELECT 
    c.CustomerID,
    c.Name AS customer_name,
    c.Email AS customer_email,
    c.MinimalDetails,
    c.DateCreated AS account_created,
    COUNT(t.TransactionID) AS total_transactions,
    COALESCE(SUM(CASE WHEN t.Status = 'completed' THEN t.Amount ELSE 0 END), 0) AS total_spent,
    COALESCE(AVG(CASE WHEN t.Status = 'completed' THEN t.Amount END), 0) AS avg_transaction,
    MAX(t.TransactionDate) AS last_transaction_date,
    COUNT(CASE WHEN t.Status = 'failed' THEN 1 END) AS failed_transactions,
    COUNT(DISTINCT t.PaymentMethodID) AS payment_methods_used,
    CASE 
        WHEN SUM(CASE WHEN t.Status = 'completed' THEN t.Amount ELSE 0 END) > 10000 THEN 'Premium'
        WHEN SUM(CASE WHEN t.Status = 'completed' THEN t.Amount ELSE 0 END) > 3000 THEN 'Gold'
        ELSE 'Standard'
    END AS customer_tier
FROM Customer c
LEFT JOIN Transaction t ON c.CustomerID = t.CustomerID
    AND t.TransactionDate >= CURRENT_DATE - INTERVAL '365 days'
GROUP BY c.CustomerID, c.Name, c.Email, c.MinimalDetails, c.DateCreated;

-- Test SELECT for CustomerServiceView
SELECT * FROM CustomerServiceView 
WHERE customer_tier IN ('Premium', 'Gold')
ORDER BY total_spent DESC
LIMIT 10;

-- ===============================================
-- VIEW 2: Merchant Management View
-- ===============================================
-- Purpose: Provides merchant managers with merchant performance data
-- User Group: Merchant Relationship Managers

CREATE OR REPLACE VIEW MerchantManagementView AS
SELECT 
    m.MerchantID,
    m.MerchantName AS merchant_name,
    m.Address AS merchant_address,
    COUNT(t.TransactionID) AS total_transactions,
    COALESCE(SUM(CASE WHEN t.Status = 'completed' THEN t.Amount ELSE 0 END), 0) AS revenue_processed,
    COALESCE(AVG(t.Amount), 0) AS avg_transaction_size,
    COUNT(DISTINCT t.CustomerID) AS unique_customers,
    COUNT(DISTINCT t.PaymentMethodID) AS payment_methods_accepted,
    ROUND(
        COALESCE(
            (COUNT(CASE WHEN t.Status = 'completed' THEN 1 END) * 100.0 / 
             NULLIF(COUNT(t.TransactionID), 0)), 0
        ), 2
    ) AS success_rate,
    MAX(t.TransactionDate) AS last_transaction_date,
    CASE 
        WHEN COUNT(t.TransactionID) > 50 THEN 'High Volume'
        WHEN COUNT(t.TransactionID) > 15 THEN 'Medium Volume' 
        WHEN COUNT(t.TransactionID) > 0 THEN 'Low Volume'
        ELSE 'Inactive'
    END AS activity_level
FROM Merchant m
LEFT JOIN Transaction t ON m.MerchantID = t.MerchantID
    AND t.TransactionDate >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY m.MerchantID, m.MerchantName, m.Address;

-- Test SELECT for MerchantManagementView
SELECT * FROM MerchantManagementView 
WHERE activity_level != 'Inactive'
ORDER BY revenue_processed DESC;

-- ===============================================
-- VIEW 3: Financial Analytics View
-- ===============================================
-- Purpose: Provides financial analysts with transaction and currency data
-- User Group: Financial Analysts

CREATE OR REPLACE VIEW FinancialAnalyticsView AS
SELECT 
    t.Currency,
    t.Status AS transaction_status,
    DATE_TRUNC('month', t.TransactionDate) AS transaction_month,
    ch.NetworkType AS clearing_network,
    COUNT(t.TransactionID) AS transaction_count,
    SUM(t.Amount) AS total_volume,
    AVG(t.Amount) AS avg_amount,
    MIN(t.Amount) AS min_amount,
    MAX(t.Amount) AS max_amount,
    COUNT(DISTINCT t.CustomerID) AS unique_customers,
    COUNT(DISTINCT t.MerchantID) AS unique_merchants,
    ROUND(AVG(EXTRACT(DAYS FROM (t.SettlementDate - t.TransactionDate))), 2) AS avg_settlement_days
FROM Transaction t
JOIN PaymentMethod pm ON t.PaymentMethodID = pm.PaymentMethodID
JOIN Account a ON pm.AccountID = a.AccountID
JOIN ClearingHouse ch ON a.ClearingHouseID = ch.ClearingHouseID
WHERE t.TransactionDate >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY t.Currency, t.Status, DATE_TRUNC('month', t.TransactionDate), ch.NetworkType;

-- Test SELECT for FinancialAnalyticsView
SELECT 
    Currency,
    transaction_month,
    SUM(total_volume) as monthly_volume,
    SUM(transaction_count) as monthly_count
FROM FinancialAnalyticsView 
WHERE transaction_status = 'completed'
GROUP BY Currency, transaction_month
ORDER BY transaction_month DESC, monthly_volume DESC;

-- ===============================================
-- VIEW 4: Operations Dashboard View
-- ===============================================
-- Purpose: Provides operations team with system performance metrics
-- User Group: Operations Team

CREATE OR REPLACE VIEW OperationsDashboardView AS
SELECT 
    ch.ClearingHouseID,
    ch.Name AS clearing_house_name,
    ch.NetworkType,
    a.BankName,
    a.AccountType,
    pm.Type AS payment_type,
    COUNT(t.TransactionID) AS daily_transactions,
    SUM(CASE WHEN t.Status = 'completed' THEN t.Amount ELSE 0 END) AS daily_volume,
    COUNT(CASE WHEN t.Status = 'pending' THEN 1 END) AS pending_count,
    COUNT(CASE WHEN t.Status = 'failed' THEN 1 END) AS failed_count,
    ROUND(
        (COUNT(CASE WHEN t.Status = 'completed' THEN 1 END) * 100.0 / 
         GREATEST(COUNT(t.TransactionID), 1)), 2
    ) AS success_rate,
    t.TransactionDate AS report_date
FROM ClearingHouse ch
JOIN Account a ON ch.ClearingHouseID = a.ClearingHouseID
JOIN PaymentMethod pm ON a.AccountID = pm.AccountID
LEFT JOIN Transaction t ON pm.PaymentMethodID = t.PaymentMethodID
    AND t.TransactionDate >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY ch.ClearingHouseID, ch.Name, ch.NetworkType, 
         a.BankName, a.AccountType, pm.Type, t.TransactionDate;

-- Test SELECT for OperationsDashboardView
SELECT 
    clearing_house_name,
    NetworkType,
    SUM(daily_transactions) as total_transactions,
    AVG(success_rate) as avg_success_rate
FROM OperationsDashboardView 
WHERE report_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY clearing_house_name, NetworkType
ORDER BY total_transactions DESC;

-- ===============================================
-- VIEW MANIPULATIONS - INSERT, UPDATE, DELETE
-- ===============================================

-- ===============================================
-- Manipulation 1: CustomerServiceView - UPDATE customer tier manually
-- ===============================================

-- Note: Direct updates to views with aggregates are not always possible
-- This demonstrates updating the underlying Customer table through the view context

-- Update customer details for premium customers
UPDATE Customer 
SET MinimalDetails = MinimalDetails || ' [PREMIUM_VERIFIED]'
WHERE CustomerID IN (
    SELECT CustomerID FROM CustomerServiceView 
    WHERE customer_tier = 'Premium' 
    AND MinimalDetails NOT LIKE '%PREMIUM_VERIFIED%'
);

-- Verify the update
SELECT customer_name, MinimalDetails, customer_tier, total_spent
FROM CustomerServiceView 
WHERE MinimalDetails LIKE '%PREMIUM_VERIFIED%';

-- ===============================================
-- Manipulation 2: MerchantManagementView - INSERT new merchant
-- ===============================================

-- Insert a new merchant (this affects the base table)
INSERT INTO Merchant (MerchantID, MerchantName, Address) 
VALUES (
    (SELECT COALESCE(MAX(MerchantID), 0) + 1 FROM Merchant),
    'New Digital Store Ltd',
    '999 Innovation Drive, Tech City, TC 12345'
);

-- Verify the insertion appears in the view
SELECT * FROM MerchantManagementView 
WHERE merchant_name = 'New Digital Store Ltd';

-- ===============================================
-- Manipulation 3: FinancialAnalyticsView - Demonstrate constraint
-- ===============================================

-- Attempt to insert invalid transaction (should demonstrate business rules)
BEGIN;
-- This will work as it inserts into base Transaction table
INSERT INTO Transaction (
    TransactionID, Amount, Currency, Status, TransactionDate, 
    SettlementDate, CustomerID, MerchantID, PaymentMethodID
) VALUES (
    (SELECT COALESCE(MAX(TransactionID), 0) + 1 FROM Transaction),
    2500, 'EUR', 'completed', CURRENT_DATE, CURRENT_DATE + 1,
    1, 1, 1
);

-- Verify it appears in financial view
SELECT * FROM FinancialAnalyticsView 
WHERE Currency = 'EUR' 
AND transaction_month = DATE_TRUNC('month', CURRENT_DATE)
ORDER BY total_volume DESC;

COMMIT;

-- ===============================================
-- Manipulation 4: OperationsDashboardView - DELETE old records
-- ===============================================

-- Delete old failed transactions (affects base table)
DELETE FROM Transaction 
WHERE Status = 'failed' 
AND TransactionDate < CURRENT_DATE - INTERVAL '180 days';

-- Verify the deletion effect in operations view
SELECT 
    report_date,
    SUM(failed_count) as total_failed_today
FROM OperationsDashboardView 
WHERE report_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY report_date
ORDER BY report_date DESC;

-- ===============================================
-- VIEW WITH CHECK OPTION DEMONSTRATION
-- ===============================================

-- Create a view with CHECK OPTION for active customers only
CREATE OR REPLACE VIEW ActiveCustomersView AS
SELECT 
    CustomerID,
    Name,
    Email,
    MinimalDetails,
    DateCreated
FROM Customer
WHERE EXISTS (
    SELECT 1 FROM Transaction t 
    WHERE t.CustomerID = Customer.CustomerID 
    AND t.TransactionDate >= CURRENT_DATE - INTERVAL '90 days'
)
WITH CHECK OPTION;

-- Test SELECT on ActiveCustomersView
SELECT COUNT(*) as active_customer_count FROM ActiveCustomersView;

-- Attempt UPDATE that violates CHECK OPTION (demonstration)
BEGIN;
-- This should work as it doesn't violate the view's WHERE condition
UPDATE ActiveCustomersView 
SET MinimalDetails = MinimalDetails || ' [ACTIVE_USER]'
WHERE CustomerID IN (SELECT CustomerID FROM ActiveCustomersView LIMIT 3);
COMMIT;

-- ===============================================
-- VIEW INFORMATION QUERIES
-- ===============================================

-- List all created views
SELECT 
    schemaname,
    viewname,
    viewowner,
    definition
FROM pg_views 
WHERE schemaname = 'public'
AND viewname LIKE '%View'
ORDER BY viewname;

-- Check view dependencies
SELECT 
    v.table_name AS view_name,
    v.view_definition
FROM information_schema.views v
WHERE v.table_schema = 'public'
AND v.table_name LIKE '%View';
