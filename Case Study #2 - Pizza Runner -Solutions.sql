-- USE DATABASE
use eight_week_sql_challenge;

-- DROP SCHEMA IF EXISTS 
DROP SCHEMA pizza_runner;

-- CREATE SCHEMA
create schema pizza_runner;

-- USE SCHEMA 
USE pizza_runner;

-- Create runners table which shows the registration_date for each new runner 

DROP TABLE IF EXISTS runners;

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
  
-- Customer pizza orders are captured in the customer_orders table with 1 row for each individual pizza that is part of the order.

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

-- After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and 
-- can be cancelled by the restaurant or the customer.

DROP TABLE IF EXISTS runner_orders;

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

-- Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian! which is captured in pizza_names table
DROP TABLE IF EXISTS pizza_names;

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

-- Each pizza_id has a standard set of toppings which are used as part of the pizza recipe.These details are captured in the pizza_recieps table
DROP TABLE IF EXISTS pizza_recipes;

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

-- Toppings table contains all of the topping_name values with their corresponding topping_id value
DROP TABLE IF EXISTS pizza_toppings;

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

/*Lets Clean Data :
The customer_order table has inconsistent data types.
We must first clean the data before answering any questions.
The exclusions and extras columns contain values that are either 'null' (text), null (data type) or '' (empty).
We will create a temporary table where all forms of null will be transformed to NULL (data type).*/

-- The source data
select * from customer_orders;

DROP TABLE IF EXISTS customer_orders_temp;

CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT  order_id,
        customer_id,
        pizza_id,
        CASE  
            WHEN exclusions = '' THEN null
            WHEN exclusions = 'null' THEN NULL
            ELSE exclusions
		END AS exclusions,
        CASE 
            WHEN extras = '' THEN NULL
            WHEN extras = 'null' THEN NULL
            ELSE extras 
		END as extras,
        order_time
FROM customer_orders;

SELECT * FROM customer_orders_temp;

-- *** Clean Data ***--------------------------
-- The runner_order table has inconsistent data types. 
-- We must first clean the data before answering any questions. 
-- The distance and duration columns have text and numbers.
-- We will remove the text values and convert to numeric values.
-- We will convert all 'null' (text) and 'NaN' values in the cancellation column to NULL (data type).
-- We will convert the pickup_time (varchar) column to a timestamp data type.

-- The orginal table structure.
SELECT * FROM pizza_runner.runner_orders;

-- original data
select * from runner_orders;

DROP TABLE IF EXISTS runner_orders_temp;

CREATE TEMPORARY TABLE runner_orders_temp AS

SELECT order_id,
       runner_id,
       CASE 
          WHEN pickup_time LIKE 'null' THEN NULL
		  ELSE pickup_time
	   END AS pickup_time,
       CASE 
          WHEN distance LIKE 'null' THEN NULL 
          ELSE CAST(regexp_replace(distance,'[a-z]+','') AS FLOAT)
	   END AS distance,
       CASE 
           WHEN duration LIKE 'null' THEN NULL 
           ELSE CAST(regexp_replace(duration,'[a-z]+','') AS FLOAT)
	   END AS duration,
       CASE 
           WHEN cancellation LIKE '' THEN NULL 
           WHEN cancellation LIKE 'null' THEN NULL
           ELSE cancellation
	   END AS cancellation
	FROM runner_orders;
       
SELECT * FROM runner_orders_temp; 

-- pizza_recipes table The toppings column in the pizza_recipes table is a comma separated string.
-- Using JSON functions : These functions are used to split the comma separated string into multiple rows.
-- json_array() converts the string to a JSON array
-- We enclose array elements with double quotes, this is performed using the replace function and we trim the resultant array
SELECT *,
       json_array(toppings),
       replace(json_array(toppings),',','","'),
       trim(replace(json_array(toppings),',','","'))
FROM pizza_runner.pizza_recipes;

-- We convert the json data into a tabular data using json_table().
-- Syntax: JSON_TABLE(expr, path COLUMNS (column_list) [AS] alias)
-- It extracts data from a JSON document and returns it as a relational table having the specified columns
-- Each match for the path preceding the COLUMNS keyword maps to an individual row in the result table.
 -- The expression "$[*]" matches each element of the array and maps it to an individual row in the result table.
-- columns (topping varchar(50) PATH '$') -- Within a column definition, "$" passes the entire match to the column; 

SELECT t.pizza_id, (j.topping)
FROM pizza_recipes t
JOIN json_table(trim(replace(json_array(t.toppings), ',', '","')), '$[*]' columns (topping varchar(50) PATH '$')) j ;

-- customer_orders_temp table
-- The exclusions and extras columns in the pizza_recipes table are comma separated strings.
SELECT t.order_id,
       t.customer_id,
       t.pizza_id,
       trim(j1.exclusions) AS exclusions,
       trim(j2.extras) AS extras,
       t.order_time
FROM customer_orders_temp t
INNER JOIN json_table(trim(replace(json_array(t.exclusions), ',', '","')), '$[*]' columns (exclusions varchar(50) PATH '$')) j1
INNER JOIN json_table(trim(replace(json_array(t.extras), ',', '","')), '$[*]' columns (extras varchar(50) PATH '$')) j2 ;

-- 🍕 Case Study #2: Pizza runner - Pizza Metrics
-- Case Study Questions

-- 1. How many pizzas were ordered?
SELECT count(pizza_id) AS "Total Number Of Pizzas Ordered"
FROM pizza_runner.customer_orders;

/*

Results:

number_of_orders|
----------------+
              14|
      
*/

-- 2. How many unique customer orders were made?
SELECT 
  COUNT(DISTINCT order_id) AS 'Number Of Unique Orders'
FROM customer_orders_temp;

/*

unique_orders|
-------------+
           10|      
*/
-- 3. How many successful orders were delivered by each runner?
SELECT runner_id,
       count(order_id) AS 'Number Of Successful Orders'
FROM pizza_runner.runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;

/*

runner_id|successful_orders|
---------+-----------------+
        1|                4|
        2|                3|
        3|                1|  
            
*/

-- 4. How many of each type of pizza was delivered?
SELECT pizza_id,
       pizza_name,
       count(pizza_id) AS 'Number Of Pizzas Delivered'
FROM pizza_runner.runner_orders_temp
INNER JOIN customer_orders_temp USING (order_id)
INNER JOIN pizza_names USING (pizza_id)
WHERE cancellation IS NULL
GROUP BY pizza_id;

-- OR 

SELECT 
    T2. pizza_id,
     pizza_name,
     count(T2.pizza_id) AS Number_of_Pizzas_Delivered
FROM 
	customer_orders_temp AS T1
INNER JOIN 
     pizza_names AS T2
ON 
    T2.pizza_id = T1.pizza_id
INNER JOIN 
    runner_orders_temp AS T3
ON 
   T1.order_id = T3.order_id
WHERE 
  cancellation IS NULL
GROUP BY 
  T2.pizza_name
ORDER BY Number_of_Pizzas_Delivered DESC;
     
/*
pizza_name|delivery_count|
----------+--------------+
Meatlovers|             9|
Vegetarian|             3|  
*/     

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT DISTINCT customer_id,
       pizza_name,
       count(pizza_id) AS 'Number Of Pizzas Ordered'
FROM customer_orders_temp
INNER JOIN pizza_names USING (pizza_id)
GROUP BY  customer_id,
         pizza_id
ORDER BY customer_id ;

-- OR

SELECT 
      customer_id,
	  SUM(CASE
              WHEN pizza_id = 1 THEN 1
              ELSE 0
		   END) AS  meat_lovers,
	  SUM(CASE
              WHEN pizza_id = 2 THEN 1 
              ELSE 0 
           END) AS vegetarian
FROM customer_orders_temp
GROUP BY customer_id 
ORDER BY customer_id;
         
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
        
-- 6. What was the maximum number of pizzas delivered in a single order?  
SELECT 
      customer_id,
      order_id,
      count(order_id) AS pizza_count
FROM 
     customer_orders_temp
GROUP BY 
     order_id
ORDER BY 
     pizza_count DESC
LIMIT 1;

-- OR 
SELECT 
      MAX(pizza_count) as max_count 
FROM 
     (SELECT 
            T1.order_id,
            count(T1.pizza_id) as pizza_count
	  FROM 
          customer_orders_temp AS T1
	  INNER JOIN 
           runner_orders_temp AS T2 
	  ON 
      T1.order_id  = T2.order_id
      WHERE 
	  T2.cancellation IS NULL  OR  T2.cancellation  NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
      GROUP BY T1.order_id) as MAX_ORDER_COUNT ;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- at least 1 change -> either exclusion or extras
-- no changes -> exclusion and extras are NULL
SELECT customer_id,
      SUM(CASE 
              WHEN (exclusions IS NOT NULL OR extras IS NOT NULL ) THEN 1
              ELSE 0 
		 END ) AS change_in_pizza,
	  SUM(CASE 
              WHEN (exclusions IS NULL AND extras  IS NULL) THEN 1 
		  ELSE 0 
          END ) AS  no_change_in_pizza
FROM customer_orders_temp
INNER JOIN  runner_orders_temp using (order_id)
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY  customer_id;

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
SELECT customer_id,
       SUM(CASE
               WHEN (exclusions IS NOT NULL
                     AND extras IS NOT NULL) THEN 1
               ELSE 0
           END) AS both_change_in_pizza
FROM customer_orders_temp
INNER JOIN runner_orders_temp USING (order_id)
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id;
    
-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT hour(order_time) AS 'Hour',
       count(order_id) AS 'Number of pizzas ordered',
       round(100*count(order_id) /sum(count(order_id)) over(), 2) AS 'Volume of pizzas ordered'
FROM pizza_runner.customer_orders_temp
GROUP BY 1
ORDER BY 1;

-- OR 
SELECT 
      HOUR(order_time) AS hour_of_day, 
	  COUNT(order_id) AS pizza_count
FROM 
      customer_orders_temp
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
-- The DAYOFWEEK() function returns the weekday index for a given date ( 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday )
-- DAYNAME() returns the name of the week day

SELECT dayname(order_time) AS 'Day Of Week',
       count(order_id) AS 'Number of pizzas ordered',
       round(100*count(order_id) /sum(count(order_id)) over(), 2) AS 'Volume of pizzas ordered'
FROM pizza_runner.customer_orders_temp
GROUP BY 1
ORDER BY 2 DESC;

-- OR
SELECT 
      dayname(order_time) AS day_of_week,
      count(*) AS number_of_pizzas
FROM 
    customer_orders_temp
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


