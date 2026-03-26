# E-Commerce Profitability Analysis

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue) ![Status](https://img.shields.io/badge/Status-Completed-brightgreen) ![Period](https://img.shields.io/badge/Period-2024--2025-orange)

Analyzing profitability across product categories, sales channels, return rates, and marketing platforms — for a multi-channel e-commerce operation between 2024 and 2025.

---

## 1. Project Background

This project analyzes a fictional e-commerce business selling products across 8 categories through four sales channels: Website, Mobile App, Marketplace, and Social Commerce. Despite generating gross revenue across 2,000 orders, the average profit margin sits at only 20.3% — raising the question of where margin is being lost and how to fix it.

Marketing spend of $503,506 is spread across 6 platforms with widely varying returns. Some platforms are generating 24x ROAS while others barely break 5x. Some product categories deliver 31% margins while others struggle to reach 12%.

As a fresher data analyst, I chose this dataset because profitability analysis — combining revenue, cost structures, return rates, and marketing ROI — reflects real decision-making at e-commerce companies, and requires applying business logic across multiple joined tables.

This project uses SQL (PostgreSQL) for all data cleaning, validation, and analysis across three source tables: `orders`, `products`, and `marketing_spend`.

---

## 2. Data Structure & Initial Checks

| Table | Rows | Description |
|---|---|---|
| `orders.csv` | 2,000 | One row per customer order — revenue, costs, channel, category, returns |
| `products.csv` | — | Product catalog — unit cost, selling price, shipping cost per unit |
| `marketing_spend.csv` | — | Monthly ad spend by platform — ROAS, CPA, CPC, impressions, conversions |

**Key metrics at a glance:**

| Total Orders | Avg Profit Margin |
|---|---|
| 2,000 | 20.3% |

**Initial checks performed:**
- Duplicate primary keys in `orders` and `products`
- NULL checks across all key identifier columns
- Cost reconciliation: `product_cost + shipping_cost + platform_fee + transaction_fee = total_costs`
- Negative value checks on revenue, cost, and profit columns
- Discount amount never exceeds gross revenue

>  **Result:** No data quality issues found. All cost components reconcile correctly to `total_costs`.

---

## 3. Problem Statement

This analysis was built to answer five business questions:

1. What is the average profit margin by product category? Which categories are the most and least profitable, and what is driving the difference (product cost, shipping, returns, or discounts)?
2. How does profitability differ across sales channels (Website, Mobile App, Marketplace, Social Commerce)? Which channel has the best and worst profit per order after accounting for platform fees?
3. What is the return rate by category and channel? Estimate how much total revenue was lost to returns over the analysis period.
4. Analyze the marketing spend data: Which advertising platform delivers the best ROAS (Return on Ad Spend)? Are there any platforms where the company is spending money but not getting a positive return?
5. If the CEO asked you to cut 20% of the marketing budget, which platforms and months would you recommend reducing spend on? 

---

## 4. Key Insights

| # | Insight | Finding |
|---|---|---|
| 1 | Electronics is the most profitable category | **$13,973 total profit** and 31.13% margin — highest across all 8 categories |
| 2 | Books is the least profitable category | **$2,250 total profit** and 11.94% margin — high return rate compounds the problem |
| 3 | Mobile App is the best sales channel | **$36.32 avg profit per order** after platform fees — zero platform fees |
| 4 | Marketplace is the worst sales channel | **-$3.58 avg profit per order** — $18.97 platform fee destroys margin |
| 5 | TikTok Ads delivers the best ROAS | **24.44x** — highest return among all 6 platforms |
| 6 | Email Marketing is the lowest-performing platform | **5.41x ROAS** — lowest return despite positive status |

---

## 5. Insight Deep Dive

### Insight 1 — Category Profitability (sorted by total profit)

| Category | Total Orders | Total Revenue | Total Cost | Total Profit | Margin % |
|---|---|---|---|---|---|
| Electronics | 267 | $44,885.84 | $30,912.38 | $13,973.46 | 31.13% |
| Toys | 257 | $33,595.68 | $24,809.43 | $8,786.25 | 26.15% |
| Sports | 292 | $32,329.83 | $24,733.20 | $7,596.63 | 23.50% |
| Food & Beverage | 247 | $30,662.69 | $23,070.92 | $7,591.77 | 24.76% |
| Home & Kitchen | 200 | $26,359.76 | $19,671.19 | $6,688.57 | 25.37% |
| Clothing | 293 | $31,383.13 | $25,110.65 | $6,272.48 | 19.99% |
| Beauty | 205 | $18,254.07 | $15,079.19 | $3,174.88 | 17.39% |
| Books | 239 | $18,847.37 | $16,597.58 | $2,249.79 | 11.94% |

**Cost drivers breakdown:**

| Category | Margin % | Avg Discount | Avg Shipping | Avg Product Cost | Avg Fees | Avg Refund |
|---|---|---|---|---|---|---|
| Electronics | 31.13 | $14.65 | $26.74 | $75.25 | $13.79 | $15.27 |
| Toys | 26.15 | $11.73 | $26.23 | $60.74 | $9.57 | $9.61 |
| Home & Kitchen | 25.37 | $10.90 | $24.94 | $61.74 | $11.67 | $11.70 |
| Food & Beverage | 24.76 | $10.98 | $26.08 | $57.89 | $9.43 | $14.19 |
| Sports | 23.50 | $10.67 | $23.68 | $53.74 | $7.28 | $6.88 |
| Clothing | 19.99 | $9.98 | $25.41 | $52.37 | $7.92 | $10.95 |
| Beauty | 17.39 | $8.54 | $25.23 | $41.91 | $6.42 | $4.22 |
| Books | 11.94 | $6.11 | $26.20 | $37.48 | $5.77 | $8.81 |

**Key takeaway:** Shipping cost is flat across all categories (~$24–27). The primary differentiator is `avg_product_cost` — Electronics commands the highest product cost ($75.25) indicating higher-value items that generate more profit per order. Books has the lowest product cost ($37.48) but still carries a 26.20 shipping cost, compressing margin significantly.

---

### Insight 2 — Channel Profitability (sorted by profit after platform fee)

| Channel | Total Orders | Avg Order Value | Avg Profit After Fee | Margin % | Avg Platform Fee | Rank |
|---|---|---|---|---|---|---|
| Mobile App | 589 | $140.45 | $36.32 | 29.76% | $0.00 | ✅ Best |
| Website | 795 | $139.83 | $31.60 | 27.01% | $0.00 | 2 |
| Social Commerce | 197 | $134.25 | $7.24 | 15.37% | $9.87 | 3 |
| Marketplace | 419 | $137.55 | -$3.58 | 13.03% | $18.97 | ❌ Worst |

**Key takeaway:** Average order values are nearly identical across all channels (~$134–140). The entire profitability gap is fee-driven — Mobile App and Website charge zero platform fees, while Marketplace's $18.97 fee results in negative profit per order (-$3.58).

---

### Insight 3 — Return Rate Analysis

**By category:**

| Category | Return Rate |
|---|---|
| Electronics | 8.61% |
| Books | 8.37% |
| Clothing | 8.19% |
| Sports | 7.19% |
| Toys | 7.00% |
| Home & Kitchen | 6.00% |
| Beauty | 5.85% |
| Food & Beverage | 5.67% |

**By channel:**

| Channel | Return Rate |
|---|---|
| Social Commerce | 9.14% |
| Website | 7.04% |
| Mobile App | 7.30% |
| Marketplace | 6.44% |

> 💰 **Total revenue lost to returns: $20,582.45**

**Key takeaway:** Electronics and Clothing have the highest return rates (8.61% and 8.19%). Social Commerce has the highest return rate by channel at 9.14%, which further compounds its already-low profit per order.

---

### Insight 4 — Marketing ROAS by Platform

| Platform | Total Spend | Avg ROAS | Return Status |
|---|---|---|---|
| Email Marketing | $24,461.37 | 5.41x | Positive return |
| Facebook Ads | $106,451.93 | 11.25x | Positive return |
| Google Ads | $152,546.48 | 13.69x | Positive return |
| Instagram Ads | $65,154.02 | 16.99x | Positive return |
| Influencer | $97,663.12 | 23.45x | Positive return |
| TikTok Ads | $57,229.22 | 24.44x | Positive return |

**Key takeaway:** All 6 platforms generate positive returns (ROAS > 1). No platform is spending money without return. However, Email Marketing has the lowest ROAS at 5.41x — significantly underperforming relative to its budget share. Google Ads consumes the largest budget ($152,546) but delivers only 13.69x ROAS compared to TikTok's 24.44x at less than half the spend.

---

### Insight 5 — Budget Cut Recommendation (20% = $100,701.23 target)

The strategy targets platform-month combinations where ROAS falls furthest below that platform's own average (most negative `roas_gap`). Top cut candidates:

| Platform | Month | Spend | ROAS | ROAS Gap | Cumulative Cut | Action |
|---|---|---|---|---|---|---|
| Influencer | 2025-01 | $4,482.46 | 3.78 | -19.67 | $4,482.46 | Cut |
| Influencer | 2025-09 | $2,371.92 | 4.57 | -18.88 | $6,854.38 | Cut |
| Influencer | 2024-11 | $4,269.49 | 4.97 | -18.48 | $11,123.87 | Cut |
| TikTok Ads | 2024-08 | $2,195.14 | 6.01 | -18.43 | $13,319.01 | Cut |
| TikTok Ads | 2024-12 | $2,219.28 | 6.28 | -18.16 | $15,538.29 | Cut |
| ... | ... | ... | ... | ... | ... | Cut |
| TikTok Ads | 2024-09 | $2,120.05 | 17.19 | -7.25 | $102,032.44 | Keep |

>  **Cuts stop at cumulative_cut = $100,701.23** — the first 26 rows labeled `Cut` reach the 20% target.

**Key takeaway:** The cut logic targets months where each platform performed worst relative to its own average — not the lowest-ROAS platforms overall. This is why even high-performing platforms like Influencer and TikTok appear in the cut list: their worst months still underperform their own benchmarks.

---

## 6. Recommendations

**Rec 1 — Address Books and Beauty Margin Through Shipping or Order Thresholds**
Books carries $26.20 shipping on a low-value item with 8.37% return rate — driving the worst margin at 11.94%. A minimum order value or negotiated shipping rate could meaningfully improve margin.

**Rec 2 — Redirect Volume from Marketplace to Owned Channels**
Marketplace generates -$3.58 profit per order due to $18.97 platform fees. Mobile App and Website generate $36.32 and $31.60 respectively with zero fees. Shifting volume to owned channels directly recovers margin.

**Rec 3 — Prioritize Return Reduction for Electronics and Clothing**
Electronics (8.61%) and Clothing (8.19%) have the highest return rates. Total revenue lost to returns across all categories is $20,582.45. Improving product descriptions for Electronics and adding size guidance for Clothing are low-cost interventions with direct revenue impact.

**Rec 4 — Cut Worst-Performing Months Across Platforms to Reach 20% Budget Target**
Using cumulative spend ranked by `roas_gap`, the first 26 platform-month combinations labeled `Cut` reach exactly $100,701.23 in savings — 20% of total budget. These are months where ROAS fell furthest below each platform's own average, minimizing revenue impact from the cuts.

---

## 7. SQL Techniques Used

| Technique | Applied In |
|---|---|
| `GROUP BY` + `SUM`, `AVG`, `COUNT` | All category and channel analysis |
| `CASE WHEN` for conditional aggregation | Return rate calculation, ROAS status labels |
| `NULLIF` to prevent division by zero | All margin and profit margin calculations |
| `CONCAT` | Formatting profit margin as percentage string |
| `RANK() OVER (ORDER BY ...)` | Channel best/worst ranking (Q2) |
| `AVG() OVER (PARTITION BY ...)` | Per-platform ROAS benchmark (Q5) |
| `SUM() OVER (ORDER BY ...)` | Cumulative budget cut tracking (Q5) |
| CTEs (`WITH`) | Multi-step budget cut recommendation (Q5) |
| `ROUND(...::NUMERIC, 2)` | PostgreSQL casting for FLOAT columns |

---

## 8. Files

```
├── E-Commerce_profitability_analysis.sql   # All queries organized by question
├── E-Commerce_Profitability_Report.docx    # Full written analysis report
├── orders.csv
├── products.csv
├── marketing_spend.csv
└── README.md
```

---

## 9. Tools & Technologies

| Tool | Usage |
|---|---|
| PostgreSQL | Query execution and analysis |
| pgAdmin | Query editor and output review |
| SQL | Primary analysis language |

---

## 10. Author & Contact

**Van Huu Hien Nguyen** — Aspiring Data Analyst | SQL · Excel · Power BI · Python

| Platform | Link |
|---|---|
| Email | vnguy072@fiu.edu |
| LinkedIn | [linkedin.com/in/vanhuuhiennguyen](https://linkedin.com/in/vanhuuhiennguyen) |
| GitHub | [github.com/vnguy072](https://github.com/vnguy072) |
