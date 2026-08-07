# Citi Bike Operational Analytics

> **Work in progress:** Data ingestion, validation, and business understanding are complete. The remaining phases will cover data understanding, cleaning, exploratory analysis, recommendations, and Tableau dashboard development.

## Project Overview

Citi Bike's service depends on having bikes and open docks available where riders need them. Because trip demand changes throughout the day and across the station network, some locations may experience more operational pressure than others.

In this project, I am analyzing **4,674,903 Citi Bike trips from May 2026** to understand when demand is highest, which stations handle the most activity, and where differences between bike pickups and returns may require closer attention.

The goal is not simply to report trip counts. The analysis is designed to help operations teams identify stations and time periods that may benefit from additional monitoring, rebalancing, or operational support.

## Main Business Question

> Which Citi Bike stations are busiest, when is demand highest, and where do pickup and return patterns suggest a need for closer operational monitoring?

Trip history shows completed rides, but it does not show whether a station was empty or full at a particular moment. I will therefore use trip patterns to identify **potential availability pressure** without claiming that a confirmed bike or dock shortage occurred.

See the complete [Phase 2 Business Understanding](docs/02_business_understanding.md).

## Dataset

The analysis uses five trip-history files from the [official Citi Bike System Data page](https://citibikenyc.com/system-data).

| Source table | Imported rows |
|---|---:|
| `tripdata_1` | 992,819 |
| `tripdata_2` | 998,471 |
| `tripdata_3` | 995,417 |
| `tripdata_4` | 994,151 |
| `tripdata_5` | 694,045 |
| **Total** | **4,674,903** |

### Why the complete CSV files are not stored here

The five source files and the complete staging export are large, reproducible data files. Committing them would make the repository unnecessarily heavy without making the analysis easier to review.

Instead, the repository includes:

- The official data source
- Control totals for every imported file
- SQL that rebuilds and validates the staging table
- Documentation of the ingestion process
- A [2,500-row staging sample](data/citibike_staging_sample.csv), with 500 records from each source table

All validation results and future analysis are based on the complete dataset, not the sample.

## Tools

- MySQL and MySQL Workbench
- SQL
- Tableau
- GitHub

## Project Progress

| Phase | Deliverable | Status |
|---|---|---|
| 1 | Data ingestion, staging, and validation | Complete |
| 2 | Business understanding | Complete |
| 3 | Data understanding | Next |
| 4 | Data cleaning and analytical table | Not started |
| 5 | Exploratory business analysis | Not started |
| 6 | Executive recommendations | Not started |
| 7 | Tableau dashboard | Not started |

## Phase 1: Ingestion and Validation

I combined the five imported tables into `stg_citibike`. The `source_table` field preserves the origin of every record, and `stg_row_id` supplies a staging key.

The validation established that:

- All five source counts reconcile to **4,674,903 staged records**
- Every staged record has a unique ride ID
- No duplicate ride IDs were found
- No database NULLs, blank strings, or zero-value placeholders were found
- Rider and bike categories are standardized
- No rides end before or exactly when they start
- Coordinates fall within plausible ranges for the Citi Bike service area
- Each station ID maps consistently to one station name

I retained four issues for documented treatment in later phases:

- **478 rides** started April 30 and ended May 1
- **22 rides** lasted slightly longer than 24 hours
- Timestamps were imported as text and must be converted in the cleaned table
- Station IDs should remain text because they are identifiers, not measurements

These records were not silently deleted. Their treatment will depend on the business definition used for each metric.

## Repository Structure

```text
citibike-operational-analytics/
├── README.md
├── .gitignore
├── data/
│   ├── README.md
│   └── citibike_staging_sample.csv
├── docs/
│   └── 02_business_understanding.md
└── sql/
    └── 01_citibike_ingestion_staging_validation.sql
```

Additional SQL, documentation, Tableau assets, findings, and recommendations will be added as the project progresses.

## Portfolio

Return to my [Data Analytics Portfolio](https://github.com/keyswill/data-analytics-portfolio).
