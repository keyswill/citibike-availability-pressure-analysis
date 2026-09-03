# Exploratory Findings and Executive Recommendations

## Executive Summary

This analysis examined 4,674,903 Citi Bike trip records from the May 2026 data release to identify when demand was highest, how usage differed by rider and bike type, which stations handled the most activity, and where pickup and return patterns suggested potential availability pressure.

The results show two distinct demand patterns. Weekdays were shaped by concentrated morning and evening peaks consistent with commuting, while weekend activity was distributed more broadly across midday and afternoon. Members dominated total ridership, but casual riders represented a larger share of weekend use and took longer trips. Electric bikes accounted for more than 70% of rides across both rider groups.

Monthly station totals appeared relatively balanced, but that view concealed substantial hourly reversals. Several stations received far more bikes than they released during morning hours and then experienced the opposite pattern in the evening. These station-hour differences provide a stronger operational signal than monthly net flow alone.

The recommended response is a targeted monitoring and rebalancing pilot focused on recurring station-hour reversals, supported by separate weekday and weekend operating schedules. These findings identify where operational teams should investigate first; they do not prove that a station was empty or full because the trip data does not include live inventory or dock capacity.

## Decision Supported

> Which stations and time periods should Citi Bike operations teams monitor or investigate first when planning availability support and rebalancing activity?

## Scope and Metric Definitions

- **Records in the May release:** All 4,674,903 cleaned trip records.
- **May departures:** 4,674,425 rides with pickup timestamps in May.
- **May arrivals:** 4,674,903 rides with return timestamps in May.
- **Boundary rides:** 478 rides that started April 30 and ended May 1.
- **Net flow:** Arrivals minus departures for a station or station-hour combination.
- **Potential accumulation:** More arrivals than departures during the measured period.
- **Potential depletion:** More departures than arrivals during the measured period.

Departure analyses use `starts_in_may = 1`, while arrival analyses use `ends_in_may = 1`. This preserves the correct reporting event for the 478 boundary rides.

## Validated Findings

### 1. Demand was stronger on weekdays

| Day type | Days | Total departures | Average departures per day |
|---|---:|---:|---:|
| Weekday | 21 | 3,412,531 | 162,501.48 |
| Weekend | 10 | 1,261,894 | 126,189.40 |

Average weekend demand was 22.35% lower than average weekday demand. May 29 was the busiest date with 190,977 departures, while May 24 was the slowest with 42,423.

The unusually low totals on May 23 and May 24 require external investigation before they are treated as normal weekend demand. The trip data alone cannot determine whether weather, service conditions, events, or another factor caused the decline.

### 2. Hourly patterns differed between weekdays and weekends

Overall demand peaked at 5 p.m., when 440,657 rides began. The 5–7 p.m. period accounted for 855,327 departures, or 18.30% of all May departures.

Weekday demand showed two clear peaks:

- 8 a.m.: 12,186.57 average departures per weekday
- 5 p.m.: 16,699.62 average departures per weekday
- 6 p.m.: 15,729.90 average departures per weekday

Weekend demand rose more gradually and remained elevated from midday through the afternoon. Its highest average occurred at 1 p.m., with 9,867.50 departures per weekend day.

The timing is consistent with commute-oriented weekday travel and more flexible weekend use. Trip-purpose data would be required to confirm those explanations.

### 3. Casual demand became more important on weekends

| Measure | Weekday | Weekend |
|---|---:|---:|
| Member share | 83.75% | 76.27% |
| Casual share | 16.25% | 23.73% |
| Average daily member departures | 136,092.71 | 96,239.70 |
| Average daily casual departures | 26,408.76 | 29,949.70 |

Compared with weekdays:

- Average member demand decreased 29.28% on weekends.
- Average casual demand increased 13.41% on weekends.
- Casual riders gained 7.48 percentage points of total rider share.

Members showed the stronger morning pattern: 18.77% of member rides occurred from 6–9 a.m., compared with 10.54% of casual rides. Casual demand was more concentrated from midday through the afternoon and represented a larger share of late-night use.

### 4. Electric bikes supported most trips

| Rider type | Electric-bike share | Classic-bike share |
|---|---:|---:|
| Member | 71.27% | 28.73% |
| Casual | 75.88% | 24.12% |

Electric bikes represented 72.11% of all records in the May release and dominated departures during every hour. Their share was 4.61 percentage points higher among casual riders than members.

This result measures observed use, not unconstrained rider preference. The dataset does not show how many electric and classic bikes were available when each rider selected a bike.

### 5. Most rides were short, but casual trips lasted longer

| Duration band | Departures | Share |
|---|---:|---:|
| Under 5 minutes | 995,374 | 21.29% |
| 5–14 minutes | 2,362,545 | 50.54% |
| 15–29 minutes | 993,758 | 21.26% |
| 30–59 minutes | 280,998 | 6.01% |
| 60 minutes–24 hours | 41,728 | 0.89% |
| Over 24 hours | 22 | Less than 0.01% |

The average ride lasted 13.06 minutes. Excluding the 22 rides over 24 hours reduced that figure to 13.05 minutes, demonstrating that these exceptions did not materially distort the overall average.

| Rider and bike type | Average minutes, excluding rides over 24 hours |
|---|---:|
| Casual, classic bike | 22.80 |
| Casual, electric bike | 17.65 |
| Member, classic bike | 11.65 |
| Member, electric bike | 11.78 |

Casual electric-bike rides lasted approximately 50% longer than member electric-bike rides. Casual classic-bike rides lasted approximately 96% longer than member classic-bike rides.

### 6. A small group of stations handled the highest overall activity

| Rank | Station | Departures | Arrivals | Total activity |
|---:|---|---:|---:|---:|
| 1 | W 21 St & 6 Ave | 16,566 | 16,643 | 33,209 |
| 2 | Cooper Square & Astor Pl | 16,233 | 16,264 | 32,497 |
| 3 | Pier 61 at Chelsea Piers | 16,038 | 16,089 | 32,127 |
| 4 | Broadway & E 14 St | 14,068 | 14,147 | 28,215 |
| 5 | E 17 St & Broadway | 13,383 | 13,457 | 26,840 |

High activity increases the potential impact of downtime or availability problems, but it does not by itself demonstrate a need for rebalancing.

### 7. Monthly net flow concealed meaningful hourly reversals

The largest absolute monthly net flow among stations with at least 1,000 activities was 569 rides at Greenwich St & W Houston St. That represented only 4.06% of its 14,017 monthly activities.

Hour-level analysis revealed much stronger directional patterns:

| Station | Morning signal | Evening signal |
|---|---|---|
| 9 Ave & W 33 St | +1,324 net arrivals at 8 a.m.; +1,079 at 9 a.m. | −1,705 net flow at 5 p.m. |
| North Moore St & Greenwich St | +910 at 6 a.m.; +1,087 at 7 a.m. | −1,113 at 4 p.m.; −989 at 5 p.m. |
| E 47 St & Park Ave | +803 at 7 a.m.; +816 at 8 a.m. | −983 at 5 p.m. |
| Dock 72 Way & Market St | +700 at 8 a.m.; +651 at 9 a.m. | −776 at 5 p.m. |
| E 50 St & Park Ave | +842 at 8 a.m. | −738 at 5 p.m.; −736 at 6 p.m. |

A positive value indicates more arrivals than departures and therefore potential bike accumulation or dock pressure. A negative value indicates potential bike depletion. These opposing patterns can cancel when summarized across an entire month.

## Executive Recommendations

### Priority 1: Pilot station-hour monitoring at recurring reversal locations

Begin with:

1. 9 Ave & W 33 St
2. North Moore St & Greenwich St
3. E 47 St & Park Ave
4. Dock 72 Way & Market St
5. E 50 St & Park Ave

Monitor open docks during morning net-inflow periods and available bikes during evening net-outflow periods. These stations repeatedly appeared among the largest hour-level imbalances and therefore provide the clearest starting point for an operational pilot.

**Success measures:** empty-station minutes, full-station minutes, unsuccessful rental attempts, unsuccessful return attempts, and the number of emergency rebalancing interventions.

### Priority 2: Use separate weekday and weekend operating schedules

Concentrate weekday field coverage around 7–9 a.m. and 4–7 p.m. Shift weekend monitoring toward midday and afternoon, when demand is more broadly distributed and casual usage is more prominent.

This schedule should be tested against live inventory before staffing or vehicle routes are permanently changed.

**Success measures:** bike and dock availability during peak windows, response time to station alerts, and completed trips during historically high-demand periods.

### Priority 3: Establish a high-activity station service tier

Prioritize W 21 St & 6 Ave, Cooper Square & Astor Pl, Pier 61 at Chelsea Piers, Broadway & E 14 St, and E 17 St & Broadway for reliability monitoring and preventive maintenance.

These stations are not necessarily the most imbalanced, but an outage or sustained availability problem at a high-throughput location would affect more trips.

**Success measures:** station uptime, unresolved maintenance time, trips served, and availability alerts per 1,000 station activities.

### Priority 4: Align electric-bike support with observed workload

Electric bikes supported more than 70% of observed trips across both rider groups. Charging, battery rotation, maintenance capacity, and field support should reflect that workload.

Fleet allocation should not be changed solely from these shares. Availability data is needed to distinguish rider preference from the greater supply of electric bikes.

**Success measures:** electric-bike availability, charging turnaround time, out-of-service rate, maintenance incidents, and trips per available electric bike.

### Priority 5: Plan separately for weekend casual demand

Weekend operations should account for the increase in casual volume and longer average ride durations. Longer trips keep bikes away from stations for more time and may change where and when bikes return.

Use clearer visitor-facing station guidance and monitor midday availability near high-casual-demand locations once rider-by-station results or live inventory become available.

**Success measures:** casual trip completions, average bike cycle time, midday availability, and unsuccessful rental or return attempts.

### Priority 6: Investigate abnormal dates before forecasting or staffing decisions

May 23 and May 24 should be linked to weather, service alerts, planned events, and station outages before the month is used as a staffing or demand-forecasting baseline. Treating those values as normal could understate expected weekend demand.

**Success measures:** documented explanation for anomalous dates and a forecasting dataset with verified event and weather features.

## Recommended Pilot Sequence

| Stage | Action | Purpose |
|---|---|---|
| 1 | Add live inventory, dock capacity, and outage data | Confirm whether trip-flow signals correspond to actual shortages |
| 2 | Monitor the five priority stations for two to four weeks | Establish baseline empty/full station time by hour |
| 3 | Test targeted interventions during identified peak windows | Measure whether timing-specific support improves availability |
| 4 | Compare intervention stations with similar untreated stations | Separate intervention effects from normal demand variation |
| 5 | Expand only if availability and completion metrics improve | Avoid scaling an unvalidated operating rule |

## Limitations

- Trip records describe completed rides, not unmet demand.
- The data does not include live bike inventory, open docks, station capacity, outages, or operational bike movements.
- One month cannot establish seasonality or long-term demand patterns.
- Weather, holidays, service disruptions, and local events were not included.
- Rider purpose is inferred from timing and membership category; it is not directly observed.
- Electric-bike usage may reflect fleet availability rather than preference.
- Station-hour results combine all dates in the month; a production operating plan should distinguish weekdays, weekends, and exceptional dates.

## Conclusion

The strongest operational finding is not that certain stations were globally unbalanced. It is that monthly balance can hide predictable, time-specific directional pressure. A focused pilot using live station data at the recurring reversal locations would allow Citi Bike to determine whether those trip patterns translate into actual dock shortages or bike shortages and whether targeted monitoring or rebalancing improves service availability.

The next project deliverable is an executive Tableau dashboard that communicates demand timing, rider and bike patterns, high-activity stations, and priority station-hour signals without presenting trip-flow proxies as confirmed inventory failures.
