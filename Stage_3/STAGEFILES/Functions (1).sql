-- ===============================================
-- Stage 3 - Functions (PL/pgSQL)
-- If your table is "Transaction" (quoted), replace payment_transaction with "Transaction".
-- ===============================================

-- F1: Count all transactions
CREATE OR REPLACE FUNCTION fn_count_transactions()
RETURNS INT AS $$
DECLARE total_count INT;
BEGIN
  SELECT COUNT(*) INTO total_count FROM payment_transaction;
  RETURN total_count;
END;
$$ LANGUAGE plpgsql;

-- F2: Total amount of completed transactions
CREATE OR REPLACE FUNCTION fn_total_amount_completed()
RETURNS NUMERIC AS $$
DECLARE total NUMERIC;
BEGIN
  SELECT SUM(amount) INTO total
  FROM payment_transaction
  WHERE status = 'Completed';
  RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql;

-- F3: Unique customers who transacted
CREATE OR REPLACE FUNCTION fn_unique_customers()
RETURNS INT AS $$
DECLARE unique_count INT;
BEGIN
  SELECT COUNT(DISTINCT customerid) INTO unique_count
  FROM payment_transaction;
  RETURN unique_count;
END;
$$ LANGUAGE plpgsql;

-- F4: Total completed amount for a given customer
CREATE OR REPLACE FUNCTION fn_customer_total_completed(customer_id INT)
RETURNS NUMERIC AS $$
DECLARE total NUMERIC;
BEGIN
  SELECT SUM(amount) INTO total
  FROM payment_transaction
  WHERE customerid = fn_customer_total_completed.customer_id
    AND status = 'Completed';
  RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql;

-- Example calls (commented):
-- SELECT fn_count_transactions();
-- SELECT fn_total_amount_completed();
-- SELECT fn_unique_customers();
-- SELECT fn_customer_total_completed(101);
