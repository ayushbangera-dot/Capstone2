
DROP TABLE IF EXISTS gold.dashboard_rides;

CREATE TABLE gold.dashboard_rides AS
SELECT
    -- Ride identifiers
    r.ride_id,
    r.city,
    r.ride_status,
    r.request_time,
    r.start_time,
    r.end_time,

    -- Ride metrics
    r.ride_duration_min,
    r.distance_km,
    r.fare_amount,

    -- Rider info
    rd.rider_id,
    rd.rider_name,
    rd.rating AS rider_rating,

    -- Driver info
    d.driver_id,
    d.driver_name,
    d.driver_rating,
    d.is_active,

    -- Payment info
    p.payment_method,
    p.payment_status,
    p.amount AS payment_amount,

    -- Derived KPIs (VERY IMPORTANT)
    CASE
        WHEN r.ride_status = 'COMPLETED' THEN 1
        ELSE 0
    END AS is_completed_ride,

    CASE
        WHEN r.ride_status = 'CANCELLED' THEN 1
        ELSE 0
    END AS is_cancelled_ride,

    ROUND(
        r.fare_amount / NULLIF(r.distance_km, 0),
        2
    ) AS fare_per_km

FROM silver.rides r
LEFT JOIN silver.riders rd
    ON r.rider_id = rd.rider_id
LEFT JOIN silver.drivers d
    ON r.driver_id = d.driver_id
LEFT JOIN silver.payments p
    ON r.ride_id = p.ride_id;