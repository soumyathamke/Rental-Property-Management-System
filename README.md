# Rental-Property-Management-System
Real-world rental property management system built in MySQL. Tracks tenant details, monthly rent payments, and maintenance requests across 2 units. Includes 7 SQL queries, 3 stored procedures for automated payment flagging, and a Power BI dashboard for property performance reporting.


# Rental Property Management & Analytics System

![MySQL](https://img.shields.io/badge/MySQL-Database-blue)
![SQL](https://img.shields.io/badge/SQL-Queries%20%26%20Stored%20Procedures-lightblue)
![Power BI](https://img.shields.io/badge/PowerBI-Dashboard-yellow)
![Excel](https://img.shields.io/badge/Excel-Reporting-green)

**Author:** Soumya Thamke  
**Tools:** MySQL · MS Excel · Power BI

---

## Objective

To design and implement a relational database system to manage real-world rental property data across 2 units — a single-room unit (₹7,000/month) and a 2BHK unit (₹25,000/month) — tracking tenant details, monthly rent payments, and maintenance requests. Query outputs are exported to Excel and visualised in Power BI for property performance reporting.

---

## Database Structure

5 tables, all linked via foreign keys:

```
Owner
  └── Properties
        └── Tenants
              └── Payments
        └── Maintenance_Requests
```

### Tables

| Table | Description |
|---|---|
| `Owner` | Property owner details |
| `Properties` | Two rental units — 1 Room with Bathroom & Kitchen (₹7,000/month) and 2BHK (₹25,000/month) |
| `Tenants` | Tenant info, lease dates, security deposit, payment mode |
| `Payments` | Monthly rent records — amount due, amount paid, status (Paid/Pending/Late/Partial) |
| `Maintenance_Requests` | Issue type, repair cost, who raised it, resolution status |

### Constraints used
- `PRIMARY KEY`, `FOREIGN KEY` — referential integrity across all tables
- `NOT NULL` — mandatory fields enforced at database level
- `CHECK` — rent amount > 0, security deposit >= 0
- `ENUM` — controlled values for status, payment mode, paid_by fields
- `DEFAULT` — auto-set status to Pending, properties to Vacant on insert

---

## SQL Queries

| # | Query | Purpose |
|---|---|---|
| 1 | Monthly rent collection status | Full payment breakdown per tenant per month |
| 2 | Outstanding payments | Filter Pending and Partial payments |
| 3 | Revenue collected vs expected | Total per month with outstanding amount |
| 4 | Occupancy status | Which properties are occupied, by whom, lease dates |
| 5 | Leases expiring in 90 days | Proactive lease renewal tracking |
| 6 | Maintenance cost by property | Total requests, cost, open issues per unit |
| 7 | Late payment history | Days late per payment, sorted by severity |

---

## Stored Procedures

### `flag_overdue_payments()`
Automatically updates all pending payments past their due date to `Late`, then returns a report showing tenant name, unit type, payment month, amount due, and due date.

```sql
CALL flag_overdue_payments();
```

### `record_payment(tenant_id, month, amount_paid, payment_date)`
Logs a rent payment and auto-sets status based on amount and date — Paid, Late, or Partial.

```sql
CALL record_payment(1, '2025-03', 7000.00, '2025-03-06');
```

### `monthly_collection_report(month)`
Returns a full collection summary for any given month — tenant, unit type, amount due, amount paid, status.

```sql
CALL monthly_collection_report('2025-03');
```

---

## Power BI Dashboard

Query outputs exported to Excel and loaded into Power BI. Dashboard tracks:

- **Occupancy rate** — occupied vs vacant units
- **Monthly revenue collected vs expected** — ₹32,000 total per month
- **Payment status breakdown** — Paid / Pending / Late / Partial
- **Outstanding dues** — per tenant, per month
- **Maintenance cost trend** — by unit and issue type

---

## How to Run

1. Download and install [MySQL Workbench](https://www.mysql.com/products/workbench/) and [MySQL Server](https://dev.mysql.com/downloads/mysql/)
2. Clone this repo
   ```bash
   git clone https://github.com/soumyathamke/rental-property-management.git
   ```
3. Open `rental_property_final.sql` in MySQL Workbench
4. Run the full script — it creates the database, tables, sample data, queries, and stored procedures
5. Replace sample tenant data with real data as needed

---

## Key Facts

- Total expected monthly rent: **₹32,000** (₹7,000 + ₹25,000)
- Payment mode: **Cash only**
- Maintenance costs are fully borne by tenants
- Stored procedure auto-flags late payments — no manual tracking needed
