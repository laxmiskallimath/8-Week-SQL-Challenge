create database eight_week_sql_challenge;

use  eight_week_sql_challenge;

-- ************************** Case Study #1 - Danny's Diner *****************************************--
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
 

CREATE TABLE menu (
  product_id INTEGER,
   product_name  VARCHAR(5),
   price  INTEGER
);

INSERT INTO menu
  ( product_id ,  product_name ,  price )
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
   customer_id  VARCHAR(1),
   join_date  DATE
);

INSERT INTO members
  ( customer_id ,  join_date )
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
-- Lets view data 
select * from sales;
select *  from menu;
select *  from members;


-- Solved on mysql by laxmi, January, 3, 2024
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
select 
	s.customer_id,
	sum(price) as total_amount_spent from menu m 
join 
	 sales s 
on        
	m.product_id = s.product_id
group by
	s.customer_id
order by 
	s.customer_id;

-- result 
/* A	76
B	74
C	36 */


-- 2. How many days has each customer visited the restaurant?
--  Use order_date to find days 
select 
      customer_id, 
      count(distinct((order_date))) as days_visited_to_restaurant 
      from 
	sales
group by 
	customer_id
order by
	customer_id;

-- result 
/*A	4
B	6
C	2*/

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
FROM 
	SALES S
INNER JOIN 
	MENU M 
ON 
	S.PRODUCT_ID = M.PRODUCT_ID)
SELECT 
* FROM 
	FIRST_ITEM_PURCHASED 
WHERE ORDER_NUMBER = 1;

-- result 
/* A	sushi	1
B	curry	1
C	ramen	1 */

 -- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 -- most purchased item means product/product_name
 -- count of this product_name

select 
    m1.product_name,
    count(s1.product_id) as number_of_times_purchased
from 
    sales as s1
join 
	menu as m1 
on 
	s1.product_id = m1.product_id 
group by 
	m1.product_name 
order by 
	number_of_times_purchased desc 
Limit 1;

-- ramen	8

-- 5. Which item was the most popular for each customer?
-- popular product_name 
-- group by customer_id 
with most_popular_item as
(select 
     s1.customer_id,
     m1.product_name ,
     count(m1.product_id) as ordered_count,
     dense_rank () over (partition  by s1.customer_id order by s1.customer_id desc) as rank1
from 
	menu as m1
inner join 
	sales s1 
on
	m1.product_id = s1.product_id
group by
	s1.customer_id,m1.product_name)
select customer_id,
       product_name,
       ordered_count 
from 
	most_popular_item
where rank1 = 1;

-- or using rank function
with most_popular_item_cte  as(
select 
       s1.customer_id,
       m1.product_name,
       count(m1.product_id) as item_purchased,
       rank () over (partition by s1.customer_id order by count(product_id) desc) as popularity_rank 
  from  
	sales as s1 
  inner join
	menu as m1 
  on 
	s1.product_id = m1.product_id 
  group by 
        s1.customer_id,
        m1.product_name )
        
select 
     customer_id,
     product_name,
     item_purchased
from 
	most_popular_item_cte
where 
popularity_rank = 1;

-- result 
/* A ramen	3
B	curry	2
B	sushi	2
B	ramen	2
C	ramen	3 */



-- before solving 6 to 10 questions lets see how we can join all theree tables 
-- sales s1 --customer_id,product_id
-- menu m1 -- product_id , s1.product_id = m1.product_id
-- members m2 -- customer_id , s1.customer_id  = m2.customer_id

-- 6. Which item was purchased first by the customer after they became a member?
-- first item purchased 
with first_member_purchase_cte as 
(select 
      s1.customer_id,
      m1.product_name,
      m2.join_date,
      s1.order_date,
      rank () over (partition by s1.customer_id order by s1.order_date) as purchase_rank 
from 
      sales as s1
join 
     menu as m1 
on 
    s1.product_id = m1.product_id
join 
    members as m2 
on 
    s1.customer_id = m2.customer_id 
    
where s1.order_date >= m2.join_date ) -- customer after they became a member(ordered on joined date became member or ordered multiple items and ten the became members)
select 
     customer_id,
     join_date,
     order_date,
     product_name,
     purchase_rank
from 
    first_member_purchase_cte
where purchase_rank = 1;

-- result 
/*A	2021-01-07	2021-01-07	curry	1
B	2021-01-09	2021-01-11	sushi	1*/

-- 7. Which item was purchased just before the customer became a member?
WITH last_nonmember_purchase_cte AS
(select
       s1.customer_id,
       m1.product_name,
       s1.order_date,
       m2.join_date, 
       rank () over (partition by s1.customer_id order by s1.order_date desc) as purchase_rank 
from 
      sales as s1
join 
      menu  as m1 
on 
     s1.product_id = m1.product_id
join
      members as m2 
on 
     s1.customer_id = m2.customer_id 
where s1.order_date < m2.join_date) -- before the customer became a member
select 
  customer_id,
  order_date,
  join_date,
  product_name
from 
   last_nonmember_purchase_cte
where 
   purchase_rank =1 ;
  -- result 
/*A	2021-01-01	2021-01-07	sushi
A	2021-01-01	2021-01-07	curry
B	2021-01-04	2021-01-09	sushi*/

-- 8. What is the total items and amount spent for each member before they became a member?
with total_nonmemer_purchased_items_amount_spent as
(select
       s1.customer_id,
       count(m1.product_id) as total_items ,
       sum(m1.price) as total_spent
from 
      sales as s1
join 
      menu  as m1 
on 
     s1.product_id = m1.product_id
join
      members as m2 
on 
     s1.customer_id = m2.customer_id
where 
      s1.order_date < m2.join_date
group by 
        s1.customer_id)
select * 
    from 
        total_nonmemer_purchased_items_amount_spent
order by 
       customer_id;

-- result 
/*A	2	25
B	3	40*/

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with total_customer_points_cte as 
(select 
     s1.customer_id as customer,
     sum(  
          case 
              when m1.product_name = 'sushi' then  (m1.price * 20 ) -- sushi has a 2x points multiplier
              else (m1.price * 10) -- $1 spent equates to 10 points
              end 
		)as member_points 
	from 
        sales as s1 
	join 
       menu as m1 
	on 
      s1.product_id = m1.product_id
	group by 
            s1.customer_id)
select * 
    from 
     total_customer_points_cte
ORDER BY
  member_points DESC;
  
/* B 940
A	860
C	360 */

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
WITH jan_member_points_cte AS
(
  SELECT 
  	s1.customer_id,
  	SUM(
  		CASE
  			WHEN s1.order_date < m2.join_date THEN
  				CASE 
  					WHEN m1.product_name = 'sushi' THEN (m1.price * 20)
  					ELSE (m1.price * 10)
  				END
  			WHEN s1.order_date > (m2.join_date + 6) THEN 
  				CASE 
  					WHEN m1.product_name = 'sushi' THEN (m1.price * 20)
  					ELSE (m1.price * 10)
  				END 
  			ELSE (m1.price * 20)	
  		END) AS member_points
  FROM
  	members AS m2
  JOIN
  	sales AS s1
  ON
  	m2.customer_id = s1.customer_id
  JOIN
  	menu AS m1
  ON
  	m1.product_id = s1.product_id
  WHERE 
  	s1.order_date <= '2021-01-31'
  GROUP BY 
  	s1.customer_id
)
SELECT *
FROM
  jan_member_points_cte
ORDER BY
  customer_id;

-- result
/*A	1370
B	820 */


































