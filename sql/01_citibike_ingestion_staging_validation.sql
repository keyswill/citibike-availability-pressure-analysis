# ============================================================================
# CITI BIKE OPERATIONAL ANALYTICS
# PHASE 1: DATA INGESTION, STAGING, AND VALIDATION
# DATA PERIOD: MAY 2026
#
# This script combines five imported trip tables into stg_citibike and checks
# whether the staged data is complete and reliable enough for analysis.
# Raw tables are preserved, source lineage is retained, and no records are
# cleaned or deleted in this phase.
#
# Expected staging total: 4,674,903 records
# ============================================================================

# ----------------------------------------------------------------------------
# STEP 1: REVIEW THE RAW IMPORT STRUCTURE
# ----------------------------------------------------------------------------
# Review the data types created by MySQL's Import Wizard. Timestamps arrived as TEXT, station IDs require categorical treatment, and ride ID uniqueness still needs to be tested.


DESCRIBE citibike.tripdata_1;


# ----------------------------------------------------------------------------
# STEP 2: CREATE THE CONSOLIDATED STAGING TABLE
# ----------------------------------------------------------------------------
# Create one monthly staging table while preserving the original imported values and the source of every row. Cleaning decisions are intentionally deferred.


CREATE TABLE stg_citibike (
    stg_row_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_table VARCHAR(20),
    ride_id TEXT,
    rideable_type TEXT,
    started_at TEXT,
    ended_at TEXT,
    start_station_name TEXT,
    start_station_id TEXT,
    end_station_name TEXT,
    end_station_id TEXT,
    start_lat DOUBLE,
    start_lng DOUBLE,
    end_lat DOUBLE,
    end_lng DOUBLE,
    member_casual TEXT
);


DESCRIBE stg_citibike;

# ----------------------------------------------------------------------------
# STEP 3: ESTABLISH SOURCE CONTROL TOTALS
# ----------------------------------------------------------------------------
# Count each imported table before consolidation. These totals provide the control figures used to confirm that no records are lost or added during staging.


SELECT SUM(row_count) AS total_source_records
FROM (
    SELECT COUNT(*) AS row_count FROM tripdata_1
    UNION ALL
    SELECT COUNT(*) FROM tripdata_2
    UNION ALL
    SELECT COUNT(*) FROM tripdata_3
    UNION ALL
    SELECT COUNT(*) FROM tripdata_4
    UNION ALL
    SELECT COUNT(*) FROM tripdata_5
) AS source_counts
;


# ----------------------------------------------------------------------------
# STEP 4: LOAD THE FIRST SOURCE TABLE
# ----------------------------------------------------------------------------
# Load tripdata_1 separately to confirm the column mapping and source-lineage field before appending the remaining files.


INSERT INTO stg_citibike (
    source_table,
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
)
SELECT
    'tripdata_1',
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
FROM tripdata_1
;


SELECT
    source_table,
    COUNT(*) AS rows_loaded
FROM stg_citibike
GROUP BY source_table
;


# ----------------------------------------------------------------------------
# STEP 5: APPEND THE REMAINING SOURCE TABLES
# ----------------------------------------------------------------------------
# Load tripdata_2 through tripdata_5 using the same explicit source-to-target mapping.

INSERT INTO stg_citibike (
    source_table,
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
)
SELECT
    'tripdata_2',
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
FROM tripdata_2
;

INSERT INTO stg_citibike (
    source_table,
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
)
SELECT
    'tripdata_3',
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
FROM tripdata_3
;

INSERT INTO stg_citibike (
    source_table,
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
)
SELECT
    'tripdata_4',
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
FROM tripdata_4
;

INSERT INTO stg_citibike (
    source_table,
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
)
SELECT
    'tripdata_5',
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
FROM tripdata_5
;

# ----------------------------------------------------------------------------
# STEP 6: RECONCILE THE COMPLETE STAGING LOAD
# ----------------------------------------------------------------------------
# Compare staged counts with the five source controls. Expected total: 4,674,903 records.

SELECT
    source_table,
    COUNT(*) AS rows_loaded
FROM stg_citibike
GROUP BY source_table
ORDER BY source_table
;

SELECT COUNT(*) AS total_staging_records
FROM stg_citibike;

# ----------------------------------------------------------------------------
# STEP 7: CHECK THE REPORTING PERIOD
# ----------------------------------------------------------------------------
# Confirm May 2026 coverage and investigate boundary records. The audit found 478 rides that started April 30 and ended May 1; they remain in staging for a documented reporting decision.

SELECT
    source_table,
    MIN(started_at) AS earliest_start,
    MAX(started_at) AS latest_start,
    MIN(ended_at) AS earliest_end,
    MAX(ended_at) AS latest_end
FROM stg_citibike
GROUP BY source_table
ORDER BY source_table
;

SELECT
    MIN(started_at) AS earliest_start,
    MAX(started_at) AS latest_start,
    MIN(ended_at) AS earliest_end,
    MAX(ended_at) AS latest_end
FROM stg_citibike
;



SELECT
    COUNT(*) AS april_start_count
FROM stg_citibike
WHERE started_at < '2026-05-01 00:00:00';

SELECT
    ride_id,
    started_at,
    ended_at,
    start_station_name,
    end_station_name,
    member_casual,
    source_table
FROM stg_citibike
WHERE started_at < '2026-05-01 00:00:00'
ORDER BY started_at
LIMIT 20
;

SELECT
    MIN(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS minimum_minutes,
    MAX(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS maximum_minutes,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS average_minutes
FROM stg_citibike
WHERE started_at < '2026-05-01 00:00:00'
;


# ----------------------------------------------------------------------------
# STEP 8: CHECK RIDE ID COMPLETENESS AND UNIQUENESS
# ----------------------------------------------------------------------------
# Each trip should have one unique ride_id. Missing or duplicate IDs would overstate demand and station activity.


SELECT
    COUNT(*) AS total_records,
    COUNT(ride_id) AS non_null_ride_ids,
    COUNT(DISTINCT ride_id) AS unique_ride_ids
FROM stg_citibike
;


SELECT
    ride_id,
    COUNT(*) AS occurrences
FROM stg_citibike
WHERE ride_id IS NOT NULL
GROUP BY ride_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20
;


# ----------------------------------------------------------------------------
# STEP 9: AUDIT MISSING VALUES AND PLACEHOLDERS
# ----------------------------------------------------------------------------
# Check for database NULLs, blank text, and numeric zeros because CSV imports can represent missing data in more than one way.


SELECT
    SUM(CASE WHEN ride_id IS NULL THEN 1 ELSE 0 END) AS missing_ride_id,
    SUM(CASE WHEN rideable_type IS NULL THEN 1 ELSE 0 END) AS missing_rideable_type,
    SUM(CASE WHEN started_at IS NULL THEN 1 ELSE 0 END) AS missing_started_at,
    SUM(CASE WHEN ended_at IS NULL THEN 1 ELSE 0 END) AS missing_ended_at,
    SUM(CASE WHEN start_station_name IS NULL THEN 1 ELSE 0 END) AS missing_start_station_name,
    SUM(CASE WHEN start_station_id IS NULL THEN 1 ELSE 0 END) AS missing_start_station_id,
    SUM(CASE WHEN end_station_name IS NULL THEN 1 ELSE 0 END) AS missing_end_station_name,
    SUM(CASE WHEN end_station_id IS NULL THEN 1 ELSE 0 END) AS missing_end_station_id,
    SUM(CASE WHEN start_lat IS NULL THEN 1 ELSE 0 END) AS missing_start_lat,
    SUM(CASE WHEN start_lng IS NULL THEN 1 ELSE 0 END) AS missing_start_lng,
    SUM(CASE WHEN end_lat IS NULL THEN 1 ELSE 0 END) AS missing_end_lat,
    SUM(CASE WHEN end_lng IS NULL THEN 1 ELSE 0 END) AS missing_end_lng,
    SUM(CASE WHEN member_casual IS NULL THEN 1 ELSE 0 END) AS missing_member_casual
FROM stg_citibike
;


SELECT
    SUM(CASE WHEN TRIM(ride_id) = '' THEN 1 ELSE 0 END) AS blank_ride_id,
    SUM(CASE WHEN TRIM(rideable_type) = '' THEN 1 ELSE 0 END) AS blank_rideable_type,
    SUM(CASE WHEN TRIM(started_at) = '' THEN 1 ELSE 0 END) AS blank_started_at,
    SUM(CASE WHEN TRIM(ended_at) = '' THEN 1 ELSE 0 END) AS blank_ended_at,
    SUM(CASE WHEN TRIM(start_station_name) = '' THEN 1 ELSE 0 END) AS blank_start_station_name,
    SUM(CASE WHEN TRIM(start_station_id) = '' THEN 1 ELSE 0 END) AS blank_start_station_id,
    SUM(CASE WHEN TRIM(end_station_name) = '' THEN 1 ELSE 0 END) AS blank_end_station_name,
    SUM(CASE WHEN TRIM(end_station_id) = '' THEN 1 ELSE 0 END) AS blank_end_station_id,
    SUM(CASE WHEN TRIM(member_casual) = '' THEN 1 ELSE 0 END) AS blank_member_casual
FROM stg_citibike
;


SELECT
    SUM(CASE WHEN start_station_id = '0' THEN 1 ELSE 0 END) AS zero_start_station_id,
    SUM(CASE WHEN end_station_id = '0' THEN 1 ELSE 0 END) AS zero_end_station_id,
    SUM(CASE WHEN start_lat = 0 THEN 1 ELSE 0 END) AS zero_start_lat,
    SUM(CASE WHEN start_lng = 0 THEN 1 ELSE 0 END) AS zero_start_lng,
    SUM(CASE WHEN end_lat = 0 THEN 1 ELSE 0 END) AS zero_end_lat,
    SUM(CASE WHEN end_lng = 0 THEN 1 ELSE 0 END) AS zero_end_lng
FROM stg_citibike
;


# ----------------------------------------------------------------------------
# STEP 10: CHECK RIDER AND BIKE CATEGORIES
# ----------------------------------------------------------------------------
# Confirm that rider and bike classifications use consistent values before comparing customer and fleet segments.



SELECT
    member_casual,
    COUNT(*) AS ride_count
FROM stg_citibike
GROUP BY member_casual
ORDER BY ride_count DESC
;


SELECT
    rideable_type,
    COUNT(*) AS ride_count
FROM stg_citibike
GROUP BY rideable_type
ORDER BY ride_count DESC
;


# ----------------------------------------------------------------------------
# STEP 11: CHECK TIMESTAMP ORDER AND EXTREME DURATIONS
# ----------------------------------------------------------------------------
# Identify impossible time sequences and unusually long rides. Twenty-two rides exceed 24 hours; they remain in staging and will be flagged for duration-sensitive analysis.


SELECT
    SUM(
        CASE
            WHEN ended_at < started_at THEN 1
            ELSE 0
        END
    ) AS ended_before_start,
    SUM(
        CASE
            WHEN ended_at = started_at THEN 1
            ELSE 0
        END
    ) AS same_start_and_end_time,
    MIN(TIMESTAMPDIFF(SECOND, started_at, ended_at)) AS minimum_duration_seconds,
    MAX(TIMESTAMPDIFF(SECOND, started_at, ended_at)) AS maximum_duration_seconds
FROM stg_citibike
;


SELECT
    COUNT(*) AS rides_over_24_hours
FROM stg_citibike
WHERE TIMESTAMPDIFF(SECOND, started_at, ended_at) > 86400
;


# ----------------------------------------------------------------------------
# STEP 12: CHECK GEOGRAPHIC PLAUSIBILITY
# ----------------------------------------------------------------------------
# Confirm that start and end coordinates fall within a reasonable Citi Bike service-area range before mapping the trips.


SELECT
    MIN(start_lat) AS minimum_start_latitude,
    MAX(start_lat) AS maximum_start_latitude,
    MIN(start_lng) AS minimum_start_longitude,
    MAX(start_lng) AS maximum_start_longitude,
    MIN(end_lat) AS minimum_end_latitude,
    MAX(end_lat) AS maximum_end_latitude,
    MIN(end_lng) AS minimum_end_longitude,
    MAX(end_lng) AS maximum_end_longitude
FROM stg_citibike
;


# ----------------------------------------------------------------------------
# STEP 13: CHECK STATION ID AND NAME CONSISTENCY
# ----------------------------------------------------------------------------
# Confirm that each station ID maps to one station name so station rankings are not split by inconsistent labels.


SELECT
    start_station_id,
    COUNT(DISTINCT start_station_name) AS number_of_station_names
FROM stg_citibike
GROUP BY start_station_id
HAVING COUNT(DISTINCT start_station_name) > 1
ORDER BY number_of_station_names DESC
;

 
 
 SELECT
    station_id,
    COUNT(DISTINCT station_name) AS number_of_station_names
FROM (
    SELECT
        start_station_id AS station_id,
        start_station_name AS station_name
    FROM stg_citibike
    UNION ALL
    SELECT
        end_station_id,
        end_station_name
    FROM stg_citibike
) AS all_stations
GROUP BY station_id
HAVING COUNT(DISTINCT station_name) > 1
ORDER BY number_of_station_names DESC
;


# ============================================================================
# PHASE 1 SUMMARY
# ============================================================================
# All five source tables reconciled to 4,674,903 staged records. The audit found
# no duplicate ride IDs, missing or blank values, zero placeholders, invalid
# timestamp order, implausible coordinates, unexpected categories, or
# inconsistent station mappings.
#
# Items carried forward:
# - Convert started_at and ended_at from TEXT in the cleaned table.
# - Keep station IDs as categorical text.
# - Apply a documented rule to 478 April-start/May-end rides.
# - Flag 22 rides over 24 hours when calculating duration metrics.
# ============================================================================
