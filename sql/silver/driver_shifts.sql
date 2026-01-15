DROP TABLE IF EXISTS silver.driver_shifts;
CREATE TABLE silver.driver_shifts AS
SELECT *
FROM bronze.driver_shifts
WHERE shift_id IS NOT NULL;
