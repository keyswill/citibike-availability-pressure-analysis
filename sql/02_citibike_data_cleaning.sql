# ============================================================================
# CITI BIKE OPERATIONAL ANALYTICS
# PHASE 4: DATA CLEANING AND ANALYTICAL TABLE
# DATA PERIOD: MAY 2026
#
# This script converts the validated staging data into citibike_trips_clean.
# It preserves one row per ride, converts timestamp text, standardizes text,
# derives reusable time fields, and flags reporting and duration exceptions.
# stg_citibike remains unchanged and provides the control total for validation.
#
# Expected clean-table total: 4,674,903 records
# ============================================================================

USE citibike;


# ----------------------------------------------------------------------------
# STEP 1: PROFILE TEXT LENGTHS
# ----------------------------------------------------------------------------
# Measure the data before selecting bounded VARCHAR types. Confirm that every
# result fits within the capacities defined in Step 3 before continuing.

SELECT
    MAX(CHAR_LENGTH(TRIM(source_table))) AS max_source_table_length,
    MAX(CHAR_LENGTH(TRIM(ride_id))) AS max_ride_id_length,
    MAX(CHAR_LENGTH(TRIM(rideable_type))) AS max_rideable_type_length,
    MAX(CHAR_LENGTH(TRIM(start_station_name))) AS max_start_station_name_length,
    MAX(CHAR_LENGTH(TRIM(start_station_id))) AS max_start_station_id_length,
    MAX(CHAR_LENGTH(TRIM(end_station_name))) AS max_end_station_name_length,
    MAX(CHAR_LENGTH(TRIM(end_station_id))) AS max_end_station_id_length,
    MAX(CHAR_LENGTH(TRIM(member_casual))) AS max_member_casual_length
FROM stg_citibike
;


# ----------------------------------------------------------------------------
# STEP 2: TEST TIMESTAMP CONVERSION
# ----------------------------------------------------------------------------
# Confirm that every timestamp follows the observed format and can be converted
# while preserving milliseconds. Both failure counts must equal zero.

SELECT
    COUNT(*) AS total_staging_records,
    SUM(
        CASE
            WHEN STR_TO_DATE(
                TRIM(started_at),
                '%Y-%m-%d %H:%i:%s.%f'
            ) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS failed_start_conversions,
    SUM(
        CASE
            WHEN STR_TO_DATE(
                TRIM(ended_at),
                '%Y-%m-%d %H:%i:%s.%f'
            ) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS failed_end_conversions
FROM stg_citibike
;


# ----------------------------------------------------------------------------
# STEP 3: CREATE THE CLEAN ANALYTICAL TABLE
# ----------------------------------------------------------------------------
# Rebuild the clean table from the validated staging layer. This makes the
# cleaning process repeatable without changing the imported or staged records.
#
# The selected capacities reflect the observed maximum lengths while leaving
# reasonable room for future values:
# - source_table, ride_id, rideable_type, and station IDs: 20 characters
# - station names: 100 characters
# - member_casual: 10 characters

DROP TABLE IF EXISTS citibike_trips_clean;

CREATE TABLE citibike_trips_clean (
    clean_row_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    stg_row_id BIGINT NOT NULL,
    source_table VARCHAR(20) NOT NULL,
    ride_id VARCHAR(20) NOT NULL,
    rideable_type VARCHAR(20) NOT NULL,

    started_at DATETIME(3) NOT NULL,
    ended_at DATETIME(3) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    start_time TIME(3) NOT NULL,
    end_time TIME(3) NOT NULL,
    start_hour TINYINT UNSIGNED NOT NULL,
    end_hour TINYINT UNSIGNED NOT NULL,
    start_day_of_week TINYINT UNSIGNED NOT NULL,
    end_day_of_week TINYINT UNSIGNED NOT NULL,
    start_day_name VARCHAR(9) NOT NULL,
    end_day_name VARCHAR(9) NOT NULL,
    start_is_weekend TINYINT UNSIGNED NOT NULL,
    end_is_weekend TINYINT UNSIGNED NOT NULL,

    start_station_name VARCHAR(100) NOT NULL,
    start_station_id VARCHAR(20) NOT NULL,
    end_station_name VARCHAR(100) NOT NULL,
    end_station_id VARCHAR(20) NOT NULL,
    start_lat DOUBLE NOT NULL,
    start_lng DOUBLE NOT NULL,
    end_lat DOUBLE NOT NULL,
    end_lng DOUBLE NOT NULL,

    member_casual VARCHAR(10) NOT NULL,
    duration_seconds INT NOT NULL,
    duration_minutes DECIMAL(10,2) NOT NULL,
    starts_in_may TINYINT UNSIGNED NOT NULL,
    ends_in_may TINYINT UNSIGNED NOT NULL,
    is_reporting_boundary TINYINT UNSIGNED NOT NULL,
    is_over_24_hours TINYINT UNSIGNED NOT NULL,
    is_valid_duration TINYINT UNSIGNED NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_clean_stg_row_id (stg_row_id),
    UNIQUE KEY uq_clean_ride_id (ride_id)
);

DESCRIBE citibike_trips_clean;


# ----------------------------------------------------------------------------
# STEP 4: LOAD STANDARDIZED AND DERIVED VALUES
# ----------------------------------------------------------------------------
# Trim categorical text, convert timestamps once, and derive fields used in
# later demand, station, rider, and duration analysis.
#
# Day-of-week values use 1 = Monday through 7 = Sunday. Weekend flags use
# Saturday and Sunday. A valid duration means the ride ended after it started;
# rides longer than 24 hours remain valid but receive a separate exception flag.

INSERT INTO citibike_trips_clean (
    stg_row_id,
    source_table,
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_date,
    end_date,
    start_time,
    end_time,
    start_hour,
    end_hour,
    start_day_of_week,
    end_day_of_week,
    start_day_name,
    end_day_name,
    start_is_weekend,
    end_is_weekend,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual,
    duration_seconds,
    duration_minutes,
    starts_in_may,
    ends_in_may,
    is_reporting_boundary,
    is_over_24_hours,
    is_valid_duration
)
SELECT
    stg_row_id,
    TRIM(source_table),
    TRIM(ride_id),
    TRIM(rideable_type),
    started_at_clean,
    ended_at_clean,
    DATE(started_at_clean),
    DATE(ended_at_clean),
    TIME(started_at_clean),
    TIME(ended_at_clean),
    HOUR(started_at_clean),
    HOUR(ended_at_clean),
    WEEKDAY(started_at_clean) + 1,
    WEEKDAY(ended_at_clean) + 1,
    DAYNAME(started_at_clean),
    DAYNAME(ended_at_clean),
    CASE
        WHEN WEEKDAY(started_at_clean) IN (5, 6) THEN 1
        ELSE 0
    END,
    CASE
        WHEN WEEKDAY(ended_at_clean) IN (5, 6) THEN 1
        ELSE 0
    END,
    TRIM(start_station_name),
    TRIM(start_station_id),
    TRIM(end_station_name),
    TRIM(end_station_id),
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    TRIM(member_casual),
    TIMESTAMPDIFF(SECOND, started_at_clean, ended_at_clean),
    ROUND(
        TIMESTAMPDIFF(SECOND, started_at_clean, ended_at_clean) / 60.0,
        2
    ),
    CASE
        WHEN started_at_clean >= '2026-05-01 00:00:00'
         AND started_at_clean <  '2026-06-01 00:00:00'
        THEN 1
        ELSE 0
    END,
    CASE
        WHEN ended_at_clean >= '2026-05-01 00:00:00'
         AND ended_at_clean <  '2026-06-01 00:00:00'
        THEN 1
        ELSE 0
    END,
    CASE
        WHEN started_at_clean <  '2026-05-01 00:00:00'
         AND ended_at_clean >= '2026-05-01 00:00:00'
         AND ended_at_clean <  '2026-06-01 00:00:00'
        THEN 1
        ELSE 0
    END,
    CASE
        WHEN TIMESTAMPDIFF(
            SECOND,
            started_at_clean,
            ended_at_clean
        ) > 86400
        THEN 1
        ELSE 0
    END,
    CASE
        WHEN ended_at_clean > started_at_clean THEN 1
        ELSE 0
    END
FROM (
    SELECT
        stg_row_id,
        source_table,
        ride_id,
        rideable_type,
        STR_TO_DATE(
            TRIM(started_at),
            '%Y-%m-%d %H:%i:%s.%f'
        ) AS started_at_clean,
        STR_TO_DATE(
            TRIM(ended_at),
            '%Y-%m-%d %H:%i:%s.%f'
        ) AS ended_at_clean,
        start_station_name,
        start_station_id,
        end_station_name,
        end_station_id,
        start_lat,
        start_lng,
        end_lat,
        end_lng,
        member_casual
    FROM stg_citibike
) AS parsed_staging
;


# ----------------------------------------------------------------------------
# STEP 5: RECONCILE STAGING AND CLEAN COUNTS
# ----------------------------------------------------------------------------
# Confirm that every staged ride appears exactly once in the analytical table.

SELECT
    (SELECT COUNT(*) FROM stg_citibike) AS staging_records,
    (SELECT COUNT(*) FROM citibike_trips_clean) AS clean_records,
    (SELECT COUNT(*) FROM stg_citibike)
        - (SELECT COUNT(*) FROM citibike_trips_clean) AS row_difference
;

SELECT
    source_table,
    COUNT(*) AS clean_records
FROM citibike_trips_clean
GROUP BY source_table
ORDER BY source_table
;


# ----------------------------------------------------------------------------
# STEP 6: CHECK KEYS AND LINEAGE
# ----------------------------------------------------------------------------
# Confirm that staging IDs and ride IDs remain complete and unique after load.

SELECT
    COUNT(*) AS total_clean_records,
    COUNT(stg_row_id) AS non_null_stg_row_ids,
    COUNT(DISTINCT stg_row_id) AS unique_stg_row_ids,
    COUNT(ride_id) AS non_null_ride_ids,
    COUNT(DISTINCT ride_id) AS unique_ride_ids
FROM citibike_trips_clean
;

SELECT
    COUNT(*) AS staged_rows_missing_from_clean
FROM stg_citibike AS s
LEFT JOIN citibike_trips_clean AS c
    ON s.stg_row_id = c.stg_row_id
WHERE c.stg_row_id IS NULL
;


# ----------------------------------------------------------------------------
# STEP 7: VALIDATE TIMESTAMPS AND DERIVED TIME FIELDS
# ----------------------------------------------------------------------------
# Confirm that converted timestamps and reusable date parts agree with one
# another. Every inconsistency count should equal zero.

SELECT
    SUM(CASE WHEN started_at IS NULL THEN 1 ELSE 0 END)
        AS missing_started_at,
    SUM(CASE WHEN ended_at IS NULL THEN 1 ELSE 0 END)
        AS missing_ended_at,
    SUM(CASE WHEN start_date <> DATE(started_at) THEN 1 ELSE 0 END)
        AS incorrect_start_dates,
    SUM(CASE WHEN end_date <> DATE(ended_at) THEN 1 ELSE 0 END)
        AS incorrect_end_dates,
    SUM(CASE WHEN start_time <> TIME(started_at) THEN 1 ELSE 0 END)
        AS incorrect_start_times,
    SUM(CASE WHEN end_time <> TIME(ended_at) THEN 1 ELSE 0 END)
        AS incorrect_end_times,
    SUM(CASE WHEN start_hour <> HOUR(started_at) THEN 1 ELSE 0 END)
        AS incorrect_start_hours,
    SUM(CASE WHEN end_hour <> HOUR(ended_at) THEN 1 ELSE 0 END)
        AS incorrect_end_hours,
    SUM(
        CASE
            WHEN start_day_of_week <> WEEKDAY(started_at) + 1 THEN 1
            ELSE 0
        END
    ) AS incorrect_start_weekdays,
    SUM(
        CASE
            WHEN end_day_of_week <> WEEKDAY(ended_at) + 1 THEN 1
            ELSE 0
        END
    ) AS incorrect_end_weekdays,
    SUM(CASE WHEN start_day_name <> DAYNAME(started_at) THEN 1 ELSE 0 END)
        AS incorrect_start_day_names,
    SUM(CASE WHEN end_day_name <> DAYNAME(ended_at) THEN 1 ELSE 0 END)
        AS incorrect_end_day_names,
    SUM(
        CASE
            WHEN start_is_weekend <>
                 CASE WHEN WEEKDAY(started_at) IN (5, 6) THEN 1 ELSE 0 END
            THEN 1
            ELSE 0
        END
    ) AS incorrect_start_weekend_flags,
    SUM(
        CASE
            WHEN end_is_weekend <>
                 CASE WHEN WEEKDAY(ended_at) IN (5, 6) THEN 1 ELSE 0 END
            THEN 1
            ELSE 0
        END
    ) AS incorrect_end_weekend_flags
FROM citibike_trips_clean
;

SELECT
    MIN(started_at) AS earliest_start,
    MAX(started_at) AS latest_start,
    MIN(ended_at) AS earliest_end,
    MAX(ended_at) AS latest_end
FROM citibike_trips_clean
;


# ----------------------------------------------------------------------------
# STEP 8: VALIDATE DURATION FIELDS AND FLAGS
# ----------------------------------------------------------------------------
# Confirm that duration calculations reproduce the timestamp difference. Long
# rides are retained as documented exceptions rather than silently removed.

SELECT
    SUM(
        CASE
            WHEN duration_seconds <>
                 TIMESTAMPDIFF(SECOND, started_at, ended_at)
            THEN 1
            ELSE 0
        END
    ) AS incorrect_duration_seconds,
    SUM(
        CASE
            WHEN duration_minutes <>
                 ROUND(duration_seconds / 60.0, 2)
            THEN 1
            ELSE 0
        END
    ) AS incorrect_duration_minutes,
    SUM(CASE WHEN is_valid_duration = 0 THEN 1 ELSE 0 END)
        AS invalid_duration_records,
    SUM(CASE WHEN is_over_24_hours = 1 THEN 1 ELSE 0 END)
        AS rides_over_24_hours,
    MIN(duration_seconds) AS minimum_duration_seconds,
    MAX(duration_seconds) AS maximum_duration_seconds
FROM citibike_trips_clean
;


# ----------------------------------------------------------------------------
# STEP 9: VALIDATE REPORTING-PERIOD FLAGS
# ----------------------------------------------------------------------------
# Preserve the difference between May pickup events and May return events. The
# 478 April-start/May-end rides should be retained and marked as boundaries.

SELECT
    SUM(CASE WHEN starts_in_may = 1 THEN 1 ELSE 0 END)
        AS rides_starting_in_may,
    SUM(CASE WHEN starts_in_may = 0 THEN 1 ELSE 0 END)
        AS rides_starting_outside_may,
    SUM(CASE WHEN ends_in_may = 1 THEN 1 ELSE 0 END)
        AS rides_ending_in_may,
    SUM(CASE WHEN ends_in_may = 0 THEN 1 ELSE 0 END)
        AS rides_ending_outside_may,
    SUM(CASE WHEN is_reporting_boundary = 1 THEN 1 ELSE 0 END)
        AS april_start_may_end_rides
FROM citibike_trips_clean
;

SELECT
    SUM(
        CASE
            WHEN starts_in_may <>
                 CASE
                     WHEN started_at >= '2026-05-01 00:00:00'
                      AND started_at <  '2026-06-01 00:00:00'
                     THEN 1
                     ELSE 0
                 END
            THEN 1
            ELSE 0
        END
    ) AS incorrect_start_flags,
    SUM(
        CASE
            WHEN ends_in_may <>
                 CASE
                     WHEN ended_at >= '2026-05-01 00:00:00'
                      AND ended_at <  '2026-06-01 00:00:00'
                     THEN 1
                     ELSE 0
                 END
            THEN 1
            ELSE 0
        END
    ) AS incorrect_end_flags
FROM citibike_trips_clean
;


# ----------------------------------------------------------------------------
# STEP 10: VALIDATE STANDARDIZED TEXT AND CATEGORIES
# ----------------------------------------------------------------------------
# Confirm that trimming did not create blanks and that the expected rider and
# bike categories still account for the complete clean table.

SELECT
    SUM(CASE WHEN TRIM(ride_id) = '' THEN 1 ELSE 0 END) AS blank_ride_id,
    SUM(CASE WHEN TRIM(rideable_type) = '' THEN 1 ELSE 0 END)
        AS blank_rideable_type,
    SUM(CASE WHEN TRIM(start_station_name) = '' THEN 1 ELSE 0 END)
        AS blank_start_station_name,
    SUM(CASE WHEN TRIM(start_station_id) = '' THEN 1 ELSE 0 END)
        AS blank_start_station_id,
    SUM(CASE WHEN TRIM(end_station_name) = '' THEN 1 ELSE 0 END)
        AS blank_end_station_name,
    SUM(CASE WHEN TRIM(end_station_id) = '' THEN 1 ELSE 0 END)
        AS blank_end_station_id,
    SUM(CASE WHEN TRIM(member_casual) = '' THEN 1 ELSE 0 END)
        AS blank_member_casual
FROM citibike_trips_clean
;

SELECT
    member_casual,
    COUNT(*) AS ride_count
FROM citibike_trips_clean
GROUP BY member_casual
ORDER BY ride_count DESC
;

SELECT
    rideable_type,
    COUNT(*) AS ride_count
FROM citibike_trips_clean
GROUP BY rideable_type
ORDER BY ride_count DESC
;


# ----------------------------------------------------------------------------
# STEP 11: ADD ANALYTICAL INDEXES
# ----------------------------------------------------------------------------
# Add indexes after the bulk load so later time-and-station queries do not need
# to scan the full table for every operational question.

CREATE INDEX idx_clean_start_analysis
    ON citibike_trips_clean (
        start_date,
        start_hour,
        start_station_id
    );

CREATE INDEX idx_clean_end_analysis
    ON citibike_trips_clean (
        end_date,
        end_hour,
        end_station_id
    );

CREATE INDEX idx_clean_rider_bike
    ON citibike_trips_clean (
        member_casual,
        rideable_type
    );


# ----------------------------------------------------------------------------
# STEP 12: RUN THE FINAL QUALITY GATE
# ----------------------------------------------------------------------------
# PASS means the clean table reconciles to staging, preserves unique keys,
# contains valid converted timestamps and durations, uses the expected business
# categories, and retains the documented exceptions.

SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM stg_citibike) = 4674903
         AND (SELECT COUNT(*) FROM citibike_trips_clean) =
             (SELECT COUNT(*) FROM stg_citibike)
         AND (SELECT COUNT(DISTINCT ride_id)
              FROM citibike_trips_clean) =
             (SELECT COUNT(*) FROM citibike_trips_clean)
         AND (SELECT COUNT(DISTINCT stg_row_id)
              FROM citibike_trips_clean) =
             (SELECT COUNT(*) FROM citibike_trips_clean)
         AND (SELECT COUNT(*)
              FROM stg_citibike AS s
              LEFT JOIN citibike_trips_clean AS c
                  ON s.stg_row_id = c.stg_row_id
              WHERE c.stg_row_id IS NULL) = 0
         AND (SELECT COUNT(*)
              FROM citibike_trips_clean
              WHERE started_at IS NULL OR ended_at IS NULL) = 0
         AND (SELECT COUNT(*)
              FROM citibike_trips_clean
              WHERE is_valid_duration = 0) = 0
         AND (SELECT COUNT(*)
              FROM citibike_trips_clean
              WHERE duration_seconds <>
                    TIMESTAMPDIFF(SECOND, started_at, ended_at)
                 OR duration_minutes <>
                    ROUND(duration_seconds / 60.0, 2)) = 0
         AND (SELECT COUNT(*)
              FROM citibike_trips_clean
              WHERE starts_in_may NOT IN (0, 1)
                 OR ends_in_may NOT IN (0, 1)
                 OR is_reporting_boundary NOT IN (0, 1)
                 OR is_over_24_hours NOT IN (0, 1)
                 OR is_valid_duration NOT IN (0, 1)
                 OR start_is_weekend NOT IN (0, 1)
                 OR end_is_weekend NOT IN (0, 1)) = 0
         AND (SELECT COUNT(*)
              FROM citibike_trips_clean
              WHERE starts_in_may <>
                    CASE
                        WHEN started_at >= '2026-05-01 00:00:00'
                         AND started_at <  '2026-06-01 00:00:00'
                        THEN 1 ELSE 0
                    END
                 OR ends_in_may <>
                    CASE
                        WHEN ended_at >= '2026-05-01 00:00:00'
                         AND ended_at <  '2026-06-01 00:00:00'
                        THEN 1 ELSE 0
                    END
                 OR is_reporting_boundary <>
                    CASE
                        WHEN started_at <  '2026-05-01 00:00:00'
                         AND ended_at >= '2026-05-01 00:00:00'
                         AND ended_at <  '2026-06-01 00:00:00'
                        THEN 1 ELSE 0
                    END) = 0
         AND (SELECT COUNT(*)
              FROM citibike_trips_clean
              WHERE member_casual NOT IN ('member', 'casual')
                 OR rideable_type NOT IN (
                    'electric_bike',
                    'classic_bike'
                 )) = 0
         AND (SELECT COUNT(*)
              FROM citibike_trips_clean
              WHERE is_over_24_hours = 1) = 22
         AND (SELECT COUNT(*)
              FROM citibike_trips_clean
              WHERE is_reporting_boundary = 1) = 478
        THEN 'PASS: citibike_trips_clean is ready for business analysis'
        ELSE 'FAIL: review the Phase 4 validation results'
    END AS phase_4_quality_gate
;


# ============================================================================
# PHASE 4 SUMMARY
# ============================================================================
# The clean table should contain one traceable row for each of the 4,674,903
# staged rides. Timestamps are converted to DATETIME(3), categorical text is
# trimmed, station IDs remain text, and reusable time and duration fields are
# available for analysis.
#
# No staged records are silently deleted. The 478 reporting-boundary rides and
# 22 rides over 24 hours remain available through explicit flags so each future
# metric can apply the correct business rule.
# ============================================================================
