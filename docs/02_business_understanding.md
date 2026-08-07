# Phase 2: Business Understanding

## Status

**Complete**

Phase 2 defines the business problem, stakeholders, objectives, success metrics, business questions, assumptions, and limitations that will guide the remaining SQL analysis and Tableau dashboard.

## Business Context

Citi Bike is a station-based bike-share system. Riders need an available bike when beginning a trip and an available dock when ending one. Demand is not evenly distributed across stations or time periods, which can create operational pressure at different points in the network.

The May 2026 trip-history data records completed rides, including when and where bikes were picked up and returned. It does not contain historical bike inventory, open-dock inventory, station capacity, or unsuccessful rental and return attempts.

## Main Business Question

> Based on May 2026 trip activity, which Citi Bike stations are busiest, when is demand highest, and where do differences between bike pickups and returns suggest a need for closer availability monitoring or operational support?

## Business Problem

Citi Bike riders depend on having a bike available when they begin a trip and an open dock when they reach their destination. However, ridership is not evenly distributed across the system. Demand changes by station, time of day, day of the week, rider type, and bike type.

A station with substantially more departures than arrivals may face greater pressure on bike availability. A station with more arrivals than departures may face greater pressure on dock availability. This project will analyze May 2026 trip activity to identify high-volume stations, peak travel periods, and station-level differences between pickups and returns. The findings can help Citi Bike determine where closer monitoring, bike rebalancing, or additional operational support may be most useful.

Because trip history records completed rides rather than live station inventory, the results will be presented as indicators of potential operational pressure, not proof that a station was empty or full.

## Stakeholders

| Stakeholder | Role | Information needed |
|---|---|---|
| Citi Bike Operations Management | Primary decision-maker | Priority stations, peak periods, and station-flow imbalances |
| Rebalancing and field operations teams | Carry out operational responses | Station-level arrival and departure patterns by time |
| Citi Bike executive leadership | Reviews performance and approves priorities | Systemwide KPIs, operational risks, and recommendations |
| Customer experience team | Monitors effects on riders | Patterns that may contribute to bike or dock access problems |
| New York City Department of Transportation | Oversight stakeholder | System usage, operational performance, and accountability |
| Citi Bike riders | Affected stakeholder | More reliable access to bikes and open docks |

Valet operations is not treated as a separate stakeholder because the trip-history dataset does not identify valet locations, operating hours, or valet-handled bikes.

## Business Objectives

1. Identify the days and hours with the highest trip demand.
2. Identify the busiest stations using both departures and arrivals.
3. Compare station departures and arrivals to identify potential flow imbalances.
4. Compare usage patterns across members, casual riders, electric bikes, and classic bikes.
5. Prioritize station and time-period combinations for closer operational monitoring or investigation.
6. Communicate findings through an executive Tableau dashboard that supports systemwide and station-level review.

## Success Metrics

| Metric | Definition | Business purpose |
|---|---|---|
| Total trips | Number of unique completed rides | Establish overall May ridership |
| Departures | Trips beginning at a station | Measure successful demand for bikes |
| Arrivals | Trips ending at a station | Measure successful demand for docks |
| Total station activity | Departures + arrivals | Identify the busiest stations |
| Net station flow | Arrivals − departures | Show whether bikes accumulated at or left a station |
| Absolute flow imbalance | Absolute difference between arrivals and departures | Measure imbalance magnitude |
| Imbalance rate | Absolute flow imbalance ÷ total station activity | Compare imbalance across stations of different sizes |
| Peak demand period | Hour or day with the greatest trip volume | Identify periods of highest operational pressure |
| Rider-type share | Percentage of trips classified as member or casual | Compare usage across rider categories |
| Bike-type share | Percentage of trips using electric or classic bikes | Compare demand across the fleet |
| Ride duration | Time between trip start and end | Support rider-pattern analysis and outlier assessment |

Station priority will not be based on one metric alone. Later analysis should consider total activity, imbalance magnitude, imbalance rate, time of day, and whether the pattern repeats across multiple days.

## Business Questions

### System demand

1. How many Citi Bike trips were completed during May 2026?
2. Which days of the week and hours of the day experienced the highest trip demand?
3. How did demand differ between weekdays and weekends?

### Station operations

4. Which stations had the most total activity when pickups and returns are considered together?
5. Which stations had the largest differences between pickups and returns?
6. Which high-volume stations had the highest imbalance rates?
7. At what times did the largest station imbalances occur?
8. Were station imbalances consistent across the month or driven by a few unusually busy days?
9. Which stations showed greater potential bike-availability pressure because departures exceeded arrivals?
10. Which stations showed greater potential dock-availability pressure because arrivals exceeded departures?

### Rider and bike usage

11. How did trip patterns differ between member and casual rides?
12. Did member and casual rides use different stations or occur at different times?
13. How did electric- and classic-bike usage differ by rider type, time, and station?
14. How did ride duration differ across rider and bike types?

### Operational decision

15. Which station and time-period combinations should Citi Bike Operations Management prioritize for closer monitoring or further investigation?

## Assumptions

1. Each row represents one completed ride. Ride-ID completeness and uniqueness were validated in Phase 1.
2. The five source files together represent Citi Bike's official May 2026 trip release.
3. Timestamps represent New York local time.
4. Station IDs consistently identify the same stations during the analysis period.
5. A trip start represents a successful bike pickup.
6. A trip end represents a successful bike return.
7. Differences between arrivals and departures can indicate potential operational pressure but do not prove that a station became empty or full.
8. The `member_casual` field accurately classifies each trip.
9. The `member_casual` field identifies a trip category, not a unique customer.
10. May 2026 represents one month only and should not be generalized to the entire year.
11. The dataset captures successful completed trips rather than unmet demand.

### Reporting-period rule

The staging audit identified 478 rides that started April 30 and ended May 1. These records will be retained.

- April pickup events will be excluded from May departure metrics.
- May return events will be included in May arrival metrics.
- The rides may be included when measuring trips completed during May.
- The rule will be documented rather than handled through silent deletion.

## Risks and Limitations

| Risk or limitation | Analytical impact | Treatment |
|---|---|---|
| Only completed trips are recorded | Unsuccessful rental and return attempts are invisible | Describe results as demand patterns and potential pressure |
| Historical bike and dock inventory is unavailable | Empty or full stations cannot be confirmed | Avoid direct shortage claims |
| Station capacity is unavailable | Identical flows may affect stations differently | Do not equate imbalance with capacity failure |
| Rebalancing activity is unavailable | Staff may move bikes without appearing in customer trips | Treat trip flow as an indicator, not a complete inventory calculation |
| Valet and maintenance records are unavailable | Operational interventions cannot be evaluated | Recommend further investigation rather than program evaluation |
| Only May 2026 is analyzed | Seasonal and long-term patterns cannot be established | Limit conclusions to the analysis period |
| Weather and major-event data are excluded | External causes of demand changes cannot be tested | Report patterns without unsupported causal claims |
| No unique customer identifier is available | Customers and repeat riders cannot be counted | Analyze trips by rider category |
| Rider demographics are unavailable | Demographic behavior cannot be evaluated | Limit segmentation to available trip fields |
| Membership category does not establish trip purpose | Member trips cannot automatically be called commutes | Describe observed patterns without assigning motivation |
| Twenty-two rides exceeded 24 hours | Extreme values could distort duration measures | Flag them and compare duration results with and without them |
| Timestamps were imported as text | Incorrect conversion could affect time analysis | Convert and validate them in the cleaned table |
| A single monthly total may hide hourly imbalance | Balanced monthly flow may conceal peak-period pressure | Analyze station flow by date and hour |
| An imbalance may be driven by a few unusual days | One-time events could be mistaken for recurring problems | Test consistency across multiple days |

## Main Limitation Statement

> This project uses completed trip history to identify demand patterns, high-volume stations, and differences between bike pickups and returns. Because the dataset does not include historical bike availability, open-dock availability, station capacity, rebalancing activity, weather, or unmet rider demand, the findings should be interpreted as indicators of potential operational pressure rather than proof that a station was empty, full, or underperforming.

## Phase 2 Deliverable

This framework establishes what the project will measure, who will use the results, what decisions the analysis can support, and which claims the available data cannot justify. Phase 3 will examine the fields, data types, analytical usefulness, and remaining data-quality concerns before cleaning begins.

## Source

[Citi Bike System Data](https://citibikenyc.com/system-data)
