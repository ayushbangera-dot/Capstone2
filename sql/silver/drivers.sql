DROP TABLE IF EXISTS silver.drivers;
CREATE TABLE silver.drivers AS
SELECT
    driver_id,
    driver_name,
    city,
    join_date,
    driver_rating,
    is_active
FROM bronze.drivers
WHERE driver_id IS NOT NULL;
