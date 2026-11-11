# Synthetic Palm Oil Plantation and Mill — Student Context

Tanjung Palma Agro-Industrial Estate is a **fictional** integrated oil-palm estate and crude palm oil mill.
The data represent fictional FFB harvest lots (plantation inspection, transport, milling, lab quality,
oil and kernel recovery, tank transfer, sales and collection). Source data span several departments
and contain intentionally imperfect transactional representations; master datasets are authoritative.

The **24-month arrival window** is 2024-10-01 through 2026-09-30 (UTC). Every simulated case is
completed; a case's downstream events may occur outside the arrival window. Employee and equipment
slots are virtual continuous-availability resources; do not infer real employee shift coverage.
Cost, CPO yields, prices, quality grades, queues and seasonality are illustrative teaching assumptions,
not agronomic benchmarks. Core financial amounts are **MYR**, canonical two decimal places.

All dates with day first mean **DD/MM/YYYY**, never month/day/year. Preferred timestamp:
`YYYY-MM-DD HH:MM:SS`, with UTC understood despite absence of an offset in CSV.
One event row represents completion of one activity; raw-row ID identifies an extraction row,
while event ID identifies a unique actual execution. An optional empty exception is valid.
