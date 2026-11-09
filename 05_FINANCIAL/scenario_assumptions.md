# Financial Model and Scenario Assumptions
## Tanjung Palma Agro-Industrial Estate (24SI1 • Group 03)

### 1. Currency and Exchange Rate Convention
- **Official Source**: Bank Indonesia — Kurs Transaksi Bank Indonesia.
- **Reference Date**: 13 Oktober 2026.
- **Official Raw Rates**:
  - Kurs Jual: **IDR 4.408,94** per 1 MYR.
  - Kurs Beli: **IDR 4.360,80** per 1 MYR.
- **Analytical Midpoint Rate**:
  $$\text{Reference Rate} = \frac{4.408,94 + 4.360,80}{2} = 4.384,87\text{ IDR per 1 MYR}$$
- **Interpretation Rule**: The exchange rate conversion is an analytical translation for performance reporting and investment evaluation, not a historical transactional accounting reconciliation.

---

### 2. Core Financial Definitions and Baseline Metrics
- **Dataset Scope**: 230 completed FFB-to-CPO lots spanning October 2024 to September 2026 (24-month horizon).
- **Revenue Recognition**:
  - Recognized strictly upon completed sale: `CPO Dispatch Confirmed`.
  - Negative adjustments: `Authorized CPO Sales Allowance` (recorded as valid negative revenue deductions resulting from customer delivery/FFA claims).
  - Net Revenue = **7.074.461,68 MYR** (**31.020.593.293,47 IDR**).
- **Operational Cost**:
  - Sum of `labor_cost`, `material_cost`, `equipment_cost`, and `overhead_cost` across all completed activities.
  - Crop production cost (MYR 4.907.350,72) is allocated once at `FFB Harvested` as feedstock material cost.
  - Total Operational Cost = **6.216.045,66 MYR** (**27.256.552.698,81 IDR**).
- **Profit Contribution**:
  $$\text{Profit Contribution} = \sum \text{Revenue Allocated} - \sum \text{Activity Total Cost} = 858.416,02\text{ MYR } (3.764.040.594,66\text{ IDR})$$
- **Average Cost per Lot**: **27.026,29 MYR** (**118.506.750,86 IDR**).

---

### 3. Scenario Methodologies & Assumptions

#### Scenario Q07: FFB Transport Scheduling
- **Objective**: 20% reduction in Transportation Waiting Time via dynamic truck-to-ramp dispatching.
- **Baseline Metric**: 7.763 minutes (129,38 hours) total transport waiting across 218 trips (avg 11,87 min/trip).
- **Operational Benefit**: 25,88 truck-hours saved (1.552,6 minutes).
- **Financial Translation & Avoidable Share**:
  - Fleet drivers and equipment operate primarily on salaried/fixed allocations.
  - Avoidable cost share is estimated at **12%** of equipment and fuel idle cost during wait states (~MYR 3.290,00).
- **Implementation Costs**:
  - Implementation CAPEX (Dispatch mobile schedule setup): MYR 6.000,00 (IDR 26.309.220,00).
  - Additional Annual OPEX: MYR 1.200,00 (IDR 5.261.844,00).
- **Net Financial Benefit**:
  $$\Delta\text{Contribution} = +3.290,00 - 6.000,00 - 1.200,00 = -3.910,00\text{ MYR } (-17.144.841,70\text{ IDR})$$
- **Business Conclusion**: Transport scheduling provides operational agility, driver satisfaction, and queue reduction, but yields a negative standalone net cash benefit under fixed asset leasing.

---

#### Scenario Q08: FFB Grading Improvement
- **Objective**: 15% reduction in FFB Rejection Rate through pre-harvest inspection and field-level ripeness grading.
- **Baseline Metric**: 29 rejected lots out of 218 harvested lots (13,30% rejection rate), creating **MYR 711.861,41** in cost leakage.
- **Physical Volume Saved**:
  $$29\text{ lots} \times 15\% = 4,35\text{ lots saved from reject dump}$$
- **Economics of Sunk Feedstock**:
  - In oil palm operations, crop growing/maintenance costs (MYR 23.277,27 per lot) are **sunk** upon harvest.
  - Converting 4,35 lots into CPO only incurs the **marginal milling cost** (MYR 5.672,06 per lot), NOT a second crop cost.
- **Incremental Revenue**:
  $$4,35\text{ lots} \times 37.431,01\text{ MYR/lot} = 162.824,89\text{ MYR } (713.966.575,11\text{ IDR})$$
- **Marginal Milling Cost**:
  $$4,35\text{ lots} \times 5.672,06\text{ MYR/lot} = 24.673,46\text{ MYR } (108.189.928,55\text{ IDR})$$
- **Implementation Costs**:
  - Portable NIR bunch maturity scanners & crew training: MYR 20.000,00 (IDR 87.697.400,00).
  - Annual device calibration & field audit OPEX: MYR 5.000,00 (IDR 21.924.350,00).
- **Net Financial Benefit**:
  $$\Delta\text{Contribution} = 162.824,89 - 24.673,46 - 20.000,00 - 5.000,00 = +113.151,43\text{ MYR } (+496.154.378,13\text{ IDR})$$
- **ROI**: **452,6%**. This represents the single highest financial impact intervention.

---

#### Scenario Q09: Milling Capacity Investment
- **Objective**: Model 15% throughput capacity expansion at the primary bottleneck (Sterilization Station).
- **Baseline Metric**: Sterilization duration totals 15.346 minutes (avg 81,20 min/lot) with 2.308 minutes queue delay.
- **Case A: Fixed Market Demand (189 Lots)**:
  - If plantation supply and off-take contracts remain fixed, incremental output is **0,00 MYR**.
  - Sterilizer cage modification CAPEX: MYR 110.000,00 (IDR 482.335.700,00).
  - Boiler steam and maintenance OPEX: MYR 15.000,00 (IDR 65.773.050,00).
  - Net Benefit: **-125.000,00 MYR** (**-548.108.750,00 IDR**).
  - *Decision*: Reject investment if demand is stagnant.
- **Case B: Growth Demand (+15% Estate Influx)**:
  - If supply expands by 28 additional lots, incremental revenue reaches MYR 530.538,32.
  - Net Benefit turns positive (+MYR 78.450,00 / IDR 344.011.746,50).

---

#### Scenario Q10: Recommended To-Be Improvement Portfolio
Combining the two most commercially robust and feasible interventions:
1. **Priority 1**: Early FFB Grading & Ripeness Protocol (Q08) — Net Benefit: **+113.151,43 MYR**.
2. **Priority 2**: CPO Quality Stabilization & Allowance Prevention (Q06) — Net Benefit: **+9.703,82 MYR**.
   - Eliminates 50% of customer sales allowances (recovers MYR 10.474,54) and reduces rework lab testing by 40% (saves MYR 8.729,28).
   - Implementation cost: MYR 8.000,00; OPEX: MYR 1.500,00.
- **Combined Net Financial Benefit**:
  $$\text{Portfolio Net Benefit} = +113.151,43 + 9.703,82 = +122.855,25\text{ MYR } (+538.704.294,02\text{ IDR})$$
- **To-Be Profit Contribution**:
  $$\text{To-Be Contribution} = 858.416,02 + 122.855,25 = 981.271,27\text{ MYR } (4.302.744.888,68\text{ IDR})$$
- **Improvement over Baseline**: **+14,31% increase** in total estate profit contribution.
