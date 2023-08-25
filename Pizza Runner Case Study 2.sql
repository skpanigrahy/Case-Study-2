CREATE DATABASE pizza_runner;
USE pizza_runner;

-- Creating runner table
CREATE TABLE runners(
runner_id INT,
registration_date DATE
);

-- Populating the table
INSERT INTO runners VALUES
(1, '2021-01-01'),
(2, '2021-01-03'),
(3, '2021-01-08'),
(4, '2021-01-15');

SELECT * FROM runners;

-- Creating customer_orders table
CREATE TABLE customer_orders(
order_id INT,
customer_id INT,
pizza_id INT,
exclusions VARCHAR(4),
extras VARCHAR(4),
order_date TIMESTAMP
);

-- Populating customer_orders table
INSERT INTO customer_orders VALUES
(1, 101, 1, '', '', '2021-01-01 18:05:02'),
(2, 101, 1, '', '', '2021-01-01 19:00:52'),
(3, 102, 1, '', '', '2021-01-02 23:51:23'),
(3, 102, 2, '', 'NaN', '2021-01-02 23:51:23'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 2, '4', '', '2021-01-04 13:23:46'),
(5, 104, 1, null, '1', '2021-01-08 21:00:29'),
(6, 101, 2, null, null, '2021-01-08 21:03:13'),
(7, 105, 2, null, '1', '2021-01-08 21:20:29'),
(8, 102, 1, null, null, '2021-01-09 23:54:33'),
(9, 103, 1, '4', '1,5', '2021-01-10 11:22:59'),
(10, 104, 1, null, null, '2021-01-11 18:34:49'),
(10, 104, 1, '2,6', '1,4', '2021-01-11 18:34:49');

SELECT * FROM customer_orders;

-- Creating runner_orders table
CREATE TABLE runner_orders(
order_id INT,
runner_id INT,
pickup_time TIMESTAMP,
distance VARCHAR(7),
duration VARCHAR(10),
cancellation VARCHAR(23)
);

-- Populating runner_orders table
INSERT INTO runner_orders VALUES
(1, 1, '2021-01-01 18:15:34', '20km', '32 minutes', ''),
(2, 1, '2021-01-01 19:10:54', '20km', '27 minutes', ''),
(3, 1, '2021-01-03 00:12:37', '13.4km', '20 minutes', 'NaN'),
(4, 2, '2021-01-04 13:53:03', '23.4', '40', 'NaN'),
(5, 3, '2021-01-08 21:10:57', '10', '15', 'NaN'),
(6, 3, null, null, null, 'Restaurant Cancellation'),
(7, 2, '2020-01-08 21:30:45', '25km', '25mins', null),
(8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', null),
(9, 2, null, null, null, 'Customer Cancellation'),
(10, 1, '2020-01-11 18:50;20', '10km', '10minutes', null);

SELECT * FROM runner_orders;

-- Creating pizza_names table
CREATE TABLE pizza_names(
pizza_id INT,
pizza_name VARCHAR(11)
);

-- Populating the tables
INSERT INTO pizza_names VALUES
(1, 'Meat Lovers'),
(2, 'Vegetable');

SELECT * FROM pizza_names;

-- Creating pizza_recipes table
CREATE TABLE pizza_recipes(
pizza_id INT,
toppings TEXT
);

INSERT INTO pizza_recipes VALUES
(1, '1, 2, 3, 4, 5, 6, 8, 10'),
(2, '4, 6, 7, 9, 11, 12');

SELECT * FROM pizza_recipes;

-- Creating pizza_toppings table
CREATE TABLE pizza_toppings(
topping_id INT,
topping_name TEXT
);

INSERT INTO pizza_toppings VALUES
(1, 'Bacon'),
(2, 'BBQ Sauce'),
(3, 'Beef'),
(4, 'Cheese'),
(5, 'Chicken'),
(6, 'Mushrooms'),
(7, 'Onions'),
(8, 'Pepperoni'),
(9, 'Peppers'),
(10, 'Salami'),
(11, 'Tomatoes'),
(12, 'Tomato Sauce');

SELECT * FROM pizza_toppings;

-- DATA CLEANING
-- Updating values for 'exclusions' column where its an empty set ''
UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions = '';

-- Updating values for 'extras' column where its an empty set ''
UPDATE customer_orders
SET extras = NULL
WHERE extras = '';

-- Updating values for 'extras' column where its 'NaN'
UPDATE customer_orders
SET extras = NULL
WHERE extras = 'NaN';

-- Updating values for 'cancellation' column where its an empty set ''
UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation = '';

-- Updating values for 'cancellation' where its 'NaN'
UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation = 'NaN';

--CASE STUDY QUESTIONS
-- PART A. PIZZA METRICS
/* 1. How many pizzas were ordered? */
 SELECT COUNT(*) AS total_orders
 FROM customer_orders;

 /* 2. How many unique customer orders were made? */
 SELECT COUNT(DISTINCT order_id) AS unique_orders
 FROM customer_orders;

 /* 3. How many successful orders were delivered by each runner? */
 SELECT runner_id, COUNT(*) AS total_orders_delivered
 FROM runner_orders
 WHERE cancellation IS NULL
 GROUP BY runner_id;

 /* 4. How many of each type of pizza was delivered? */
WITH joined_data AS(
    SELECT 
        r.cancellation, 
        c.pizza_id
    FROM runner_orders r
    LEFT JOIN customer_orders c ON r.order_id = c.order_id
    WHERE cancellation IS NULL
)
SELECT pizza_name, COUNT(*) AS total_deliveries
FROM joined_data j
LEFT JOIN pizza_names p ON j.pizza_id = p.pizza_id
GROUP BY pizza_name;

-- Correcting the pizza_name column 
UPDATE pizza_names
SET pizza_name = 'Vegetarian'
WHERE pizza_id = 2;

/* 5. How many Vegetarian and Meat Lovers were ordered by each 
customer? */
SELECT c.customer_id, p.pizza_name, COUNT(*) AS total_orders
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
JOIN runner_orders r ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY customer_id, pizza_name
ORDER BY customer_id;

/* 6. What was the maximum number of pizzas delivered in a 
single order? */
WITH orders AS(
    SELECT 
        c.order_id,
        COUNT(*) AS Number_of_pizzas_delivered
    FROM customer_orders c
    JOIN runner_orders r
    ON c.order_id = r.order_id
    WHERE cancellation IS NULL
    GROUP BY c.order_id
)
SELECT MAX(Number_of_pizzas_delivered) AS Max_pizzas_delivered
FROM orders ;

/* 7. For each customer, how many delivered pizzas had at least 1
change and how many had no changes */
WITH pizza_changes AS(
    SELECT
        customer_id,
        cancellation,
        exclusions,
        extras
    FROM customer_orders c
    JOIN runner_orders r ON c.order_id = r.order_id
    WHERE cancellation IS NULL
)
 SELECT customer_id,
    SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS pizzas_with_changes,
    SUM (CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END) AS pizza_with_no_change
FROM pizza_changes
GROUP BY customer_id;

/* 8. How many pizzas were delivered that had both exclusions and 
extra? */
WITH extras AS(
    SELECT 
        c.order_id, 
        exclusions, 
        extras
    FROM customer_orders c
    JOIN runner_orders r
    ON c.order_id = r.order_id
    WHERE cancellation IS NULL
)
SELECT 
    SUM(CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE 0 END) AS with_exclusions_and_extras
FROM extras;

-- 9. What is the total volume of pizzas ordered for each hour of the day?
SELECT 
    HOUR(order_date) AS hour_of_day,
    COUNT(*) AS total_pizzas_ordered
FROM customer_orders
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 10. What was the volume of orders for each day of the week?
SELECT 
    DAYOFWEEK(order_date) AS day_of_week,
    COUNT(*) AS total_orders
FROM customer_orders
GROUP BY day_of_week
ORDER BY day_of_week;

-- PART B. RUNNER AND CUSTOMER EXPERIENCE
/* 1. How many runners signed up for each 1 week period? 
(i.e. week starts 2021-01-01) */
SELECT
    WEEK(registration_date,1) AS reg_week,
    COUNT(*) AS sign_ups
FROM runners
GROUP BY reg_week;

/* 2. What is the average time in minutes it took  each
runner to arrive at the pizza runner HQ to pick up the order? */
WITH time_in_minutes AS(
    SELECT runner_id,
    c.order_date,
    r.pickup_time,
    TIMESTAMPDIFF(MINUTE, order_date, pickup_time) AS time_taken
    FROM runner_orders r
    JOIN customer_orders c
    ON r.order_id = c. order_id
    WHERE cancellation IS NULL AND YEAR(pickup_time) >= YEAR(order_date)
)
SELECT
    runner_id,
    ROUND(AVG(time_taken), 2) AS avg_time_in_minutes
FROM time_in_minutes
GROUP BY runner_id;

/* 3. Is there any relationship between the number of pizzas
and how long the order takes to prepare? */
WITH time_in_minutes AS(
    SELECT
        c.order_id,
        order_date,
        pickup_time,
        TIMESTAMPDIFF(MINUTE, order_date, pickup_time) AS time_taken
    FROM customer_orders c
    JOIN runner_orders r
    ON c.order_id = r.order_id
    WHERE cancellation IS NULL AND YEAR(pickup_time) >= YEAR(order_date)
)
SELECT 
    order_id,
    COUNT(*) AS number_of_pizzas,
    ROUND(AVG(time_taken), 2) AS avg_time_in_minutes
FROM time_in_minutes
GROUP BY order_id
ORDER BY order_id;

/* 4. What was the average distance travelled for each 
customer? */
SELECT customer_id, ROUND(AVG(distance),2) AS avg_distance_travelled
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY customer_id;

/* 5. What is the difference between the longest and shortest 
delivery times for all order? */
SELECT MAX(duration) - MIN(duration) AS diff_in_duration
FROM runner_orders;

/* 6. What was the average speed for each runner for each 
delivery and do you notice any trend for these values? */
SELECT
    order_id,
    runner_id,
    ROUND(AVG(distance / (duration / 60)), 2) AS avg_speed_kmh
FROM runner_orders
WHERE duration IS NOT NULL AND distance IS NOT NULL
GROUP BY order_id, runner_id
ORDER BY avg_speed_kmh DESC;


-- PART C INGREDIENT OPTIMIZATION
/* 1. What is the standard ingredients for each pizza? */
WITH recipe AS(
    SELECT pizza_name, toppings
    FROM pizza_names pn
    JOIN pizza_recipes pr ON pn.pizza_id = pr.pizza_id
)
SELECT
    pizza_name,
    GROUP_CONCAT(topping_name SEPARATOR ',') AS standard_recipe
FROM recipe r
JOIN pizza_toppings pt
ON FIND_IN_SET(pt.topping_id, REPLACE(r.toppings, ' ', '')) > 0
GROUP BY pizza_name;

/* 2. What was the most commonly added extra? */
SELECT pt.topping_name, COUNT(*) AS commonly_added_extra
FROM customer_orders c
JOIN pizza_recipes pr ON c.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON pt.topping_id IN (SELECT SUBSTRING_INDEX(c.extras, ',', 1) FROM customer_orders)
GROUP BY pt.topping_name
ORDER BY commonly_added_extra DESC
LIMIT 1;

/* 3. What was the most common exclusion? */
SELECT pt.topping_name, COUNT(*) AS common_exclusion
FROM customer_orders c
JOIN pizza_recipes pr ON c.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON pt.topping_id IN( SELECT SUBSTRING_INDEX(c.exclusions, ',', 1) FROM customer_orders)
GROUP BY pt.topping_name
ORDER BY common_exclusion DESC
LIMIT 1;

-- PART D. PRICING AND RATINGS
/* 1. f a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were 
no charges for changes - how much money has Pizza Runner made 
so far if there are no delivery fees? */
WITH joined_data AS(
    SELECT
        c.order_id,
        c.pizza_id,
        pn.pizza_name
    FROM customer_orders c 
    JOIN runner_orders r ON c.order_id = r.order_id
    JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
    WHERE cancellation IS NULL
)
SELECT 
    SUM(CASE WHEN pizza_name = 'Meat Lovers' THEN 12 ELSE 10 END) AS total_sales
FROM joined_data;













