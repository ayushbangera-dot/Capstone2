DROP TABLE IF EXISTS silver.rides;
CREATE TABLE silver.rides AS
SELECT *
FROM bronze.rides
WHERE ride_id IS NOT NULL;
