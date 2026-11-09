import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import duckdb
import pandas as pd
import numpy as np

# Set style
sns.set_theme(style='whitegrid')
plt.rcParams['font.sans-serif'] = 'DejaVu Sans'
plt.rcParams['axes.edgecolor'] = '#cccccc'
plt.rcParams['axes.linewidth'] = 0.8

con = duckdb.connect()
con.execute("CREATE OR REPLACE TABLE clean_events AS SELECT * FROM read_csv('24SI1_Group03_Palm_Oil/01_DATA/cleaned/celonis_event_log_clean.csv', header = true);")

# 1. Q01 Dominant Variants Chart
df_v = con.execute("""
WITH case_traces AS (
    SELECT 
        case_id,
        STRING_AGG(activity, ' -> ' ORDER BY TRY_CAST(timestamp AS TIMESTAMP), event_id) as trace,
        date_diff('minute', MIN(TRY_CAST(timestamp AS TIMESTAMP)), MAX(TRY_CAST(timestamp AS TIMESTAMP))) / 60.0 as throughput_hours,
        SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) as total_cost,
        SUM(TRY_CAST(revenue_allocated AS DECIMAL(18,2))) as total_rev,
        SUM(TRY_CAST(profit_contribution AS DECIMAL(18,2))) as total_contrib
    FROM clean_events
    GROUP BY case_id
),
trace_ranked AS (
    SELECT 
        trace,
        COUNT(*) as cases,
        AVG(throughput_hours) as avg_hours,
        AVG(total_cost) as avg_cost,
        AVG(total_rev) as avg_rev,
        AVG(total_contrib) as avg_contrib,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as rk
    FROM case_traces
    GROUP BY trace
)
SELECT 
    CASE 
        WHEN rk = 1 THEN 'Var 1: Happy Path Dispatched (61 lots)'
        WHEN rk = 2 THEN 'Var 2: Mill Rejection (23 lots)'
        WHEN rk = 3 THEN 'Var 3: Alt Sequence Dispatched (17 lots)'
        ELSE 'Other Variants (129 lots)'
    END as variant_group,
    SUM(cases) as cases,
    ROUND(AVG(avg_hours), 2) as avg_hours,
    ROUND(AVG(avg_cost), 2) as avg_cost,
    ROUND(AVG(avg_rev), 2) as avg_rev,
    ROUND(AVG(avg_contrib), 2) as avg_contrib
FROM trace_ranked
GROUP BY 1
ORDER BY cases DESC;
""").df()

fig, ax1 = plt.subplots(figsize=(10, 5))
x = np.arange(len(df_v))
width = 0.25

rects1 = ax1.bar(x - width, df_v['avg_cost'], width, label='Avg Cost (MYR)', color='#e74c3c')
rects2 = ax1.bar(x, df_v['avg_rev'], width, label='Avg Revenue (MYR)', color='#2ecc71')
rects3 = ax1.bar(x + width, df_v['avg_contrib'], width, label='Avg Contribution (MYR)', color='#3498db')

ax1.set_ylabel('MYR per Lot')
ax1.set_title('Q01: Process Discovery - Top Process Variants Financial Profile', fontsize=14, fontweight='bold', pad=15)
ax1.set_xticks(x)
ax1.set_xticklabels(df_v['variant_group'], rotation=10, ha='right')
ax1.legend(loc='upper right')
ax1.axhline(0, color='black', linewidth=0.8, linestyle='--')

plt.tight_layout()
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q01/Q01_dominant_variants_comparison.png', dpi=300)
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/process_variants/process_variants_distribution.png', dpi=300)
plt.close()

# 2. Q02 Outcomes and Cost Leakage
df_o = con.execute("""
WITH case_summary AS (
    SELECT 
        case_id,
        BOOL_OR(activity = 'Harvest Batch Cancelled') as is_cancelled,
        BOOL_OR(activity = 'FFB Lot Rejected') as is_rejected,
        BOOL_OR(activity = 'CPO Dispatch Confirmed') as is_dispatched,
        SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) as total_cost,
        SUM(TRY_CAST(revenue_allocated AS DECIMAL(18,2))) as total_rev,
        SUM(TRY_CAST(profit_contribution AS DECIMAL(18,2))) as total_contrib,
        SUM(CASE WHEN activity = 'FFB Harvested' THEN TRY_CAST(material_cost AS DECIMAL(18,2)) ELSE 0 END) as crop_cost
    FROM clean_events
    GROUP BY case_id
)
SELECT 
    CASE 
        WHEN is_cancelled THEN 'Cancelled (12 lots)'
        WHEN is_rejected THEN 'Rejected (29 lots)'
        WHEN is_dispatched THEN 'Processed / Dispatched (189 lots)'
    END as outcome,
    COUNT(*) as lots,
    SUM(total_cost) as total_cost,
    SUM(total_rev) as total_revenue,
    SUM(total_contrib) as total_contribution,
    SUM(crop_cost) as crop_production_cost
FROM case_summary
GROUP BY 1;
""").df()

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
colors = ['#95a5a6', '#e74c3c', '#2ecc71']
ax1.pie(df_o['lots'], labels=df_o['outcome'], autopct='%1.1f%%', colors=colors, startangle=140, explode=(0.05, 0.08, 0))
ax1.set_title('Case Outcomes Distribution (N=230 Lots)', fontweight='bold')

ax2.bar(df_o['outcome'], df_o['total_contribution'], color=['#95a5a6', '#e74c3c', '#2ecc71'])
ax2.set_ylabel('Total Profit Contribution (MYR)')
ax2.set_title('Economic Contribution by Outcome Category', fontweight='bold')
ax2.axhline(0, color='black', linewidth=0.8, linestyle='--')
for i, v in enumerate(df_o['total_contribution']):
    ax2.text(i, v + (30000 if v>=0 else -60000), f'{v:,.0f} MYR', ha='center', fontweight='bold', fontsize=9)

plt.tight_layout()
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q02/Q02_outcomes_cost_breakdown.png', dpi=300)
plt.close()

# 3. Q03 Stage Performance & SLA
df_s = con.execute("""
WITH staged_events AS (
    SELECT 
        *,
        CASE 
            WHEN activity IN ('Harvest Batch Created', 'Harvest Plan Approved', 'Harvest Batch Cancelled', 'Field Team Assigned', 'Palm Ripeness Assessed', 'FFB Harvested', 'FFB Field Grading') THEN '1. Plantation / Harvesting'
            WHEN activity IN ('Harvest Collection Dispatched', 'FFB Loaded for Transport', 'Transport to Palm Oil Mill') THEN '2. Transport & Logistics'
            WHEN activity IN ('Mill Weighbridge Inbound', 'Incoming FFB Quality Inspection', 'FFB Lot Rejected', 'FFB Receipt Accepted', 'FFB Unloaded at Sterilizer Ramp') THEN '3. Weighbridge & Reception'
            WHEN activity IN ('Steam and Boiler Readiness Checked', 'FFB Sterilization Completed', 'FFB Threshing Completed', 'Fruit Digestion Completed', 'Crude Oil Pressing Completed', 'Oil Clarification Completed', 'Oil Purification Completed', 'CPO Laboratory Tested', 'CPO Quality Rework Applied', 'Kernel Separation Completed', 'Kernel Drying Completed', 'CPO Storage Tank Updated') THEN '4. Milling & Processing'
            WHEN activity IN ('CPO Transfer Authorized', 'CPO Loaded for Dispatch', 'CPO Dispatch Confirmed', 'CPO Sales Invoice Issued', 'Buyer Remittance Matched', 'Authorized CPO Sales Allowance', 'Harvest Lot Closed') THEN '5. Dispatch & Finance'
        END as process_stage
    FROM clean_events
)
SELECT 
    process_stage,
    AVG(waiting_time_minutes) as avg_wait_min,
    AVG(activity_duration_minutes) as avg_dur_min,
    SUM(CASE WHEN sla_violation THEN 1 ELSE 0 END) as sla_violations,
    SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) as stage_cost
FROM staged_events
GROUP BY 1 ORDER BY 1;
""").df()

fig, ax1 = plt.subplots(figsize=(11, 5))
x = np.arange(len(df_s))
width = 0.35

ax1.bar(x - width/2, df_s['avg_wait_min'], width, label='Avg Waiting Time (min)', color='#e67e22')
ax1.bar(x + width/2, df_s['avg_dur_min'], width, label='Avg Duration (min)', color='#3498db')
ax1.set_ylabel('Minutes per Event')
ax1.set_title('Q03: Stage-Level Timeline: Waiting vs Processing Duration', fontsize=13, fontweight='bold')
ax1.set_xticks(x)
ax1.set_xticklabels(df_s['process_stage'], rotation=15, ha='right')
ax1.legend(loc='upper right')

# Twin axis for SLA violations
ax2 = ax1.twinx()
ax2.plot(x, df_s['sla_violations'], color='#c0392b', marker='o', linewidth=2.5, label='SLA Violations (count)')
ax2.set_ylabel('SLA Violation Count', color='#c0392b', fontweight='bold')
ax2.tick_params(axis='y', labelcolor='#c0392b')
ax2.grid(False)

plt.tight_layout()
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q03/Q03_sla_violations_and_wait_times.png', dpi=300)
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/performance_analysis/stage_performance_comparison.png', dpi=300)
plt.close()

# 4. Q04 Time-to-Mill vs Rejection Rate
df_q4 = con.execute("""
WITH harvest_times AS (
    SELECT 
        case_id,
        MIN(CASE WHEN activity = 'FFB Harvested' THEN TRY_CAST(activity_end_time AS TIMESTAMP) END) as harvest_end,
        MIN(CASE WHEN activity = 'Mill Weighbridge Inbound' THEN TRY_CAST(activity_start_time AS TIMESTAMP) END) as mill_inbound_start,
        BOOL_OR(activity = 'FFB Lot Rejected') as is_rejected,
        SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) as lot_cost
    FROM clean_events
    GROUP BY case_id
    HAVING MIN(CASE WHEN activity = 'FFB Harvested' THEN TRY_CAST(activity_end_time AS TIMESTAMP) END) IS NOT NULL
),
lot_durations AS (
    SELECT 
        case_id,
        is_rejected,
        lot_cost,
        date_diff('minute', harvest_end, mill_inbound_start) / 60.0 as harvest_to_mill_hours
    FROM harvest_times
)
SELECT 
    CASE 
        WHEN harvest_to_mill_hours < 2.0 THEN '< 2.0h'
        WHEN harvest_to_mill_hours BETWEEN 2.0 AND 3.0 THEN '2.0h - 3.0h'
        WHEN harvest_to_mill_hours BETWEEN 3.0 AND 4.0 THEN '3.0h - 4.0h'
        ELSE '> 4.0h'
    END as time_to_mill_bucket,
    COUNT(*) as total_lots,
    SUM(CASE WHEN is_rejected THEN 1 ELSE 0 END) as rejected_lots,
    SUM(CASE WHEN is_rejected THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as reject_rate_pct,
    SUM(CASE WHEN is_rejected THEN lot_cost ELSE 0 END) as rejected_cost,
    AVG(harvest_to_mill_hours) as avg_hours
FROM lot_durations
GROUP BY 1
ORDER BY avg_hours;
""").df()

fig, ax1 = plt.subplots(figsize=(9, 4.5))
bars = ax1.bar(df_q4['time_to_mill_bucket'], df_q4['reject_rate_pct'], color='#d35400', width=0.45)
ax1.set_ylabel('Rejection Rate (%)', fontweight='bold', color='#d35400')
ax1.set_xlabel('Harvest-to-Mill Duration Bucket')
ax1.set_title('Q04: Harvest-to-Mill Lead Time vs. FFB Rejection Rate', fontsize=13, fontweight='bold')
ax1.set_ylim(0, 30)

for bar in bars:
    yval = bar.get_height()
    ax1.text(bar.get_x() + bar.get_width()/2.0, yval + 0.8, f'{yval:.1f}%', ha='center', va='bottom', fontweight='bold')

plt.tight_layout()
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q04/Q04_time_to_mill_vs_rejection.png', dpi=300)
plt.close()

# 5. Q05 Milling Bottlenecks
df_q5 = con.execute("""
SELECT 
    activity,
    AVG(waiting_time_minutes) as avg_wait,
    AVG(activity_duration_minutes) as avg_dur,
    SUM(activity_duration_minutes) as total_dur,
    SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) as total_cost
FROM clean_events
WHERE activity IN ('FFB Sterilization Completed', 'Crude Oil Pressing Completed', 'Oil Clarification Completed', 'Fruit Digestion Completed', 'Oil Purification Completed', 'FFB Threshing Completed')
GROUP BY 1
ORDER BY total_dur DESC;
""").df()

fig, ax1 = plt.subplots(figsize=(10, 4.5))
y_pos = np.arange(len(df_q5))
ax1.barh(y_pos, df_q5['total_dur'] / 60.0, color='#8e44ad', height=0.55)
ax1.set_yticks(y_pos)
ax1.set_yticklabels(df_q5['activity'])
ax1.invert_yaxis()
ax1.set_xlabel('Total Station Occupancy (Hours)')
ax1.set_title('Q05: Milling Bottleneck Stations by Operational Duration', fontsize=13, fontweight='bold')

for i, v in enumerate(df_q5['total_dur'] / 60.0):
    ax1.text(v + 3, i, f'{v:.1f} hrs ({df_q5["avg_dur"].iloc[i]:.1f} min/lot)', va='center', fontweight='bold', fontsize=9)

plt.tight_layout()
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q05/Q05_milling_facility_bottlenecks.png', dpi=300)
plt.close()

# 6. Q06 Rework and Allowances
df_q6 = pd.DataFrame({
    'Category': ['CPO Quality Rework', 'CPO Retesting (Lab)', 'FFB Regrading', 'Sales Allowances (Deduction)'],
    'Impact_MYR': [18469.49, 2308.02, 1045.68, 20949.08],
    'Type': ['Operational Cost', 'Operational Cost', 'Operational Cost', 'Revenue Penalty']
})

fig, ax = plt.subplots(figsize=(9, 4.5))
colors = ['#e74c3c' if t == 'Operational Cost' else '#c0392b' for t in df_q6['Type']]
bars = ax.bar(df_q6['Category'], df_q6['Impact_MYR'], color=colors, width=0.45)
ax.set_ylabel('Total Financial Impact (MYR)', fontweight='bold')
ax.set_title('Q06: Breakdown of Rework Expenses and Sales Allowances', fontsize=13, fontweight='bold')
ax.set_xticks(range(len(df_q6)))
ax.set_xticklabels(df_q6['Category'], rotation=10, ha='right')

for bar in bars:
    yval = bar.get_height()
    ax.text(bar.get_x() + bar.get_width()/2.0, yval + 300, f'{yval:,.2f} MYR', ha='center', va='bottom', fontweight='bold', fontsize=9)

plt.tight_layout()
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q06/Q06_rework_and_sales_allowances.png', dpi=300)
plt.close()

# 7. Q07 Transport Scheduling Scenario
df_q7 = pd.DataFrame({
    'Metric': ['Baseline (As-Is)', 'Optimized (To-Be -20% Wait)'],
    'Transport_Wait_Hours': [129.38, 103.50],
    'Avoidable_Savings_MYR': [0.00, 3290.00],
    'Net_Benefit_MYR': [0.00, -3910.00]
})

fig, ax = plt.subplots(figsize=(8, 4))
bars = ax.bar(df_q7['Metric'], df_q7['Transport_Wait_Hours'], color=['#34495e', '#27ae60'], width=0.4)
ax.set_ylabel('Total Truck Waiting Hours', fontweight='bold')
ax.set_title('Q07: FFB Transport Scheduling Impact on Waiting Time', fontsize=13, fontweight='bold')
for bar in bars:
    yval = bar.get_height()
    ax.text(bar.get_x() + bar.get_width()/2.0, yval + 2, f'{yval:.1f} hrs (-20%)' if yval < 120 else f'{yval:.1f} hrs', ha='center', va='bottom', fontweight='bold')

plt.tight_layout()
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q07/Q07_transport_scheduling_scenario.png', dpi=300)
plt.close()

# 8. Q08 Rejection Reduction Scenario
df_q8 = pd.DataFrame({
    'Component': ['Incremental Revenue', 'Marginal Milling Cost', 'Implementation CAPEX', 'Additional OPEX', 'Net Financial Benefit'],
    'Amount_MYR': [162824.89, -24673.46, -20000.00, -5000.00, 113151.43]
})

fig, ax = plt.subplots(figsize=(10, 4.5))
colors = ['#2ecc71', '#e74c3c', '#e67e22', '#e67e22', '#27ae60']
bars = ax.bar(df_q8['Component'], df_q8['Amount_MYR'], color=colors, width=0.45)
ax.axhline(0, color='black', linewidth=0.8, linestyle='--')
ax.set_ylabel('Financial Amount (MYR)', fontweight='bold')
ax.set_title('Q08: Prescriptive FFB Grading Improvement Financial Waterfall', fontsize=13, fontweight='bold')
ax.set_xticks(range(len(df_q8)))
ax.set_xticklabels(df_q8['Component'], rotation=10, ha='right')

for bar in bars:
    yval = bar.get_height()
    va = 'bottom' if yval >= 0 else 'top'
    offset = 4000 if yval >= 0 else -8000
    ax.text(bar.get_x() + bar.get_width()/2.0, yval + offset, f'{yval:+,.2f} MYR', ha='center', va=va, fontweight='bold', fontsize=9)

plt.tight_layout()
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q08/Q08_ffb_rejection_reduction_model.png', dpi=300)
plt.close()

# 9. Q09 Capacity Investment
df_q9 = pd.DataFrame({
    'Scenario': ['Fixed Demand (189 lots)', 'Expanded Demand (+15% lots)'],
    'Net_Benefit_MYR': [-125000.00, 78450.00]
})

fig, ax = plt.subplots(figsize=(8, 4))
colors = ['#e74c3c', '#2ecc71']
bars = ax.bar(df_q9['Scenario'], df_q9['Net_Benefit_MYR'], color=colors, width=0.4)
ax.axhline(0, color='black', linewidth=0.8, linestyle='--')
ax.set_ylabel('Net Financial Benefit (MYR)', fontweight='bold')
ax.set_title('Q09: Milling Capacity Investment Viability by Market Demand', fontsize=13, fontweight='bold')

for bar in bars:
    yval = bar.get_height()
    va = 'bottom' if yval >= 0 else 'top'
    offset = 3000 if yval >= 0 else -8000
    ax.text(bar.get_x() + bar.get_width()/2.0, yval + offset, f'{yval:+,.0f} MYR', ha='center', va=va, fontweight='bold')

plt.tight_layout()
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q09/Q09_milling_capacity_investment_model.png', dpi=300)
plt.close()

# 10. Q10 Business Case Ranking
df_q10 = pd.DataFrame({
    'Improvement': ['P1: FFB Early Grading (Q08)', 'P2: CPO Quality Stabilization (Q06)', 'P3: Transport Scheduling (Q07)', 'P4: Mill Capacity CAPEX (Q09)'],
    'Net_MYR': [113151.43, 9703.82, -3910.00, -125000.00],
    'Net_IDR_Juta': [496.15, 42.55, -17.14, -548.11]
})

fig, ax = plt.subplots(figsize=(10, 5))
colors = ['#27ae60', '#2ecc71', '#e67e22', '#e74c3c']
bars = ax.barh(df_q10['Improvement'], df_q10['Net_MYR'], color=colors, height=0.5)
ax.axvline(0, color='black', linewidth=0.8, linestyle='--')
ax.set_xlabel('Net Financial Benefit (MYR)', fontweight='bold')
ax.set_title('Q10: Estate-to-Mill Process Improvement Priority Ranking', fontsize=13, fontweight='bold')
ax.invert_yaxis()

for i, bar in enumerate(bars):
    xval = bar.get_width()
    ha = 'left' if xval >= 0 else 'right'
    offset = 3000 if xval >= 0 else -4000
    ax.text(xval + offset, i, f'{xval:+,.2f} MYR\n(~{df_q10["Net_IDR_Juta"].iloc[i]:+,.1f} Juta IDR)', va='center', ha=ha, fontweight='bold', fontsize=8.5)

plt.tight_layout()
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q10/Q10_business_case_ranking_myr_idr.png', dpi=300)
plt.close()

# Process Map Overview Chart
fig, ax = plt.subplots(figsize=(14, 6))
stages = ['1. Plantation\n& Harvest', '2. Transport\n& Weighbridge', '3. Threshing &\nSterilization', '4. Pressing &\nClarification', '5. Storage, Dispatch\n& Collection']
stage_dur = [4.5, 2.8, 2.5, 3.2, 1.8]
stage_cost = [22800, 750, 1500, 1900, 350]

ax.plot(stages, stage_dur, marker='s', markersize=10, linewidth=2.5, color='#2980b9', label='Avg Duration (Hours)')
ax.set_ylabel('Avg Stage Duration (Hours)', color='#2980b9', fontweight='bold')
ax.tick_params(axis='y', labelcolor='#2980b9')

ax2 = ax.twinx()
ax2.bar(stages, stage_cost, alpha=0.3, color='#e67e22', width=0.4, label='Avg Operational Cost (MYR)')
ax2.set_ylabel('Avg Operational Cost (MYR)', color='#d35400', fontweight='bold')
ax2.tick_params(axis='y', labelcolor='#d35400')
ax2.grid(False)

plt.title('End-to-End Harvest-to-CPO Process Discovery Map (Overview Timeline & Cost)', fontsize=13, fontweight='bold', pad=15)
plt.tight_layout()
plt.savefig('24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/process_map/process_map_overview.png', dpi=300)
plt.close()

print('ALL CHARTS CREATED SUCCESSFULLY!')
