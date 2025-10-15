-- =====================================
-- OPTIMIZED INDEXES FOR PERFORMANCE TEST
-- =====================================

-- INDEX 1: Optimize Query 2 (Pending transactions + filter + sort)
-- Reason: Query filters by Status='Pending' and sorts by TransactionDate.
-- Partial index limits data to relevant rows only.
CREATE INDEX idx_transaction_pending_date 
ON Transaction(TransactionDate DESC)
WHERE Status = 'Pending';

-- INDEX 2: Optimize Query 1 (Merchant transactions aggregation)
-- Reason: Query groups by MerchantID and uses SUM/COUNT, so indexing MerchantID in Transaction helps.
CREATE INDEX idx_transaction_merchantid 
ON Transaction(MerchantID);

-- INDEX 3: Optimize Query 3 (Account–ClearingHouse join)
-- Reason: Query joins by ClearingHouseID, so we index that foreign key.
CREATE INDEX idx_account_clearinghouseid 
ON Account(ClearingHouseID);