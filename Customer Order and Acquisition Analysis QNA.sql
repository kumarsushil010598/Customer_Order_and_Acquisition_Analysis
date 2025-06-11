--1. find top restaurant by cusine type without using limit and top function

select * from orders

select * from(
	select *, ROW_NUMBER() over(partition by Cuisine order by TOTAL_ORDERS desc) as rn
	from(
		select Cuisine,restaurant_id, count(*) as TOTAL_ORDERS
		from orders
		group by Cuisine, restaurant_id
		) A) B
where rn<2

--2. find the daily new customer count from the launch date (everyday how many new customers are we acquiring)

select * from orders

select FIRST_ORDER_DATE, count(*) as NO_OF_NEW_CUSTOMERS
from(
	select Customer_code, cast(min(Placed_at) as date) as FIRST_ORDER_DATE
	from orders
	group by Customer_code
	) A
group by FIRST_ORDER_DATE
order by FIRST_ORDER_DATE

--3. count of all the users who were acquired in jan 2025 (1st order in jan) and only placed one order in jan and did not place any other order

select * from orders

select Customer_code
from orders
where DATEPART(MONTH,Placed_at)=1 
and Customer_code not in (select Customer_code
	from orders
	where DATEPART(MONTH,Placed_at)>1
	group by Customer_code)
group by Customer_code
having count(customer_code)=1

select Customer_code
from orders
where DATEPART(MONTH,Placed_at)>1
group by Customer_code

--4. list of all the customers with no order in last 7 days but were acquired one month ago with their first order on promo

select MAX(Placed_at) from orders 
--2025-03-31 to 2025-03-24

select * from orders

select * 
from orders o1
inner join (
	select Customer_code, MIN(Placed_at) as FIRST_ORDER_DATE
	,MAX(Placed_at) as LATEST_ORDER_DATE
	from orders
	group by Customer_code) o2
on o1.Customer_code=o2.Customer_code and o1.Placed_at=o2.FIRST_ORDER_DATE
where o2.LATEST_ORDER_DATE< '2025-03-24' and
o2.FIRST_ORDER_DATE <'2025-02-28'and o1.Promo_code_Name is not null

select * from(
select Customer_code
,MIN(Placed_at) as FIRST_ORDER_DATE
,MAX(Placed_at) as LATEST_ORDER_DATE
from orders
group by Customer_code) A
where LATEST_ORDER_DATE<'2025-03-24' and FIRST_ORDER_DATE <'2025-02-28'

--5. Growth team is planning to create a trigger that will target customers after their every third order
--with a personalized communication and 
--they have asked you to create a query for this
--3rd, 6th, 9th
select * from(
	select *
	,ROW_NUMBER() over(partition by customer_code order by placed_at) as ORDER_NUMBER
	from orders)A
where ORDER_NUMBER%3=0 --and cast(Placed_at as date)=GETDATE()

--6. List customers who placed more than 1 order and all their orders on a promo only
select * from(
	select Customer_code, count(*) as TOTAL_ORDERS, count(Promo_code_Name) as ORDERS_ON_PROMO
	from orders
	group by Customer_code) A
where TOTAL_ORDERS>1 and TOTAL_ORDERS=ORDERS_ON_PROMO

select Customer_code, count(*) as TOTAL_ORDERS, count(Promo_code_Name) as ORDERS_ON_PROMO
from orders
group by Customer_code
having count(*)>1 and count(*)=count(Promo_code_Name)

--7. what %age of customers were originally acquired in jan 2025.(first order without promo code)

select * from orders

select * from(
select *, ROW_NUMBER() over(partition by customer_code order by placed_at) as rn
from orders
where MONTH(Placed_at)=1) A
where rn=1 and Promo_code_Name is null

select count(case when rn=1 and Promo_code_Name is null then Customer_code end)*100/COUNT(distinct Customer_code) as PERC
from(
	select *, ROW_NUMBER() over(partition by customer_code order by placed_at) as rn
	from orders
	where MONTH(Placed_at)=1) A