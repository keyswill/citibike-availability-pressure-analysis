# ============================================================================
# PROJECT: Operational Analytics for Citi Bike
# PHASE 0: Data Ingestion, Staging, and Quality Validation
# DATA PERIOD: May 2026
# DATABASE PLATFORM: MySQL
#
# PURPOSE
# Consolidate five raw Citi Bike trip-data tables into one traceable staging
# table, then validate completeness, uniqueness, missingness, date coverage,
# categorical consistency, trip duration, geographic plausibility, and station
# mapping integrity before any cleaning or business analysis begins.
#
# CONTROL PRINCIPLE
# The five imported source tables are preserved as the raw-data layer. All
# validation is performed against stg_citibike, and no source records are
# updated or deleted in this phase. Findings are documented for later cleaning
# decisions rather than silently corrected in staging.
#
# EXPECTED CONSOLIDATED ROW COUNT: 4,674,903
# ============================================================================

# ----------------------------------------------------------------------------
# STEP 1: REVIEW THE RAW IMPORT STRUCTURE
# ----------------------------------------------------------------------------
# Objective: Inspect the structure inferred by the MySQL Table Data Import
# Wizard before designing the consolidated staging table.
#
# Business relevance: Incorrect data types can undermine downstream measures,
# including ride duration, station demand, and geographic utilization.
# Technical relevance: The raw import stores timestamps as TEXT and station IDs
# as DOUBLE. These limitations must be recognized before defining the staging
# schema and later corrected in a separate cleaned analytical table.

DESCRIBE citibike.tripdata_1;

# Observed raw-import limitations:
# 1. started_at and ended_at are TEXT rather than DATETIME.
# 2. Station IDs are DOUBLE even though identifiers are categorical attributes.
# 3. ride_id has no uniqueness constraint, so uniqueness must be validated.
# 4. The Import Wizard may represent missing CSV values as NULL, blank text, or
#    numeric zero; each representation is checked later in this script.

# ----------------------------------------------------------------------------
# STEP 2: CREATE THE CONSOLIDATED STAGING TABLE
# ----------------------------------------------------------------------------
# Objective: Create one complete monthly table while retaining source lineage.
#
# Design decisions:
# - stg_row_id supplies a database-generated surrogate key for each staged row.
# - source_table identifies the raw table from which each record originated.
# - ride_id remains unconstrained so duplicate records can be measured instead
#   of being rejected or hidden during ingestion.
# - Timestamp fields remain TEXT in staging to preserve the imported values;
#   datatype conversion belongs in the future cleaning phase.
# - Station IDs are stored as TEXT because they function as labels, not values
#   used in arithmetic.
# - Coordinates remain DOUBLE because they are continuous geographic measures.

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

# Confirm that the staging table was created with the intended columns, data
# types, nullability, primary key, and auto-increment behavior.

DESCRIBE stg_citibike;

# ----------------------------------------------------------------------------
# STEP 3: ESTABLISH THE SOURCE-TO-TARGET CONTROL TOTAL
# ----------------------------------------------------------------------------
# Objective: Calculate the combined number of raw records before consolidation.
# This total becomes the reconciliation benchmark for the staging load.
#
# UNION ALL is intentional: every source-table count must be retained. Using
# UNION could unnecessarily evaluate duplicate count values for removal.

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

# Recorded source counts:
# tripdata_1 =   992,819
# tripdata_2 =   998,471
# tripdata_3 =   995,417
# tripdata_4 =   994,151
# tripdata_5 =   694,045
# ------------------------------------------------
# Expected total = 4,674,903 records

# ----------------------------------------------------------------------------
# STEP 4: PERFORM A CONTROLLED FIRST-TABLE LOAD
# ----------------------------------------------------------------------------
# Objective: Load tripdata_1 independently before appending the remaining four
# tables. This controlled first load verifies column mapping and source-lineage
# logic before the entire monthly dataset is consolidated.
#
# stg_row_id is omitted from the INSERT column list because MySQL generates it
# automatically. The literal value 'tripdata_1' records row-level lineage.

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

# Reconcile the first staging load to its raw source count. Expected result:
# tripdata_1 = 992,819 rows.

SELECT
    source_table,
    COUNT(*) AS rows_loaded
FROM stg_citibike
GROUP BY source_table
;

# Validation result: 992,819 rows were loaded from tripdata_1, matching the
# source-table control count.

# ----------------------------------------------------------------------------
# STEP 5: APPEND THE REMAINING SOURCE TABLES
# ----------------------------------------------------------------------------
# Objective: Consolidate tripdata_2 through tripdata_5 using the same explicit
# source-to-target column mapping established in the controlled first load.
#
# Explicit column lists make the ETL logic auditable and reduce the risk of
# future schema-order changes placing values into the wrong destination fields.
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
# Objective: Confirm both file-level completeness and the overall control total.
# Expected result: each source_table count matches its raw table, and the final
# staging count equals 4,674,903 records.
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
# STEP 7: VALIDATE DATE COVERAGE
# ----------------------------------------------------------------------------
# Objective: Confirm that the consolidated files represent the expected May
# 2026 reporting period and identify boundary records outside that period.
#
# MIN and MAX are evaluated on TEXT values here. This comparison is dependable
# for the observed ISO-style YYYY-MM-DD timestamp format, but the fields should
# still be converted to DATETIME in the cleaned analytical table.
#
# The first query validates each source partition; the second establishes the
# overall reporting-period boundaries.
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

# Recorded overall range:
# - Earliest start: 2026-04-30 07:52:24.326
# - Latest start:   2026-05-31 23:58:10.888
# - Earliest end:   2026-05-01 00:00:02.682
# - Latest end:     2026-05-31 23:59:58.731
#
# Interpretation: The May files include a small number of rides that started on
# April 30 and ended in May. This suggests inclusion may be based on end time or
# provider file-assignment logic rather than strictly on May start timestamps.

# Quantify and inspect the reporting-boundary records. These queries diagnose
# the records only; they do not remove them from staging.

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

# Validation result:
# - 478 records started on April 30 and ended on May 1.
# - Minimum duration: 2 minutes.
# - Maximum duration: 1,439 minutes.
# - Average duration: approximately 47.87 minutes.
#
# Decision for staging: Retain all 478 records. The project must later define
# whether a "May trip" is based on start time or inclusion in Citi Bike's May
# release before applying any analytical-period filter.

# ----------------------------------------------------------------------------
# STEP 8: VALIDATE RIDE-ID COMPLETENESS AND UNIQUENESS
# ----------------------------------------------------------------------------
# Objective: Test the assumption that ride_id is a complete and unique natural
# identifier for individual trips.
#
# Business relevance: Duplicate ride IDs would inflate demand, rider-segment,
# station-volume, and utilization metrics.

SELECT
    COUNT(*) AS total_records,
    COUNT(ride_id) AS non_null_ride_ids,
    COUNT(DISTINCT ride_id) AS unique_ride_ids
FROM stg_citibike
;

# Validation result: total records, non-null ride IDs, and distinct ride IDs all
# equal 4,674,903. Every staged record has a ride ID and every ride ID is unique.

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

# The duplicate-detail query returned no rows, confirming that no non-null
# ride_id occurs more than once.

# ----------------------------------------------------------------------------
# STEP 9: AUDIT MISSING VALUES AND IMPORT PLACEHOLDERS
# ----------------------------------------------------------------------------
# Objective: Test three common representations of missing CSV data:
# 1. Database NULL values
# 2. Empty or whitespace-only text
# 3. Numeric zero placeholders
#
# Business relevance: Missing station or coordinate data can limit station-level
# demand analysis, route analysis, and Tableau mapping even when a trip remains
# usable for aggregate rider-volume reporting.

# 9A. Count database NULL values across every business field.
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

# Validation result: No database NULL values were detected in any audited field.

# 9B. Check text fields for empty strings and whitespace-only values. TRIM is
# used so values containing spaces are not incorrectly treated as complete.
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

# Validation result: No blank or whitespace-only values were detected in the
# audited text fields.

# 9C. Check station IDs and coordinates for zero placeholders. A coordinate of
# zero is geographically impossible for New York City and would indicate a
# missing or improperly imported value.
SELECT
    SUM(CASE WHEN start_station_id = '0' THEN 1 ELSE 0 END) AS zero_start_station_id,
    SUM(CASE WHEN end_station_id = '0' THEN 1 ELSE 0 END) AS zero_end_station_id,
    SUM(CASE WHEN start_lat = 0 THEN 1 ELSE 0 END) AS zero_start_lat,
    SUM(CASE WHEN start_lng = 0 THEN 1 ELSE 0 END) AS zero_start_lng,
    SUM(CASE WHEN end_lat = 0 THEN 1 ELSE 0 END) AS zero_end_lat,
    SUM(CASE WHEN end_lng = 0 THEN 1 ELSE 0 END) AS zero_end_lng
FROM stg_citibike
;

# Validation result: No zero-value station IDs or coordinates were detected.

# ----------------------------------------------------------------------------
# STEP 10: VALIDATE CATEGORICAL DOMAINS
# ----------------------------------------------------------------------------
# Objective: Confirm that customer and bike classifications use standardized,
# expected values. Inconsistent spelling or capitalization would split one
# business category into multiple groups and distort segment comparisons.

# Validate member_casual values and reconcile their counts to the table total.

SELECT
    member_casual,
    COUNT(*) AS ride_count
FROM stg_citibike
GROUP BY member_casual
ORDER BY ride_count DESC
;

# Validation result:
# - member = 3,820,708
# - casual =   854,195
# - total  = 4,674,903
# Both standardized rider categories account for the complete dataset.

SELECT
    rideable_type,
    COUNT(*) AS ride_count
FROM stg_citibike
GROUP BY rideable_type
ORDER BY ride_count DESC
;

# Validation result:
# - electric_bike = 3,371,041
# - classic_bike  = 1,303,862
# - total         = 4,674,903
# Both standardized bike categories account for the complete dataset.

# ----------------------------------------------------------------------------
# STEP 11: VALIDATE TIMESTAMP ORDER AND DURATION EXTREMES
# ----------------------------------------------------------------------------
# Objective: Identify impossible timestamp sequences, zero-duration rides, and
# the observed duration range before calculating operational duration metrics.
#
# Business relevance: Invalid or extreme durations can materially distort mean
# ride time and lead to incorrect conclusions about customer behavior or asset
# utilization. TIMESTAMPDIFF is used for validation only; staging values remain
# unchanged.

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

# Validation result:
# - Rides ending before start: 0
# - Rides with identical start and end timestamps: 0
# - Minimum duration: 60 seconds
# - Maximum duration: 89,528 seconds (approximately 24 hours, 52 minutes)
#
# The timestamp sequence passed validation. The maximum is treated as a quality
# exception for investigation rather than automatically classified as invalid.

# Quantify rides exceeding 24 hours (86,400 seconds).
SELECT
    COUNT(*) AS rides_over_24_hours
FROM stg_citibike
WHERE TIMESTAMPDIFF(SECOND, started_at, ended_at) > 86400
;

# Validation result: 22 rides exceed 24 hours, representing approximately
# 0.0005% of the dataset. The inspected records were narrowly above 24 hours,
# used classic bikes, and included both member and casual riders.
#
# Decision for staging: Retain these records. A later cleaning rule may flag or
# exclude them from duration-sensitive metrics, but silent deletion would erase
# potentially meaningful operational exceptions such as late returns, docking
# issues, or bikes kept out overnight.

# ----------------------------------------------------------------------------
# STEP 12: VALIDATE GEOGRAPHIC PLAUSIBILITY
# ----------------------------------------------------------------------------
# Objective: Confirm that start and end coordinates fall within a reasonable
# Citi Bike service-area range before geographic analysis and Tableau mapping.

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

# Validation result:
# - Latitude range:  40.61124 to 40.90972
# - Longitude range: -74.04079 to -73.84672
# - Start and end ranges match.
# All observed coordinates are plausible for the New York City service area.

# ----------------------------------------------------------------------------
# STEP 13: VALIDATE STATION-ID-TO-NAME CONSISTENCY
# ----------------------------------------------------------------------------
# Objective: Confirm that each station ID maps to one station name. Inconsistent
# mappings could fragment station rankings and weaken bike-rebalancing analysis.

# 13A. Test start-station mappings independently.
SELECT
    start_station_id,
    COUNT(DISTINCT start_station_name) AS number_of_station_names
FROM stg_citibike
GROUP BY start_station_id
HAVING COUNT(DISTINCT start_station_name) > 1
ORDER BY number_of_station_names DESC
;

# Validation result: No rows returned. Each start_station_id maps to exactly one
# start_station_name in the staged dataset.
 
# 13B. Combine start and end station observations, then test the mapping across
# both endpoints. UNION ALL preserves every station occurrence before the
# distinct-name count is calculated for each station ID.
 
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

# Validation result: No rows returned. Each station ID maps consistently to one
# station name across both trip endpoints.
#
# ============================================================================
# PHASE 0 CONCLUSION
# ============================================================================
# The five source tables were consolidated into stg_citibike with full source
# lineage and reconciled to the expected 4,674,903 records. No duplicate ride
# IDs, missing values, blank values, zero placeholders, invalid timestamp order,
# implausible coordinates, unexpected categories, or inconsistent station
# mappings were detected.
#
# Items carried forward for documented treatment in later phases:
# - Convert started_at and ended_at from TEXT to an appropriate datetime type.
# - Preserve station IDs as text-based identifiers.
# - Define the reporting-period rule for 478 April-start/May-end boundary rides.
# - Flag or define treatment for 22 rides exceeding 24 hours when calculating
#   duration-sensitive metrics.
#
# Portfolio value: This phase demonstrates controlled ETL, source-to-target
# reconciliation, data lineage, SQL-based quality auditing, anomaly assessment,
# and disciplined separation between raw staging and analytical cleaning.
