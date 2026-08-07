# Project Data

This project uses five Citi Bike trip-history files covering May 2026. After importing the files into MySQL, I combined them into one staging table containing **4,674,903 records**.

## Source Control Totals

| Local source table | Rows |
|---|---:|
| `tripdata_1` | 992,819 |
| `tripdata_2` | 998,471 |
| `tripdata_3` | 995,417 |
| `tripdata_4` | 994,151 |
| `tripdata_5` | 694,045 |
| **Consolidated staging total** | **4,674,903** |

The files are available from the [official Citi Bike System Data page](https://citibikenyc.com/system-data).

## Why the Complete Dataset Is Not Stored in GitHub

The five source files and the complete staging export are large, reproducible data files. Uploading them would increase cloning and download costs without making the analytical work easier to review.

Instead, this repository provides:

- A link to the official source
- The expected row count for each imported file
- SQL that builds and validates the staging table
- A 2,500-row sample containing 500 records from each source table

The sample allows reviewers to inspect the structure of the data. It does not replace the complete dataset used for validation and analysis.

## Reproducing the Staging Table

1. Download the May 2026 NYC trip-history files from Citi Bike.
2. Import the five files into MySQL as `tripdata_1` through `tripdata_5`.
3. Run `sql/01_citibike_ingestion_staging_validation.sql`.
4. Confirm that `stg_citibike` contains **4,674,903 rows**.
