1. What is the total amount each customer spent at the restaurant?
SELECT
  s.customer_id,sum(m.price)
FROM dannys_diner.sales s left join dannys_diner.menu m on s.product_id=m.product_id
group by s.customer_id;

-- 2. How many days has each customer visited the restaurant?
select customer_id,count(distinct(order_date)) from dannys_diner.sales
group by customer_id;
-- 3. What was the first item from the menu purchased by each customer?
WITH ordered_sales_cte AS
(
 SELECT customer_id, order_date, product_name,
  DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY s.order_date) AS rank
 FROM dannys_diner.sales AS s
 JOIN dannys_diner.menu AS m
  ON s.product_id = m.product_id
)
select customer_id ,product_name from ordered_sales_cte where rank=1
group by customer_id,product_name;
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select (count(s.product_id)) as most_pur_item,product_name from dannys_diner.sales as s
join dannys_diner.menu as m on s.product_id=m.product_id
group by s.product_id,m.product_name
order by most_pur_item desc;
-- 5. Which item was the most popular for each customer?
with fav_cte as (
select s.customer_id,m.product_name,count(m.product_id)as order_count,
  rank() over(partition by s.customer_id    order by count (s.customer_id) desc) as rank
  from dannys_diner.sales s join dannys_diner.menu m on s.product_id=m.product_id
  group by s.customer_id,m.product_name
)
select customer_id,product_name,order_count from fav_cte
where rank=1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH member_sales_cte AS 
(
 SELECT s.customer_id, m.join_date, s.order_date,   s.product_id,
         DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY s.order_date) AS rank
     FROM dannys_diner.sales AS s
 JOIN dannys_diner.members AS m
  ON s.customer_id = m.customer_id
 WHERE s.order_date >= m.join_date
)
SELECT s.customer_id, s.order_date, m2.product_name 
FROM member_sales_cte AS s
JOIN dannys_diner.menu AS m2
 ON s.product_id = m2.product_id
WHERE rank = 1;
   -- 7. Which item was purchased just before the customer became a member?
with before_member_cte as(
 SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
         DENSE_RANK() OVER(PARTITION BY s.customer_id
         ORDER BY s.order_date DESC) AS rank
 FROM dannys_diner.sales AS s
 JOIN dannys_diner.members AS m
  ON s.customer_id = m.customer_id
 WHERE s.order_date < m.join_date
)
select s.customer_id,s.order_date,m2.product_name from before_member_cte as s join dannys_diner.menu as m2 on s.product_id=m2.product_id
where rank=1;
-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id,count (distinct (s.product_id))as menu_item,sum(m2.price)as total_sales from dannys_diner.sales as s join dannys_diner.menu m2 on s.product_id=m2.product_id join dannys_diner.members as m on s.customer_id=m.customer_id
where s.order_date<m.join_date
group by s.customer_id;
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH price_points AS
 (
 SELECT *, 
 CASE
  WHEN product_id = 1 THEN price * 20
  ELSE price * 10
  END AS points
 FROM dannys_diner.menu
 )
select s.customer_id,sum(p.points) as total_points from  price_points as p join dannys_diner.sales as s on p.product_id=s.product_id
group by s.customer_id;
--- Joining tables
select s.customer_id,s.order_date,m.product_name,m.price ,
case 
when m2.join_date>s.order_date then 'n'
when m2.join_date <=s.order_date then 'y' else 'n'
end as member from sales s left join menu as m on s.product_id=m.product_id
left join members m2 on s.customer_id=m2.customer_id;
-- Ranking the customers
with ranking_cte as (
select s.customer_id,s.order_date,m.product_name,m.price ,
  case when m2.join_date>s.order_date then 'n'
  when m2.join_date<=s.order_date then 'y' else 'n' end as member from sales s left join menu as m on s.product_id=m.product_id
  left join members m2 on s.customer_id=m2.customer_id
)
select *,case 
when member ='n' then null
else 
rank() over(partition by customer_id,member order by order_date)end as ranking
from ranking_cte;



