CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 
INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

CREATE TABLE users(userid integer,signup_date date); 
INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

CREATE TABLE sales(userid integer,created_date date,product_id integer); 
INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

CREATE TABLE product(product_id integer,product_name text,price integer); 
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


/* Q1. What is the total amount each customer spent on zomato ? */
SELECT a.userid,sum(b.price) as Total_Amount from sales as a 
INNER join product as b
on a.product_id = b.product_id
group by a.userid
order by Total_Amount DESC;

/* Q2. How many has each customer visited zomato ? */
select userid,count(DISTINCT(created_date)) as Days from sales
group by 1;

/* Q3. What was the first product purchased by each customer ? */
select * from
(select *,rank() over(partition by userid order by created_date) rank from sales) a where rank=1;

/*Q4. What is the most purchased item and how many times it was purchased by all customer ?*/
select userid,count(product_id) as total_no_of_purchased ,product_id from sales where
product_id=(select product_id from sales 
group by product_id
order by count(product_id) DESC limit 1)
group by userid,product_id;


/*Q5. which item was the most popular for cusomers ? */
select * from
(select *,rank() over(partition by userid order by total_no_of_purchased) rank from  
(select userid,product_id,count(product_id) as total_no_of_purchased  from sales group by userid,product_id) a)b
where rank=1

/*Q6. Which item was purchased first by the customer after they become member ? */
select * from
(select c.*,rank() over(PARTITION by userid order by created_date) rank from
(select a.userid,a.product_id,a.created_date,b.gold_signup_date from sales as a
inner join goldusers_signup as b 
on a.userid=b.userid and created_date>=gold_signup_date)c)d
where rank=1

/*Q7. Which item was purchaes just before the customer become gold member ? */
select * from
(select c.*,rank() over(PARTITION by userid order by created_date DESC) rank from
(select a.userid,a.product_id,a.created_date,b.gold_signup_date from sales as a
inner join goldusers_signup as b 
on a.userid=b.userid and created_date<=gold_signup_date)c)d
where rank=1

/*Q8. What is the total orders and amount spent for each member before they become a member ? */
select userid,count(created_date),sum(price) from
(SELECT c.*,d.price from
(select a.userid,a.product_id,a.created_date,b.gold_signup_date from sales as a
inner join goldusers_signup as b 
on a.userid=b.userid and created_date<=gold_signup_date) c inner join product d
on c.product_id=d.product_id) e
group by userid

/*Q9. If buying each product generates points for eg 5rs=2 zomato point 
  and each product has different purchasing points for eg for p1 5rs=1 zomato point,
  for p2 10rs=zomato point and p3 5rs=1 zomato point  2rs =1zomato point, calculate points collected 
  by each customer and for which product most points have been given till now. */
select userid,sum(Total_points)*2.5 as total_money_earned from
(select e.*,amt/points as Total_points from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points FROM
(select c.userid,c.product_id,sum(price) as amt FROM
(select a.*,b.price from sales a inner join product b 
on a.product_id = b.product_id) c 
 group by userid,product_id)d)e)F 
 group by userid
 
select * FROM
(select *,rank() over(partition by total_points_earned  )as rnk from
( select product_id,sum(Total_points) as total_points_earned from
(select e.*,amt/points as Total_points from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points FROM
(select c.userid,c.product_id,sum(price) as amt FROM
(select a.*,b.price from sales a inner join product b 
on a.product_id = b.product_id) c 
 group by userid,product_id)d)e)f 
 group by product_id)g)H 
 where rnk=1
 
 
 /*Q10. In the first year after a customer joins the gold program (including the join date ) 
 irrespective of what customer has purchased earn 5 zomato points for every 10rs spent 
 who earned more more 1 or 3 what int earning in first yr ? 1zp = 2rs */
 
 
select c.*,d.price*0.5 as Total_points from 
(select a.userid,a.product_id,a.created_date,b.gold_signup_date from sales as a
inner join goldusers_signup as b 
on a.userid=b.userid and created_date>=gold_signup_date and created_date<=gold_signup_date+365) c 
inner join product d 
on c.product_id=d.product_id

/*Q11. rnk all transaction of the customers */
select *,rank() over(partition by userid order by created_date asc) from sales

/*12. rank all transaction for each member whenever they are zomato gold member
for every non gold member transaction mark as na */
select e.*,case when rnk=0 then 'NA' else rnk end as rnkk from
(select c.*,cast((case when gold_signup_date is null then 0 else rank() over(partition by userid order by created_date desc ) end) as varchar) as rnk from
(select a.userid,a.product_id,a.created_date,b.gold_signup_date from sales as a
left join goldusers_signup as b 
on a.userid=b.userid and created_date>=gold_signup_date) c)e

 