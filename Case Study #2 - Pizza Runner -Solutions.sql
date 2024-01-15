use eight_week_sql_challenge;

-- create runners table 
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
  
  select * from runners;
  
-- create customer_orders
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 12:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 12:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
  
select * from customer_orders;

-- CREATE TABLE runner_orders
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-02 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

select * from runner_orders;

-- CREATE TABLE pizza_names
 CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
); 
  
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');
  
select * from pizza_names;

-- CREATE TABLE pizza_recipes
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

 INSERT INTO pizza_recipes
(pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

select * from pizza_recipes;

CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
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
  
  select * from pizza_toppings;

/*
	Pizza Runner (SQL Solutions)
	SQL Author: Laxmi S Kallimath
	SQL Challenge Creator: Danny Ma (https://www.linkedin.com/in/datawithdanny/) (https://www.datawithdanny.com/)
	SQL Challenge Location: https://8weeksqlchallenge.com/
		
	File Name: pizza_runner_solutions.sql
*/

/*Lets Clean Data :The customer_order table has inconsistent data types.  We must first clean the data before answering any questions.
The exclusions and extras columns contain values that are either 'null' (text), null (data type) or '' (empty).
We will create a temporary table where all forms of null will be transformed to NULL (data type).*/

-- The source data
select * from customer_orders;

create table cleaned_customers_data as(
                  SELECT 
                        order_id,
                        customer_id,
                        pizza_id,
					    CASE 
                             WHEN exclusions = '' OR exclusions = 'null' OR exclusions = 'NaN' THEN NULL
                             ELSE exclusions
					    END AS exclusions,
                        CASE 
                            WHEN  extras = '' OR  extras = 'null' OR extras = 'NaN' THEN NULL 
						    ELSE extras
						END AS extras,
					   order_time
				 FROM customer_orders
);

select * from cleaned_customers_data;

-- Similarly customers_orders data The runner_order table has inconsistent data types. So lets clean runnerWe must first clean the data before answering any questions. 
-- The distance and duration columns have text like km and numbers hence will remove the text values and convert to numeric values .  
-- We will convert all 'null' (text) and 'NaN' values in the cancellation column to null (data type).
-- We will convert the pickup_time (varchar) column to a timestamp data type.

-- original data
select * from runner_orders;

SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'runner_orders';

CREATE TABLE cleaned_runner_orders AS
SELECT 
  order_id, 
  runner_id,  
  CASE
	  WHEN pickup_time LIKE 'null' THEN ' '
	  ELSE pickup_time
	  END AS pickup_time,
  CASE
	  WHEN distance LIKE 'null' THEN ' '
	  WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	  ELSE distance 
    END AS distance,
  CASE
	  WHEN duration LIKE 'null' THEN ' '
	  WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	  WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	  WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	  ELSE duration
	  END AS duration,
  CASE
	  WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ' '
	  ELSE cancellation
	  END AS cancellation
FROM runner_orders;

SELECT * FROM cleaned_runner_orders;

-- WHEN I TRIED MODIFY DATATPE OF PICKUP TIME USING ALTER COMMAND I WAS GETTING 
--  ERROR 1292 (22007): Incorrect datetime value: '' for column 'pickup_time' at row 6
-- to resolve this issue in mysql i used below command
SET SQL_MODE='ALLOW_INVALID_DATES';


ALTER TABLE cleaned_runner_orders MODIFY COLUMN  pickup_time DATETIME;
-- ALTER TABLE runner_orders_temp MODIFY COLUMN  pickup_time datetime  NULL DEFAULT '1970-01-01 00:00:00';
ALTER TABLE cleaned_runner_orders MODIFY COLUMN  distance FLOAT;
ALTER TABLE cleaned_runner_orders MODIFY COLUMN  duration int;

select sum(duration) from cleaned_runner_orders;

select sum(distance) from cleaned_runner_orders;

SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'cleaned_runner_orders';

-- 1. How many pizzas were ordered?
SELECT 
      COUNT(*) AS no_of_pizza_ordered_count
FROM 
	cleaned_customers_data;
-- no_of_pizza_ordered_count : 14    

-- 2. How many unique customer orders were made?
SELECT 
  COUNT(DISTINCT order_id) AS unique_order_count
FROM
    cleaned_customers_data;

/*

unique_orders|
-------------+
           10|      
*/

-- 3. How many successful orders were delivered by each runner?
select 
      runner_id,
      count(order_id) as successful_orders
from 
      cleaned_runner_orders
where 
      cancellation IS NULL OR cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY
	   runner_id
ORDER BY
	successful_orders DESC;
-- RESULT    
/*

runner_id|successful_orders|
---------+-----------------+
        1|                4|
        2|                3|
        3|                1|  
            
*/

-- 4. How many of each type of pizza was delivered?
-- pizza_names
SELECT 
      PIZZA_NAME ,
      COUNT(*) AS PIZZA_TYPE_COUNT
FROM 
     cleaned_customers_data AS T1
INNER JOIN 
     pizza_names AS T2
ON  
     t2.pizza_id  = t1.pizza_id
INNER JOIN 
     cleaned_runner_orders AS T3
ON 
    T1.order_id = T3.order_id
WHERE 
     cancellation IS NULL OR cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY 
       T2.pizza_name 
ORDER BY 
      PIZZA_TYPE_COUNT DESC;

-- RESULT
/*

pizza_name|delivery_count|
----------+--------------+
Meatlovers|             9|
Vegetarian|             3|  
            
*/   


SELECT 
      PIZZA_NAME ,
      COUNT(*) AS PIZZA_TYPE_COUNT
FROM 
     cleaned_customers_data AS T1
INNER JOIN 
     pizza_names AS T2
ON  
     t2.pizza_id  = t1.pizza_id
GROUP BY 
       T2.pizza_name 
ORDER BY 
      PIZZA_TYPE_COUNT DESC;
      
-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
      customer_id,
      SUM(
           CASE 
               WHEN pizza_id = 1 THEN 1
               ELSE 0
			END 
            )AS Meatlovers,
            
	  SUM(
           CASE 
               WHEN pizza_id = 2 THEN 1
               ELSE 0 
		  END 
          ) AS Vegetarian
FROM 
     cleaned_customers_data
GROUP BY 
       customer_id 
ORDER BY 
       customer_id;
 -- RESULT 
  /*

customer_id|meat_lovers|vegetarian|
-----------+-----------+----------+
        101|          2|         1|
        102|          2|         1|
        103|          3|         1|
        104|          3|         0|
        105|          0|         1|  
            
*/
        
  
  -- or 
  SELECT 
  T2.customer_id, 
  T1.pizza_name, 
  COUNT(T1.pizza_name) AS order_count
FROM pizza_names AS T1
JOIN cleaned_customers_data AS T2
  ON T2.pizza_id= T1.pizza_id
GROUP BY T2.customer_id, T1.pizza_name
ORDER BY T2.customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?  
WITH order_count_cte as (
  SELECT 
      T1.order_id,
      COUNT(T1.pizza_id) AS n_orders
FROM 
     cleaned_customers_data AS T1
INNER JOIN 
      cleaned_runner_orders AS T2
ON 
      T1.order_id = T2.order_id
WHERE 
     T2.cancellation IS NULL or cancellation  NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP  BY 
      T1.order_id
 )     
SELECT 
       MAX(n_orders) AS maximum_number_of_pizzas_delivered
FROM order_count_cte;

-- OR 
SELECT
       MAX(pizza_count) as max_count
FROM
	(SELECT 
          T1. order_id ,
           count(T1.pizza_id) AS pizza_count
     FROM 
     cleaned_customers_data AS T1
     JOIN 
    cleaned_runner_orders AS T2
     ON 
    T1.order_id = T2.order_id 
     WHERE 
       T2.cancellation IS NULL
    OR T2 .cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
    GROUP BY T1.order_id )  AS MAX_ORDER_COUNT; 
-- RESULT
   /*

max_delivered_pizzas|
--------------------+
                   3|  
            
*/

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
      customer_id ,
      SUM(
            CASE 
                WHEN  T1.exclusions IS NOT NULL OR T1.extras IS NOT NULL THEN 1
                ELSE 0 
			END 
		) AS with_one_change,
		SUM(
            CASE 
                WHEN  T1.exclusions IS NULL AND  T1.extras IS NULL THEN 1
                ELSE 0 
			END 
		) AS no_changes
FROM 
     cleaned_customers_data AS T1
JOIN 
     cleaned_runner_orders AS T2
ON 
    T1.order_id = T2.order_id
WHERE 
    T2.cancellation IS NULL 
     OR T2.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY
     T1.customer_id
ORDER BY
      T1.customer_id;
      
-- RESULT
/*

customer_id|with_changes|no_changes|
-----------+------------+----------+
        101|           0|         2|
        102|           0|         3|
        103|           3|         0|
        104|           2|         1|
        105|           1|         0|  
            
*/

-- 8. How many pizzas were delivered that had both exclusions and extras?        

SELECT
	SUM(
		CASE
			WHEN T1.exclusions IS NOT NULL AND t1.extras IS NOT NULL THEN 1
			ELSE 0
		END
	) AS number_of_pizzas
FROM 
	cleaned_customers_data AS T1
JOIN 
	cleaned_runner_orders AS T2
ON 
	T1.order_id = T2.order_id
WHERE 
	T2.cancellation IS NULL
	OR T2.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation');

/*

number_of_pizzas|
----------------+
               1|  
            
*/      

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
      HOUR(order_time) AS hour_of_day, 
	  COUNT(order_id) AS pizza_count
FROM 
      cleaned_customers_data
GROUP BY 
      HOUR(order_time)
ORDER  BY 
       HOUR(order_time);
 
-- Result:
//*+──────────────+──────────────+
| hour_of_day  | pizza_count  |
+──────────────+──────────────+
| 11           | 1            |
| 12           | 2            |
| 13           | 3            |
| 18           | 3            |
| 19           | 1            |
| 21           | 3            |
| 23           | 1            |
+──────────────+──────────────+*/
-- 10. What was the volume of orders for each day of the week?
SELECT 
      dayname(order_time) AS day_of_week,
      count(*) AS number_of_pizzas
FROM 
    cleaned_customers_data
GROUP BY 
    day_of_week
ORDER BY 
    day_of_week;
    
/* --Result:
+──────────────+──────────────+
| day_of_week  | pizza_count  |
+──────────────+──────────────+
| Friday       | 1            |
| Saturday     | 5            |
| Thursday     | 3            |
| Wednesday    | 5            |
+──────────────+──────────────+*/


