import random
import csv
from datetime import datetime, timedelta

# Set seed for reproducible results
random.seed(42)

def create_clearinghouse_data():
    """Create clearing house data - 7 records"""
    print("Creating ClearingHouse data...")
    
    data = [
        (1, 'ACH Network', 'ACH'),
        (2, 'SWIFT International', 'Wire Transfer'),
        (3, 'FedWire', 'Federal Wire'),
        (4, 'CHIPS', 'High Value'),
        (5, 'TARGET2', 'European Payments'),
        (6, 'Visa Network', 'Card Processing'),
        (7, 'MasterCard Network', 'Card Processing')
    ]
    
    with open('clearinghouse.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['ClearingHouseID', 'Name', 'NetworkType'])
        writer.writerows(data)
    
    print(f"✓ Created {len(data)} ClearingHouse records")
    return len(data)

def create_account_data(num_clearinghouses):
    """Create account data - 2000 records"""
    print("Creating Account data...")
    
    banks = ['JPMorgan Chase', 'Bank of America', 'Wells Fargo', 'Citibank', 'Goldman Sachs', 
             'HSBC', 'Deutsche Bank', 'Barclays', 'Credit Suisse', 'UBS']
    account_types = ['Checking', 'Savings', 'Business', 'Corporate', 'Investment']
    
    data = []
    for i in range(1, 2001):
        data.append((
            i,
            random.choice(banks),
            f"{random.randint(100000000, 999999999)}",
            random.choice(account_types),
            random.randint(1, num_clearinghouses)
        ))
    
    with open('account.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['AccountID', 'BankName', 'AccountNumber', 'AccountType', 'ClearingHouseID'])
        writer.writerows(data)
    
    print(f"✓ Created {len(data)} Account records")
    return len(data)

def create_paymentmethod_data(num_accounts):
    """Create payment method data - 1000 records"""
    print("Creating PaymentMethod data...")
    
    payment_types = [
        ('Credit Card', 'Visa/MasterCard/Amex processing'),
        ('Debit Card', 'Direct debit transaction'),
        ('Wire Transfer', 'Electronic wire transfer'),
        ('ACH Transfer', 'Automated clearing house'),
        ('Cash Payment', 'Cash processing'),
        ('Digital Wallet', 'PayPal/Apple Pay/Google Pay')
    ]
    
    data = []
    for i in range(1, 1001):
        payment_type, description = random.choice(payment_types)
        data.append((
            i,
            payment_type,
            description,
            random.randint(1, num_accounts)
        ))
    
    with open('paymentmethod.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['PaymentMethodID', 'Type', 'Description', 'AccountID'])
        writer.writerows(data)
    
    print(f"✓ Created {len(data)} PaymentMethod records")
    return len(data)

def create_customer_data():
    """Create customer data - 60000 records"""
    print("Creating Customer data...")
    
    first_names = ['John', 'Mary', 'David', 'Sarah', 'Michael', 'Jennifer', 'William', 'Elizabeth',
                   'James', 'Patricia', 'Robert', 'Linda', 'Richard', 'Barbara', 'Joseph', 'Susan']
    last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis']
    jobs = ['Engineer', 'Teacher', 'Manager', 'Developer', 'Consultant', 'Analyst']
    
    data = []
    for i in range(1, 60001):
        first = random.choice(first_names)
        last = random.choice(last_names)
        
        # Random date in last 5 years
        start_date = datetime(2020, 1, 1)
        end_date = datetime(2025, 8, 1)
        random_days = random.randint(0, (end_date - start_date).days)
        created_date = start_date + timedelta(days=random_days)
        
        data.append((
            i,
            f"{first} {last}",
            f"{first.lower()}.{last.lower()}{i}@email.com",
            f"Customer {i} - {random.choice(jobs)}",
            created_date.strftime('%Y-%m-%d')
        ))
        
        if i % 10000 == 0:
            print(f"  Generated {i} customers...")
    
    with open('customer.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['CustomerID', 'Name', 'Email', 'MinimalDetails', 'DateCreated'])
        writer.writerows(data)
    
    print(f"✓ Created {len(data)} Customer records")
    return len(data)

def create_merchant_data():
    """Create merchant data - 15000 records"""
    print("Creating Merchant data...")
    
    business_types = ['Restaurant', 'Retail Store', 'Gas Station', 'Grocery Store', 'Hotel',
                      'Pharmacy', 'Electronics Store', 'Coffee Shop', 'Clothing Store']
    suffixes = ['Inc', 'LLC', 'Corp', 'Co', 'Group']
    cities = ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix']
    states = ['NY', 'CA', 'IL', 'TX', 'AZ']
    
    data = []
    for i in range(1, 15001):
        business = random.choice(business_types)
        suffix = random.choice(suffixes)
        city = random.choice(cities)
        state = random.choice(states)
        
        data.append((
            i,
            f"{business} {suffix}",
            f"{random.randint(100, 999)} Main St, {city}, {state} {random.randint(10000, 99999)}"
        ))
        
        if i % 5000 == 0:
            print(f"  Generated {i} merchants...")
    
    with open('merchant.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['MerchantID', 'MerchantName', 'Address'])
        writer.writerows(data)
    
    print(f"✓ Created {len(data)} Merchant records")
    return len(data)

def create_transaction_data(num_customers, num_merchants, num_payment_methods):
    """Create transaction data - 200000 records (MAIN BUSINESS PROCESS)"""
    print("Creating Transaction data - MAIN BUSINESS PROCESS...")
    
    currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD']
    statuses = ['Pending', 'Cleared', 'Settled', 'Failed', 'Cancelled']
    status_weights = [0.05, 0.25, 0.60, 0.05, 0.05]  # Most are settled
    
    def get_amount():
        """Realistic transaction amounts"""
        rand = random.random()
        if rand < 0.6:    # 60% small ($1-100)
            return random.randint(1, 100)
        elif rand < 0.85: # 25% medium ($100-1000)
            return random.randint(100, 1000)
        else:             # 15% large ($1000-50000)
            return random.randint(1000, 50000)
    
    data = []
    start_date = datetime(2023, 1, 1)
    end_date = datetime(2025, 8, 1)
    total_days = (end_date - start_date).days
    
    for i in range(1, 200001):  # 200,000 transactions
        # Transaction date (more recent transactions)
        days_back = int(random.betavariate(2, 5) * total_days)
        transaction_date = end_date - timedelta(days=days_back)
        
        # Settlement date (1-3 days later)
        settlement_date = transaction_date + timedelta(days=random.randint(1, 3))
        
        data.append((
            i,
            get_amount(),
            random.choice(currencies),
            random.choices(statuses, weights=status_weights)[0],
            transaction_date.strftime('%Y-%m-%d'),
            settlement_date.strftime('%Y-%m-%d'),
            random.randint(1, num_customers),
            random.randint(1, num_merchants),
            random.randint(1, num_payment_methods)
        ))
        
        if i % 25000 == 0:
            print(f"  Generated {i} transactions...")
    
    with open('transaction.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['TransactionID', 'Amount', 'Currency', 'Status', 
                        'TransactionDate', 'SettlementDate', 'CustomerID', 
                        'MerchantID', 'PaymentMethodID'])
        writer.writerows(data)
    
    print(f"✓ Created {len(data)} Transaction records")
    return len(data)

def main():
    """Main function - creates data for all 6 tables"""
    print("=== PAYMENT CLEARING DATA GENERATOR ===")
    print("Creating 200,000+ transaction records...\n")
    
    # Create data in correct order (respecting foreign keys)
    num_clearinghouses = create_clearinghouse_data()
    num_accounts = create_account_data(num_clearinghouses)
    num_payment_methods = create_paymentmethod_data(num_accounts)
    num_customers = create_customer_data()
    num_merchants = create_merchant_data()
    num_transactions = create_transaction_data(num_customers, num_merchants, num_payment_methods)
    
    total = num_clearinghouses + num_accounts + num_payment_methods + num_customers + num_merchants + num_transactions
    
    print(f"\n=== SUMMARY ===")
    print(f"ClearingHouse: {num_clearinghouses:,}")
    print(f"Account: {num_accounts:,}")
    print(f"PaymentMethod: {num_payment_methods:,}")
    print(f"Customer: {num_customers:,}")
    print(f"Merchant: {num_merchants:,}")
    print(f"Transaction: {num_transactions:,} MAIN PROCESS")
    print(f"TOTAL: {total:,} records")
    
    print(f"\nFiles created:")
    print("• clearinghouse.csv")
    print("• account.csv") 
    print("• paymentmethod.csv")
    print("• customer.csv")
    print("• merchant.csv")
    print("• transaction.csv")
    
    print(f"\n Ready to import into your PostgreSQL database!")

if __name__ == "__main__":
    main()