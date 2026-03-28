-- Monthly order trend 
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
       COUNT(*) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;
-- monthly revenue
SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
       ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY order_month
ORDER BY order_month;

-- average order value by month

SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
       ROUND(SUM(p.payment_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY order_month
ORDER BY order_month;

-- payment type distribution

SELECT payment_type,
       COUNT(*) AS payment_count,
       ROUND(SUM(payment_value), 2) AS total_payment_value
FROM payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

-- customer state analysis

SELECT c.customer_state,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

#top selling products
SELECT 
    oi.product_id,
    COUNT(*) AS total_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
GROUP BY oi.product_id
ORDER BY total_revenue DESC
LIMIT 10;

-- revenue per category
SELECT 
    t.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY total_revenue DESC;

-- average delivery time
SELECT 
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 2) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- delay rate
SELECT 
    SUM(CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 
        ELSE 0 
    END) AS late_orders,
    COUNT(*) AS total_orders,
    ROUND(
        SUM(CASE 
            WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 
            ELSE 0 
        END) * 100.0 / COUNT(*), 2
    ) AS late_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
  #order speed by area
  SELECT 
    c.customer_state,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- number of customers by state
SELECT 
    customer_state,
    COUNT(DISTINCT customer_id) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;

-- detailed order dataset
SELECT 
    o.order_id,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    c.customer_state,
    t.product_category_name_english AS category,
    oi.price,
    p.payment_value,
    
    DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS delivery_days,

    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
        ELSE 0
    END AS is_late

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products pr
    ON oi.product_id = pr.product_id

JOIN category_translation t
    ON pr.product_category_name = t.product_category_name

JOIN payments p
    ON o.order_id = p.order_id;
    

-- monthly revenue by category
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    t.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation t ON p.product_category_name = t.product_category_name
GROUP BY order_month, category
ORDER BY order_month;
  