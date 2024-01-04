-- Case Study #1 - Danny's Diner

----Create dataase in mysql
create database eight_week_sql_challenge;

-- Use database 
use  eight_week_sql_challenge;


--- Create table sales
CREATE TABLE sales (
   customer_id  VARCHAR(1),
   order_date  DATE,
   product_id  INTEGER
);


--- insert records into sales table
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
--- CREATE TABLE menu
CREATE TABLE menu (
  product_id INTEGER,
   product_name  VARCHAR(5),
   price  INTEGER
);

--- Insert records in menu
INSERT INTO menu
  ( product_id ,  product_name ,  price )
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
--- CREATE TABLE members

CREATE TABLE members (
   customer_id  VARCHAR(1),
   join_date  DATE
);

------ Insert records in members
INSERT INTO members
  ( customer_id ,  join_date )
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
-- Lets view data 
select * from menu;
select * from members;
select * from sales;

-- Solved on mysql by laxmi, January, 3, 2024
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(price) as total_amount_spent from menu m 
join sales s 
on m.product_id = s.product_id
group by s.customer_id
order by s.customer_id;

-- 2. How many days has each customer visited the restaurant?
--  Use order_date to find days 
select 
      customer_id, 
      count(distinct((order_date))) as days_visited_to_restaurant 
      from sales
group by customer_id
order by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
-- FIRST ITEM(PRODUCT_NAME)
-- CUSTOMER_ID
-- -- FIRST FETCH CUSTOMER ID,ORDERDATE ,PRODUCT NAME THEN APPLY DENSE RANK TO APPLY UNIQUE ROW NUMER PER ORDER
WITH FIRST_ITEM_PURCHASED AS 
(SELECT 
      S.CUSTOMER_ID,
      M.PRODUCT_NAME,
      ROW_NUMBER() OVER (PARTITION BY S.CUSTOMER_ID
					 ORDER BY S.ORDER_DATE,S.PRODUCT_ID) AS ORDER_NUMBER
FROM SALES S
INNER JOIN MENU M 
ON S.PRODUCT_ID = M.PRODUCT_ID)
SELECT * FROM FIRST_ITEM_PURCHASED 
WHERE ORDER_NUMBER = 1;


 -- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 
with most_purchased as(
select product_name,count(product_name) as total_purchase_qty,
row_number () over() as row_numer from sales as s1
join menu as m1 on s1.product_id = m1.product_id 
group by 1)
select product_name,total_purchase_qty  from most_purchased 
where row_numer = 1;

-- 5. Which item was the most popular for each customer?
