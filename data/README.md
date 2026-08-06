# Data Directory

## Source

The project uses the NYC Citi Bike May 2026 trip-history files available from the [official Citi Bike System Data page](https://citibikenyc.com/system-data).

## Source Control Totals

| Local source table | Rows |
|---|---:|
| `tripdata_1` | 992,819 |
| `tripdata_2` | 998,471 |
| `tripdata_3` | 995,417 |
| `tripdata_4` | 994,151 |
| `tripdata_5` | 694,045 |
| **Consolidated staging total** | **4,674,903** |

## Why the Full CSV Files Are Not Stored Here

The raw exports and consolidated staging CSV are large, reproducible data files. Committing them would increase clone and download costs without improving review of the analytical workflow.

To reproduce the staging layer:

1. Download the May 2026 NYC trip-history archive from Citi Bike.
2. Import the five CSV files into MySQL as `tripdata_1` through `tripdata_5`.
3. Run `sql/01_citibike_ingestion_staging_validation.sql`.
4. Confirm that `stg_citibike` contains 4,674,903 rows.

A 2,500-row representative staging sample is available as `citibike_staging_sample.csv`. It contains 500 records from each of the five source tables for balanced structure review. The sample does not replace the complete 4,674,903-row dataset used for analysis.
