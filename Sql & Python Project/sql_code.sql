--find top 10 highest revenue generating products

SELECT
    product_id,
    sum(sale_price) AS sales
FROM
    df_orders
GROUP BY
    product_id
ORDER BY
    sales DESC
LIMIT 10;

--find top 5 highest selling products in each region

WITH each_region AS(
    SELECT
        product_id,
        region,
        sale_price,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY sale_price DESC) AS rank
    FROM
        df_orders
)
SELECT
    product_id,
    region,
    sale_price
FROM
    each_region
WHERE
    rank <= 5
ORDER BY 
    region, 
    rank;

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

WITH growth_comparison AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM
        df_orders
    GROUP BY
       EXTRACT(YEAR FROM order_date),
       EXTRACT(MONTH FROM order_date)
)
SELECT 
    order_month
   ,SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022
   ,SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM
    growth_comparison
GROUP BY
    order_month
ORDER BY
    order_month;

--for each category which month had highest sales

WITH monthly_sales AS (
    SELECT
        category,
        TO_CHAR(order_date, 'YYYYMM') AS order_year_month,
        SUM(sale_price) AS sales
    FROM
        df_orders
    GROUP BY
        category,
        TO_CHAR(order_date, 'YYYYMM')
)
SELECT
    category,
    order_year_month,
    sales
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rank
    FROM
        monthly_sales
) AS a
WHERE
    rank = 1;

--which sub category had highest growth by profit in 2023 compare to 2022

WITH growth_comparison AS (
    SELECT
        sub_category,
        EXTRACT(YEAR FROM order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM
        df_orders
    GROUP BY
       sub_category,
       EXTRACT(YEAR FROM order_date)
)
, sub_category_growth AS(
SELECT 
    sub_category
   ,SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022
   ,SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM
    growth_comparison
GROUP BY
    sub_category
)
SELECT 
    sub_category,
    sales_2022,
    sales_2023,
    (sales_2023-sales_2022)*100/sales_2022 AS growth_percent
FROM
    sub_category_growth
ORDER BY
    growth_percent  DESC