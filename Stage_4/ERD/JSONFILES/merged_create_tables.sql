-- ================================
-- Merged Schema (Payments × Airline)
-- ================================

-- You can change the schema name if needed
CREATE SCHEMA IF NOT EXISTS merged;
SET search_path TO merged;

-- ---------- Payments domain ----------
CREATE TABLE IF NOT EXISTS Customer (
  CustomerID      INT PRIMARY KEY,
  Name            VARCHAR(50)  NOT NULL,
  Email           VARCHAR(100) NOT NULL UNIQUE,
  MinimalDetails  VARCHAR(255) NOT NULL,
  DateCreated     DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS Merchant (
  MerchantID   INT PRIMARY KEY,
  MerchantName VARCHAR(100) NOT NULL,
  Address      VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS ClearingHouse (
  ClearingHouseID INT PRIMARY KEY,
  Name            VARCHAR(100) NOT NULL,
  NetworkType     VARCHAR(50)  NOT NULL
);

CREATE TABLE IF NOT EXISTS Account (
  AccountID       INT PRIMARY KEY,
  BankName        VARCHAR(100) NOT NULL,
  AccountNumber   VARCHAR(50)  NOT NULL,
  AccountType     VARCHAR(50)  NOT NULL,
  ClearingHouseID INT NOT NULL REFERENCES ClearingHouse(ClearingHouseID)
);

CREATE TABLE IF NOT EXISTS PaymentMethod (
  PaymentMethodID INT PRIMARY KEY,
  Type            VARCHAR(255) NOT NULL,
  Description     VARCHAR(255) NOT NULL,
  AccountID       INT NOT NULL REFERENCES Account(AccountID)
);

CREATE TABLE IF NOT EXISTS "Transaction" (
  TransactionID   INT PRIMARY KEY,
  Amount          INT          NOT NULL,
  Currency        VARCHAR(10)  NOT NULL,
  Status          VARCHAR(50)  NOT NULL CHECK (Status IN ('Pending','Cleared','Settled','Failed','Cancelled','Completed')),
  TransactionDate DATE         NOT NULL,
  SettlementDate  DATE,
  CustomerID      INT NOT NULL REFERENCES Customer(CustomerID),
  MerchantID      INT NOT NULL REFERENCES Merchant(MerchantID),
  PaymentMethodID INT NOT NULL REFERENCES PaymentMethod(PaymentMethodID)
);

-- ---------- Airline domain ----------
CREATE TABLE IF NOT EXISTS Company (
  CompanyID    INT PRIMARY KEY,
  CompanyName  VARCHAR(100) NOT NULL,
  CompanyEmail VARCHAR(100),
  ModeOfTransportation VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Event (
  EventID     INT PRIMARY KEY,
  EventDate   DATE NOT NULL,
  EventTime   TIME,
  Source      VARCHAR(50),
  Destination VARCHAR(50),
  CompanyID   INT NOT NULL REFERENCES Company(CompanyID)
);

CREATE TABLE IF NOT EXISTS TicketPricing (
  TicketID INT PRIMARY KEY,
  EventID  INT NOT NULL REFERENCES Event(EventID),
  -- If airline has its own customer table, keep it nullable or FK to airline-side Customer
  CustomerID INT,
  Price   NUMERIC(12,2) NOT NULL,
  Tax     NUMERIC(12,2) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS Discounts (
  DiscountID          INT PRIMARY KEY,
  DiscountName        VARCHAR(100),
  DiscountDescription VARCHAR(255),
  AmountDiscounted    NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS FinalInvoice (
  InvoiceID            INT PRIMARY KEY,
  TicketID             INT NOT NULL REFERENCES TicketPricing(TicketID),
  TotalPrice           NUMERIC(12,2) NOT NULL,
  PaymentType          VARCHAR(50),
  CompanyContactStatus VARCHAR(50),
  PurchaseDate         DATE NOT NULL DEFAULT CURRENT_DATE,
  DiscountID           INT REFERENCES Discounts(DiscountID)
);

-- ---------- Bridge between domains ----------
CREATE TABLE IF NOT EXISTS Flight_Payment_Link (
  LinkID        SERIAL PRIMARY KEY,
  TransactionID INT NOT NULL REFERENCES "Transaction"(TransactionID) ON DELETE CASCADE,
  TicketID      INT NOT NULL REFERENCES TicketPricing(TicketID)      ON DELETE CASCADE,
  CONSTRAINT uq_transaction_ticket UNIQUE (TransactionID, TicketID)
);

-- Useful indexes
CREATE INDEX IF NOT EXISTS idx_txn_date ON "Transaction"(TransactionDate);
CREATE INDEX IF NOT EXISTS idx_txn_currency ON "Transaction"(Currency);
CREATE INDEX IF NOT EXISTS idx_ticket_event ON TicketPricing(EventID);
CREATE INDEX IF NOT EXISTS idx_event_company ON Event(CompanyID);
CREATE INDEX IF NOT EXISTS idx_link_ticket  ON Flight_Payment_Link(TicketID);
CREATE INDEX IF NOT EXISTS idx_link_txn     ON Flight_Payment_Link(TransactionID);
