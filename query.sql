DROP TABLE IF EXISTS marketing_spend;
CREATE TABLE marketing_spend (
	month VARCHAR(7),
	platform VARCHAR(75),
	spend FLOAT,
	impressions	INT,
	clicks INT,
	conversions INT,	
	revenue_attributed FLOAT,	
	cpc	FLOAT,
	cpa	FLOAT,
	roas FLOAT
);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id            VARCHAR(20)  PRIMARY KEY, 
    customer_id         VARCHAR(20),                
    order_date          DATE,
    channel             VARCHAR(50),
    payment_method      VARCHAR(50),
    region              VARCHAR(50),
    items_ordered       INT,
    primary_category    VARCHAR(50),
    gross_revenue       DECIMAL(10, 2),
    discount_pct        INT,
    discount_amount     DECIMAL(10, 2),
    shipping_cost       DECIMAL(10, 2),
    product_cost        DECIMAL(10, 2),
    platform_fee        DECIMAL(10, 2),
    transaction_fee     DECIMAL(10, 2),
    returned            VARCHAR(5),             
    refund_amount       DECIMAL(10, 2),
    net_revenue         DECIMAL(10, 2),
    total_costs         DECIMAL(10, 2),
    profit              DECIMAL(10, 2)
);

DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id              VARCHAR(20)  PRIMARY KEY,  
    product_name            VARCHAR(100),
    category                VARCHAR(50),
    sub_category            VARCHAR(50),
    unit_cost               DECIMAL(10, 2),
    selling_price           DECIMAL(10, 2),
    shipping_cost_per_unit  DECIMAL(10, 2),
    weight_lbs              DECIMAL(10, 2),
    supplier                VARCHAR(50)
);

----CHECKING FOR DATA QUALITY ISSUES
SELECT *
FROM orders
WHERE 
    order_id IS NULL
    OR order_date IS NULL
    OR gross_revenue IS NULL;

SELECT *
FROM orders
WHERE 
    gross_revenue < 0
    OR product_cost < 0
    OR shipping_cost < 0;

SELECT *
FROM orders
WHERE discount_amount > gross_revenue;

-----CHECK FOR NULL VALUES
SELECT order_id 
from orders
where order_id ISNULL;

SELECT product_id 
from products
where product_id ISNULL;

SELECT month, platform
from marketing_spend
where (month ,platform) ISNULL;

--CHECK FOR DUPLICATE VALUES IN PRIMARY KEY

SELECT order_id, count(*)
FROM orders
group by order_id
having count(*) > 1;

SELECT product_id, count(*)
FROM products
group by product_id
having count(*) > 1;

-----Verify that order-level costs add up correctly (product cost + shipping + fees = total costs).
select * from orders;

SELECT 
    order_id,
    product_cost,
    shipping_cost,
    platform_fee,
    transaction_fee,
    total_costs,
    (product_cost + shipping_cost + platform_fee + transaction_fee) AS calculated_total
FROM orders
WHERE 
    ROUND(product_cost + shipping_cost + platform_fee + transaction_fee, 2) 
    <> ROUND(total_costs, 2);


-- 1.What is the average profit margin by product category? 
-- Which categories are the most and least profitable, and what is driving the difference (product cost, shipping, returns, or discounts)?

-- Profit margin by category (most → least profitable)
SELECT
    primary_category,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(net_revenue), 2) AS total_revenue,
    ROUND(SUM(total_costs), 2) AS total_cost,
    ROUND(SUM(profit), 2) AS total_profit,
    CONCAT(ROUND(SUM(profit) / NULLIF(SUM(net_revenue), 0) * 100, 2), '%') AS profit_margin
FROM orders
GROUP BY primary_category
ORDER BY total_profit DESC;

--Cost drivers by category
SELECT
    primary_category,
    ROUND(SUM(profit) * 100.0 / NULLIF(SUM(net_revenue), 0), 2) AS profit_margin_pct,
    ROUND(AVG(discount_amount), 2) AS avg_discount,
    ROUND(AVG(shipping_cost), 2) AS avg_shipping,
    ROUND(AVG(product_cost), 2) AS avg_product_cost,
    ROUND(AVG(platform_fee + transaction_fee), 2) AS avg_fees,
    ROUND(AVG(refund_amount), 2) AS avg_refund
FROM orders
GROUP BY primary_category
ORDER BY profit_margin_pct DESC;


-- 2.How does profitability differ across sales channels (Website, Mobile App, Marketplace, Social Commerce)?
-- Which channel has the best and worst profit per order after accounting for platform fees?
SELECT
    channel,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(gross_revenue), 2) AS avg_order_value,
    ROUND(AVG(profit - platform_fee), 2) AS avg_profit_after_fee,
    ROUND(SUM(profit) * 100.0 / NULLIF(SUM(net_revenue), 0), 2) AS profit_margin_pct,
    ROUND(AVG(platform_fee), 2) AS avg_platform_fee,
    RANK() OVER (ORDER BY AVG(profit - platform_fee) DESC) AS profit_rank,
    CASE
        WHEN RANK() OVER (ORDER BY AVG(profit - platform_fee) DESC) = 1
            THEN 'Best'
        WHEN RANK() OVER (ORDER BY AVG(profit - platform_fee) DESC)
            = (SELECT COUNT(DISTINCT channel) FROM orders)
            THEN 'Worst'
        ELSE '-'
    END AS channel_label
FROM orders
GROUP BY channel
ORDER BY avg_profit_after_fee DESC;

-- 3.What is the return rate by category and channel? Estimate how much total revenue was lost to returns 
-- over the analysis period.
--Return rate by category
SELECT 
	primary_category,
	ROUND(
        SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(order_id), 2) AS return_rate_pct
FROM orders
GROUP BY primary_category

--Return rate by channel
SELECT 
	channel,
	ROUND(
        SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(order_id), 2) AS return_rate_pct
FROM orders
GROUP BY channel

--Total revenue was lost to returns over the analysis period.
SELECT 
	ROUND(SUM(CASE WHEN returned = 'Yes' THEN refund_amount ELSE 0 END), 2) AS total_revenue_lost
FROM orders

-- 4.Analyze the marketing spend data: Which advertising platform delivers the best ROAS (Return on Ad Spend)? 
-- Are there any platforms where the company is spending money but not getting a positive return?

SELECT 
	platform,
	ROUND(SUM(spend)::NUMERIC, 2) AS total_spend,
	ROUND(AVG(roas)::NUMERIC, 2) AS avg_roas,
	CASE 
		WHEN AVG(roas) < 1 THEN 'Negative return'
		WHEN AVG(roas) = 1 THEN 'Break even'
		ELSE 'Positive return'
	END AS return_status
FROM marketing_spend
GROUP BY platform
ORDER BY avg_roas ASC

-- 5.If the CEO asked you to cut 20% of the marketing budget, which platforms and months would you recommend
-- reducing spend on? Support your recommendation with data.

WITH platform_stats AS (
    SELECT
        platform,
        month,
        spend,
        roas,
        AVG(roas) OVER (PARTITION BY platform) AS avg_roas_platform,
        SUM(spend) OVER () AS total_budget
    FROM marketing_spend
),
cuts AS (
    SELECT
        platform,
        month,
        ROUND(spend::NUMERIC, 2) AS spend,
        ROUND(roas::NUMERIC, 2) AS roas,
        ROUND((roas - avg_roas_platform)::NUMERIC, 2) AS roas_gap,
        ROUND((total_budget * 0.20)::NUMERIC, 2) AS target_cut,
        ROUND(SUM(spend) OVER (ORDER BY roas - avg_roas_platform ASC)::NUMERIC, 2) AS cumulative_cut
    FROM platform_stats
)
SELECT
    platform,
    month,
    spend,
    roas,
    roas_gap,
    target_cut,
    cumulative_cut,
    CASE
        WHEN cumulative_cut <= target_cut THEN 'Cut'
        ELSE 'Keep'
    END AS recommendation
FROM cuts
ORDER BY roas_gap ASC;













