# Phase 2: Business Understanding

**Status: Complete**

This phase defines the decision the analysis should support, the people who would use the results, the measures needed, and the limits of what the available data can prove.

## Business Context

Citi Bike is a station-based bike-share system. Riders need a bike when beginning a trip and an open dock when ending one. Demand is not evenly distributed across stations or time periods, so operational pressure may shift throughout the network during the day.

The May 2026 trip data records completed rides, including when and where bikes were picked up and returned. It does not include historical bike inventory, open-dock inventory, station capacity, unsuccessful rental attempts, or bike movements performed by operations teams.

## Main Business Question

> Which Citi Bike stations are busiest, when is demand highest, and where do pickup and return patterns suggest a need for closer operational monitoring?

## Business Problem

A station with substantially more departures than arrivals may experience pressure on bike availability. A station with more arrivals than departures may experience pressure on dock availability.

This project will use May 2026 trip activity to identify high-volume stations, peak periods, and recurring differences between pickups and returns. The analysis is intended to help Citi Bike decide where closer monitoring, rebalancing, or further operational investigation may be useful.

Trip records alone cannot confirm that a station became empty or full. Findings will therefore be described as indicators of potential operational pressure rather than confirmed service failures.

## Stakeholders

| Stakeholder | How the analysis could be used |
|---|---|
| Citi Bike Operations Management | Prioritize stations and time periods for monitoring or rebalancing |
| Rebalancing and field operations teams | Understand where and when pickup and return patterns diverge |
| Citi Bike executive leadership | Review system performance, operational risks, and resource priorities |
| Customer experience team | Investigate patterns that may affect access to bikes or open docks |
| New York City Department of Transportation | Review system use and operational accountability |
| Citi Bike riders | Benefit from more reliable access to bikes and docks |

Valet operations is not listed separately because the trip data does not identify valet locations, operating hours, or valet-handled bikes.

## Business Objectives

1. Identify the days and hours with the highest trip demand.
2. Rank the busiest stations using both departures and arrivals.
3. Identify stations where pickups and returns differ substantially.
4. Compare usage patterns for members, casual riders, electric bikes, and classic bikes.
5. Prioritize station and time-period combinations for closer operational review.
6. Present the findings in an executive Tableau dashboard.

## Success Metrics

| Metric | Definition | Decision supported |
|---|---|---|
| Total trips | Number of unique completed rides | Establish overall May activity |
| Departures | Trips beginning at a station | Measure successful bike pickups |
| Arrivals | Trips ending at a station | Measure successful bike returns |
| Total station activity | Departures + arrivals | Identify the busiest stations |
| Net station flow | Arrivals − departures | Show the direction of station flow |
| Absolute flow imbalance | Absolute difference between arrivals and departures | Measure the size of an imbalance |
| Imbalance rate | Absolute imbalance ÷ total station activity | Compare stations of different sizes |
| Peak demand period | Hour or day with the most trips | Identify periods of greatest operational pressure |
| Rider-type share | Percentage of member or casual trips | Compare rider categories |
| Bike-type share | Percentage of electric or classic-bike trips | Compare fleet usage |
| Ride duration | Time between trip start and end | Analyze ride patterns and assess outliers |

I will not label a station as an operational priority based on one measure alone. A busy station may naturally have a large difference between pickups and returns, while a smaller station may have a high imbalance rate based on relatively few trips. Station activity, imbalance size and direction, time of day, and consistency across the month will be considered together.

## Business Questions

### System demand

1. How many trips were completed during May 2026?
2. Which days and hours had the highest trip demand?
3. How did weekday and weekend demand differ?

### Station operations

4. Which stations had the most activity across pickups and returns?
5. Which stations had the largest differences between pickups and returns?
6. Which high-volume stations also had high imbalance rates?
7. When did the largest station imbalances occur?
8. Did those imbalances repeat or come from a few unusual days?
9. Where did departures exceed arrivals, suggesting possible bike-availability pressure?
10. Where did arrivals exceed departures, suggesting possible dock-availability pressure?

### Rider and bike usage

11. How did member and casual trip patterns differ?
12. Did member and casual trips occur at different stations or times?
13. How did electric- and classic-bike use differ by rider type, time, and station?
14. How did ride duration vary by rider and bike type?

### Operational decision

15. Which station and time-period combinations should operations managers investigate first?

## Assumptions

- Each row represents one completed ride. Ride ID completeness and uniqueness were validated in Phase 1.
- The five source files together represent Citi Bike's May 2026 trip release.
- Timestamps use New York local time.
- Station IDs identify the same stations throughout the month.
- A trip start represents a successful bike pickup, and a trip end represents a successful return.
- Pickup and return differences may signal operational pressure but do not prove a station was empty or full.
- `member_casual` classifies the trip, not a unique customer.
- One month of activity should not be generalized to the entire year.
- The data contains successful completed trips, not unmet demand.

### Reporting-Period Rule

The staging audit found 478 rides that started April 30 and ended May 1. I will retain these records and use an event-based reporting rule:

- April pickups will be excluded from May departure measures.
- May returns will be included in May arrival measures.
- The rides may be included when measuring trips completed during May.
- The rule will be documented instead of handled through silent deletion.

## Risks and Limitations

| Limitation | Effect on the analysis | Treatment |
|---|---|---|
| Only completed trips are recorded | Unsuccessful pickup and return attempts are invisible | Describe demand patterns, not unmet demand |
| Historical inventory is unavailable | Empty and full stations cannot be confirmed | Use potential-pressure language |
| Station capacity is unavailable | Similar flows may affect stations differently | Do not treat imbalance as proof of failure |
| Rebalancing activity is unavailable | Customer trip flow is not a complete inventory calculation | Recommend further operational investigation |
| Valet and maintenance records are unavailable | Operational interventions cannot be evaluated | Do not evaluate programs without supporting data |
| Only May 2026 is included | Seasonal and long-term patterns cannot be established | Limit conclusions to the analysis period |
| Weather and event data are excluded | Causes of demand changes cannot be tested | Avoid unsupported causal claims |
| No customer identifier is available | Unique riders and repeat behavior cannot be measured | Analyze trips by rider category |
| Membership does not reveal trip purpose | Member trips cannot automatically be called commutes | Describe observed timing without assigning motivation |
| Twenty-two rides exceeded 24 hours | Extreme values may distort duration measures | Compare results with and without flagged rides |
| Timestamps were imported as text | Incorrect conversion could affect time analysis | Convert and validate them in the cleaned table |
| Monthly totals may hide hourly pressure | A station can appear balanced across the month but not within the day | Analyze flow by date and hour |

## Main Limitation

> This project uses completed trip history to identify demand patterns, busy stations, and differences between pickups and returns. Without historical inventory, station capacity, rebalancing records, weather, or unmet-demand data, the findings can indicate potential operational pressure but cannot prove that a station was empty, full, or underperforming.

## What This Phase Accomplished

Phase 2 established the business decision, stakeholder needs, success measures, analytical questions, assumptions, and claim boundaries for the project. This prevents the SQL analysis and Tableau dashboard from becoming a collection of disconnected charts.

The next phase will review each field, its data type, its analytical value, and any remaining quality concerns before cleaning begins.

## Source

[Citi Bike System Data](https://citibikenyc.com/system-data)
