-- Advanced SQL Data Analysis Project | Zomato SQL (Guided) - Portfolio Series #3/10 - Dataset 

-- Zomato Data Analysis using SQL

use zomato_db; 
show tables; 


SET GLOBAL local_infile = 1;

select * from customers; 

select * from deliveries; 

select * from orders; 


select count(*) from customers
where customer_name is null
or reg_date is null; 

insert into orders(order_id, customer_id, restaurant_id)
	values
    (1002, 9, 54),
    (1003, 10, 51),
    (1005, 10, 50)
; 

select count(*) from orders; 

select * from orders
where order_id = 1002; 


set sql_safe_updates = 0; 
delete from orders
where 
	order_item is null
    or 
    order_date is null
    or 
    order_time is null
    or 
    order_status is null
    or 
    total_amount is null
; 


-- Q.1
-- Write a query to find the top 5 most frequently ordered dishes by customer called "Arjun Mehta" in the last 1 year.
select 
	o.order_item, 
	count(o.order_item) as total
from orders as o
join customers as c
    on o.customer_id = c.customer_id
where c.customer_name = 'Arjun Mehta'
    and o.order_date >= current_date - interval 365 day 
group by 1
order by total desc
limit 5; 
    
select * from restaurants; 
select * from riders; 

-- 2. Popular Time Slots
-- Question: Identify the time slots during which the most orders are placed. Based on 2-hour intervals. 
select * from orders; 

select 
	case 
		when extract(hour from order_time) between 0 and 1 then '00:00 - 02:00'
        when extract(hour from order_time) between 2 and 3 then '02:00 - 04:00'
        when extract(hour from order_time) between 4 and 5 then '04:00 - 06:00'
        when extract(hour from order_time) between 6 and 7 then '06:00 - 08:00'
        when extract(hour from order_time) between 8 and 9 then '08:00 - 10:00'
        when extract(hour from order_time) between 10 and 11 then '10:00 - 12:00'
        when extract(hour from order_time) between 12 and 13 then '12:00 - 14:00'
        when extract(hour from order_time) between 14 and 15 then '14:00 - 16:00'
        when extract(hour from order_time) between 16 and 17 then '16:00 - 18:00'
        when extract(hour from order_time) between 18 and 19 then '18:00 - 20:00'
        when extract(hour from order_time) between 20 and 21 then '20:00 - 22:00'
        when extract(hour from order_time) between 22 and 23 then '22:00 - 00:00'
	end as time_slot,
    count(order_id) as order_count
    from orders 
    group by 1
    order by order_count desc; 
    
-- approach 2
select
	floor(extract(hour from order_time)/2)*2 as start_time,
    floor(extract(hour from order_time)/2)*2 + 2 as end_time,
    count(*) as total_orders
from orders
group by 1,2
order by 3 desc; 

-- 3) Order Value Analysis 
-- Question: Find the average order value per customer who has placed more than 750 orders.
-- Return customer_name, and aov(average order value)
select * from orders; 
select * from customers; 

select 
	c.customer_name,
    count(o.order_id) as total_orders,
    round(avg(o.total_amount), 2) as order_value
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by 1
having total_orders >= 750; 

-- 4) High-Value customers
-- Question: List the customers who have spent more than 100k in total on food orders.
-- return customer_name, and customer_id! 
select * from orders; 

select count(*) as total_customers
	from(
    select
		c.customer_name,
		c.customer_id,
		format(sum(o.total_amount), 0) as total_spent,
		row_number() over (order by sum(o.total_amount) desc) as rank_num
	from customers as c
	join orders as o
		on c.customer_id = o.customer_id
	group by 1,2
	having sum(o.total_amount) > 100000
	order by sum(o.total_amount) desc
) as high_value_customers; 


-- 5. Orders without delivery
-- Question: Write a query to find orders that were placed but not delivered.
-- return each restaurant name, city, and number of not delivered orders 
select 
	r.restaurant_name,
    r.city,
    count(*) as not_delivered_count
from orders as o
join deliveries as d
on o.order_id = d.order_id
join restaurants as r
on o.restaurant_id = r.restaurant_id
where d.delivery_status = 'Not Delivered'
group by 1,2; 

-- another
select * from deliveries; 


select 
	r.restaurant_name, 
    count(o.order_id) as cnt_not_delivered_orders
from orders as o
left join restaurants as r
on r.restaurant_id = o.restaurant_id
left join 
deliveries as d
on d.order_id = o.order_id
where d.delivery_id is null
group by 1
order by 2 desc; 


-- 6) 
-- Restaurant Revenue Ranking:
-- Rank restaurants by their total revenue from the last year, including their name, 
-- total revenue, and rank within their city
select * from orders;
select * from restaurants; 

with ranking_table as 
(
	select 
		r.restaurant_name,
		r.city, 
		format(sum(o.total_amount), 0) as total_revenue,
		rank() over (
			partition by r.city
			order by sum(o.total_amount) desc
		) as city_rank 
	from orders as o
	join restaurants as r
		on o.restaurant_id = r.restaurant_id
	where o.order_date >= current_date - interval 3 year
	group by 1,2
)
select * 
from ranking_table
where city_rank = 1
order by city, city_rank;  

-- 7) 
-- Most popular dish by city:
-- Identify the most popular dish in each city based on the number of orders 
select * from orders;
select * from restaurants; 

with popular_dish as 
(
	select
		r.city, 
		o.order_item,
		count(order_item) as total_dish,
        rank() over ( 
			partition by r.city
            order by count(order_item) desc
        ) as ranking_city
	from orders as o
	join restaurants as r
		on o.restaurant_id = r.restaurant_id
	group by 1,2
)
select *
from popular_dish
where ranking_city = 1
order by city; 

-- 8) customer churn: 
-- find customers who haven't placed an order in 2024 but did in 2023; 

select * from customers;
select * from orders; 

select distinct customer_id 
from orders
where extract(year from order_date) = 2023
    and customer_id not in 
		(
			select distinct customer_id 
            from orders 
			where extract(year from order_date) = 2024
		); 
    
-- 9) Cancellation Rate comparison:
-- Calculate and compare the order cancellation rate for each restaurant between the 
-- current year and the previous year
select * from restaurants; 
-- 2023
WITH cancel_ratio_23 AS 
(
    SELECT
        o.restaurant_id,
        COUNT(o.order_id) AS total_orders,
        COUNT(CASE 
            WHEN d.delivery_id IS NULL 
              OR d.delivery_status = 'Not Delivered'
            THEN 1 
        END) AS cancelled_orders
    FROM orders AS o
    LEFT JOIN deliveries AS d
        ON o.order_id = d.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2023
    GROUP BY o.restaurant_id
),
cancel_ratio_24 AS 
(
    SELECT
        o.restaurant_id,
        COUNT(o.order_id) AS total_orders,
        COUNT(CASE 
            WHEN d.delivery_id IS NULL 
              OR d.delivery_status = 'Not Delivered'
            THEN 1 
        END) AS cancelled_orders
    FROM orders AS o
    LEFT JOIN deliveries AS d
        ON o.order_id = d.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2024
    GROUP BY o.restaurant_id
),
last_year_data AS 
(
    SELECT 
        restaurant_id, 
        total_orders,
        cancelled_orders, 
        ROUND(cancelled_orders * 100.0 / total_orders, 2) AS cancel_ratio
    FROM cancel_ratio_23
), 
current_year_data AS 
(
    SELECT 
        restaurant_id,
        total_orders,
        cancelled_orders,
        ROUND(cancelled_orders * 100.0 / total_orders, 2) AS cancel_ratio
    FROM cancel_ratio_24
)
SELECT
    c.restaurant_id,
    c.cancel_ratio AS current_year_cancel_ratio,
    l.cancel_ratio AS last_year_cancel_ratio
FROM current_year_data AS c
JOIN last_year_data AS l
    ON c.restaurant_id = l.restaurant_id;
        

-- 10) Rider Average Delivery Time:
-- Determine each rider's average delivery time. 

select * from riders; 
select * from deliveries; 

select 
	d.rider_id,
    r.rider_name,
    round(avg(
		case
			when d.delivery_time >= o.order_time
            then timestampdiff(minute, o.order_time, d.delivery_time)
            else timestampdiff(minute, o.order_time, addtime(d.delivery_time, '24:00:00'))
		end 
	), 2) as avg_delivery_minutes
from orders as o
join deliveries as d
	on o.order_id = d.order_id
join riders as r
	on d.rider_id = r.rider_id
where d.delivery_status = 'Delivered'
group by 1,2
order by avg_delivery_minutes; 

-- 11) Monthly Restaurant growth ratio: 
-- Calculate each resataurant's growth ratio based on the total number of delivered orders since its joining 
WITH monthly_orders AS
(
    SELECT
        o.restaurant_id,
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        COUNT(*) AS current_month_orders
    FROM orders AS o
    JOIN deliveries AS d
        ON o.order_id = d.order_id
    WHERE d.delivery_status = 'Delivered'
    GROUP BY 1,2
)
SELECT
    restaurant_id,
    order_month,
    current_month_orders,
    LAG(current_month_orders) OVER (
        PARTITION BY restaurant_id
        ORDER BY order_month
    ) AS previous_month_orders
FROM monthly_orders
ORDER BY restaurant_id, order_month;

-- 12) customer segmentation:
-- customer segmentation: segment customers into 'gold' or 'silver' groups based on their total spending
-- compared to the average order value (aov). if a customer's total spending exceeds the aov,
-- label them as 'gold; otherwise, label them as 'silver'. write a sql query to determine each segment's 
-- total number of orders and total revenue. 
    
    -- find customer total spending
    -- find average order value
    -- if total spending exceeds average, then lable gold
    -- else label them silver

WITH spending_power AS
(
    SELECT
        customer_id, 
        SUM(total_amount) AS total_spending,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
),
customer_segment AS
(
    SELECT 
        customer_id, 
        total_spending,
        total_orders,
        AVG(total_spending) OVER () AS average_spending, 
        CASE 
            WHEN total_spending > AVG(total_spending) OVER () THEN 'Gold' 
            ELSE 'Silver'
        END AS spending_status
    FROM spending_power
)
SELECT 
    spending_status,
    SUM(total_orders) AS total_orders,
    FORMAT(SUM(total_spending), 0) AS total_revenue
FROM customer_segment
GROUP BY spending_status;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    




    
    
	






    












