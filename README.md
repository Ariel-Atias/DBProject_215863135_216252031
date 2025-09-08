# Payment Clearing System Database - Stage 1

**Student IDs:** 215863135, 216252031

---

## 📊 Stage 1 - Database Design and Population

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

### Backup Process

...

