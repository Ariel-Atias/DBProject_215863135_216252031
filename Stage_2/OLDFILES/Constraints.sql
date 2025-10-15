-- Constraints.sql

-- Indexes
CREATE INDEX idx_transaction_date ON Transaction(TransactionDate);
CREATE INDEX idx_transaction_currency ON Transaction(Currency);
CREATE INDEX idx_customer_name ON Customer(Name);

-- אילוץ: סכום עסקה לא יכול להיות שלילי
INSERT INTO Transaction (TransactionID, Amount, Currency, Status, TransactionDate, CustomerID, MerchantID, PaymentMethodID)
VALUES ('TXN1000', -999.99, 'USD', 'Pending', CURRENT_DATE, 'CUST001', 'MERCH001', 'PAY001');


-- אילוץ: סטטוס עסקה רק מתוך רשימה
ALTER TABLE Transaction
ADD CONSTRAINT chk_status_values CHECK (Status IN ('Pending', 'Completed', 'Failed', 'Cancelled'));

-- אילוץ: מטבע רק מתוך רשימה מאושרת
ALTER TABLE Transaction
ADD CONSTRAINT chk_currency_values CHECK (Currency IN ('USD', 'EUR', 'ILS', 'GBP'));

-- אילוץ: ייחודיות כתובת אימייל לקוחות
ALTER TABLE Customer
ADD CONSTRAINT chk_name_long CHECK (LENGTH(Name) > 100);

-- ברירת מחדל לתאריך יצירת לקוח
ALTER TABLE Customer
ALTER COLUMN DateCreated SET DEFAULT CURRENT_DATE;
