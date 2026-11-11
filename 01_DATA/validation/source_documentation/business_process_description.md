# Fresh Fruit Bunch (FFB) Harvest-to-Crude Palm Oil (CPO) Dispatch

**Unit of analysis:** one planned FFB harvest batch tracked to a processing lot (not an individual palm tree).
**Case start:** Harvest Batch Created. **Case finish:** Harvest Lot Closed.
**One row:** completed activity with ready, start, and end timestamps; timestamp=end.

**Main route:** Harvest Batch Created → Harvest Plan Approved → Field Team Assigned →
Palm Ripeness Assessed → FFB Harvested → FFB Field Grading [→ FFB Field Grading again]
→ FFB Loaded for Transport → Transport to Palm Oil Mill → Mill Weighbridge Inbound
→ Incoming FFB Quality Inspection → FFB Receipt Accepted → FFB Unloaded at Sterilizer Ramp
+ Steam and Boiler Readiness Checked → FFB Sterilization Completed → FFB Threshing Completed
→ Fruit Digestion Completed → Crude Oil Pressing Completed →
{Oil Clarification → Oil Purification → CPO Laboratory Tested [→ Quality Rework → Lab Retest]
|| Kernel Separation → Kernel Drying} → CPO Storage Tank Updated →
CPO Transfer Authorized → CPO Loaded for Dispatch → CPO Dispatch Confirmed
→ CPO Sales Invoice Issued → Buyer Remittance Matched [→ Authorized CPO Sales Allowance]
→ Harvest Lot Closed.

Alternate paths are cancellation after approval and rejection following mill intake assessment.
Some accepted lots genuinely bypass incoming inspection; treat that as an operational control deviation,
not as data corruption or a recommendation for real-world processing. A legitimate repeated field grade
or repeat lab test is a new activity execution. Oil and kernel operations can overlap with distinct resources.

**Money:** MYR (RM), two decimals. Self-grown FFB feedstock has its crop-production cost allocated once at harvest, including subsequently rejected lots. Revenue is recognized once at CPO Dispatch Confirmed,
with separately identified negative allowances. Invoicing and remittance do not re-recognize sales.
Facility and employee slots have capacity 1 and may cause real waits. These are simulated assumptions.
