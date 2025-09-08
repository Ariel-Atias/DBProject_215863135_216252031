CREATE TABLE Customer
(
  CustomerID INT NOT NULL,
  Name VARCHAR(50) NOT NULL,
  Email VARCHAR(100) NOT NULL,
  MinimalDetails VARCHAR(255) NOT NULL,
  DateCreated DATE NOT NULL,
  PRIMARY KEY (CustomerID)
);

CREATE TABLE Merchant
(
  MerchantID INT NOT NULL,
  MerchantName VARCHAR(100) NOT NULL,
  Address VARCHAR(255) NOT NULL,
  PRIMARY KEY (MerchantID)
);

CREATE TABLE ClearingHouse
(
  ClearingHouseID INT NOT NULL,
  Name VARCHAR(100) NOT NULL,
  NetworkType VARCHAR(50) NOT NULL,
  PRIMARY KEY (ClearingHouseID)
);

CREATE TABLE Account
(
  AccountID INT NOT NULL,
  BankName VARCHAR(100) NOT NULL,
  AccountNumber VARCHAR(50) NOT NULL,
  AccountType VARCHAR(50) NOT NULL,
  ClearingHouseID INT NOT NULL,
  PRIMARY KEY (AccountID),
  FOREIGN KEY (ClearingHouseID) REFERENCES ClearingHouse(ClearingHouseID)
);

CREATE TABLE PaymentMethod
(
  PaymentMethodID INT NOT NULL,
  Type VARCHAR(255) NOT NULL,
  Description VARCHAR(255) NOT NULL,
  AccountID INT NOT NULL,
  PRIMARY KEY (PaymentMethodID),
  FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
);

CREATE TABLE Transaction
(
  TransactionID INT NOT NULL,
  Amount INT NOT NULL,
  Currency VARCHAR(10) NOT NULL,
  Status VARCHAR(50) NOT NULL,
  TransactionDate DATE NOT NULL,
  SettlementDate DATE NOT NULL,
  CustomerID INT NOT NULL,
  MerchantID INT NOT NULL,
  PaymentMethodID INT NOT NULL,
  PRIMARY KEY (TransactionID),
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
  FOREIGN KEY (MerchantID) REFERENCES Merchant(MerchantID),
  FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethod(PaymentMethodID)
);