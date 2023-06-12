1.SELECT sum(qty) as Total_quantity FROM balanced_tree.sales ;

ans:45216

2.SELECT sum(qty*price) as Total_quantity FROM balanced_tree.sales ;

ans:1289453

3:SELECT sum(discount) as Total_quantity FROM balanced_tree.sales ;

ans:182700

4.SELECT count(distinct txn_id) as Total_quantity FROM balanced_tree.sales ;

ans:2500

5.SELECT avg(unique_product) FROM(
select count(distinct prod_id) as unique_product from  balanced_tree.sales 
  group by txn_id
) as subquery ;

ans:6.03800

6:with cte as (select sum(qty*price) as revenue from balanced_tree.sales
           group by txn_id
            )
SELECT  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) AS percentile_25,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY revenue) AS percentile_50,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) AS percentile_75
FROM cte

ans:percentile_25	percentile_50	percentile_75
375.75	509.5	647

7. select avg(discount) as avg_discount from balanced_tree.sales
   group by txn_id;

8. select 
  member,
  count(txn_id) as total_transaction,
  count(txn_id)*100/(select count(txn_id) from balanced_tree.sales) as percentage
 from balanced_tree.sales
 group by member;

ans:member	total_transaction	percentage
false	6034	39
true	9061	60

9.with cte as (select member,sum(qty*price) as revenue
from balanced_tree.sales
group by member
)
select avg(revenue) from cte

ans:644726.500000

10.select p.product_id,p.product_name , sum(s.qty*s.price) as revenue
from balanced_tree.product_details as p join balanced_tree.sales s on p.product_id=s.prod_id 
group by product_id,product_name
order by revenue desc
limit 3;

ans:product_id	product_name	revenue
2a2353	Blue Polo Shirt - Mens	217683
9ec847	Grey Fashion Jacket - Womens	209304
5d267b	White Tee Shirt - Mens	152000

11.select p.segment_name ,

sum(s.qty*s.price) as revenue,
sum(s.discount) total_discount,
sum(qty)total_quantity
from balanced_tree.product_details as p join balanced_tree.sales s on p.product_id=s.prod_id 
group by segment_name;

ans:segment_name	revenue	total_discount	total_quantity
Shirt	406143	46043	11265
Jeans	208350	45740	11349
Jacket	366983	45452	11385
Socks	307977	45465	11217

12.with cte as (
  select 
p.segment_name,
p.product_name,
row_number() over(partition by p.segment_name order by count(s.txn_id) desc) as rank
from balanced_tree.product_details as p join balanced_tree.sales s on p.product_id=s.prod_id 
group by segment_name,product_name
  )
  select segment_name,product_name
  from cte 
  where rank=1;

ans:segment_name	product_name
Jacket	Grey Fashion Jacket - Womens
Jeans	Navy Oversized Jeans - Womens
Shirt	Blue Polo Shirt - Mens
Socks	Navy Solid Socks - Mens

13:select p.category_name ,
sum(s.qty*s.price) as revenue,
sum(s.discount) total_discount,
sum(qty)total_quantity
from balanced_tree.product_details as p join balanced_tree.sales s on p.product_id=s.prod_id 
group by category_name;

ans:category_name	revenue	total_discount	total_quantity
Mens	714120	91508	22482
Womens	575333	91192	22734

14:with cte as (
  select 
p.category_name,
p.product_name,
row_number() over(partition by p.category_name order by count(s.txn_id) desc) as rank
from balanced_tree.product_details as p join balanced_tree.sales s on p.product_id=s.prod_id 
group by category_name,product_name
  )
  select category_name,product_name
  from cte 
  where rank=1;

ans:Mens	Navy Solid Socks - Mens
Womens	Grey Fashion Jacket - Womens

15:with cte as (
  select 
  p.segment_name,
p.product_name,
 sum(s.qty*s.price) as revenue,
  sum(s.qty*s.price)*100/(select sum(s.qty*s.price) from balanced_tree.sales s) as percentile_revenue
from balanced_tree.product_details as p join balanced_tree.sales s on p.product_id=s.prod_id 
group by segment_name,product_name
  )
  select segment_name,product_name,revenue,percentile_revenue
  from cte ;

ans:segment_name	product_name	revenue	percentile_revenue
Jacket	Grey Fashion Jacket - Womens	209304	16
Jacket	Khaki Suit Jacket - Womens	86296	6
Shirt	Teal Button Up Shirt - Mens	36460	2
Socks	White Striped Socks - Mens	62135	4
Jacket	Indigo Rain Jacket - Womens	71383	5
Socks	Pink Fluro Polkadot Socks - Mens	109330	8
Jeans	Black Straight Jeans - Womens	121152	9
Shirt	White Tee Shirt - Mens	152000	11
Shirt	Blue Polo Shirt - Mens	217683	16
Jeans	Cream Relaxed Jeans - Womens	37070	2
Socks	Navy Solid Socks - Mens	136512	10
Jeans	Navy Oversized Jeans - Womens	50128	3

16.with cte as (
  select 
  p.category_name,
p.segment_name,
 sum(s.qty*s.price) as revenue,
  sum(s.qty*s.price)*100/(select sum(s.qty*s.price) from balanced_tree.sales s) as percentile_revenue
from balanced_tree.product_details as p join balanced_tree.sales s on p.product_id=s.prod_id 
group by category_name,segment_name
  )
  select category_name,segment_name,revenue,percentile_revenue
  from cte ;

ans:category_name	segment_name	revenue	percentile_revenue
Womens	Jeans	208350	16
Womens	Jacket	366983	28
Mens	Socks	307977	23
Mens	Shirt	406143	31

17.with cte as (
  select 
  p.category_name,
 sum(s.qty*s.price) as revenue,
  sum(s.qty*s.price)*100/(select sum(s.qty*s.price) from balanced_tree.sales s) as percentile_revenue
from balanced_tree.product_details as p join balanced_tree.sales s on p.product_id=s.prod_id 
group by category_name
  )
  select category_name,revenue,percentile_revenue
  from cte ;

ans:category_name	revenue	percentile_revenue
Mens	714120	55
Womens	575333	44

18.SELECT
  product_name,
  COUNT(DISTINCT CASE WHEN s.qty >= 1 THEN s.txn_id END) * 100.0 / COUNT(DISTINCT s.txn_id) AS penetration
FROM balanced_tree.product_details p join balanced_tree.sales s on p.product_id=s.prod_id
GROUP BY product_name;

ans:product_name	penetration
Black Straight Jeans - Womens	100.0000000000000000
Blue Polo Shirt - Mens	100.0000000000000000
Cream Relaxed Jeans - Womens	100.0000000000000000
Grey Fashion Jacket - Womens	100.0000000000000000
Indigo Rain Jacket - Womens	100.0000000000000000
Khaki Suit Jacket - Womens	100.0000000000000000
Navy Oversized Jeans - Womens	100.0000000000000000
Navy Solid Socks - Mens	100.0000000000000000
Pink Fluro Polkadot Socks - Mens	100.0000000000000000
Teal Button Up Shirt - Mens	100.0000000000000000
White Striped Socks - Mens	100.0000000000000000
White Tee Shirt - Mens	100.0000000000000000