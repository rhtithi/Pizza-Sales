create database pizzahut;
Use pizzahut;

# Retrive the total number of orders placed

select count(order_id) as total_orders 
from orders;

# find total revenue generated through pizza sales--

select (sum(order_details.quantity * pizzas.price)) as total_revenue
from order_details
join Pizzas
on Pizzas.pizza_id = order_details.pizza_id;

# find pizza which has the highest price

select pizza_types.name, pizzas.price
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;

#identify the most common pizza size ordered

select pizzas.size, count(order_details.order_id) as top_ordered
from pizzas
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
limit 1;

# identify top 5 most ordered pizza types along with their quantities

select pizza_types.name, sum(order_details.quantity) as mostpizzaordered
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name, order_details.quantity
order by sum(order_details.quantity) desc
limit 5;

# find the total quantity of each pizza ordered 

select pizza_types.category as pizzacategory, sum(order_details.quantity) as quantity
from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by quantity;

# determine the distribution of orders by hour of the day

select count(order_id) as distributionoforders, hour(order_time)
from orders
group by hour(order_time);

# find categorywise distribution of pizza

select category, count(name) as pizzatype
from pizza_types
group by category;

# group the orders by day and calculate the average number of pizza ordered per day


select round(avg(dailyorders), 2) from (select orders.order_date, sum(order_details.quantity) as dailyorders
from orders
join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;

# determine the top 3 most ordered pizza based on revenue

select sum(pizzas.price * order_details.quantity) as revenue, pizza_types.name
from pizzas
join order_details
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name
order by sum(pizzas.price * order_details.quantity) desc
limit 3;

# calculate the percentage contribution of each pizza type to total revenue

SELECT 
    pizza_types.category,
    ROUND(SUM(pizzas.price * order_details.quantity) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS totalsales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS percentagerevenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;

# analyze the cumulative revenue generated over time

select order_date, sum(revenue) over (order by order_date) as cumulative from 
(select orders.order_date, sum(order_details.quantity * pizzas.price) as revenue
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on order_details.order_id = orders.order_id
group by orders.order_date) as totalsales;

# determine top 3 most ordered pizza types based on revenue for each pizza category

select name, revenue from (select category, name, revenue,
rank() over(partition by category order by revenue desc) as ranking from
(select pizza_types.category, pizza_types.name, sum(pizzas.price * order_details.quantity) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as b) as a
where ranking <= 3;

use pizzahut;
select * from order_details;
select * from orders;
select * from pizzas;
select * from pizza_types;


