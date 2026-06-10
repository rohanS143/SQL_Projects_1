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
    
-- 13) Rider Monthly Earnings:
-- Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount 
with find_eight
as (
	select
		o.order_id,
        date_format(o.order_date, '%Y-%m') as earning_month, 
		round(total_amount * 0.08, 2) as eight_percentage, 
		d.rider_id
	from orders as o
	join deliveries as d
		on o.order_id = d.order_id
) 
select 
	rider_id,
    earning_month, 
    round(sum(eight_percentage), 2) as total_earning
from find_eight
group by rider_id, earning_month
order by rider_id, earning_month; 

-- 14) Rider Rating Analysis:
-- Find the number of 5-star, 4-star, and 3-star ratings each rider has.
-- riders receive this rating based on delivery time. 
-- If orders are delivered less than 15 minutes of order received time the rider get 5 star rating, 
-- if they deliver between 15 and 20 minute they get 4 star rating
-- if they deliver after 20 minute they get 3 star rating. 

select * from deliveries;
select * from orders;  



with rider_rating
as(
	select 
		d.rider_id,
        case 
			when d.delivery_time >= o.order_time
			then TIME_TO_SEC(TIMEDIFF(d.delivery_time, o.order_time)) / 60 
			else TIME_TO_SEC(TIMEDIFF(addtime(d.delivery_time, '24:00:00'), o.order_time)) / 60 
        end as minute_diff
	from deliveries as d
    join orders as o
		on d.order_id = o.order_id
	where delivery_status = 'Delivered'

),
calcuate_rider_rating 
as (
	select
		rider_id,
		case 
			when minute_diff < 15 then '5-star'
			when minute_diff between 15 and 20 then '4-star'
			else '3-star'
		end as riders_rating
	from rider_rating
)
select 
	rider_id,
    count(case when riders_rating = '5-star' then 1 end) as five_star_count,
    count(case when riders_rating = '4-star' then 1 end) as four_star_count,
    count(case when riders_rating = '3-star' then 1 end) as three_star_count
from calcuate_rider_rating
group by 1
order by 1; 
		
        
-- 15) Order frequency by day:
-- Analyze order frequency per day of the week and identify the peak day for each restaurant. 

select * from orders; 
select * from restaurants; 

with order_freq
as (
	select
		restaurant_id, 
		dayname(order_date) as day_name, 
		count(order_id) as total_orders 
	from orders 
	group by 1,2
),
peak_day as ( 
	select
		restaurant_id,
		day_name, 
		total_orders, 
		rank() over (
			partition by restaurant_id
			order by total_orders desc
		) as day_rank
	from order_freq
) 
select
	restaurant_id, 
    day_name,
    total_orders
from peak_day
where day_rank = 1; 
	
-- 16) Customer lifetime value (CLV):
-- Calculate the total revenue generated by each customer over all their orders

select * from customers; 
select * from orders; 

select
	c.customer_name,
	c.customer_id,
    sum(o.total_amount) as total_amount 
from orders as o
join customers as c
	on o.customer_id = c.customer_id
group by 1,2; 

-- 17) Monthly Sales Trends:
-- Identify sales trends by comparing each month's total sales to the previous month. 
    select * from orders; 
    
with current_month_sales
as (
    select 
        month(order_date) as sales_month,
        sum(total_amount) as current_total_sales
	from orders
    group by 1
    order by 1
), 
previous_month_sales as 
(
	select
		sales_month,
		current_total_sales,
        lag(current_total_sales) over (
			order by sales_month
		) as previous_total_sales
	from current_month_sales
),
sale_difference as (
	select
		sales_month,
		current_total_sales, 
		previous_total_sales, 
		(current_total_sales - previous_total_sales) as difference_sale
	from previous_month_sales
),
percentage_sales
as (
	select
		sales_month, 
		current_total_sales,
		previous_total_sales,
        difference_sale, 
        round((current_total_sales - previous_total_sales) / previous_total_sales * 100, 2) as percentage_differences 
	from sale_difference
) 
select 
	sales_month,
    current_total_sales,
    previous_total_sales,
    difference_sale, 
    percentage_differences,
    case 
		when previous_total_sales is null then 'No previous month'
		when percentage_differences >= 0 then 'Profit'
        else 'loss'
	end as profit_loss
from percentage_sales; 


-- 18) Rider Efficiency: 
-- Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages. 

select * from riders; 
select * from orders;
select * from deliveries; 

with minute_cal
as(
	select 
		d.rider_id,
		o.order_time,
		d.delivery_time,
		case 
			when delivery_time >= o.order_time
			then round(time_to_sec(timediff(d.delivery_time, o.order_time)) / 60, 2)
			
			else round(time_to_sec(timediff(addtime(d.delivery_time, '24:00:00'), o.order_time)) / 60, 2)
		end as minute_diff
	from orders as o
	join deliveries as d
		on o.order_id = d.order_id
	where d.delivery_status = 'Delivered'
), 
rider_average as (
	select  
		rider_id, 
		round(avg(minute_diff), 2) as average_delivery_time
	from minute_cal
	group by 1
	order by 1
),
max_min_average as 
(
	select 
		max(average_delivery_time) as highest_average, 
		min(average_delivery_time) as lowest_average
	from rider_average
)
select 
	ra.rider_id,
    ra.average_delivery_time, 
    case 
		when ra.average_delivery_time = mma.lowest_average then 'Most Efficient'
        when ra.average_delivery_time = mma.highest_average then 'Least Efficient'
	end as efficiency_status
from rider_average as ra
cross join max_min_average as mma
where ra.average_delivery_time = mma.lowest_average
	or ra.average_delivery_time = mma.highest_average; 
    
-- 19) Order Item Popularity:
-- Track the popularity of specific order items over time and identify seasonal demand spikes 

select * from orders; 

with popularity 
as (
	select
		order_item,
		month(order_date) as month_num, 
		count(order_item) as total_orders
	from orders
	group by 1,2
	order by 1, 2
), 
using_lag 
as (
	select
		order_item, 
		month_num,
		total_orders,
		lag(total_orders) over(
			partition by order_item
            order by month_num
		) as previous_order
	from popularity
)
select
	order_item,
    month_num,
    total_orders,
    previous_order,
    total_orders - previous_order as order_difference, 
    case
		when total_orders > previous_order then 'Spike'
        else 'No Spike'
	end as demand_spike
from using_lag
where previous_order is not null
order by order_difference desc; 
    

-- Q.20) Monthly Restaurant Growth Ratio:
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining 

with current_month
as (
	select
		o.restaurant_id,
		month(o.order_date) as month_num, 
		count(d.delivery_status) as delivered_item
	from orders as o
	join deliveries as d
		on o.order_id = d.order_id
	where d.delivery_status = 'Delivered' 
	group by 1,2
	order by 1,2
), 
previous_month
as 
(
	select 
		restaurant_id,
        month_num,
        delivered_item, 
        lag(delivered_item) over (
			partition by restaurant_id
            order by month_num
		) as previous_delivered
	from current_month
),
growth_ratio
as (
	select 
		restaurant_id,
		month_num,
		delivered_item,
		previous_delivered,
		round((delivered_item - previous_delivered) / previous_delivered * 100, 2) as growth_ratio
	from previous_month
)
select
	restaurant_id,
	month_num,
	delivered_item,
	previous_delivered,
    growth_ratio,
    case
		when growth_ratio < 0 then 'Went down'
        when growth_ratio > 0 then 'Went up'
        else 'No change' 
	end as ratio_status
from growth_ratio
where growth_ratio is not null;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    




    
    
	






    












