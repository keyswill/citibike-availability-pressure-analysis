# Phase 3: Data Understanding

**Status: Complete**

This phase explains what each record and field represents, how the data can support Citi Bike's operational questions, and what must be addressed before analysis begins.

## Dataset Grain

> One row in `stg_citibike` represents one completed Citi Bike ride recorded in the May 2026 trip-data release.

The phrase "recorded in the May 2026 release" is important because 478 rides began April 30 and ended May 1. Not every staged ride started in May.

## Keys and Data Lineage

| Field | Role | Interpretation |
|---|---|---|
| `stg_row_id` | Staging primary key | Uniquely identifies a row in `stg_citibike` |
| `ride_id` | Natural trip identifier | Identifies the completed ride |
| `source_table` | Lineage field | Identifies which imported table supplied the record |
| Station IDs | Categorical identifiers | Identify departure and arrival stations |

Phase 1 confirmed that all 4,674,903 staged records have a unique `ride_id`. The `source_table` field supports ingestion checks and troubleshooting, but it does not represent a business segment or a confirmed part of the month.

## Field Review

| Field | Current type | Business use | Data-understanding note |
|---|---|---|---|
| `stg_row_id` | `BIGINT` | Staging control and troubleshooting | Technical field; not a business KPI |
| `source_table` | `VARCHAR(20)` | Source reconciliation and lineage | File assignment should not be interpreted as demand timing |
| `ride_id` | `TEXT` | Unique trip counting | Complete and unique, but the type is broader than necessary |
| `rideable_type` | `TEXT` | Compare electric- and classic-bike trips | Describes the bike used for a trip, not fleet availability |
| `started_at` | `TEXT` | Departure date, hour, weekday, and reporting period | Requires conversion to a true datetime type |
| `ended_at` | `TEXT` | Arrival timing, reporting period, and ride duration | Requires conversion to a true datetime type |
| `start_station_name` | `TEXT` | Readable departure-station label | Names are less stable than station IDs |
| `start_station_id` | `TEXT` | Group trips by departure station | Correctly treated as a categorical identifier |
| `end_station_name` | `TEXT` | Readable arrival-station label | Names are less stable than station IDs |
| `end_station_id` | `TEXT` | Group trips by arrival station | Correctly treated as a categorical identifier |
| `start_lat` | `DOUBLE` | Map departure locations | Supports geography but does not explain demand |
| `start_lng` | `DOUBLE` | Map departure locations | Supports geography but does not explain demand |
| `end_lat` | `DOUBLE` | Map arrival locations | Supports geography but does not confirm dock availability |
| `end_lng` | `DOUBLE` | Map arrival locations | Supports geography but does not confirm dock availability |
| `member_casual` | `TEXT` | Compare member and casual trip patterns | Classifies trips, not unique customers |

## Field Roles

### Primary analytical fields

These fields directly support business measures:

- `ride_id`
- `rideable_type`
- `member_casual`
- `started_at`
- `ended_at`
- Start and end station IDs

### Supporting fields

These fields provide labels or geographic context:

- Start and end station names
- Start and end coordinates

### Technical fields

These fields support auditability rather than executive reporting:

- `stg_row_id`
- `source_table`

No field is useless, but not every field belongs in a KPI or dashboard.

## Connection to Business Questions

| Business question | Required fields | Planned measure | Interpretation limit |
|---|---|---|---|
| When is demand highest? | `ride_id`, `started_at` | Trips by hour, date, and weekday | Measures completed pickups only |
| Which stations are busiest? | Start and end station fields | Departures, arrivals, and total activity | Activity does not measure station capacity |
| Where might operational pressure exist? | Station fields and timestamps | Arrivals versus departures by station and time | Cannot confirm empty or full stations |
| How do member and casual trips differ? | `member_casual`, time, station, and duration | Trip share and usage patterns | Trips are not unique customers |
| How are bike types used? | `rideable_type`, rider type, time, and station | Electric versus classic-bike activity | Fleet size and maintenance status are unavailable |
| How long do rides last? | `started_at`, `ended_at` | Median and average duration | Twenty-two rides exceed 24 hours |
| Where does activity occur? | Station IDs, names, and coordinates | Station maps and geographic patterns | Location does not explain why demand occurs |

## Operational Event Logic

Departures and arrivals must initially be measured separately:

- A start timestamp and start station represent a completed bike pickup.
- An end timestamp and end station represent a completed bike return.

After calculating both sides, the project can derive:

```text
Total station activity = departures + arrivals
Net station flow = arrivals - departures
Absolute imbalance = ABS(arrivals - departures)
Imbalance rate = absolute imbalance / total station activity
```

A positive net flow means more bikes arrived than departed during the selected period. A negative net flow means more bikes departed than arrived.

A station can appear balanced across the month while experiencing large hourly differences. Station flow must therefore be examined by time period rather than from monthly totals alone.

## Quality Issues, Exceptions, and Limitations

### Issues to address during cleaning

- Convert `started_at` and `ended_at` from `TEXT` to `DATETIME(3)`.
- Consider a more precise bounded type for `ride_id` after checking its observed length.
- Create analytical date, time, weekday, and duration fields.
- Preserve station IDs as text.
- Apply a documented reporting rule to the 478 April-start/May-end rides.
- Flag the 22 rides over 24 hours so they do not silently distort duration measures.

### Limitations that cleaning cannot solve

- No historical bike inventory
- No historical open-dock inventory
- No station-capacity field
- No unsuccessful pickup or return attempts
- No rebalancing, valet, or maintenance records
- No unique customer identifier
- No trip-purpose field
- No weather or major-event data
- Only one month of activity

These limitations define the claims the project can make. Trip patterns can indicate potential operational pressure, but they cannot prove that a station was empty, full, or unable to serve a rider.

## Phase 3 Handoff to Cleaning

The cleaned analytical table should:

1. Preserve one row per validated ride.
2. Keep the staging table unchanged.
3. Convert timestamp text while preserving millisecond precision.
4. Derive reusable date, time, weekday, weekend, and duration fields.
5. retain station IDs as categorical text.
6. document the treatment of reporting-boundary and long-duration rides.
7. preserve enough source information to trace analytical records back to staging.

No cleaning transformation was performed during this phase. Phase 3 only established the requirements that Phase 4 must follow.

## Phase 3 Summary

### What was accomplished

- Defined the dataset grain and keys.
- Reviewed the type, meaning, and usefulness of every field.
- Connected the available fields to the project's business questions.
- Distinguished technical fields from business measures.
- Separated correctable quality issues from source-data limitations.
- Established requirements for the cleaned analytical table.

### Business value created

The analysis now has clear boundaries. Citi Bike stakeholders can understand which operational questions the trip data can support and which questions require inventory, capacity, or service-attempt data.

### Skills demonstrated

- Data profiling
- Data modeling and grain definition
- KPI requirements
- Business-rule development
- Data-lineage awareness
- Analytical risk assessment
- Stakeholder-focused documentation

### Why this matters to a hiring manager

This phase shows that the project is not moving directly from imported data to charts. The analytical design is tied to business decisions, and the limits of the data are documented before conclusions are drawn.
