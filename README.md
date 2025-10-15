# Payment Clearing System Database

**Student IDs:** 215863135, 216252031

---

## 📊 Stage 1 - Database Design and Creation

### Project Overview

This project creates a Payment Clearing System database that manages the full process of financial transactions, from the moment they start until settlement. The system supports multiple payment methods, works with different clearing houses, and keeps complete transaction records.

### Why This Domain?

Payment clearing systems are critical infrastructure in modern finance, handling billions of transactions daily. Our design addresses real-world challenges:
- **Multi-network support** - Different payment types use different clearing processes
- **Compliance** - Full history and records for regulations
- **Scalability** - Can manage very large numbers of transactions
- **International support** - Works with different currencies and cross-border payments

---

## 🏗️ Database Design

### Entity-Relationship Model

The system has **6 entities** built using proper normalization (3NF):

#### 1. **Customer** - Transaction Initiators
```
CustomerID (PK, INT) - Unique ID
Name (VARCHAR) - Full name
Email (VARCHAR) - Contact details
MinimalDetails (VARCHAR) - Extra info
DateCreated (DATE) - When account was created
```
**Purpose:** Represents people or companies making payments. The creation date helps analyze customer activity and detect fraud.

#### 2. **Transaction** - Core Business Process
```
TransactionID (PK, INT) - Unique ID
Amount (INT) - Value in cents
Currency (VARCHAR) - Currency code (USD, EUR, etc.)
Status (VARCHAR) - Transaction status
TransactionDate (DATE) - When it started
SettlementDate (DATE) - When it finished
CustomerID (FK) - Links to customer
MerchantID (FK) - Links to merchant
PaymentMethodID (FK) - Links to payment method
```
**Purpose:** Records each transaction. Both dates are important to study settlement speed and for reports.

#### 3. **Merchant** - Transaction Recipients
```
MerchantID (PK, INT) - Unique ID
MerchantName (VARCHAR) - Business name
Address (VARCHAR) - Business address
```
**Purpose:** Companies that receive transactions. Their location helps analyze risks and regional activity.

#### 4. **PaymentMethod** - Payment Instruments
```
PaymentMethodID (PK, INT) - Unique ID
Type (VARCHAR) - Payment type (Credit Card, ACH, etc.)
Description (VARCHAR) - Details about the method
AccountID (FK) - Connected account
```
**Purpose:** Represents the type of payment. It connects to accounts for processing.

#### 5. **Account** - Financial Accounts
```
AccountID (PK, INT) - Unique ID
BankName (VARCHAR) - Bank name
AccountNumber (VARCHAR) - Account number
AccountType (VARCHAR) - Type of account
ClearingHouseID (FK) - Connected clearing house
```
**Purpose:** Represents financial accounts. The link to clearing houses makes routing possible.

#### 6. **ClearingHouse** - Payment Networks
```
ClearingHouseID (PK, INT) - Unique ID
Name (VARCHAR) - Network name (ACH, SWIFT, etc.)
NetworkType (VARCHAR) - Type of network
```
**Purpose:** Networks that process payments (ACH, SWIFT, etc.).

---

### Visual Schema Representation

#### ER Diagram:

![ERD](Stage_1/ER_Diagram.png)

The ERD shows the logical relationships between entities:
- **Customer → Transactions** : One-to-Many (customers can have multiple transactions)
- **Merchant → Transactions** : One-to-Many (merchants receive multiple payments)
- **PaymentMethod → Transactions** : One-to-Many (payment methods used in multiple transactions)
- **PaymentMethod → Account** : Many-to-One (multiple payment methods can link to one account)
- **ClearingHouse → Account** : One-to-Many (clearing houses manage multiple accounts)

#### DS Diagram:

![DSD](Stage_1/DS_Diagram.png)

---

## 📈 Data Generation Strategy

### Why Realistic Data?
A payment system needs realistic data to:
- Test performance under real-world loads
- Validate business logic with edge cases
- Support analysis and reports
- Meet audit and compliance needs

### Implementation Approach

We used **Python scripts** to create the data and make sure that:
- **Relationships are realistic** – Settlement dates always come after transaction dates  
- **Business rules are followed** – Transaction amounts and frequencies make sense  
- **Data is consistent** – All foreign key links are correct  
- **It can scale** – Large datasets can be generated quickly and efficiently  

We create the python script that will generate all the data and records for the tables.  
See the generator script here: [DataGenerator.py](Stage_1/DataGenerator.py)

We run the script with te following command:

```bash
python3 DataGenerator.py
```

**Output:**

```
=== PAYMENT CLEARING DATA GENERATOR ===
Creating 200,000+ transaction records...

Creating ClearingHouse data...
✓ Created 7 ClearingHouse records
Creating Account data...
✓ Created 2000 Account records
Creating PaymentMethod data...
✓ Created 1000 PaymentMethod records
Creating Customer data...
  Generated 10000 customers...
  Generated 20000 customers...
  Generated 30000 customers...
  Generated 40000 customers...
  Generated 50000 customers...
  Generated 60000 customers...
✓ Created 60000 Customer records
Creating Merchant data...
  Generated 5000 merchants...
  Generated 10000 merchants...
  Generated 15000 merchants...
✓ Created 15000 Merchant records
Creating Transaction data - MAIN BUSINESS PROCESS...
  Generated 25000 transactions...
  Generated 50000 transactions...
  Generated 75000 transactions...
  Generated 100000 transactions...
  Generated 125000 transactions...
  Generated 150000 transactions...
  Generated 175000 transactions...
  Generated 200000 transactions...
✓ Created 200000 Transaction records

=== SUMMARY ===
ClearingHouse: 7
Account: 2,000
PaymentMethod: 1,000
Customer: 60,000
Merchant: 15,000
Transaction: 200,000 MAIN PROCESS
TOTAL: 278,007 records

Files created:
• clearinghouse.csv
• account.csv
• paymentmethod.csv
• customer.csv
• merchant.csv
• transaction.csv

 Ready to import into your PostgreSQL database!
```

And here is the generated data file:

![GeneratedFile](Stage_1/GeneratedFile.png)

### Generated Dataset Statistics

| Entity | Records | Purpose |
|--------|---------|---------|
| **ClearingHouse** | 7 | Major payment networks (ACH, SWIFT, Visa, etc.) |
| **Account** | 2,000 | Bank accounts across major institutions |
| **PaymentMethod** | 1,000 | Various payment instruments |
| **Customer** | 60,000 | Individual and business customers |
| **Merchant** | 15,000 | Businesses receiving payments |
| **Transaction** | **200,000** | **Main business process** |
| **TOTAL** | **278,007** | Complete dataset |

#### Transaction Distribution Analysis
- **60%** Small transactions ($1-$100) - Daily consumer purchases
- **25%** Medium transactions ($100-$1,000) - Business payments
- **15%** Large transactions ($1,000-$50,000) - Corporate transfers

#### Status Distribution
- **60%** Settled - Successfully processed
- **25%** Cleared - In clearing process  
- **10%** Pending/Failed/Cancelled - Various processing states

---

## 🔧 Database Implementation

### SQL Schema Creation

The tables for the system were created using SQL scripts found here: [CreateTables.sql](Stage_1/CreateTables.sql)  
This script contains all necessary constraints, keys, and relationships for the database.

### Data Insertion

After generating the data, the records were added to the tables using pgAdmin’s Import feature.
This method directly imports the CSV files into the appropriate tables using pgAdmin's graphical interface.

### Database Dump

To back up the full database, we used the following dump script: [DumpDatabase.sh](Stage_1/DumpDatabase.sh)  
Here is an example of typical output after running the dump process:

![DumpDatabase.png](Stage_1/DumpDatabase.png)

---

## 📊 Stage 2 - 

# README – Part B (Queries, Parametrized Queries, Constraints)

## 🎯 Purpose of This Stage
The second stage focuses on creating complex queries that simulate real-world system usage, as well as implementing constraints to ensure data quality. The goal is to demonstrate that the system can meet real business needs.

## 📦 Database Backup

### Stage 2 Backup Strategy

After completing all queries and constraints implementation, we performed comprehensive database backups using multiple formats to ensure data safety and recovery capabilities.

#### Backup Methods Used:

**1. SQL Text-Based Backup (pg_dump)**
We created a complete SQL backup file containing DROP, CREATE, and INSERT statements:
- **Output file:** `backupSQL.sql`
- **Log file:** `backupSQL.log`
- **Command used:** `pg_dump --verbose --clean --create --insert`

**2. PostgreSQL Custom Format Backup**
We generated a binary backup file and tested the restore process:
- **Backup file:** `backupPSQL.sql` 
- **Log file:** `backupPSQL.log`
- **Process:** Database cleared and restored using `pg_restore`

**3. Performance Timing**
All backup operations were timed using methods covered in class, with timing statistics recorded in the respective log files.

#### Git Integration
The backup files are managed using Git-LFS due to their large size, as shown in the upload process:

![Git Backup Upload](screenshots/BACKUP2.jpeg)

**Repository Contents:**
- Backup scripts and log files stored in git repository
- Large backup files managed with Git-LFS
- Complete timing and performance metrics documented
- All backup operations logged with detailed responses

This comprehensive backup strategy ensures multiple recovery options and maintains complete audit trail of the backup process.


==================================================
## 1. SELECT / UPDATE / DELETE Queries (Queries.sql)
==================================================

### Complex SELECT Queries

**Why are complex queries important?**
Complex queries simulate real business needs such as generating reports, analyzing user behavior, and creating insights for business decisions.

### SELECT Queries

**1. All transactions above 500, including customer and merchant details**
```sql
SELECT c.Name, m.MerchantName, t.Amount, t.Currency, t.TransactionDate
FROM Transaction t
JOIN Customer c ON t.CustomerID = c.CustomerID
JOIN Merchant m ON t.MerchantID = m.MerchantID
WHERE t.Amount > 500
ORDER BY t.TransactionDate DESC;
```
**Why this query is important:**
Identifies high-value transactions for risk management and helps detect unusual spending patterns that might require attention.

![Screenshot](screenshots/SELECT1.jpeg)


---

**2. Average transaction amounts per currency**
```sql
SELECT t.Currency, AVG(t.Amount) AS avgAmount, COUNT(*) AS transactionCount
FROM Transaction t
GROUP BY t.Currency
ORDER BY avgAmount DESC;
```
**Why this query is important:**
Provides insights into transaction volume distribution per currency and helps in financial planning and currency exchange rate analysis.

![Screenshot](screenshots/SELECT2.jpeg)


---

**3. Customers with transactions above 1000 in the last year**
```sql
SELECT c.Name, c.Email, SUM(t.Amount) AS totalAmount
FROM Customer c
JOIN Transaction t ON c.CustomerID = t.CustomerID
WHERE t.TransactionDate >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY c.CustomerID
HAVING SUM(t.Amount) > 1000;
```
**Why this query is important:**
Identifies high-value customers for loyalty programs and targeted marketing campaigns, helping improve customer retention.

![Screenshot](screenshots/SELECT3.jpeg)


---

**4. Bank accounts with more than two payment methods**
```sql
SELECT a.BankName, a.AccountNumber, COUNT(pm.PaymentMethodID) AS paymentMethodCount
FROM Account a
JOIN PaymentMethod pm ON a.AccountID = pm.AccountID
GROUP BY a.AccountID
HAVING COUNT(pm.PaymentMethodID) > 2;
```
**Why this query is important:**
Detects accounts with multiple payment methods, which is relevant for risk management and fraud prevention.

![Screenshot](screenshots/SELECT4.jpeg)


---

**5. Transaction count per currency**
```sql
SELECT Currency, COUNT(*) AS cnt
FROM Transaction
GROUP BY Currency
ORDER BY cnt DESC;
```
**Why this query is important:**
Provides a quick overview of transaction volume per currency, essential for business intelligence and market analysis.
also showes us the data before the DELETE\UPDATE queris

![Screenshot](screenshots/PREDELETE.jpeg)

### Data Modification Operations

#### DELETE Operations

**Why is deleting old data important?**
Deleting old and irrelevant data improves performance, saves storage space, and maintains compliance with privacy regulations like GDPR.

**1. Delete cancelled transactions**
```sql
DELETE FROM Transaction WHERE Status = 'Cancelled';
```
**Why this deletion is necessary:**
Cancelled transactions clutter the database and can skew analytics. Removing them improves query performance and data accuracy.

DELETE:
![Screenshot](screenshots/DELETE11.jpeg)

RESULT:
![Screenshot](screenshots/AFTERDELETE11.jpeg)


---

**2. Delete failed transactions**
```sql
DELETE FROM Transaction WHERE Status = 'Failed';
```
**Why this deletion is necessary:**
Failed transactions from system errors should be cleaned up to avoid confusion in financial reports and maintain data integrity.

USE:
![Screenshot](screenshots/DELETE21.jpeg)

RESULT:
![Screenshot](screenshots/AFTERDELETE21.jpeg)


#### UPDATE Operations

**Why is updating data important?**
Data updates ensure that information in the system is always current and accurate, which is crucial for making correct business decisions.

**1. Update transactions from 'Pending' to 'Completed'**
```sql
UPDATE Transaction SET Status = 'Completed' WHERE Status = 'Pending';
```
**Why this update is important:**
Transactions that have been processed but still marked as "Pending" could cause unjustified service blocking for customers.

USE:
![Screenshot](screenshots/UPDATE11.jpeg)

RESULT:
![Screenshot](screenshots/AFTERUPDATE11.jpeg)


---

**2. Update transaction currency from EUR to ILS**
```sql
UPDATE Transaction SET Currency = 'ILS' WHERE Currency = 'EUR';
```
**Why this update is important:**
Standardizing transactions to local currency simplifies financial reporting and reduces complexity in currency conversion calculations.

BEFORE:
(we update a different table from the first screenshot...)
![Screenshot](screenshots/PREUPDATE21.jpeg)

USE:
![Screenshot](screenshots/UPDATE21.jpeg)

RESULT:
![Screenshot](screenshots/AFTERUPDATE21.jpeg)


### Transaction Control

#### Rollback Demonstration
**Why is Rollback important?**
Rollback allows canceling changes in case of errors or issues, ensuring data integrity and allowing safe testing of operations.

For testing purposes, queries can be wrapped with:
```sql
BEGIN;
-- run queries
ROLLBACK;
```

- During Rollback: Insert screenshot here
- After Rollback: Insert screenshot here

==================================================
## 2. Parametrized Queries (ParamsQueries.sql)
==================================================

We created **4 parametrized queries** that simulate real user questions requiring input parameters.

**Why are parametrized queries important?**
They provide flexibility for users to get specific information based on their needs, making the system more interactive and useful.

### The 4 Parametrized Queries:

**1. Show all transactions for a specific customer by name**
- **Business Question:** "Show me all transactions for customer John Doe"
- **Parameter:** Customer Name (e.g., 'John Smith')
- **Uses:** JOIN, ORDER BY
- **Purpose:** Retrieves all transaction details for a given customer, including merchant and payment method, allowing focused analysis on individual customer behavior.

**2. Show transactions within a date range and minimum amount**
- **Business Question:** "Show me all transactions between two dates with amount above threshold"
- **Parameters:** Start Date = '2024-01-01', End Date = '2024-12-31', Minimum Amount = 100
- **Uses:** JOIN, WHERE with date range and minimum amount, ORDER BY
- **Purpose:** Filters transactions to a specific period and threshold, useful for reporting and detecting significant transactions over time.

**3. Merchant transaction summary**
- **Business Question:** "Give me transaction summary for merchant example 'Amazon' in 'USD'"
- **Parameters:** Merchant Name = 'Amazon', Currency = 'USD'
- **Uses:** JOIN, GROUP BY, SUM/AVG/MAX/MIN functions
- **Purpose:** Aggregates all transactions for a merchant in a given currency, showing total, average, highest, and lowest transaction amounts. Useful for merchant performance analysis.

**4. Payment methods usage by bank and account type**
- **Business Question:** "Show payment method usage for bank example 'Bank Hapoalim' and 'Checking' accounts"
- **Parameters:** Bank Name = 'Bank Hapoalim', Account Type = 'Checking'
- **Uses:** JOIN, GROUP BY, COUNT/SUM functions
- **Purpose:** Provides insights into payment method usage per bank and account type, supporting financial analysis and operational decisions.

### Execution Results:

1:
![Screenshot](screenshots/PARAM1.jpeg)

2:
![Screenshot](screenshots/PARAM2.jpeg)

3:
![Screenshot](screenshots/PARAM3.jpeg)

4:
![Screenshot](screenshots/PARAM4.jpeg)


### Performance Timing:
Each query was executed with `EXPLAIN ANALYZE` to measure performance:
Insert timing results here.

==================================================
## 3. Constraints & Indexes (Constraints.sql)
==================================================

### Database Constraints

**Why are constraints important?**
Constraints ensure that data entering the system is valid and consistent, preventing incorrect data that could damage system reliability.

### Indexes Created:
- `idx_transaction_date` on TransactionDate - improves date-range queries
- `idx_transaction_currency` on Currency - speeds up currency-based filtering
- `idx_customer_name` on Customer Name - accelerates customer searches

FIRST & SECONED INDEX:
![Screenshot](Stage_2/SCREENSHOTS2/CREATEINDEX12.jpeg)

THIRD INDEX:
![Screenshot](Stage_2/CREATEINDEX21.jpeg)


### Constraint Violation Tests

Testing the constraints with invalid data:

**Test 1: Try to insert negative amount (should fail)**
```sql
-- This should fail due to chk_amount_positive
INSERT INTO Transaction (TransactionID, Amount, Currency, Status, TransactionDate, CustomerID, MerchantID, PaymentMethodID)
VALUES ('TXN999', -100.00, 'USD', 'Pending', CURRENT_DATE, 'CUST001', 'MERCH001', 'PAY001');
```
![Screenshot](Stage_2/SCREENSHOTS2/ERROR11.jpeg)

**Test 2: Try to insert invalid status (should fail)**
```sql
-- This should fail due to chk_status_values
INSERT INTO Transaction (TransactionID, Amount, Currency, Status, TransactionDate, CustomerID, MerchantID, PaymentMethodID)
VALUES ('TXN998', 100.00, 'USD', 'Invalid Status', CURRENT_DATE, 'CUST001', 'MERCH001', 'PAY001');
```
![Screenshot](Stage_2/ERROR12.jpeg)

**Test 3: Try to insert duplicate email (should fail)**
```sql
-- This should fail due to uk_customer_email
INSERT INTO Customer (CustomerID, Name, Email, MinimalDetails, DateCreated) 
VALUES ('CUST999', 'Test User', 'existing@email.com', 'Test Details', CURRENT_DATE);
```
![Screenshot](Stage_2/ERROR13.jpeg)

**4. Customer email addresses must be unique**
```sql
ALTER TABLE Customer
ADD CONSTRAINT chk_name_long CHECK (LENGTH(Name) > 100);
```
**Why this constraint is essential:**
Prevents duplicate customer accounts and ensures proper customer identification.

![Screenshot](Stage_2/ERROR21.jpeg)


---

**5. Default value for customer creation date**
```sql
ALTER TABLE Customer
ALTER COLUMN DateCreated SET DEFAULT CURRENT_DATE;
```
**Why this default is essential:**
Ensures every customer has a creation date for analytics and compliance tracking.

![Screenshot](Stage_2/SCREENSHOTS2/שגיאה22.jpeg)

==================================================
## 4. Files Structure
==================================================

- **[Queries.sql](Queries.sql)** - All SELECT, UPDATE, DELETE queries
- **[ParamsQueries.sql](ParamsQueries.sql)** - Parametrized queries for user input
- **[Constraints.sql](Constraints.sql)** - Database constraints and indexes definitions

==================================================
# Payment Clearing System Database - Stage 3

---

# 📊 Stage 3 – Advanced Database Operations

## 🧾 Project Overview

Stage 3 extends our **Payment Clearing System** with practical database operations that make it closer to a real-world system.
In this stage, we focus on **advanced SQL queries**, **user-friendly views**, **visual insights**, and **simple reusable functions** that support analysis and automation.

---

## 🎯 Objectives

| Component          | Purpose                                | Business Value                                       |
| ------------------ | -------------------------------------- | ---------------------------------------------------- |
| **Queries**        | Advanced analytics with multiple joins | Helps analyze financial and operational patterns     |
| **Views**          | Simplified role-based access           | Easier access for users with different needs         |
| **Visualizations** | Graphs and charts                      | Better business decisions through visual insights    |
| **Functions**      | Simplified logic and reusability       | Reduces repetitive SQL code and improves performance |

---

## 🔍 1. Queries (`Stage3_Queries.sql`)

### 🧩 Query 1 – Recent Transactions per Customer

**Business Question:**
Which customers made transactions during the last week, and what are their payment details?

```sql
-- Q1: Recent transactions per customer (last 7 days relative to data)
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
JOIN transaction t ON t.customerid = c.customerid
JOIN merchant m ON m.merchantid = t.merchantid
WHERE t.transactiondate >= (
    SELECT MAX(transactiondate) FROM transaction
  ) - INTERVAL '7 days'
ORDER BY c.customerid, t.transactiondate DESC;
```

#### 🧠 Explanation

1. Displays all transactions made in the past 7 days relative to the most recent transaction date in the dataset.
2. Useful for **daily or weekly monitoring** of transaction activity per customer.
3. Helps track customer engagement and detect **recent spikes or declines**.

📸 **Screenshots:**

![Query 1 Result](Stage_3/Screenshots33/query1.png)

---

### 💰 Query 2 – Top-10 Merchants by Total Amount

**Business Question:**
Which merchants generated the highest total processed amount?

```sql
-- Q2: Top-10 merchants by total amount
SELECT
  m.merchantid,
  m.merchantname,
  COUNT(*)        AS txn_count,
  SUM(t.amount)   AS total_amount
FROM merchant m
JOIN transaction t ON t.merchantid = m.merchantid
GROUP BY m.merchantid, m.merchantname
ORDER BY total_amount DESC
LIMIT 10;
```

#### 🧠 Explanation

1. Joins **merchant** with **transaction**.
2. Aggregates per merchant – counts total transactions and sums their amounts.
3. Sorts by total amount to surface the **top contributors** by volume.

📸 **Screenshots:**

![Query 2 Result](Stage_3/Screenshots33/q2.png)

---

### 🏦 Query 3 – Distribution by Clearing House

**Business Question:**
How are transactions distributed across different clearing houses, and which clearing house processes the highest number and total amount of transactions?

```sql
-- Q3: Distribution by clearing house
SELECT
  ch.clearinghouseid,
  ch.name AS clearing_house,
  COUNT(t.transactionid) AS txn_count,
  SUM(t.amount) AS total_amount
FROM transaction t
JOIN paymentmethod pm ON pm.paymentmethodid = t.paymentmethodid
JOIN account a ON a.accountid = pm.accountid
JOIN clearinghouse ch ON ch.clearinghouseid = a.clearinghouseid
GROUP BY ch.clearinghouseid, ch.name
ORDER BY txn_count DESC;
```

#### 🧠 Explanation

1. Connects **transaction → paymentmethod → account → clearinghouse** tables.
2. Aggregates transactions by clearing house:

   * `txn_count` → number of transactions processed.
   * `total_amount` → total value processed.
3. Ordered by `txn_count` to identify the **most active networks**.
4. Useful for operational analysis of transaction routing and **load distribution**.

📸 **Screenshot:**

![Query 3 Result](Stage_3/Screenshots33/q3.jpeg)

---

### ✅ Summary of Queries

* Implemented **multi-join analytical queries** covering customer activity, merchant ranking, and network distribution.
* Each query supports a **specific business need** and can be reused for dashboards or reporting.
* Execution times were tested in `pgAdmin` using `EXPLAIN ANALYZE` to ensure good performance.

---

## 🧩 Stage 3 — Views and Data Insights

This section follows the analytical SQL queries and introduces a series of **views** designed for reusable insights and safe updates.
Each view includes:

* ✅ **Creation** – the `CREATE OR REPLACE VIEW` definition
* 🔍 **Usage** – example of reading from the view
* 🛠️ **Update** – a real update that uses the view

---

### 1️⃣ View: `v_recent_txn_30d` – Recent Transactions (Last 30 Days)

**Purpose:** Provides the latest transactions within the last 30 days relative to the newest transaction in the dataset, joining customer and merchant info.

#### ✳️ Create

```sql
CREATE OR REPLACE VIEW v_recent_txn_30d AS
SELECT
  t.transactionid,
  t.transactiondate,
  t.settlementdate,
  t.amount,
  t.currency,
  t.status,
  c.customerid,
  c.name AS customer_name,
  m.merchantid,
  m.merchantname
FROM transaction t
JOIN customer  c ON c.customerid  = t.customerid
JOIN merchant  m ON m.merchantid  = t.merchantid
WHERE t.transactiondate >= (
  SELECT MAX(transactiondate) FROM transaction
) - INTERVAL '30 days';
```

![CREATE v\_recent\_txn\_30d](Stage_3/Screenshots33/v1.jpeg)

#### 🔍 Usage

```sql
SELECT *
FROM v_recent_txn_30d
ORDER BY transactiondate DESC
LIMIT 20;
```

![USE v\_recent\_txn\_30d](Stage_3/Screenshots33/sv1.jpeg)

#### 🛠️ Update using the View

```sql
UPDATE transaction t
SET status = 'Cancelled'
FROM v_recent_txn_30d v
WHERE v.transactionid = t.transactionid
  AND t.status = 'Pending'
  AND v.transactiondate <= CURRENT_DATE - INTERVAL '7 days';
```

![UPDATE v\_recent\_txn\_30d](Stage_3/Screenshots33/uv1.jpeg)

---

### 2️⃣ View: `v_merchant_summary` – Merchant Totals

**Purpose:** Aggregates total number of transactions and total amount processed by each merchant.
Shows all merchants, even those with no transactions.

#### ✳️ Create

```sql
CREATE OR REPLACE VIEW v_merchant_summary AS
SELECT
  m.merchantid,
  m.merchantname,
  COUNT(t.transactionid)     AS txn_count,
  COALESCE(SUM(t.amount), 0) AS total_amount
FROM merchant m
LEFT JOIN transaction t ON t.merchantid = m.merchantid
GROUP BY m.merchantid, m.merchantname;
```

![CREATE v\_merchant\_summary](Stage_3/Screenshots33/v2.jpeg)

#### 🔍 Usage

```sql
SELECT merchantid, merchantname, txn_count, total_amount
FROM v_merchant_summary
ORDER BY total_amount DESC
LIMIT 10;
```

![USE v\_merchant\_summary](Stage_3/Screenshots33/sv2.jpeg)

#### 🛠️ Update using the View
```sql

UPDATE merchant m
SET merchantname = m.merchantname || ' [HIGH_VOLUME]'
FROM v_merchant_summary v
WHERE v.merchantid = m.merchantid
  AND v.total_amount > 1500000;
```

![UPDATE v\_merchant\_summary](Stage_3/Screenshots33/uv2n.jpeg)

---

### 3️⃣ View: `v_paymentmethod_usage` – Payment Method Performance

**Purpose:** Summarizes usage frequency and total processed volume by each payment method.

#### ✳️ Create

```sql
CREATE OR REPLACE VIEW v_paymentmethod_usage AS
SELECT
  pm.paymentmethodid,
  pm.type AS payment_type,
  COUNT(t.transactionid)     AS txn_count,
  COALESCE(SUM(t.amount), 0) AS total_amount
FROM paymentmethod pm
LEFT JOIN transaction t ON t.paymentmethodid = pm.paymentmethodid
GROUP BY pm.paymentmethodid, pm.type;
```

![CREATE v\_paymentmethod\_usage](Stage_3/Screenshots33/v3.jpeg)

#### 🔍 Usage

```sql
SELECT paymentmethodid, payment_type, txn_count, total_amount
FROM v_paymentmethod_usage
ORDER BY txn_count DESC;
```

![USE v\_paymentmethod\_usage](Stage_3/Screenshots33/sv3.jpeg)

#### 🛠️ Update using the View

```sql
UPDATE paymentmethod pm
SET description = 'Low usage – review'
WHERE pm.paymentmethodid IN (
  SELECT paymentmethodid
  FROM v_paymentmethod_usage
  WHERE txn_count < 50
);
```

![UPDATE v\_paymentmethod\_usage](Stage_3/Screenshots33/uv3n.jpeg)

---

### 4️⃣ View: `v_txn_status` – Transaction Status Control

**Purpose:** Provides visibility and control for allowed transaction statuses with built-in protection via `WITH CHECK OPTION`.


#### ✳️ Create

```sql
CREATE OR REPLACE VIEW v_txn_status AS
SELECT transactionid, status
FROM transaction
WHERE status IN ('Pending','Cleared','Settled','Failed','Cancelled')
WITH CHECK OPTION;
```

![CREATE v\_txn\_status](Stage_3/Screenshots33/v4.jpeg)

#### 🔍 Usage

```sql
SELECT *
FROM v_txn_status
ORDER BY transactionid DESC
LIMIT 20;
```

![USE v\_txn\_status](Stage_3/Screenshots33/sv2.jpeg)

#### 🛠️ Update using the View

```sql
UPDATE v_txn_status
SET status = 'Cancelled'
WHERE transactionid = 100001;
```

![UPDATE v\_txn\_status](Stage_3/Screenshots33/uv4n.jpeg)


---

### ✅ Summary of Stage 3 (Views Section)

* Introduced **reusable analytical views** for transactions, merchants, methods, and statuses.
* Demonstrated **real updates** that use or rely on those views.
* Maintained **clean SQL syntax** and **readable GitHub formatting**.
* Each view includes creation, usage, and update examples with **embedded screenshots** for visual clarity.

---

## 📈 3. Visualizations (`Visualizations.sql`)

This section contains two visuals built directly in **pgAdmin Graph Visualiser**, powered by the views from Stage 3:

* `v_merchant_summary` → **Bar chart** of top merchants by total amount
* `v_clearing_summary` → **Pie chart** of transactions by clearing house

> Tip: In pgAdmin, open the **Graph Visualiser** tab after running a query, choose a chart type, set fields, then click **Download** to save the image into your repo.

---

### Visualization A — **Top 10 Merchants by Total Amount** (Bar Chart)

**Query**

```sql
SELECT merchantname, total_amount
FROM v_merchant_summary
ORDER BY total_amount DESC
LIMIT 10;
```

📸 **Screenshot**

![Top 10 merchants by total amount – bar chart](Stage_3/Screenshots33/barchart.jpeg)

**What it shows**

* Ranks the **top 10 merchants** by processed volume (`total_amount`).
* Great for identifying **key partners** and prioritizing commercial focus.

**Explanation**
The bar height represents the cumulative processed amount per merchant. In the sample output, *Hotel Co* clearly leads, followed by *Retail Store Inc* and *Hotel Corp*. Since this chart is based on the `v_merchant_summary` view, it stays up-to-date as data changes.

---

### Visualization B — **Transaction Share by Clearing House** (Pie Chart)

**Query**

```sql
SELECT clearinghouse_name, txn_count
FROM v_clearing_summary
ORDER BY txn_count DESC;
```

📸 **Screenshot**

![Transaction share by clearing house – pie chart](Stage_3/Screenshots33/piechart.jpeg)

**What it shows**

* The relative **share of transactions** (`txn_count`) handled by each clearing network.
* Helps Operations/Finance assess **load distribution** and **network dependency**.

**Explanation**
Each slice corresponds to a clearing network (e.g., **TARGET2**, **FedWire**, **Visa Network**). Slice size is proportional to the number of transactions handled. The chart updates automatically when `v_clearing_summary` changes.

---

### Why these two visuals?

* They demonstrate **two complementary angles**: revenue concentration (bar) and network distribution (pie).
* Both are backed by **views**, so they’re **auto-refreshing** as data is updated.
* Clear, demo-friendly, and directly support merchant management and routing analysis.


---

## ⚙️ 4. Functions (`Functions.sql`)

### Function 1 – `fn_count_transactions`

**Purpose:** Count how many transactions belong to a given merchant.
**Input:** `p_merchantid INT`
**Output:** `INT` (number of rows in the transactions table for that merchant)
**Why it’s useful:** Quick KPI for ranking merchants by activity (used in Top-10 report).

#### 🧩 Definition

```sql
CREATE OR REPLACE FUNCTION fn_count_transactions(p_merchantid int)
RETURNS int
LANGUAGE sql
AS $$
  SELECT COUNT(*)
  FROM transaction
  WHERE merchantid = p_merchantid;
$$;
```

📸 **Function Created**
![fn\_count\_transactions – created](Stage_3/Screenshots33/f1.png)

---

#### 🔍 Example Usage – Rank Top Merchants by Transaction Count

```sql
SELECT
  m.merchantid,
  m.merchantname,
  fn_count_transactions(m.merchantid) AS transaction_count
FROM merchant m
ORDER BY transaction_count DESC
LIMIT 10;
```

📸 **Result Output**
![Top 10 merchants by transaction count](Stage_3/Screenshots33/sf1.jpeg)

**Explanation**

* Each row shows a merchant and its total number of transactions.
* Great for dashboards and weekly monitoring.

**Edge Cases**

* If a merchant has **no transactions**, returns `0`.
* If `NULL` input → returns 0 rows (no match).

---

### Function 2 – `fn_total_amount`

**Purpose:** Calculates total transaction amount for a specific merchant.
**Input:** `p_merchantid INT`
**Output:** `NUMERIC`
**Why it’s useful:** Measures each merchant’s total financial activity — essential for revenue analytics.

#### 🧩 Definition

```sql
CREATE OR REPLACE FUNCTION fn_total_amount(p_merchantid int)
RETURNS numeric
LANGUAGE sql
AS $$
  SELECT COALESCE(SUM(amount), 0)
  FROM transaction
  WHERE merchantid = p_merchantid;
$$;
```

📸 **Function Created**
![fn\_total\_amount – created](Stage_3/Screenshots33/f2.jpeg)

---

#### 🔍 Example Usage – Top 10 Merchants by Total Amount

```sql
SELECT
  m.merchantid,
  m.merchantname,
  fn_total_amount(m.merchantid) AS total_amount
FROM merchant m
ORDER BY total_amount DESC
LIMIT 10;
```

📸 **Result Output**
![Top 10 merchants by total amount](Stage_3/Screenshots33/sf2.jpeg)
**Explanation**

* Displays merchants ranked by **total processed value**.
* “Hotel Co” usually leads with the highest revenue.

**Edge Cases**

* Returns `0` if merchant has no transactions.
* Uses `COALESCE` to prevent `NULL` sums.

---

### Function 3 – `fn_unique_customers`

**Purpose:** Counts how many **unique customers** made transactions with a merchant.
**Input:** `p_merchantid INT`
**Output:** `INT`
**Why it’s useful:** Helps analyze merchant reach and customer diversity.

#### 🧩 Definition

```sql
CREATE OR REPLACE FUNCTION fn_unique_customers(p_merchantid int)
RETURNS int
LANGUAGE sql
AS $$
  SELECT COUNT(DISTINCT customerid)
  FROM transaction
  WHERE merchantid = p_merchantid;
$$;
```

📸 **Function Created**
![fn\_unique\_customers – created](Stage_3/Screenshots33/f3.jpeg)

---

#### 🔍 Example Usage – Top Merchants by Unique Customers

```sql
SELECT
  m.merchantid,
  m.merchantname,
  fn_unique_customers(m.merchantid) AS unique_customers
FROM merchant m
ORDER BY unique_customers DESC
LIMIT 10;
```

📸 **Result Output**
![Top merchants by unique customers](Stage_3/Screenshots33/sf3.jpeg)

**Explanation**

* Shows which merchants attract the most distinct customers.
* Example: “Retail Store Co” & “Pharmacy LLC” both reached 69 unique customers.

**Edge Cases**

* Returns `0` if no customers.
* Automatically ignores duplicates.

---

### Function 4 – `fn_customer_total`

**Purpose:** Calculates the **total amount spent** by a specific customer.
**Input:** `p_customerid INT`
**Output:** `NUMERIC`
**Why it’s useful:** Provides lifetime spending insights — ideal for loyalty programs or value segmentation.

#### 🧩 Definition

```sql
CREATE OR REPLACE FUNCTION fn_customer_total(p_customerid int)
RETURNS numeric
LANGUAGE sql
AS $$
  SELECT COALESCE(SUM(amount), 0)
  FROM transaction
  WHERE customerid = p_customerid;
$$;
```

📸 **Function Created**
![fn\_customer\_total – created](Stage_3/Screenshots33/f4.jpeg)

---

#### 🔍 Example Usage – Top Customers by Total Spending

```sql
SELECT
  c.customerid,
  c.name AS customer_name,
  fn_customer_total(c.customerid) AS total_spent
FROM customer c
WHERE c.customerid < 50
ORDER BY total_spent DESC;
```

📸 **Result Output**
![Top customers by total spending](Stage_3/Screenshots33/sf4.jpeg)

**Explanation**

* Displays top spenders by total value.
* Example:

  * *William Garcia* — 2,298,339
  * *Elizabeth Brown* — 2,012,378
  * *Patricia Brown* — 1,848,981

**Edge Cases**

* Returns `0` if no purchases.
* You can limit to completed payments: `WHERE status = 'Completed'`.

---

## 🧠 Summary

Stage 3 introduced **views**, **visuals**, and **functions** that transformed the database into a **dynamic analytical tool**.
These SQL utilities improve maintainability, analytics, and business intelligence while keeping the schema clean and modular.

---



