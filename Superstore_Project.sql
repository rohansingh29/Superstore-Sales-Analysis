CREATE TABLE superstore_sales (

category VARCHAR(100),
city VARCHAR(100),
country VARCHAR(100),
customer_id VARCHAR(50),
customer_name VARCHAR(150),
discount NUMERIC(5,2),
market VARCHAR(50),

order_date DATE,
order_id VARCHAR(50),
order_priority VARCHAR(20),

product_id VARCHAR(50),
product_name VARCHAR(255),

profit NUMERIC(12,2),
quantity INT,

region VARCHAR(50),
sales NUMERIC(12,2),

segment VARCHAR(50),

ship_date DATE,
ship_mode VARCHAR(50),
shipping_cost NUMERIC(12,2),

state VARCHAR(100),
sub_category VARCHAR(100),

discount_bin VARCHAR(20),
profit_margin NUMERIC(10,2),
sales_per_unit NUMERIC(12,2),
order_year INT,
order_month INT,
order_month_name VARCHAR(20),
order_day INT,
order_week INT,
order_quarter INT,
shipping_days INT
);
select * from superstore_sales

-- BUSINESS QUERIES

-- 1)Top 10 Customers by Total Profit
select customer_id,customer_name,sum(profit) as total_profit from superstore_sales
group by customer_id,customer_name
order by sum(profit) desc limit 10 ;

--2)Top Product in Each Category
with cte as(
select category,product_name,sum(sales) as total_sales,
dense_rank() over(partition by category order by sum(sales)desc)as rnk from superstore_sales
group by category,product_name
)
select * from cte where rnk = 1

--3)Month-over-Month Sales Growth
with cte as (select order_year,order_month,sum(sales) as total_sales from superstore_sales
group by order_year,order_month)

select *,lag(total_sales)over(order by order_year,order_month)as previous_month_sales,
total_sales-lag(total_sales)over(order by order_year,order_month) as Growth
from cte

--4)Next Month Sales Comparison
with cte as (select order_year,order_month,sum(sales) as total_sales from superstore_sales
group by order_year,order_month)

select *,lead(total_sales)over(order by order_year,order_month)as next_month_sales
from cte

--5) TOP 10 States Profit-wise
with cte as (select state,sum(profit) as total_profit,
dense_rank()over(order by sum(profit) desc) as rnk from superstore_sales
group by state)

select * from cte where rnk <=10

--6) 3 Months moving Average of Sales
select order_year,order_month,sum(sales)as total_sales,
avg(sum(sales))over(order by order_year, order_month rows between 2 preceding and current row) as moving_average from superstore_sales
group by order_year,order_month

--7) Highest Profit Order in Every Region
with cte as (select *,
row_number()over(partition by region order by profit desc) as rnk from superstore_sales)

select * from cte where rnk=1

--8) Customer Lifetime Value
select customer_name,count(order_id) as total_orders,sum(sales)as lifetime_sales,
sum(profit) as lifetime_profit from superstore_sales 
group by customer_name
order by sum(sales) desc

--9) Discount Impact on Profit
select discount_bin,avg(profit) as avg_profit,sum(sales) as total_sales from superstore_sales
group by discount_bin order by discount_bin

alter table superstore_sales
rename column "Shiping days" to shipping_days

--10) Shipping Mode Performance
select ship_mode,avg(Shipping_days) as avg_shipping_days, sum(sales) as total_sales,
sum(profit) as total_profit from superstore_sales group by ship_mode

--11) Most Profitable Product in Every Region
with cte as(select region,product_name,sum(profit) as total_profit,
dense_rank()over(partition by region order by sum(profit) desc) as rnk from superstore_sales group by region,product_name)

select * from cte where rnk = 1 order by total_profit desc

--12) Profitability Classification
with cte as (select product_name,sum(profit) as total_profit
from superstore_sales group by product_name)

select *,
case
when total_profit<0 then 'Loss'
when total_profit between 0 and 100 then 'Low Profit'
when total_profit between 101 and 500 then 'Medium Profit'
else 'High Profit' 
end as profit_category from cte

--13) Top 5 Customers in Every Region
with cte as(select region,customer_name,sum(sales) as total_sales,
dense_rank() over(partition by region order by sum(sales)desc) as rnk from superstore_sales
group by region,customer_name)

select * from cte where rnk<=5

--14) 








