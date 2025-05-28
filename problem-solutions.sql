use swiggy_case_study

select * 
from delivery_partners;

select * from users;
select * from orders;

# 1. Find customers who have never ordered

select *
from users
where user_id not in(select user_id from orders);

# 2. Average Price per Dish

select * from menu
select * from food

select f.f_name as Dish , avg(m.price) as price
from menu m
inner join food f
on m.f_id = f.f_id
group by f.f_name, m.f_id
order by price desc


# 3. Find the top restaurant in terms of the number of orders 
# for a given month

select * from orders
select * from restaurants


select r.r_id, r.r_name, count(*) as num_orders
from orders o
inner join restaurants r
on o.r_id = r.r_id
where extract(month from date)  = 6
group by r.r_id, r.r_name
order by num_orders desc

## Highest number of orders per month
WITH RankedOrders AS (
    SELECT 
        EXTRACT(MONTH FROM date) AS _months,
        r.r_id,
        r.r_name,
        COUNT(*) AS num_orders,
        RANK() OVER (PARTITION BY EXTRACT(MONTH FROM date) ORDER BY COUNT(*) DESC) AS rank_order
    FROM orders o
    INNER JOIN restaurants r ON o.r_id = r.r_id
    GROUP BY r.r_id, r.r_name, _months
)
SELECT _months, r_id, r_name, num_orders
FROM RankedOrders
WHERE rank_order = 1;


## 4. Restaurants with monthly sales greater than 500

select * from orders
select * from restaurants

select r.r_name,o.r_id, sum(amount) as revenue
from restaurants r
inner join orders o
where extract(month from o.date) = 6
group by o.r_id,r.r_name
having sum(amount) > 500
order by sum(amount)

# 5.Show all orders with order details for a particular
#   customer in a particular date range

select * from order_details
select * from orders
select * from users
select * from food
select * from menu

select o.order_id, r.r_name, f.f_name
from orders o
inner join restaurants r
on o.r_id = r.r_id
inner join order_details od
on od.order_id = o.order_id
inner join food f
on f.f_id = od.f_id
where o.user_id = 4
and o.date > '2022-06-01' and o.date < '2022-08-01' ;


# 6. Find restaurants with max repeated customers
select * from order_details
select * from orders
select * from users
select * from food
select * from menu
select * from restaurants


select a.r_name, count(*) as loyal_customers
from
(
select r.r_name, o.user_id, count(*) as _num
from restaurants r
inner join orders o
on r.r_id = o.r_id
group by r.r_name, o.user_id
having _num > 1
)a 
group by a.r_name
order by loyal_customers desc
limit 1;



# 7. Find the most loyal customers for all restaurant

select * from users

select * from
(
select *, rank() over(partition by c.r_name order by c.total_count) as rnk
from
(
select b.r_name, u.name as user_name, b.total_count 
from
(
select r.r_name, a.user_id, a.total_count 
from
(
select user_id, r_id, count(*) as total_count
from orders
group by user_id, r_id
having count(*) > 1
)a inner join restaurants r
on a.r_id = r.r_id
)b inner join users u
on b.user_id = u.user_id
)c
)d where d.rnk  = 1


# 8. Month-over-month revenue growth of Swiggy

select * from orders

with sale_2 as
(
  select extract(month from date) as _month, sum(amount) as sales
  from orders
  group by _month
)
select _month, sales, _prev,
  case
    when _prev is not null and _prev > 0 then (sales - _prev)/cast(_prev as decimal) * 100
    else null
  end as _growth    
from(
	  select _month, sales,
      lag(sales,1) over(order by _month asc) as _prev
      from sale_2
)t;



select b._month, b.sales, b._prev,
case
   when b._prev is not null and b._prev > 0 then (b.sales - b._prev)/cast(b._prev as decimal)* 100
   else null
end as growth
from
(
 select a._month, a.sales,
 lag(a.sales,1) over(order by a._month asc) as _prev
 from
(
  select extract(month from date) as _month, sum(amount) as sales
  from orders
  group by _month
 )a
)b

# 9. Month-over-month revenue growth of a restaurant
select * from restaurants

select d.* from
(
select c._month, c.r_name, c.sales, c._prev,
case 
  when c._prev is not null and c._prev > 0 then (c.sales - c._prev)/cast(c._prev as decimal)* 100
  else null
end as growth
from
(
select b._month, b.r_name, b.sales, 
lag(b.sales,1) over(partition by b.r_name order by b._month) as _prev
from
(
select a._month, r.r_name, a.sales from
(
  select extract(month from date) as _month, r_id, sum(amount) as sales
  from orders
  group by _month, r_id
)a inner join
restaurants r on a.r_id = r.r_id
)b
)c
)d where d.r_name = 'dominos';


# 10. Customer — favourite food

select * from orders
select * from order_details
select * from users


select u.name, f.f_name, f.times_ordered from
(
select * from
(
select d.user_id, d.f_name, d.times_ordered,
rank() over(partition by d.user_id order by d.times_ordered desc) as _rank
from
(
select c.user_id, c.f_name, count(*) as times_ordered
from
(
select b.user_id, f.f_name from
(
select a.order_id, a.user_id, od.f_id from 
(
select order_id, user_id
from orders
)a inner join order_details od
on a.order_id = od.order_id
)b inner join food f
on b.f_id = f.f_id
)c
group by c.user_id, c.f_name
)d
)e where _rank = 1
)f inner join users u
on f.user_id = u.user_id



# 11. Overall revenue generated by the platform between a specific time period

select * from orders

select sum(amount) as revenues
from orders
where date >= '2022-05-10' and date <= '2022-07-28'
