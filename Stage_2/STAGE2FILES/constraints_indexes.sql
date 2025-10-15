-- ======================================
-- Step 1: Add additional constraints
-- ======================================

-- CONSTRAINT 1: Transaction amount must be positive
-- Purpose: Ensures all transaction amounts are greater than zero
-- Rationale: Negative or zero amounts are invalid in real payment systems
ALTER TABLE Transaction
ADD CONSTRAINT chk_transaction_amount_positive CHECK (Amount > 0);

-- CONSTRAINT 2: Customer email must be unique
-- Purpose: Enforces uniqueness of customer email addresses
-- Rationale: Each customer needs a unique identifier for authentication and communication
ALTER TABLE Customer
ADD CONSTRAINT uq_customer_email UNIQUE (Email);

-- CONSTRAINT 3: Account number must have at least 8 digits
-- Purpose: Validates minimum length for account numbers
-- Rationale: Standard bank account numbers require minimum length for security and validity
ALTER TABLE Account
ADD CONSTRAINT chk_account_number_length CHECK (LENGTH(AccountNumber) >= 8);


-- ======================================
-- Step 2: Test the constraints
-- ======================================

-- TEST 1: Violates CHECK (Amount > 0)
-- Description: Attempts to insert a transaction with negative amount
-- Expected Error: new row for relation "transaction" violates check constraint "chk_transaction_amount_positive"
-- Explanation: The constraint prevents invalid negative transaction amounts
INSERT INTO Transaction (TransactionID, CustomerID, MerchantID, Amount, Status)
VALUES (9999, 301, 1, -50, 'Settled');

-- TEST 2: Violates UNIQUE (duplicate email)
-- Description: Attempts to insert a customer with an existing email address
-- Expected Error: duplicate key value violates unique constraint "uq_customer_email"
-- Explanation: The constraint ensures each customer has a unique email for identification
INSERT INTO Customer (CustomerID, Name, Email)
VALUES (9999, 'Test', 'existing@email.com');

-- TEST 3: Violates CHECK (Account number too short)
-- Description: Attempts to update account number to less than 8 characters
-- Expected Error: new row for relation "account" violates check constraint "chk_account_number_length"
-- Explanation: The constraint enforces minimum account number length for validity
UPDATE Account
SET AccountNumber = '123'
WHERE AccountID = 101;