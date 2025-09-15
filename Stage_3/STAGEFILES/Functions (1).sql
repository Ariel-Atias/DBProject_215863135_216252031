-- ===============================================
-- Stage 3: Database Functions (Functions.sql)
-- Payment Clearing System Database
-- 4 functions to optimize and simplify complex queries
-- ===============================================

-- Enable timing for all operations
\timing

-- ===============================================
-- FUNCTION 1: Calculate Customer Tier
-- ===============================================
-- Purpose: Replaces complex CASE statements for customer classification
-- Used in: CustomerServiceView and various customer analysis queries

CREATE OR REPLACE FUNCTION calculate_customer_tier(
    customer_id INT,
    days_lookback INT DEFAULT 365
) RETURNS TEXT AS $$
DECLARE
    total_spent NUMERIC;
    transaction_count INT;
    tier TEXT;
BEGIN
    -- Calculate total spending and transaction count for the customer
    SELECT 
        COALESCE(SUM(CASE WHEN Status = 'completed' THEN Amount ELSE 0 END), 0),
        COUNT(CASE WHEN Status = 'completed' THEN 1 END)
    INTO total_spent, transaction_count
    FROM Transaction
    WHERE CustomerID = customer_id
    AND TransactionDate >= CURRENT_DATE - INTERVAL days_lookback || ' days';

    -- Determine tier based on spending and activity
    IF total_spent >= 15000 AND transaction_count >= 10 THEN
        tier := 'Platinum';
    ELSIF total_spent >= 10000 AND transaction_count >= 5 THEN
        tier := 'Premium';
    ELSIF total_spent >= 3000 AND transaction_count >= 3 THEN
        tier := 'Gold';
    ELSIF total_spent >= 1000 AND transaction_count >= 1 THEN
        tier := 'Silver';
    ELSE
        tier := 'Standard';
    END IF;

    RETURN tier;
END;
$$ LANGUAGE plpgsql;

-- Test Function 1
SELECT 
    c.Name,
    calculate_customer_tier(c.CustomerID) as customer_tier,
    calculate_customer_tier(c.CustomerID, 90) as tier_90_days
FROM Customer c
ORDER BY c.Name
LIMIT 10;

-- ===============================================
-- FUNCTION 2: Calculate Merchant Success Rate
-- ===============================================
-- Purpose: Standardizes success rate calculation across merchant queries
-- Used in: MerchantManagementView and merchant performance analysis

CREATE OR REPLACE FUNCTION calculate_merchant_success_rate(
    merchant_id INT,
    days_lookback INT DEFAULT 90
) RETURNS NUMERIC AS $$
DECLARE
    total_transactions INT;
    completed_transactions INT;
    success_rate NUMERIC;
BEGIN
    -- Count total and completed transactions
    SELECT 
        COUNT(*),
        COUNT(CASE WHEN Status = 'completed' THEN 1 END)
    INTO total_transactions, completed_transactions
    FROM Transaction
    WHERE MerchantID = merchant_id
    AND TransactionDate >= CURRENT_DATE - INTERVAL days_lookback || ' days';

    -- Calculate success rate
    IF total_transactions > 0 THEN
        success_rate := ROUND((completed_transactions * 100.0) / total_transactions, 2);
    ELSE
        success_rate := 0;
    END IF;

    RETURN success_rate;
END;
$$ LANGUAGE plpgsql;

-- Test Function 2
SELECT 
    m.MerchantName,
    calculate_merchant_success_rate(m.MerchantID) as success_rate_90_days,
    calculate_merchant_success_rate(m.MerchantID, 30) as success_rate_30_days
FROM Merchant m
ORDER BY calculate_merchant_success_rate(m.MerchantID) DESC
LIMIT 8;

-- ===============================================
-- FUNCTION 3: Calculate Average Settlement Days
-- ===============================================
-- Purpose: Standardizes settlement time calculations with null handling
-- Used in: FinancialAnalyticsView and operations reports

CREATE OR REPLACE FUNCTION calculate_avg_settlement_days(
    filter_type TEXT DEFAULT 'all',
    filter_value TEXT DEFAULT NULL,
    days_lookback INT DEFAULT 180
) RETURNS NUMERIC AS $$
DECLARE
    avg_days NUMERIC;
    query_text TEXT;
BEGIN
    -- Build dynamic query based on filter type
    query_text := '
        SELECT ROUND(AVG(EXTRACT(DAYS FROM (SettlementDate - TransactionDate))), 2)
        FROM Transaction t
        WHERE t.Status = ''completed''
        AND t.TransactionDate >= CURRENT_DATE - INTERVAL ''' || days_lookback || ' days''
        AND t.SettlementDate IS NOT NULL';

    -- Add specific filters
    IF filter_type = 'currency' AND filter_value IS NOT NULL THEN
        query_text := query_text || ' AND t.Currency = ''' || filter_value || '''';
    ELSIF filter_type = 'merchant' AND filter_value IS NOT NULL THEN
        query_text := query_text || ' AND t.MerchantID = ' || filter_value;
    ELSIF filter_type = 'customer' AND filter_value IS NOT NULL THEN
        query_text := query_text || ' AND t.CustomerID = ' || filter_value;
    END IF;

    -- Execute dynamic query
    EXECUTE query_text INTO avg_days;

    RETURN COALESCE(avg_days, 0);
END;
$$ LANGUAGE plpgsql;

-- Test Function 3
SELECT 
    'All Transactions' as category,
    calculate_avg_settlement_days() as avg_settlement_days
UNION ALL
SELECT 
    'USD Transactions' as category,
    calculate_avg_settlement_days('currency', 'USD') as avg_settlement_days
UNION ALL
SELECT 
    'EUR Transactions' as category,
    calculate_avg_settlement_days('currency', 'EUR') as avg_settlement_days;

-- ===============================================
-- FUNCTION 4: Bulk Transaction Status Update
-- ===============================================
-- Purpose: Handles complex transaction status updates with business logic
-- Used in: Operations workflows and batch processing

CREATE OR REPLACE FUNCTION update_transaction_status(
    days_pending INT DEFAULT 1,
    max_amount INT DEFAULT 10000,
    target_status TEXT DEFAULT 'completed'
) RETURNS TABLE(
    updated_count INT,
    total_amount NUMERIC,
    affected_customers INT,
    affected_merchants INT
) AS $$
DECLARE
    result_count INT;
    result_amount NUMERIC;
    result_customers INT;
    result_merchants INT;
BEGIN
    -- Update pending transactions based on criteria
    WITH updated_transactions AS (
        UPDATE Transaction
        SET Status = target_status,
            SettlementDate = CASE 
                WHEN target_status = 'completed' THEN TransactionDate + INTERVAL '1 day'
                ELSE SettlementDate 
            END
        WHERE Status = 'pending'
        AND TransactionDate <= CURRENT_DATE - INTERVAL days_pending || ' days'
        AND Amount <= max_amount
        RETURNING TransactionID, Amount, CustomerID, MerchantID
    ),
    summary AS (
        SELECT 
            COUNT(*) as update_count,
            SUM(Amount) as total_amt,
            COUNT(DISTINCT CustomerID) as unique_customers,
            COUNT(DISTINCT MerchantID) as unique_merchants
        FROM updated_transactions
    )
    SELECT 
        update_count,
        COALESCE(total_amt, 0),
        unique_customers,
        unique_merchants
    INTO result_count, result_amount, result_customers, result_merchants
    FROM summary;

    -- Return results
    updated_count := COALESCE(result_count, 0);
    total_amount := COALESCE(result_amount, 0);
    affected_customers := COALESCE(result_customers, 0);
    affected_merchants := COALESCE(result_merchants, 0);

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Test Function 4 (first check what would be updated)
SELECT 
    COUNT(*) as pending_transactions,
    SUM(Amount) as pending_amount
FROM Transaction 
WHERE Status = 'pending'
AND TransactionDate <= CURRENT_DATE - INTERVAL '1 days'
AND Amount <= 10000;

-- Execute the update function
SELECT * FROM update_transaction_status(1, 5000, 'completed');

-- ===============================================
-- FUNCTION USAGE IN OPTIMIZED QUERIES
-- ===============================================

-- Query 1: Customer Analysis Using calculate_customer_tier Function
-- BEFORE: Complex CASE statement in every query
-- AFTER: Simple function call

SELECT 
    c.CustomerID,
    c.Name,
    c.Email,
    calculate_customer_tier(c.CustomerID, 90) as current_tier,
    calculate_customer_tier(c.CustomerID, 365) as annual_tier
FROM Customer c
WHERE calculate_customer_tier(c.CustomerID, 90) IN ('Premium', 'Platinum', 'Gold')
ORDER BY c.Name;

-- Query 2: Merchant Performance Using calculate_merchant_success_rate Function
-- BEFORE: Repeated complex aggregation calculations
-- AFTER: Simple function call

SELECT 
    m.MerchantID,
    m.MerchantName,
    m.Address,
    calculate_merchant_success_rate(m.MerchantID, 30) as monthly_success_rate,
    calculate_merchant_success_rate(m.MerchantID, 90) as quarterly_success_rate
FROM Merchant m
WHERE calculate_merchant_success_rate(m.MerchantID, 30) >= 80.0
ORDER BY calculate_merchant_success_rate(m.MerchantID, 30) DESC;

-- Query 3: Settlement Analysis Using calculate_avg_settlement_days Function
-- BEFORE: Complex date arithmetic repeated in multiple places  
-- AFTER: Standardized function call

SELECT 
    'System Overview' as analysis_type,
    calculate_avg_settlement_days() as overall_avg,
    calculate_avg_settlement_days('currency', 'USD') as usd_avg,
    calculate_avg_settlement_days('currency', 'EUR') as eur_avg;

-- Query 4: Operations Dashboard Enhanced with Functions
SELECT 
    m.MerchantName,
    calculate_merchant_success_rate(m.MerchantID, 7) as weekly_success_rate,
    calculate_avg_settlement_days('merchant', m.MerchantID::TEXT, 30) as avg_settlement,
    (SELECT COUNT(*) FROM Transaction t 
     WHERE t.MerchantID = m.MerchantID 
     AND t.Status = 'pending') as pending_transactions
FROM Merchant m
ORDER BY calculate_merchant_success_rate(m.MerchantID, 7) DESC;

-- ===============================================
-- PERFORMANCE TESTING FOR FUNCTIONS
-- ===============================================

-- Test function performance vs inline calculations
EXPLAIN ANALYZE
SELECT 
    CustomerID,
    calculate_customer_tier(CustomerID) as tier_function
FROM Customer
LIMIT 20;

-- Compare with inline calculation
EXPLAIN ANALYZE  
SELECT 
    c.CustomerID,
    CASE 
        WHEN COALESCE(SUM(CASE WHEN t.Status = 'completed' THEN t.Amount ELSE 0 END), 0) >= 10000 THEN 'Premium'
        WHEN COALESCE(SUM(CASE WHEN t.Status = 'completed' THEN t.Amount ELSE 0 END), 0) >= 3000 THEN 'Gold'
        ELSE 'Standard'
    END as tier_inline
FROM Customer c
LEFT JOIN Transaction t ON c.CustomerID = t.CustomerID 
    AND t.TransactionDate >= CURRENT_DATE - INTERVAL '365 days'
GROUP BY c.CustomerID
LIMIT 20;

-- ===============================================
-- FUNCTION INFORMATION QUERIES
-- ===============================================

-- List all custom functions
SELECT 
    routinename,
    routinetype,
    returntype,
    routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routinename LIKE 'calculate_%' OR routinename LIKE 'update_%'
ORDER BY routinename;

-- Function usage statistics (if available)
SELECT 
    schemaname,
    funcname,
    calls,
    total_time,
    self_time
FROM pg_stat_user_functions
WHERE schemaname = 'public'
ORDER BY calls DESC;
