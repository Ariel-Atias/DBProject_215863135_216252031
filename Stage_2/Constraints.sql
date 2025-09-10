-- Constraints.sql

-- Indexes
CREATE INDEX idx_transaction_date ON Transaction(TransactionDate);
CREATE INDEX idx_transaction_currency ON Transaction(Currency);
CREATE INDEX idx_customer_name ON Customer(Name);

-- אילוץ: סכום עסקה לא יכול להיות שלילי
ALTER TABLE Transaction
ADD CONSTRAINT chk_amount_positive CHECK (Amount >= 0);

-- אילוץ: סטטוס עסקה רק מתוך רשימה
ALTER TABLE Transaction
ADD CONSTRAINT chk_status_values CHECK (Status IN ('Pending', 'Completed', 'Failed', 'Cancelled'));

-- אילוץ: מטבע רק מתוך רשימה מאושרת
ALTER TABLE Transaction
ADD CONSTRAINT chk_currency_values CHECK (Currency IN ('USD', 'EUR', 'ILS', 'GBP'));

-- אילוץ: ייחודיות כתובת אימייל לקוחות
ALTER TABLE Customer
ADD CONSTRAINT uk_customer_email UNIQUE (Email);

-- ברירת מחדל לתאריך יצירת לקוח
ALTER TABLE Customer
ALTER COLUMN DateCreated SET DEFAULT CURRENT_DATE;
