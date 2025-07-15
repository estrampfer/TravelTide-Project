WITH
-- CTE 1: Get the latest session date
max_session AS (
  SELECT MAX(session_start) AS max_date
  FROM sessions
),

-- CTE 2: Filter sessions within one year of the latest session
filtered_sessions AS (
  SELECT s.*
  FROM sessions s
  CROSS JOIN max_session m
  WHERE s.session_start BETWEEN m.max_date - INTERVAL '1 year' AND m.max_date
),

-- CTE 3: Select users with more than 7 sessions
user_session_counts AS (
  SELECT user_id, COUNT(*) AS session_count
  FROM filtered_sessions
  GROUP BY user_id
  HAVING COUNT(*) > 7
),

-- CTE 4: Keep only sessions from those users
cohort_2 AS (
  SELECT fs.*
  FROM filtered_sessions fs
  JOIN user_session_counts uc ON fs.user_id = uc.user_id
),

-- CTE 5: Identify canceled trips
canceled_trips AS (
  SELECT DISTINCT trip_id
  FROM cohort_2
  WHERE cancellation = TRUE
),

-- CTE 6: Enriched user-session-travel table
Cohort_TravelTide AS (
  SELECT
    c.session_id,
    c.user_id,
    c.trip_id,
    c.session_start,
    c.session_end,
    EXTRACT(EPOCH FROM (c.session_end - c.session_start)) / 60 AS session_duration_minutes,

    CASE
      WHEN c.flight_booked = TRUE AND f.return_flight_booked = TRUE THEN 2
      WHEN c.flight_booked = TRUE OR f.return_flight_booked = TRUE THEN 1
      ELSE 0
    END AS flights_booked_count,

    CASE WHEN ct.trip_id IS NOT NULL THEN NULL ELSE c.flight_discount_amount END AS flight_discount_amount,
    CASE WHEN ct.trip_id IS NOT NULL THEN NULL ELSE c.hotel_discount_amount END AS hotel_discount_amount,
    c.page_clicks,

    CASE WHEN ct.trip_id IS NOT NULL THEN c.trip_id ELSE NULL END AS canceled_trip_id,
    CASE WHEN ct.trip_id IS NULL     THEN c.trip_id ELSE NULL END AS valid_trip_id,
    CASE WHEN ct.trip_id IS NOT NULL THEN NULL ELSE f.checked_bags END AS checked_bags,
    CASE WHEN ct.trip_id IS NOT NULL THEN NULL ELSE f.seats END AS seats,

    CASE WHEN ct.trip_id IS NOT NULL THEN NULL ELSE
         public.haversine_distance(
           f.destination_airport_lat,
           f.destination_airport_lon,
           u.home_airport_lat,
           u.home_airport_lon
         )
    END AS distance_km,

    CASE WHEN ct.trip_id IS NOT NULL THEN NULL ELSE
         (CASE WHEN h.nights < 0 THEN ABS(h.nights) ELSE h.nights END) * h.rooms * h.hotel_per_room_usd
    END AS total_hotel_spend,

    CASE WHEN ct.trip_id IS NOT NULL THEN NULL ELSE
         c.hotel_discount_amount * ((CASE WHEN h.nights < 0 THEN ABS(h.nights) ELSE h.nights END) * h.rooms * h.hotel_per_room_usd)
    END AS hotel_spend_discount,

    CASE WHEN ct.trip_id IS NOT NULL THEN NULL ELSE
      (CASE
        WHEN c.flight_booked = TRUE AND f.return_flight_booked = TRUE THEN 2
        WHEN c.flight_booked = TRUE OR f.return_flight_booked = TRUE THEN 1
        ELSE 0
      END) * f.base_fare_usd
    END AS flight_spend,

    CASE WHEN ct.trip_id IS NOT NULL THEN NULL ELSE
      ((CASE
        WHEN c.flight_booked = TRUE AND f.return_flight_booked = TRUE THEN 2
        WHEN c.flight_booked = TRUE OR f.return_flight_booked = TRUE THEN 1
        ELSE 0
      END) * f.base_fare_usd) * c.flight_discount_amount
    END AS flight_spend_discount,

    CASE WHEN ct.trip_id IS NOT NULL THEN NULL ELSE
      EXTRACT(EPOCH FROM (f.return_time - f.departure_time)) / 3600
    END AS trip_duration_hours,

    -- User demographics
    u.birthdate,
    DATE_PART('year', AGE(DATE '2025-07-11', u.birthdate)) AS user_age,
    DATE_PART('year', AGE(DATE '2025-07-11', u.sign_up_date)) AS user_tenure_years,
    u.gender,
    u.married,
    u.has_children,
    u.home_country,
    u.home_city,
    u.home_airport,
    u.sign_up_date

  FROM cohort_2 c
  JOIN users u ON c.user_id = u.user_id
  LEFT JOIN flights f ON c.trip_id = f.trip_id
  LEFT JOIN hotels h ON c.trip_id = h.trip_id
  LEFT JOIN canceled_trips ct ON c.trip_id = ct.trip_id
),

-- CTE 7: Aggregate at user level
User_Aggregates AS (
  SELECT
    user_id,
    COUNT(DISTINCT session_id) AS num_of_sessions,
    SUM(page_clicks) AS total_page_clicks,
    COUNT(DISTINCT trip_id) AS num_of_trips,
    AVG(session_duration_minutes) AS avg_session_duration_min,
    AVG(checked_bags) AS avg_checked_bags,
    AVG(seats) AS avg_seats,
    COUNT(DISTINCT canceled_trip_id) AS num_of_canceled_trips,
    COUNT(DISTINCT valid_trip_id) AS num_of_valid_trips,
    SUM(flights_booked_count) AS total_flights_booked,
    AVG(distance_km) AS avg_distance_km,
    SUM(total_hotel_spend) AS total_hotel_spend,
    SUM(hotel_spend_discount) AS total_hotel_discount,
    SUM(flight_spend) AS total_flight_spend,
    SUM(flight_spend_discount) AS total_flight_spend_discount,
    AVG(trip_duration_hours) AS avg_trip_duration_hours,

    MIN(birthdate) AS birthdate,
    MIN(user_age) AS user_age,
    MIN(user_tenure_years) AS user_tenure_years,
    MIN(gender) AS gender,
    BOOL_OR(married) AS married,
    BOOL_OR(has_children) AS has_children,
    MIN(home_country) AS home_country,
    MIN(home_city) AS home_city,
    MIN(home_airport) AS home_airport

  FROM Cohort_TravelTide
  GROUP BY user_id
),

-- CTE 8: User Segmentation
User_Segmentation AS (
  SELECT *,
    CASE
      WHEN num_of_valid_trips = 0 AND avg_session_duration_min <= 1 THEN 'Just Looking'
      WHEN num_of_valid_trips = 0 AND avg_session_duration_min > 1 THEN 'Visitors with High Potential'
      WHEN num_of_valid_trips >= 1 AND user_age < 30 THEN 'Young Travelers'
      WHEN num_of_valid_trips >= 1 AND user_age >= 30 AND avg_trip_duration_hours <= (24*3) THEN 'Business Traveler'
      WHEN num_of_valid_trips >= 1 AND user_age >= 30 AND avg_trip_duration_hours >= (24*3) AND has_children = FALSE THEN 'Adult Explorer'
      WHEN num_of_valid_trips >= 1 AND user_age >= 30 AND avg_trip_duration_hours >= (24*3) AND has_children = TRUE THEN 'Family Traveler'
      WHEN num_of_valid_trips >= 1 AND user_age >= 30 AND avg_trip_duration_hours IS NULL THEN 'Hotels Only'
      ELSE 'Others'
    END AS user_perk
  FROM User_Aggregates
),

-- CTE 9: Perk Assignment
User_Perks AS (
  SELECT *,
    CASE
      WHEN user_perk = 'Young Travelers' THEN 'free check bag'
      WHEN user_perk = 'Business Traveler' THEN 'no cancellation fees'
      WHEN user_perk = 'Adult Explorer' THEN 'exclusive discounts & free check bag'
      WHEN user_perk = 'Family Traveler' THEN '1 night free hotel with flight'
      WHEN user_perk = 'Hotels Only' THEN 'free hotel meal'
      WHEN user_perk = 'Visitors with High Potential' THEN 'free hotel meal'
      WHEN user_perk = 'Just Looking' THEN 'free hotel meal'
      ELSE 'no perk'
    END AS assigned_perk
  FROM User_Segmentation
)

-- Final result
SELECT *
FROM User_Perks;
