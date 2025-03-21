Create schema Sales;
use Sales;

CREATE TABLE sales_data (
    Id INT PRIMARY KEY NOT NULL,
    customer_name VARCHAR(25),
    product VARCHAR(30),
    category VARCHAR(30),
    quantity INT,
    price DECIMAL(10 , 2 ),
    total_amount DECIMAL(10 , 2 ),
    order_date DATE,
    region VARCHAR(25),
    payment_method VARCHAR(25)
);

-- ========================================================Questions/Answers==============================================================

-- 1) Retrieve all records from the sales_data table.

SELECT 
    *
FROM
    sales_data;
    
-- 2) Get a list of distinct product categories   

SELECT DISTINCT
    product
FROM
    sales_data;
  
--  3) Count the total number of sales transactions
 
 SELECT 
    COUNT(*) AS sales_transactions
FROM
    sales_data;
    
-- 4) Find the total revenue generated
   
   SELECT 
    SUM(total_amount) AS total_revenue
FROM
    sales_data;
 
-- 5) Retrieve all sales where the quantity is greater than 3
 
SELECT 
    *
FROM
    sales_data
WHERE
    quantity > 3;
    
--  6) Find the average price of products sold.
   
   SELECT 
    AVG(price) AS avg_price
FROM
    sales_data;
    
--  7) Show all sales transactions for the region "North".
   
   SELECT 
    *
FROM
    sales_data
WHERE
    region = 'North';
    
-- 8) Find the earliest and latest order date.
 
SELECT 
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date
FROM
    sales_data;
    
-- 9) Retrieve all records for the product "Laptop".

SELECT 
    *
FROM
    sales_data
WHERE
    product = 'Laptop';
    
-- 10) Show all records where the payment method was "Credit Card".

SELECT 
    *
FROM
    sales_data
WHERE
    payment_method = 'Credit Card';
    
-- 11) Find the total number of orders per product.

SELECT 
    product, COUNT(*) AS total_product
FROM
    sales_data
GROUP BY product;

-- 12) Get the total revenue generated per region.

SELECT 
    region, SUM(total_amount) AS total_revenue
FROM
    sales_data
GROUP BY region;

-- 13) Show the highest-priced product in each category.

SELECT 
    category, product, MAX(price) AS highest_priced_product
FROM
    sales_data
GROUP BY category , product;

-- 14) Retrieve all sales where the total amount is greater than the average total amount.

SELECT 
    *
FROM
    sales_data
WHERE
    total_amount > (SELECT 
            AVG(total_amount)
        FROM
            sales_data);
            
-- 15) Find the top 5 customers who spent the most.

SELECT 
    customer_name, SUM(total_amount) AS total_spent
FROM
    sales_data
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 5;

-- 16) Find the most frequently purchased product.
 
 SELECT 
    product, COUNT(*) AS frequent_purchased_product
FROM
    sales_data
GROUP BY product
ORDER BY frequent_purchased_product DESC
LIMIT 1;

-- 17) Show the total quantity sold for each product in descending order.

SELECT 
    product, SUM(quantity) AS quantity_sold
FROM
    sales_data
GROUP BY product
ORDER BY quantity_sold DESC;

-- 18) Find the number of sales made each month.

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS number_of_sales
FROM
    sales_data
GROUP BY month
ORDER BY month ASC;

-- 19) Find the total revenue generated by each payment method.

SELECT 
    payment_method, SUM(total_amount) AS total_revenue
FROM
    sales_data
GROUP BY payment_method;

-- 20) Find customers who purchased more than 2 different products.

SELECT 
    customer_name, COUNT(DISTINCT product) AS product_count
FROM
    sales_data
GROUP BY customer_name
HAVING product_count = 2; -- No customer have purchased more than 2 different products

-- 21) Find the second highest revenue-generating product.

SELECT 
    product, SUM(total_amount) AS total_revenue
FROM
    sales_data
GROUP BY product
ORDER BY total_revenue DESC
LIMIT 1 OFFSET 1;

-- 22) Retrieve the top-selling product in each category.

SELECT 
    category, product, SUM(quantity) AS top_selling_product
FROM
    sales_data
GROUP BY category , product
HAVING top_selling_product = (SELECT 
        MAX(top_selling_product)
    FROM
        (SELECT 
            category, product, SUM(quantity) AS top_selling_product
        FROM
            sales_data
        GROUP BY category , product) AS subquery
    WHERE
        subquery.category = sales_data.category);
        

-- 23) Find the customer with the highest total spending in each region.

SELECT 
    customer_name, region, SUM(total_amount) AS total_spending
FROM
    sales_data
GROUP BY customer_name , region
HAVING total_spending = (SELECT 
        MAX(total_spending)
    FROM
        (SELECT 
            customer_name, region, SUM(total_amount) AS total_spending
        FROM
            sales_data
        GROUP BY customer_name , region) AS subquery
    WHERE
        subquery.region = sales_data.region);
    
-- ======================ALTERNATIVE SOLUTION===================================

SELECT customer_name,region,total_spent FROM (
SELECT customer_name,region,sum(total_amount) AS total_spent,
RANK () OVER (PARTITION BY  region ORDER BY sum(total_amount) DESC ) AS rnk
FROM sales_data
GROUP BY customer_name, region) ranked WHERE rnk = 1;


-- 24) Calculate the month-over-month growth in revenue.

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_amount) AS revenue,
LAG(sum(total_amount)) OVER (ORDER BY date_format(order_date,'%Y-%m')) AS prev_month_revenue,
(sum(total_amount) - LAG(sum(total_amount)) OVER (ORDER BY date_format(order_date,'%Y-%m'))) /
LAG(sum(total_amount)) OVER (ORDER BY date_format(order_date,'%Y-%m')) * 100 AS growth_percentage
FROM sales_data
GROUP BY month; 

-- 25) Find the top 3 most sold products in each region.

SELECT region, product, total_sold FROM(
SELECT product, region, sum(quantity) AS total_sold,
RANK () OVER (PARTITION BY region ORDER BY sum(quantity) DESC ) AS rnk
FROM sales_data
GROUP BY region, product ) ranked 
WHERE rnk <= 3;


-- 26) Find the cumulative revenue over time.

SELECT order_date, sum(total_amount) OVER (ORDER BY order_date) AS cumulative_revenue
FROM sales_data;


-- 27) Identify customers who made consecutive purchases within 3 days.

WITH purchase_history AS (
    SELECT 
        customer_name, 
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_name ORDER BY order_date) AS prev_order_date
    FROM sales_data)
SELECT 
    customer_name, 
    order_date, 
    prev_order_date
FROM purchase_history
WHERE  DATEDIFF(order_date, prev_order_date) BETWEEN 1 AND 3;

-- ====================================================================================================
SELECT 
    customer_name, COUNT(*) AS total_orders
FROM
    sales_data
GROUP BY customer_name
ORDER BY total_orders DESC;

-- Since the maximum number of purchases per customer is 2, it means:

-- No customer has purchased more than twice.
-- If their second purchase was more than 3 days apart, our query naturally returns no results.

-- =======================================================================================================

-- 28) Find the average order value (AOV) per region.

SELECT 
    region, AVG(total_amount) AS avg_order_value
FROM
    sales_data
GROUP BY region;


-- 29) Identify the customers who made purchases in multiple regions.

SELECT 
    customer_name, COUNT(DISTINCT region) AS region
FROM
    sales_data
GROUP BY customer_name
HAVING COUNT(DISTINCT region) > 1;

-- 30) Find the last purchase made by each customer.

SELECT 
    customer_name, MAX(order_date) AS last_purhcase
FROM
    sales_data
GROUP BY customer_name;

