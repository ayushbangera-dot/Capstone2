CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.riders;
CREATE TABLE silver.riders AS
SELECT
    rider_id,
    rider_name,
    city,
    signup_date,
    rating
FROM bronze.riders
WHERE rider_id IS NOT NULL;
