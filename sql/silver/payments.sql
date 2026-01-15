DROP TABLE IF EXISTS silver.payments;
CREATE TABLE silver.payments AS
SELECT *
FROM bronze.payments
WHERE payment_id IS NOT NULL;
