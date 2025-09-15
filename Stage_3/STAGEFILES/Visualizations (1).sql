-- ===============================================
-- Stage 3: Visualizations (Visualizations.sql)
-- Payment Clearing System Database
-- Queries for visual plots - Pie Chart and Bar Graph
-- ===============================================

-- Enable timing for all operations
\timing

-- ===============================================
-- VISUALIZATION 1: PIE CHART - Transaction Volume by Currency
-- ===============================================
-- Purpose: Show distribution of transaction volume across different currencies
-- Chart Type: Pie Chart
-- Business Value: Understand currency preferences and international exposure

-- Query for Pie Chart Data
SELECT 
    t.Currency AS currency_code,
    COUNT(t.TransactionID) AS transaction_count,
    SUM(t.Amount) AS total_volume,
    ROUND((COUNT(t.TransactionID) * 100.0 / 
           (SELECT COUNT(*) FROM Transaction WHERE Status = 'completed')), 2) AS percentage_by_count,
    ROUND((SUM(t.Amount) * 100.0 / 
           (SELECT SUM(Amount) FROM Transaction WHERE Status = 'completed')), 2) AS percentage_by_volume
FROM Transaction t
WHERE t.Status = 'completed'
    AND t.TransactionDate >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY t.Currency
ORDER BY total_volume DESC;

-- Enhanced Pie Chart Query with Currency Names
SELECT 
    CASE 
        WHEN t.Currency = 'USD' THEN 'US Dollar'
        WHEN t.Currency = 'EUR' THEN 'Euro'
        WHEN t.Currency = 'GBP' THEN 'British Pound'
        WHEN t.Currency = 'CAD' THEN 'Canadian Dollar'
        WHEN t.Currency = 'JPY' THEN 'Japanese Yen'
        ELSE t.Currency
    END AS currency_name,
    t.Currency AS currency_code,
    SUM(t.Amount) AS volume,
    COUNT(t.TransactionID) AS transactions,
    ROUND(AVG(t.Amount), 2) AS avg_transaction_size
FROM Transaction t
WHERE t.Status = 'completed'
    AND t.TransactionDate >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY t.Currency
HAVING SUM(t.Amount) > 0
ORDER BY volume DESC;

-- Additional data for pie chart context
SELECT 
    'Summary Statistics' as metric_type,
    COUNT(DISTINCT Currency) as total_currencies,
    SUM(Amount) as grand_total_volume,
    COUNT(*) as total_transactions,
    ROUND(AVG(Amount), 2) as overall_avg_transaction
FROM Transaction 
WHERE Status = 'completed'
    AND TransactionDate >= CURRENT_DATE - INTERVAL '90 days';

-- ===============================================
-- VISUALIZATION 2: BAR GRAPH - Merchant Performance Comparison
-- ===============================================
-- Purpose: Compare merchant transaction volumes and success rates
-- Chart Type: Bar Graph (Horizontal or Vertical)
-- Business Value: Identify top-performing merchants and growth opportunities

-- Query for Bar Graph Data
SELECT 
    m.MerchantName AS merchant,
    COUNT(t.TransactionID) AS total_transactions,
    SUM(CASE WHEN t.Status = 'completed' THEN t.Amount ELSE 0 END) AS completed_volume,
    SUM(CASE WHEN t.Status = 'failed' THEN t.Amount ELSE 0 END) AS failed_volume,
    ROUND(AVG(CASE WHEN t.Status = 'completed' THEN t.Amount END), 2) AS avg_completed_amount,
    ROUND(
        (COUNT(CASE WHEN t.Status = 'completed' THEN 1 END) * 100.0 / 
         GREATEST(COUNT(t.TransactionID), 1)), 2
    ) AS success_rate,
    COUNT(DISTINCT t.CustomerID) AS unique_customers,
    MAX(t.TransactionDate) AS last_transaction_date
FROM Merchant m
LEFT JOIN Transaction t ON m.MerchantID = t.MerchantID
    AND t.TransactionDate >= CURRENT_DATE - INTERVAL '120 days'
GROUP BY m.MerchantID, m.MerchantName
HAVING COUNT(t.TransactionID) > 0
ORDER BY completed_volume DESC
LIMIT 10;

-- Enhanced Bar Graph Query with Multiple Metrics
SELECT 
    m.MerchantName AS merchant,
    COALESCE(SUM(CASE WHEN t.Status = 'completed' THEN t.Amount END), 0) AS completed_volume,
    COALESCE(COUNT(CASE WHEN t.Status = 'completed' THEN 1 END), 0) AS completed_count,
    COALESCE(COUNT(CASE WHEN t.Status = 'pending' THEN 1 END), 0) AS pending_count,
    COALESCE(COUNT(CASE WHEN t.Status = 'failed' THEN 1 END), 0) AS failed_count,
    ROUND(COALESCE(AVG(CASE WHEN t.Status = 'completed' THEN t.Amount END), 0), 2) AS avg_amount,
    -- Performance score calculation
    ROUND(
        (COALESCE(SUM(CASE WHEN t.Status = 'completed' THEN t.Amount END), 0) / 1000) +
        (COALESCE(COUNT(CASE WHEN t.Status = 'completed' THEN 1 END), 0) * 10) -
        (COALESCE(COUNT(CASE WHEN t.Status = 'failed' THEN 1 END), 0) * 5), 2
    ) AS performance_score
FROM Merchant m
LEFT JOIN Transaction t ON m.MerchantID = t.MerchantID
    AND t.TransactionDate >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY m.MerchantID, m.MerchantName
ORDER BY performance_score DESC;

-- ===============================================
-- ADDITIONAL VISUALIZATION QUERIES
-- ===============================================

-- Time Series Data for Line Chart (Bonus)
-- Daily transaction volume over time
SELECT 
    t.TransactionDate AS transaction_date,
    COUNT(t.TransactionID) AS daily_transactions,
    SUM(CASE WHEN t.Status = 'completed' THEN t.Amount ELSE 0 END) AS daily_volume,
    AVG(CASE WHEN t.Status = 'completed' THEN t.Amount END) AS daily_avg_amount,
    COUNT(DISTINCT t.CustomerID) AS daily_unique_customers
FROM Transaction t
WHERE t.TransactionDate >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY t.TransactionDate
ORDER BY t.TransactionDate;

-- Payment Method Distribution for Stacked Bar Chart
SELECT 
    pm.Type AS payment_method,
    t.Currency,
    COUNT(t.TransactionID) AS transaction_count,
    SUM(t.Amount) AS total_amount
FROM PaymentMethod pm
JOIN Transaction t ON pm.PaymentMethodID = t.PaymentMethodID
WHERE t.Status = 'completed'
    AND t.TransactionDate >= CURRENT_DATE - INTERVAL '60 days'
GROUP BY pm.Type, t.Currency
ORDER BY pm.Type, total_amount DESC;

-- Network Type Performance for Comparison Chart
SELECT 
    ch.NetworkType AS network,
    COUNT(t.TransactionID) AS total_transactions,
    SUM(t.Amount) AS total_volume,
    ROUND(AVG(EXTRACT(DAYS FROM (t.SettlementDate - t.TransactionDate))), 2) AS avg_settlement_days,
    ROUND(
        (COUNT(CASE WHEN t.Status = 'completed' THEN 1 END) * 100.0 / 
         GREATEST(COUNT(t.TransactionID), 1)), 2
    ) AS success_rate
FROM ClearingHouse ch
JOIN Account a ON ch.ClearingHouseID = a.ClearingHouseID
JOIN PaymentMethod pm ON a.AccountID = pm.AccountID
JOIN Transaction t ON pm.PaymentMethodID = t.PaymentMethodID
WHERE t.TransactionDate >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY ch.NetworkType
ORDER BY total_volume DESC;

-- ===============================================
-- VIEW-BASED VISUALIZATION QUERIES
-- ===============================================
-- Using the views created earlier for consistent visualization data

-- Customer Tier Distribution (from CustomerServiceView)
SELECT 
    customer_tier,
    COUNT(*) AS customer_count,
    SUM(total_spent) AS tier_total_volume,
    ROUND(AVG(total_spent), 2) AS tier_avg_spending
FROM CustomerServiceView
WHERE total_transactions > 0
GROUP BY customer_tier
ORDER BY 
    CASE customer_tier 
        WHEN 'Premium' THEN 1 
        WHEN 'Gold' THEN 2 
        WHEN 'Standard' THEN 3 
    END;

-- Merchant Activity Levels (from MerchantManagementView)
SELECT 
    activity_level,
    COUNT(*) AS merchant_count,
    ROUND(AVG(revenue_processed), 2) AS avg_revenue,
    ROUND(AVG(success_rate), 2) AS avg_success_rate
FROM MerchantManagementView
GROUP BY activity_level
ORDER BY 
    CASE activity_level
        WHEN 'High Volume' THEN 1
        WHEN 'Medium Volume' THEN 2
        WHEN 'Low Volume' THEN 3
        WHEN 'Inactive' THEN 4
    END;

-- ===============================================
-- FUNCTION-ENHANCED VISUALIZATION QUERIES
-- ===============================================
-- Using the functions created earlier for dynamic visualizations

-- Customer Tiers by Function (Dynamic Pie Chart Data)
SELECT 
    calculate_customer_tier(c.CustomerID, 90) AS customer_tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(
        (SELECT SUM(Amount) FROM Transaction t 
         WHERE t.CustomerID = c.CustomerID 
         AND t.Status = 'completed' 
         AND t.TransactionDate >= CURRENT_DATE - INTERVAL '90 days')
    ), 2) AS avg_spending_90_days
FROM Customer c
GROUP BY calculate_customer_tier(c.CustomerID, 90)
ORDER BY customer_count DESC;

-- Merchant Success Rate Distribution (Bar Chart with Function)
SELECT 
    CASE 
        WHEN calculate_merchant_success_rate(m.MerchantID, 90) >= 95 THEN '95-100%'
        WHEN calculate_merchant_success_rate(m.MerchantID, 90) >= 90 THEN '90-95%'
        WHEN calculate_merchant_success_rate(m.MerchantID, 90) >= 80 THEN '80-90%'
        WHEN calculate_merchant_success_rate(m.MerchantID, 90) >= 70 THEN '70-80%'
        ELSE 'Below 70%'
    END AS success_rate_range,
    COUNT(*) AS merchant_count,
    ROUND(AVG(calculate_merchant_success_rate(m.MerchantID, 90)), 2) AS avg_success_rate
FROM Merchant m
WHERE EXISTS (SELECT 1 FROM Transaction t WHERE t.MerchantID = m.MerchantID)
GROUP BY 
    CASE 
        WHEN calculate_merchant_success_rate(m.MerchantID, 90) >= 95 THEN '95-100%'
        WHEN calculate_merchant_success_rate(m.MerchantID, 90) >= 90 THEN '90-95%'
        WHEN calculate_merchant_success_rate(m.MerchantID, 90) >= 80 THEN '80-90%'
        WHEN calculate_merchant_success_rate(m.MerchantID, 90) >= 70 THEN '70-80%'
        ELSE 'Below 70%'
    END
ORDER BY avg_success_rate DESC;

-- ===============================================
-- CHART CREATION INSTRUCTIONS
-- ===============================================

/*
INSTRUCTIONS FOR CREATING CHARTS IN pgAdmin:

1. PIE CHART - Currency Distribution:
   - Run the "Enhanced Pie Chart Query with Currency Names" above
   - In pgAdmin Query Tool, after running the query:
     a) Click on the "Data Output" tab
     b) Look for the chart/graph icon in the toolbar
     c) Select "Pie Chart"
     d) Choose "currency_name" as Labels
     e) Choose "volume" as Values
     f) Add title: "Transaction Volume Distribution by Currency (Last 90 Days)"
     g) Save/Export the chart

2. BAR GRAPH - Merchant Performance:
   - Run the "Enhanced Bar Graph Query with Multiple Metrics" above
   - In pgAdmin Query Tool:
     a) Click on the "Data Output" tab
     b) Click the chart/graph icon
     c) Select "Bar Chart" (Vertical or Horizontal)
     d) Choose "merchant" as X-axis (Categories)
     e) Choose "completed_volume" as Y-axis (Values)
     f) Optional: Add "performance_score" as secondary series
     g) Add title: "Merchant Performance - Transaction Volume (Last 90 Days)"
     h) Save/Export the chart

3. Alternative Method (if pgAdmin charts not available):
   - Export query results as CSV
   - Import into Excel, Google Sheets, or other visualization tool
   - Create charts using the exported data

CHART CUSTOMIZATION TIPS:
- Use colors to distinguish categories clearly
- Add data labels for better readability
- Include legends when multiple series are shown
- Set appropriate axis labels and scales
- Consider using different chart types for different data patterns
*/

-- ===============================================
-- EXPORT-READY QUERIES FOR EXTERNAL TOOLS
-- ===============================================

-- CSV-ready query for Pie Chart
SELECT 
    CASE 
        WHEN Currency = 'USD' THEN 'US Dollar'
        WHEN Currency = 'EUR' THEN 'Euro'
        WHEN Currency = 'GBP' THEN 'British Pound'
        ELSE Currency
    END AS "Currency Name",
    SUM(Amount) AS "Total Volume"
FROM Transaction
WHERE Status = 'completed'
    AND TransactionDate >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY Currency
ORDER BY "Total Volume" DESC;

-- CSV-ready query for Bar Chart
SELECT 
    MerchantName AS "Merchant Name",
    SUM(CASE WHEN Status = 'completed' THEN Amount ELSE 0 END) AS "Completed Volume",
    COUNT(CASE WHEN Status = 'completed' THEN 1 END) AS "Completed Transactions",
    ROUND(
        (COUNT(CASE WHEN Status = 'completed' THEN 1 END) * 100.0 / 
         GREATEST(COUNT(*), 1)), 2
    ) AS "Success Rate %"
FROM Merchant m
JOIN Transaction t ON m.MerchantID = t.MerchantID
WHERE t.TransactionDate >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY m.MerchantID, m.MerchantName
HAVING COUNT(*) > 0
ORDER BY "Completed Volume" DESC;
