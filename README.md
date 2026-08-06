# Citi Bike Operational Analytics

> **Work in progress:** This project is being developed phase by phase. Data ingestion, staging, and initial quality validation are complete. Business framing, cleaning, exploratory analysis, recommendations, and the Tableau dashboard are still in development.

## Project Overview

This portfolio project treats Citi Bike as an operational analytics case study. The goal is to analyze one complete month of NYC trip activity and develop recommendations that could improve bike availability, station performance, customer access, and operational efficiency.

The project is designed to demonstrate an end-to-end business analytics workflow using MySQL, SQL, Tableau, and GitHub. It emphasizes traceable ETL, defensible data-quality decisions, business-focused analysis, and executive communication rather than producing charts without an operational question.

## Business Problem

Citi Bike must position bikes and docking capacity where and when riders need them. Uneven demand can create empty stations, full stations, lost trips, poor customer experiences, and unnecessary rebalancing work.

This project will investigate:

- When and where demand is highest
- How member and casual rider behavior differs
- Which stations experience the greatest inbound and outbound activity
- Where demand patterns may create bike-availability or dock-capacity pressure
- How operational resources could be prioritized more effectively

Trip history alone does not directly measure real-time bike or dock availability. Any availability conclusions will therefore be framed as demand-pressure indicators unless additional station-status data is incorporated.

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
- A small sample dataset to be added for structure review

## Technology

- MySQL
- MySQL Workbench
- SQL
- Tableau
- GitHub

## Project Workflow

| Phase | Deliverable | Status |
|---|---|---|
| 0 | Data ingestion, staging, and validation | Complete |
| 1 | Business understanding | Next |
| 2 | Data understanding | Not started |
| 3 | Data cleaning and analytical table | Not started |
| 4 | Exploratory business analysis | Not started |
| 5 | Executive recommendations | Not started |
| 6 | Tableau dashboard | Not started |
| 7 | Portfolio documentation | In progress |
| 8 | Interview preparation | Not started |

## Phase 0: Ingestion and Validation

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
│   └── README.md
└── sql/
    └── 01_citibike_ingestion_staging_validation.sql
```

Additional SQL, documentation, Tableau assets, and final findings will be added as the project progresses.

## Portfolio

Return to the [Data Analytics Portfolio](https://github.com/keyswill/data-analytics-portfolio).
