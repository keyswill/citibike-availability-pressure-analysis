# Citi Bike Operational Analytics

> **Work in progress:** This project is being developed phase by phase. Data ingestion, staging, validation, and business understanding are complete. Data understanding, cleaning, exploratory analysis, recommendations, and the Tableau dashboard are still in development.

## Project Overview

This portfolio project treats Citi Bike as an operational analytics case study. The goal is to analyze one complete month of NYC trip activity and develop recommendations that could improve bike availability, station performance, customer access, and operational efficiency.

The project is designed to demonstrate an end-to-end business analytics workflow using MySQL, SQL, Tableau, and GitHub. It emphasizes traceable ETL, defensible data-quality decisions, business-focused analysis, and executive communication rather than producing charts without an operational question.

## Business Problem

Citi Bike riders need an available bike when beginning a trip and an available dock when ending one. Because demand changes by station, time, rider type, and bike type, some parts of the system may experience more operational pressure than others.

This project analyzes May 2026 trip activity to identify high-volume stations, peak periods, and differences between pickups and returns. The findings will support decisions about where closer monitoring, bike rebalancing, or additional operational support may be most useful.

Trip history records completed rides rather than live station inventory. Findings will therefore be presented as indicators of potential availability pressure, not proof that a station was empty or full.

See the complete [Phase 2 Business Understanding](docs/02_business_understanding.md).

## Dataset

The analysis uses five NYC Citi Bike CSV files covering May 2026.

| Source table | Imported rows |
|---|---:|
| `tripdata_1` | 992,819 |
| `tripdata_2` | 998,471 |
| `tripdata_3` | 995,417 |
| `tripdata_4` | 994,151 |
| `tripdata_5` | 694,045 |
| **Total** | **4,674,903** |

The files were downloaded from the [official Citi Bike System Data page](https://citibikenyc.com/system-data).

### Data-storage decision

The five raw CSV files and the 4.67-million-row staging export are not committed to this repository. They are large, reproducible source artifacts rather than project code, and storing them in Git would make the repository unnecessarily heavy.

Instead, this repository provides:

- The official source link
- Source-level control totals
- SQL that reconstructs and validates the staging table
- Documentation of the ingestion workflow
- A [2,500-row staging sample](data/citibike_staging_sample.csv) for structure review, containing 500 records from each source table

## Technology

- MySQL
- MySQL Workbench
- SQL
- Tableau
- GitHub

## Project Workflow

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

The five imported tables were consolidated into `stg_citibike`. A `source_table` field preserves row-level lineage, while `stg_row_id` provides a staging surrogate key.

Validation completed:

- Reconciled all five source counts to **4,674,903** staged records
- Confirmed **4,674,903 unique, non-null ride IDs**
- Found no duplicate ride IDs
- Found no database NULLs, blank strings, or zero-value placeholders
- Confirmed standardized rider categories: `member` and `casual`
- Confirmed standardized bike categories: `electric_bike` and `classic_bike`
- Found no rides ending before or exactly when they started
- Confirmed plausible NYC coordinate ranges
- Confirmed each station ID maps consistently to one station name

Documented exceptions retained for later business-rule decisions:

- **478 rides** started April 30 and ended May 1
- **22 rides** lasted slightly longer than 24 hours
- Imported timestamps are stored as text and require conversion in the cleaned table
- Station identifiers should remain categorical text values

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

Additional SQL, documentation, Tableau assets, and final findings will be added as the project progresses.

## Portfolio

Return to the [Data Analytics Portfolio](https://github.com/keyswill/data-analytics-portfolio).
