-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- lets use week() function to roll back the start of the week
-- week numbers will be between 0 to 520 or 0 to 53
-- default week number in data is 0 and firstday of the week is Friday

USE pizza_runner;

SELECT week(registration_date) as 'Week of registration'
FROM pizza_runner.runners;

select registration_date,week(registration_date)  FROM pizza_runner.runners;

SELECT week(registration_date) as 'Week of registration',
       count(runner_id) as 'Number_of_runners_signed_up'
FROM pizza_runner.runners
GROUP BY 1;

select
    dayname(registration_date) as weekname,
    week(registration_date)  'week of registration',
    count(runner_id) as 'Number_of_runners_signed_up'
from  runners
group by 2;

/* RESULT
weekname, week of registration, Number_of_runners_signed_up
Friday	          2                	1
Sunday	          1	                2
Friday	          0	                1  */

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- pickuptime-order_time
SELECT runner_id,
       TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS runner_pickup_time,
       round(avg(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)), 2) avg_runner_pickup_time
FROM runner_orders_temp
INNER JOIN customer_orders_temp USING (order_id)
WHERE cancellation IS NULL
GROUP BY runner_id;


WITH runner_time AS(
SELECT
      DISTINCT C1.order_id,
     (R1.pickup_time - C1.order_time)AS runner_arrival_time
FROM 
     runner_orders_temp AS R1
INNER JOIN
      customer_orders_temp AS C1
ON 
	 R1.order_id = C1.order_id
WHERE 
    R1.pickup_time  IS NOT NULL)
SELECT
 -- EXTRACT('minutes' FROM AVG(runner_arrival_time)) AS avg_pickup_time
  DATE_FORMAT(runner_arrival_time, "%i") as minute
FROM
  runner_time;

-- RESULT
--avg_pickup_time
-- 15

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH time_for_orders_prepare AS
(
SELECT 
      C1.order_id,
      COUNT(C1.order_id) AS pizza_order_count,
      TIMESTAMPDIFF(MINUTE,C1.order_time,R1.pickup_time) as Prep_Time
FROM 
     runner_orders_temp R1
INNER JOIN 
     customer_orders_temp C1
ON  C1.order_id = R1.order_id
WHERE cancellation IS NULL
GROUP BY order_id)
select 
      pizza_order_count,
      round(avg(prep_time),2)
FROM time_for_orders_prepare
GROUP BY pizza_order_count;

-- OR 
DROP TABLE IF EXISTS number_of_pizzas;

CREATE TEMPORARY TABLE number_of_pizzas(
    SELECT 
           order_id,
           order_time,
		   count(pizza_id) as n_pizzas
	FROM 
          customer_orders_temp
	GROUP BY 
           order_id,
           order_time);
           
SELECT * FROM number_of_pizzas;

WITH preperation_time_cte AS 
(SELECT 
	  C1.order_id,
      C1.runner_id,
      R1.order_time,
      C1.pickup_time,
      R1.n_pizzas,
     ( TIME_TO_SEC(C1.pickup_time)-TIME_TO_SEC(R1.order_time))/60 AS runner_arrival_time
    
FROM runner_orders_temp AS C1
JOIN
  	number_of_pizzas AS R1
  ON
  	R1.order_id = C1.order_id
  WHERE 
  	C1.pickup_time IS NOT NULL)    
SELECT
  order_id,
  n_pizzas AS number_of_pizzas,
  runner_arrival_time AS pickup_time
FROM 
  preperation_time_cte
ORDER BY 
  number_of_pizzas, order_id;

-- RESULT 
/*
order_id	number_of_pizzas	pickup_time
1	          1	              00:10:32
2         	1	              00:10:02
5         	1	              00:10:28
7          	1	              00:10:16
8	          1	              00:20:29
3	          2             	00:21:14
10         	2             	00:15:31
4	          3	              00:29:17  */
  
  -- 4. What was the average distance travelled for each customer?
  SELECT 
        customer_id,
        round(avg(distance),2) AS 'average_distance_travelled'
FROM  
	runner_orders_temp T1
INNER JOIN 
    customer_orders_temp T2
ON T1.order_id = T2.order_id
WHERE cancellation IS NULL
GROUP BY customer_id;

-- Results:
/*customer_id	avg_distance
101	         20.00
102	         18.40
103	         23.40
104	         10.00
105	         25.00 */

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT 
      MIN(duration) AS minimum_duration,
      MAX(duration) AS maximum_duration,
      MAX(duration) - MIN(duration) AS maximum_difference
FROM 
     runner_orders_temp;

-- Results:
-- time_difference
-- 30

-- OR
SELECT 
      MAX(duration) - MIN(duration) AS time_difference
FROM 
     runner_orders_temp;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
with customer_order_count as
(SELECT 
      customer_id,
      order_id,
      order_time,
      count(pizza_id) as n_pizzas
FROM 
     customer_orders_temp
GROUP BY 
     customer_id,
     order_id,
     order_time)
	
SELECT
      C1.customer_id,
      R1.order_id,
      R1.runner_id,
      C1.n_pizzas,
      R1.distance,
      R1.duration,
	  ROUND(60 * R1.distance/R1.duration,2) as  AVG_SPEED_KPH,
	  ROUND((60 * R1.distance/R1.duration)/1.609,2) as AVG_SPEED_MPH
FROM 
    runner_orders_temp AS R1
JOIN
    customer_order_count AS C1
ON
     R1.order_id = C1.order_id
WHERE 
     R1.pickup_time IS NOT NULL
ORDER BY 
    order_id;
    
-- RESULT
/*
customer_id	order_id	runner_id	n_pizzas	distance	duration	avg_speed_kph	avg_speed_mph
101	            1	       1	       1	       20	      32	      37.50	          23.31
101	            2	       1	       1	       20	      27	       44.44	      27.62
102           	3	       1	       2	       13.4	    20	       40.20	      24.98
103	            4	       2	       3	       23.4	    40	       35.10	      21.81
104          	  5	       3	       1	        10	    15	       40.00	      24.86
105	            7	       2	       1	        25	    25	       60.00	      37.29
102            	8	       2	       1	       23.4	    15	       93.60	      58.17
104	           10	       1	       2	        10	    10	       60.00	      37.29
*/

-- 7. What is the successful delivery percentage for each runner?
SELECT 
      runner_id,
      COUNT(pickup_time) AS delivery_orders,
      COUNT(*) AS total_orders,
      ROUND(100 * COUNT(pickup_time)/COUNT(*)) AS delivery_success_percentage
FROM 
     runner_orders_temp
GROUP BY 
        runner_id
ORDER BY 
        runner_id;
	
-- RESULT
/* runner_id, delivery_orders, total_orders, delivery_success_percentage        
1	        4	                 4	           100
2	        3	                 4	            75
3	        1	                 2	            50   */    


 
        















  
  
  







