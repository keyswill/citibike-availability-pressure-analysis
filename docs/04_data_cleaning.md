# Phase 4: Data Cleaning and Analytical Table

**Status: Complete**

This phase converted the validated staging data into a reusable trip-level analytical table while preserving the raw imports and `stg_citibike`.

## Objective

Create `citibike_trips_clean` as the consistent source for demand, station, rider, bike, and duration analysis.

The cleaning process follows three principles:

1. Preserve one row per validated ride.
2. Do not silently delete unusual but potentially valid records.
3. Reconcile every transformation to the staging layer.

## Preflight Results

Before defining the clean table, the staging fields were profiled rather than assigned arbitrary sizes.

| Field | Maximum observed length | Clean-table capacity |
|---|---:|---:|
| `source_table` | 10 | 20 |
| `ride_id` | 16 | 20 |
| `rideable_type` | 13 | 20 |
| `start_station_name` | 45 | 100 |
| `start_station_id` | 7 | 20 |
| `end_station_name` | 45 | 100 |
| `end_station_id` | 7 | 20 |
| `member_casual` | 6 | 10 |

All 4,674,903 start timestamps and all 4,674,903 end timestamps converted successfully during preflight testing.

## Transformations

| Transformation | Treatment | Business purpose |
|---|---|---|
| Text standardization | Applied `TRIM()` to categorical and identifier fields | Prevent hidden spaces from splitting categories |
| Timestamp conversion | Converted text to `DATETIME(3)` | Enable accurate time analysis while preserving milliseconds |
| Date and time fields | Derived start/end dates, times, hours, weekday numbers, and day names | Support reusable demand dimensions |
| Weekend flags | Marked Saturday and Sunday events | Compare weekday and weekend patterns consistently |
| Duration | Calculated seconds and decimal minutes | Support rider and utilization analysis |
| May event flags | Created separate start and end flags | Apply the reporting period to the correct operational event |
| Boundary flag | Flagged April-start/May-end rides | Preserve records while preventing inconsistent reporting |
| Long-duration flag | Flagged rides over 24 hours | Retain exceptions for sensitivity analysis |
| Lineage | Retained `stg_row_id` and `source_table` | Trace analytical records to staging |
| Indexes | Added start, end, rider, and bike indexes | Improve common analytical queries |

## Reporting Rules

The clean table retains all 478 rides that started April 30 and ended May 1.

- May departure measures will use `starts_in_may = 1`.
- May arrival measures will use `ends_in_may = 1`.
- Boundary rides remain available for completed-trip and arrival analysis.
- The rule is visible through flags rather than hidden through deletion.

The 22 rides lasting longer than 24 hours were also retained. They passed timestamp-order validation but are flagged so duration measures can be compared with and without them.

## Validation Results

| Check | Result |
|---|---:|
| Staging records | 4,674,903 |
| Clean records | 4,674,903 |
| Row difference | 0 |
| Unique staging IDs | 4,674,903 |
| Unique ride IDs | 4,674,903 |
| Staged rows missing from clean | 0 |
| Failed timestamp conversions | 0 |
| Invalid durations | 0 |
| Reporting-boundary rides | 478 |
| Rides over 24 hours | 22 |
| Final quality gate | PASS |

Source-level totals, rider categories, and bike categories also reconciled to the validated staging results.

## Technical Issue Resolved

The first bulk-load attempt exceeded MySQL Workbench's 30-second connection read timeout. The statement rolled back, leaving zero clean records. After increasing the client timeout, the load completed successfully and reconciled to all 4,674,903 staged rides.

This was a client timeout rather than evidence of invalid source data. Record counts and the final quality gate were rechecked after the successful load.

## Analytical Table

`citibike_trips_clean` preserves the original trip fields and adds consistent dimensions for:

- Departure and arrival timing
- Weekday and weekend analysis
- Station activity
- Rider and bike comparisons
- Ride duration
- Reporting-period treatment
- Quality-exception filtering

## Phase 4 Summary

### What was accomplished

- Created a reproducible clean analytical table.
- Converted and validated timestamp fields.
- Standardized categorical text.
- Derived reusable time and duration dimensions.
- Preserved data lineage.
- Flagged boundary and long-duration exceptions.
- Reconciled the clean table to staging.
- Added analytical indexes and a final PASS/FAIL gate.

### Business value created

Future analyses can now use one set of definitions for departures, arrivals, durations, rider categories, and reporting-period boundaries. This reduces the risk of conflicting KPIs across SQL queries and Tableau views.

### Skills demonstrated

- SQL data transformation
- Schema design
- Feature engineering
- Business-rule implementation
- Data lineage
- Exception handling
- Reconciliation and quality assurance
- Performance-oriented indexing
- Database troubleshooting
