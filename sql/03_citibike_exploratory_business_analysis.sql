# ============================================================================
# CITI BIKE OPERATIONAL ANALYTICS
# PHASE 5: EXPLORATORY BUSINESS ANALYSIS
# DATA PERIOD: MAY 2026
#
# This script examines demand patterns, rider and bike usage, ride duration,
# station activity, and directional station flow. Departure metrics use rides
# that started in May, while arrival metrics use rides that ended in May.
#
# Station flow is a trip-based rebalancing proxy. The data does not contain
# dock capacity, live inventory, outages, or bikes moved by operations teams.
# ============================================================================

USE citibike;


# ----------------------------------------------------------------------------
# STEP 1: ESTABLISH KPI BASELINES
# ----------------------------------------------------------------------------
# Establish the control totals and category shares used throughout the analysis.

# 1. How many rides are represented in the clean table?

SELECT COUNT(*) AS total_records
FROM citibike_trips_clean
;
# Result: 4,674,903 records are represented in the clean table.


# 2. How many rides started during May?

SELECT COUNT(*) AS may_departures
FROM citibike_trips_clean
WHERE starts_in_may = 1
;
# Result: 4,674,425 rides started in May.


# 3. How many rides ended during May?

SELECT COUNT(*) AS may_arrivals
FROM citibike_trips_clean
WHERE ends_in_may = 1
;
# Result: 4,674,903 rides ended in May.


# 4. What share of trips were member versus casual?

SELECT
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM citibike_trips_clean),
        2
    ) AS ride_percentage
FROM citibike_trips_clean
GROUP BY member_casual
ORDER BY total_rides DESC
;
# Result: 3,820,708 member rides (81.73%) and 854,195 casual rides
# (18.27%) are represented in the May release.


# 5. What share used electric versus classic bikes?

SELECT
    rideable_type,
    COUNT(*) AS total_rides,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM citibike_trips_clean),
        2
    ) AS ride_percentage
FROM citibike_trips_clean
GROUP BY rideable_type
ORDER BY total_rides DESC
;
# Result: 3,371,041 rides used electric bikes (72.11%) and 1,303,862
# used classic bikes (27.89%).


# 6. How many stations appear as departure and arrival locations?

SELECT
    COUNT(DISTINCT CASE
        WHEN starts_in_may = 1 THEN start_station_id
    END) AS unique_departure_stations,
    COUNT(DISTINCT CASE
        WHEN ends_in_may = 1 THEN end_station_id
    END) AS unique_arrival_stations
FROM citibike_trips_clean
;
# Result: 2,231 unique departure stations and 2,231 unique arrival stations.


# ----------------------------------------------------------------------------
# STEP 2: ANALYZE DEMAND BY DATE AND DAY OF WEEK
# ----------------------------------------------------------------------------
# Compare daily volume and normalize weekday/weekend totals by the number of
# calendar days so groups with more dates do not appear stronger by default.

# Daily departures by rider and bike type.

SELECT
    start_date,
    COUNT(*) AS total_departures,
    SUM(member_casual = 'member') AS member_departures,
    SUM(member_casual = 'casual') AS casual_departures,
    SUM(rideable_type = 'electric_bike') AS electric_bike_departures,
    SUM(rideable_type = 'classic_bike') AS classic_bike_departures
FROM citibike_trips_clean
WHERE starts_in_may = 1
GROUP BY start_date
ORDER BY start_date
;
# Result: May 29 was the busiest date with 190,977 departures. May 24 was
# the slowest date with 42,423 departures.


# Demand by day of week. Average daily departures controls for the fact that
# May 2026 does not contain the same number of every weekday.

SELECT
    start_day_of_week,
    start_day_name,
    COUNT(DISTINCT start_date) AS number_of_days,
    COUNT(*) AS total_departures,
    ROUND(
        COUNT(*) * 1.0 / COUNT(DISTINCT start_date),
        2
    ) AS average_daily_departures
FROM citibike_trips_clean
WHERE starts_in_may = 1
GROUP BY
    start_day_of_week,
    start_day_name
ORDER BY start_day_of_week
;


# Weekday versus weekend demand.

SELECT
    CASE
        WHEN start_is_weekend = 1 THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(DISTINCT start_date) AS number_of_days,
    COUNT(*) AS total_departures,
    ROUND(
        COUNT(*) * 1.0 / COUNT(DISTINCT start_date),
        2
    ) AS average_daily_departures
FROM citibike_trips_clean
WHERE starts_in_may = 1
GROUP BY start_is_weekend
ORDER BY start_is_weekend
;
# Result: Weekdays averaged 162,501.48 departures, compared with 126,189.40
# on weekends. Average weekend demand was 22.35% lower than weekday demand.


# ----------------------------------------------------------------------------
# STEP 3: ANALYZE HOURLY DEMAND PATTERNS
# ----------------------------------------------------------------------------
# Identify overall peak hours, then separate weekday and weekend patterns to
# avoid combining commute-oriented and discretionary travel behavior.

# Overall demand by hour.

SELECT
    start_hour,
    COUNT(*) AS total_departures,
    ROUND(
        COUNT(*) * 100.0 /
        (
            SELECT COUNT(*)
            FROM citibike_trips_clean
            WHERE starts_in_may = 1
        ),
        2
    ) AS hourly_percentage
FROM citibike_trips_clean
WHERE starts_in_may = 1
GROUP BY start_hour
ORDER BY start_hour
;
# Result: 5 p.m. was the busiest hour with 440,657 departures (9.43%).
# The 5-7 p.m. period accounted for 855,327 departures (18.30%).


# Hourly weekday versus weekend demand.

SELECT
    start_hour,
    CASE
        WHEN start_is_weekend = 1 THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(DISTINCT start_date) AS number_of_days,
    COUNT(*) AS total_departures,
    ROUND(
        COUNT(*) * 1.0 / COUNT(DISTINCT start_date),
        2
    ) AS average_daily_departures
FROM citibike_trips_clean
WHERE starts_in_may = 1
GROUP BY
    start_hour,
    start_is_weekend
ORDER BY
    start_hour,
    start_is_weekend
;
# Result: Weekday demand peaked at 5 p.m., with a smaller peak at 8 a.m.
# Weekend demand was distributed more broadly across midday and afternoon.


# ----------------------------------------------------------------------------
# STEP 4: COMPARE MEMBER AND CASUAL RIDER DEMAND
# ----------------------------------------------------------------------------
# Compare category shares and average daily volume by day type, then measure
# how each rider group's own demand is distributed across the day.

# Rider demand by weekday and weekend.

SELECT
    CASE
        WHEN start_is_weekend = 1 THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(DISTINCT start_date) AS number_of_days,
    COUNT(*) AS total_departures,
    SUM(member_casual = 'member') AS member_departures,
    SUM(member_casual = 'casual') AS casual_departures,
    ROUND(
        SUM(member_casual = 'member') * 100.0 / COUNT(*),
        2
    ) AS member_percentage,
    ROUND(
        SUM(member_casual = 'casual') * 100.0 / COUNT(*),
        2
    ) AS casual_percentage,
    ROUND(
        SUM(member_casual = 'member') * 1.0 /
        COUNT(DISTINCT start_date),
        2
    ) AS average_daily_member_departures,
    ROUND(
        SUM(member_casual = 'casual') * 1.0 /
        COUNT(DISTINCT start_date),
        2
    ) AS average_daily_casual_departures
FROM citibike_trips_clean
WHERE starts_in_may = 1
GROUP BY start_is_weekend
ORDER BY start_is_weekend
;


# Hourly distribution within each rider category. Each percentage uses that
# rider category's May total rather than the combined rider population.

SELECT
    start_hour,
    SUM(member_casual = 'member') AS member_departures,
    ROUND(
        SUM(member_casual = 'member') * 100.0 /
        (
            SELECT COUNT(*)
            FROM citibike_trips_clean
            WHERE starts_in_may = 1
              AND member_casual = 'member'
        ),
        2
    ) AS member_hourly_percentage,
    SUM(member_casual = 'casual') AS casual_departures,
    ROUND(
        SUM(member_casual = 'casual') * 100.0 /
        (
            SELECT COUNT(*)
            FROM citibike_trips_clean
            WHERE starts_in_may = 1
              AND member_casual = 'casual'
        ),
        2
    ) AS casual_hourly_percentage
FROM citibike_trips_clean
WHERE starts_in_may = 1
GROUP BY start_hour
ORDER BY start_hour
;


# ----------------------------------------------------------------------------
# STEP 5: COMPARE ELECTRIC AND CLASSIC BIKE USAGE
# ----------------------------------------------------------------------------
# Determine whether bike selection differs by rider category and whether the
# two bike types follow different hourly usage patterns.

# Bike preference within each rider category.

SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS total_departures,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY member_casual),
        2
    ) AS percentage_within_rider_type
FROM citibike_trips_clean
WHERE starts_in_may = 1
GROUP BY
    member_casual,
    rideable_type
ORDER BY
    member_casual,
    total_departures DESC
;


# Hourly distribution within each bike type.

SELECT
    start_hour,
    SUM(rideable_type = 'electric_bike') AS electric_bike_departures,
    ROUND(
        SUM(rideable_type = 'electric_bike') * 100.0 /
        (
            SELECT COUNT(*)
            FROM citibike_trips_clean
            WHERE starts_in_may = 1
              AND rideable_type = 'electric_bike'
        ),
        2
    ) AS electric_hourly_percentage,
    SUM(rideable_type = 'classic_bike') AS classic_bike_departures,
    ROUND(
        SUM(rideable_type = 'classic_bike') * 100.0 /
        (
            SELECT COUNT(*)
            FROM citibike_trips_clean
            WHERE starts_in_may = 1
              AND rideable_type = 'classic_bike'
        ),
        2
    ) AS classic_hourly_percentage
FROM citibike_trips_clean
WHERE starts_in_may = 1
GROUP BY start_hour
ORDER BY start_hour
;


# ----------------------------------------------------------------------------
# STEP 6: ANALYZE RIDE DURATION
# ----------------------------------------------------------------------------
# Report duration with and without rides over 24 hours. This sensitivity check
# prevents a small group of extreme rides from silently distorting averages.

# Overall duration profile.

SELECT
    COUNT(*) AS total_departures,
    ROUND(AVG(duration_minutes), 2) AS average_minutes_all_rides,
    ROUND(
        AVG(CASE
            WHEN is_over_24_hours = 0 THEN duration_minutes
        END),
        2
    ) AS average_minutes_excluding_over_24_hours,
    MIN(duration_minutes) AS minimum_minutes,
    MAX(duration_minutes) AS maximum_minutes,
    SUM(is_over_24_hours = 1) AS rides_over_24_hours
FROM citibike_trips_clean
WHERE starts_in_may = 1
  AND is_valid_duration = 1
;


# Duration by rider and bike type.

SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS total_departures,
    ROUND(AVG(duration_minutes), 2) AS average_minutes_all_rides,
    ROUND(
        AVG(CASE
            WHEN is_over_24_hours = 0 THEN duration_minutes
        END),
        2
    ) AS average_minutes_excluding_over_24_hours,
    SUM(is_over_24_hours = 1) AS rides_over_24_hours
FROM citibike_trips_clean
WHERE starts_in_may = 1
  AND is_valid_duration = 1
GROUP BY
    member_casual,
    rideable_type
ORDER BY
    member_casual,
    rideable_type
;


# Distribution across practical duration bands. Rides over 24 hours are shown
# as a separate exception category rather than mixed into the 60+ minute band.

SELECT
    CASE
        WHEN is_over_24_hours = 1 THEN 'Over 24 hours'
        WHEN duration_minutes < 5 THEN 'Under 5 minutes'
        WHEN duration_minutes < 15 THEN '5-14 minutes'
        WHEN duration_minutes < 30 THEN '15-29 minutes'
        WHEN duration_minutes < 60 THEN '30-59 minutes'
        ELSE '60 minutes-24 hours'
    END AS duration_band,
    COUNT(*) AS total_departures,
    ROUND(
        COUNT(*) * 100.0 /
        (
            SELECT COUNT(*)
            FROM citibike_trips_clean
            WHERE starts_in_may = 1
              AND is_valid_duration = 1
        ),
        2
    ) AS departure_percentage
FROM citibike_trips_clean
WHERE starts_in_may = 1
  AND is_valid_duration = 1
GROUP BY duration_band
ORDER BY MIN(duration_minutes)
;


# ----------------------------------------------------------------------------
# STEP 7: RANK STATIONS BY DEPARTURES, ARRIVALS, AND ACTIVITY
# ----------------------------------------------------------------------------
# Rank stations from each operational perspective. Departure and arrival
# rankings use their respective reporting-period flags.

# Top 20 departure stations.

SELECT
    start_station_id AS station_id,
    MAX(start_station_name) AS station_name,
    COUNT(*) AS total_departures
FROM citibike_trips_clean
WHERE starts_in_may = 1
GROUP BY start_station_id
ORDER BY total_departures DESC
LIMIT 20
;


# Top 20 arrival stations.

SELECT
    end_station_id AS station_id,
    MAX(end_station_name) AS station_name,
    COUNT(*) AS total_arrivals
FROM citibike_trips_clean
WHERE ends_in_may = 1
GROUP BY end_station_id
ORDER BY total_arrivals DESC
LIMIT 20
;


# Top 20 stations by combined activity.

WITH station_events AS (
    SELECT
        start_station_id AS station_id,
        start_station_name AS station_name,
        1 AS departures,
        0 AS arrivals
    FROM citibike_trips_clean
    WHERE starts_in_may = 1

    UNION ALL

    SELECT
        end_station_id AS station_id,
        end_station_name AS station_name,
        0 AS departures,
        1 AS arrivals
    FROM citibike_trips_clean
    WHERE ends_in_may = 1
)
SELECT
    station_id,
    MAX(station_name) AS station_name,
    SUM(departures) AS total_departures,
    SUM(arrivals) AS total_arrivals,
    COUNT(*) AS total_activity
FROM station_events
GROUP BY station_id
ORDER BY total_activity DESC
LIMIT 20
;


# ----------------------------------------------------------------------------
# STEP 8: MEASURE STATION FLOW AND POTENTIAL IMBALANCE
# ----------------------------------------------------------------------------
# Net flow equals arrivals minus departures. Positive values indicate net
# inflow; negative values indicate net outflow. This is a prioritization proxy,
# not proof that a station became full or empty.

WITH station_events AS (
    SELECT
        start_station_id AS station_id,
        start_station_name AS station_name,
        1 AS departures,
        0 AS arrivals
    FROM citibike_trips_clean
    WHERE starts_in_may = 1

    UNION ALL

    SELECT
        end_station_id AS station_id,
        end_station_name AS station_name,
        0 AS departures,
        1 AS arrivals
    FROM citibike_trips_clean
    WHERE ends_in_may = 1
),
station_flow AS (
    SELECT
        station_id,
        MAX(station_name) AS station_name,
        SUM(departures) AS total_departures,
        SUM(arrivals) AS total_arrivals,
        COUNT(*) AS total_activity,
        SUM(arrivals) - SUM(departures) AS net_flow
    FROM station_events
    GROUP BY station_id
)
SELECT
    station_id,
    station_name,
    total_departures,
    total_arrivals,
    total_activity,
    net_flow,
    ABS(net_flow) AS absolute_imbalance,
    ROUND(ABS(net_flow) * 100.0 / total_activity, 2) AS imbalance_rate,
    CASE
        WHEN net_flow > 0 THEN 'Net inflow'
        WHEN net_flow < 0 THEN 'Net outflow'
        ELSE 'Balanced'
    END AS flow_direction
FROM station_flow
WHERE total_activity >= 1000
ORDER BY absolute_imbalance DESC
LIMIT 50
;


# ----------------------------------------------------------------------------
# STEP 9: IDENTIFY PRIORITY STATION-HOUR COMBINATIONS
# ----------------------------------------------------------------------------
# Compare departures and arrivals within each station-hour combination. The
# minimum-activity filter keeps very small differences from outranking locations
# with material operational volume.

WITH station_hour_events AS (
    SELECT
        start_station_id AS station_id,
        start_station_name AS station_name,
        start_hour AS event_hour,
        1 AS departures,
        0 AS arrivals
    FROM citibike_trips_clean
    WHERE starts_in_may = 1

    UNION ALL

    SELECT
        end_station_id AS station_id,
        end_station_name AS station_name,
        end_hour AS event_hour,
        0 AS departures,
        1 AS arrivals
    FROM citibike_trips_clean
    WHERE ends_in_may = 1
),
station_hour_flow AS (
    SELECT
        station_id,
        MAX(station_name) AS station_name,
        event_hour,
        SUM(departures) AS total_departures,
        SUM(arrivals) AS total_arrivals,
        COUNT(*) AS total_activity,
        SUM(arrivals) - SUM(departures) AS net_flow
    FROM station_hour_events
    GROUP BY
        station_id,
        event_hour
)
SELECT
    station_id,
    station_name,
    event_hour,
    total_departures,
    total_arrivals,
    total_activity,
    net_flow,
    ABS(net_flow) AS absolute_imbalance,
    ROUND(ABS(net_flow) * 100.0 / total_activity, 2) AS imbalance_rate,
    CASE
        WHEN net_flow > 0 THEN 'Potential bike accumulation'
        WHEN net_flow < 0 THEN 'Potential bike depletion'
        ELSE 'Balanced flow'
    END AS operational_signal
FROM station_hour_flow
WHERE total_activity >= 500
ORDER BY absolute_imbalance DESC
LIMIT 50
;


# ----------------------------------------------------------------------------
# STEP 10: RUN THE FINAL ANALYSIS QUALITY GATE
# ----------------------------------------------------------------------------
# Confirm that the principal analytical groupings reconcile to the established
# May departure and arrival totals. Every difference must equal zero.

SELECT
    (SELECT COUNT(*)
     FROM citibike_trips_clean
     WHERE starts_in_may = 1) AS may_departures,

    (SELECT SUM(daily_departures)
     FROM (
         SELECT COUNT(*) AS daily_departures
         FROM citibike_trips_clean
         WHERE starts_in_may = 1
         GROUP BY start_date
     ) AS daily_totals) AS departures_from_daily_analysis,

    (SELECT SUM(hourly_departures)
     FROM (
         SELECT COUNT(*) AS hourly_departures
         FROM citibike_trips_clean
         WHERE starts_in_may = 1
         GROUP BY start_hour
     ) AS hourly_totals) AS departures_from_hourly_analysis,

    (SELECT SUM(rider_departures)
     FROM (
         SELECT COUNT(*) AS rider_departures
         FROM citibike_trips_clean
         WHERE starts_in_may = 1
         GROUP BY member_casual
     ) AS rider_totals) AS departures_from_rider_analysis,

    (SELECT SUM(bike_departures)
     FROM (
         SELECT COUNT(*) AS bike_departures
         FROM citibike_trips_clean
         WHERE starts_in_may = 1
         GROUP BY rideable_type
     ) AS bike_totals) AS departures_from_bike_analysis,

    (SELECT COUNT(*)
     FROM citibike_trips_clean
     WHERE ends_in_may = 1) AS may_arrivals
;


# Final PASS/FAIL result.

SELECT
    CASE
        WHEN
            (SELECT COUNT(*)
             FROM citibike_trips_clean
             WHERE starts_in_may = 1) = 4674425
        AND
            (SELECT COUNT(*)
             FROM citibike_trips_clean
             WHERE ends_in_may = 1) = 4674903
        AND
            (SELECT COUNT(DISTINCT start_hour)
             FROM citibike_trips_clean
             WHERE starts_in_may = 1) = 24
        AND
            (SELECT COUNT(DISTINCT start_date)
             FROM citibike_trips_clean
             WHERE starts_in_may = 1) = 31
        AND
            (SELECT COUNT(*)
             FROM citibike_trips_clean
             WHERE starts_in_may = 1
               AND is_valid_duration <> 1) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS analysis_quality_gate
;
