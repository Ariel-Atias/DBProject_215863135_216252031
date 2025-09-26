import random
import csv
from datetime import datetime, timedelta
from collections import defaultdict

# reproducible
random.seed(42)

# -----------------------------
# 1) ClearingHouse
# -----------------------------
def create_clearinghouse_data():
    """Create clearing house data - 7 records, and return id->networkType"""
    data = [
        (1, 'ACH Network', 'ACH'),
        (2, 'SWIFT International', 'Wire'),
        (3, 'FedWire', 'Wire'),
        (4, 'CHIPS', 'Wire'),
        (5, 'TARGET2', 'Wire'),
        (6, 'Visa Network', 'Card'),
        (7, 'MasterCard Network', 'Card')
    ]
    with open('clearinghouse.csv', 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f); w.writerow(['ClearingHouseID','Name','NetworkType']); w.writerows(data)
    # mapping: id -> network type
    ch_type = {row[0]: row[2] for row in data}
    return len(data), ch_type

# -----------------------------
# 2) Accounts
# -----------------------------
def create_account_data(num_clearinghouses, num_customers, num_merchants):
    """
    Create 2000 accounts.
    כל חשבון: בנק, מספר, סוג, clearing house.
    בנוסף מחזירים מבני עזר כדי לייצר עסקאות חוקיות:
      - account_to_ch: accountID -> clearingHouseID
      - cust_accts_by_ch: ch -> [accountIDs של לקוחות]
      - merch_accts_by_ch: ch -> [accountIDs של סוחרים]
    """
    banks = ['JPMorgan Chase','Bank of America','Wells Fargo','Citibank','Goldman Sachs',
             'HSBC','Deutsche Bank','Barclays','Credit Suisse','UBS']
    account_types = ['Checking','Savings','Business','Corporate','Investment']

    account_to_ch = {}
    cust_accts_by_ch  = defaultdict(list)
    merch_accts_by_ch = defaultdict(list)

    rows = []
    for i in range(1, 2001):
        ch_id = random.randint(1, num_clearinghouses)
        rows.append((
            i,
            random.choice(banks),
            f"{random.randint(100000000, 999999999)}",
            random.choice(account_types),
            ch_id
        ))
        account_to_ch[i] = ch_id

        # בעלות חשבון: 55% לקוח, 45% סוחר (שרירותי אך סביר)
        if random.random() < 0.55:
            cust_accts_by_ch[ch_id].append(i)
        else:
            merch_accts_by_ch[ch_id].append(i)

    with open('account.csv', 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(['AccountID','BankName','AccountNumber','AccountType','ClearingHouseID'])
        w.writerows(rows)

    helpers = {
        'account_to_ch': account_to_ch,
        'cust_by_ch': dict(cust_accts_by_ch),
        'merch_by_ch': dict(merch_accts_by_ch),
        'num_accounts': len(rows)
    }
    return len(rows), helpers

# -----------------------------
# 3) PaymentMethod
# -----------------------------
def create_paymentmethod_data(account_helpers, ch_type):
    """
    Create 1000 payment methods. כל אמצעי תשלום שייך לחשבון קיים בלבד.
    סוג האמצעי נקבע בהתאם ל-NetworkType של ה-clearing house של החשבון.
    מחזיר גם mapping: accountID -> [paymentMethodIDs]
    """
    num_accounts = account_helpers['num_accounts']
    account_to_ch = account_helpers['account_to_ch']

    # אילוץ סוגים לפי סוג רשת
    pm_by_network = {
        'ACH':  [('ACH Transfer','Automated clearing house')],
        'Wire': [('Wire Transfer','Electronic wire transfer')],
        'Card': [('Credit Card','Card processing'),
                 ('Debit Card','Direct debit card'),
                 ('Digital Wallet','Apple/Google/PayPal wallet')],
    }

    pm_by_acct = defaultdict(list)
    rows = []
    for i in range(1, 1001):
        acct = random.randint(1, num_accounts)              # תמיד בטווח קיים
        net = ch_type[account_to_ch[acct]]                   # סוג רשת של החשבון הזה
        pm_type, desc = random.choice(pm_by_network[net])    # סוג מתאים לרשת
        rows.append((i, pm_type, desc, acct))
        pm_by_acct[acct].append(i)

    with open('paymentmethod.csv', 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(['PaymentMethodID','Type','Description','AccountID'])
        w.writerows(rows)

    return len(rows), pm_by_acct

# -----------------------------
# 4) Customers & Merchants
# -----------------------------
def create_customer_data():
    first_names = ['John','Mary','David','Sarah','Michael','Jennifer','William','Elizabeth',
                   'James','Patricia','Robert','Linda','Richard','Barbara','Joseph','Susan']
    last_names  = ['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis']
    jobs = ['Engineer','Teacher','Manager','Developer','Consultant','Analyst']
    start_date = datetime(2020,1,1); end_date = datetime(2025,8,1)

    rows = []
    for i in range(1, 60001):
        first = random.choice(first_names); last = random.choice(last_names)
        created = start_date + timedelta(days=random.randint(0, (end_date-start_date).days))
        rows.append((i, f"{first} {last}", f"{first.lower()}.{last.lower()}{i}@email.com",
                     f"Customer {i} - {random.choice(jobs)}", created.strftime('%Y-%m-%d')))
    with open('customer.csv','w',newline='',encoding='utf-8') as f:
        w=csv.writer(f); w.writerow(['CustomerID','Name','Email','MinimalDetails','DateCreated']); w.writerows(rows)
    return len(rows)

def create_merchant_data():
    business_types=['Restaurant','Retail Store','Gas Station','Grocery Store','Hotel',
                    'Pharmacy','Electronics Store','Coffee Shop','Clothing Store']
    suffixes=['Inc','LLC','Corp','Co','Group']
    cities=['New York','Los Angeles','Chicago','Houston','Phoenix']
    states=['NY','CA','IL','TX','AZ']
    rows=[]
    for i in range(1,15001):
        rows.append((i, f"{random.choice(business_types)} {random.choice(suffixes)}",
                        f"{random.randint(100,999)} Main St, {random.choice(cities)}, "
                        f"{random.choice(states)} {random.randint(10000,99999)}"))
    with open('merchant.csv','w',newline='',encoding='utf-8') as f:
        w=csv.writer(f); w.writerow(['MerchantID','MerchantName','Address']); w.writerows(rows)
    return len(rows)

# -----------------------------
# 5) Transactions (החלק המרכזי המתוקן)
# -----------------------------
def create_transaction_data(account_helpers, pm_by_acct):
    """
    200,000 עסקאות. תמיד:
      - FromAccountID ו-ToAccountID בטווח קיים (1..num_accounts)
      - החשבונות שונים זה מזה
      - שניהם באותו ClearingHouse
      - PaymentMethodID שייך ל-FromAccountID
    """
    account_to_ch = account_helpers['account_to_ch']
    cust_by_ch  = account_helpers['cust_by_ch']
    merch_by_ch = account_helpers['merch_by_ch']

    # רשימת CH שבה יש גם חשבונות לקוחות עם PM וגם חשבונות סוחרים
    valid_ch = []
    for ch in range(1, max(account_to_ch.values())+1):
        cust_with_pm = [a for a in cust_by_ch.get(ch, []) if pm_by_acct.get(a)]
        if cust_with_pm and merch_by_ch.get(ch):
            valid_ch.append((ch, cust_with_pm, merch_by_ch[ch]))
    if not valid_ch:
        raise RuntimeError("No clearing house has both (customer accounts WITH payment methods) and merchant accounts.")

    currencies = ['USD','EUR','GBP','JPY','CAD']
    statuses   = ['Pending','Cleared','Settled','Failed','Cancelled']
    status_w   = [0.05, 0.25, 0.60, 0.05, 0.05]

    def random_amount():
        r = random.random()
        if r < 0.60:   return random.randint(1, 100)     # small
        if r < 0.85:   return random.randint(100, 1000)  # medium
        return random.randint(1000, 50000)               # large

    start_date = datetime(2023,1,1); end_date = datetime(2025,8,1)
    total_days = (end_date - start_date).days

    rows = []
    for i in range(1, 200001):
        ch, from_candidates, to_candidates = random.choice(valid_ch)
        from_acct = random.choice(from_candidates)       # יש PM בוודאות
        to_acct   = random.choice(to_candidates)         # סוחר
        # ביטחון: לעולם לא אותו חשבון (בפועל גם לא אותה קבוצה)
        while to_acct == from_acct:
            to_acct = random.choice(to_candidates)

        # PaymentMethod חייב להיות של from_acct
        pm_id = random.choice(pm_by_acct[from_acct])

        # תאריכים
        days_back = int(random.betavariate(2, 5) * total_days)
        txn_date  = end_date - timedelta(days=days_back)
        settle    = txn_date + timedelta(days=random.randint(1,3))

        rows.append((
            i,
            random_amount(),
            random.choice(currencies),
            random.choices(statuses, weights=status_w)[0],
            txn_date.strftime('%Y-%m-%d'),
            settle.strftime('%Y-%m-%d'),
            from_acct,
            to_acct,
            ch,
            pm_id
        ))

    with open('transaction.csv','w',newline='',encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(['TransactionID','Amount','Currency','Status',
                    'TransactionDate','SettlementDate',
                    'FromAccountID','ToAccountID','ClearingHouseID','PaymentMethodID'])
        w.writerows(rows)

    return len(rows)

# -----------------------------
# 6) Main
# -----------------------------
def main():
    print("=== PAYMENT CLEARING DATA GENERATOR (FIXED) ===")

    num_ch, ch_type = create_clearinghouse_data()
    num_customers   = create_customer_data()
    num_merchants   = create_merchant_data()
    num_accounts, account_helpers = create_account_data(num_ch, num_customers, num_merchants)
    num_pms, pm_by_acct = create_paymentmethod_data(account_helpers, ch_type)
    num_txn = create_transaction_data(account_helpers, pm_by_acct)

    print("\n=== SUMMARY ===")
    print(f"ClearingHouse:  {num_ch}")
    print(f"Customer:       {num_customers}")
    print(f"Merchant:       {num_merchants}")
    print(f"Account:        {num_accounts}")
    print(f"PaymentMethod:  {num_pms}")
    print(f"Transaction:    {num_txn}  (valid pairs, within range)")
    print("\nFiles: clearinghouse.csv, account.csv, paymentmethod.csv, customer.csv, merchant.csv, transaction.csv")

if __name__ == "__main__":
    main()
