# DBProject_215863135_216252031

## Stage 1

### Here will be the explenaitin of preplexity on the design...

Here is the Json code of the tables:

```json
{
  "entities": [
    {
      "name": "Customer",
      "fields": [
        "CustomerID (PK)",
        "Name",
        "Email",
        "MinimalDetails",
        "DateCreated"
      ]
    },
    {
      "name": "Transaction",
      "fields": [
        "TransactionID (PK)",
        "Amount",
        "Currency",
        "Status",
        "TransactionDate",
        "SettlementDate",
        "CustomerID (FK)",
        "MerchantID (FK)",
        "PaymentMethodID (FK)"
      ]
    },
    {
      "name": "Merchant",
      "fields": [
        "MerchantID (PK)",
        "MerchantName",
        "Address"
      ]
    },
    {
      "name": "PaymentMethod",
      "fields": [
        "PaymentMethodID (PK)",
        "Type",
        "Description",
        "AccountID (FK)"
      ]
    },
    {
      "name": "Account",
      "fields": [
        "AccountID (PK)",
        "BankName",
        "AccountNumber",
        "AccountType",
        "ClearingHouseID (FK)"
      ]
    },
    {
      "name": "ClearingHouse",
      "fields": [
        "ClearingHouseID (PK)",
        "Name",
        "NetworkType"
      ]
    }
  ],
  "relationships": [
    {"from": "Customer", "to": "Transaction", "type": "one-to-many", "name": "Performs"},
    {"from": "Merchant", "to": "Transaction", "type": "one-to-many", "name": "Receives"},
    {"from": "PaymentMethod", "to": "Transaction", "type": "one-to-many", "name": "UsedIn"},
    {"from": "PaymentMethod", "to": "Account", "type": "many-to-one", "name": "LinkedTo"},
    {"from": "ClearingHouse", "to": "Account", "type": "one-to-many", "name": "Clears"}
  ]
}
```

ER Diagram:

![ERD](Stage_1/ER_Diagram.png)

DS Diagram:

![DSD](Stage_1/DS_Diagram.png)

We create a python script that will generate all the data and records for the tables.

See the generator script here: [`DataGenerator.py`](Stage_1/DataGenerator.py)

We run the script, and here is the result:

```console
ryltys@MacBook-Pro-sl-ryl python scripts % python3 DataGenerator.py
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

We can see that the script generate us a total of **278,007 records**!

### Here will be the script that dumps your PostgreSQL database’s schema and data...
