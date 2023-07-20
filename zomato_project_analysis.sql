CREATE DATABASE ZOMATO_PROJECT;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-09-22'),
(3,'2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);


drop table if exists product;
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

-- LET US SOLVE FEW BUSINESS QUESTIONS......

-- 1. What is the total amount each customer spent on zomato ?
select c.userid,sum(c.price) total_amt from 
(select a.* ,b.product_name,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid;

-- 2. How many days has each customer visited zomato?
select userid,count(distinct created_date) days_visited from sales group by userid

-- 3. What was the first product purchased by each customer ?
select a.userid,a.created_date,product_id from
(select userid,created_date,product_id,rank() over (partition by userid order by created_date) rnk
from sales)a
where rnk=1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all the customers?
select userid,count(product_id) most_purchased_count from sales where product_id=
(select product_id from sales group by product_id order by count(product_id) desc limit 1)
group by userid

-- 5. Which item was most popular for each customer?
select b.* from
(select a.*,rank() over(partition by a.userid order by a.cnt desc) rnk from
(select userid , product_id, count(product_id) cnt from sales group  by userid,product_id 
order by userid,count(product_id) desc)a)b
where b.rnk=1;

-- 6. What is the total orders amd amount spent for each member before they became a member?
select f.userid,count(f.product_id) no_of_orders,sum(f.price) amt_purchased from
(select d.userid,d.product_id,e.price from 
(select c.* from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a
inner join goldusers_signup b on a.userid=b.userid)c
where c.created_date<=gold_signup_date)d
inner join product e on d.product_id=e.product_id)f
group by f.userid
order by userid asc;

Q9 If buying each product generates points. FOR eg: 5 Rs= 2 points and each product has different points. For eg: 
P1  5Rs = 1zomato points ,
P2  10rs= 5 zomato points,
p3 5Rs =1 zomato points;

 Calculate points collected by each customer and for which product most points have bbeen given till date
 select f.userid,sum(total_points) as grand_total from
 (select e.*, e.amt/e.points as total_points from
 (select d.* , case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end points from
 (select c.userid,c.product_id,sum(c.price) amt from
 (select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
 group by c.userid,c.product_id
 order by userid,product_id)d)e)f
 group  by f.userid;
 
 -- Money earned
 select g.userid,g.grand_total/2.5 as money_earned from
 (select f.userid,sum(total_points) as grand_total from
 (select e.*, e.amt/e.points as total_points from
 (select d.* , case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end points from
 (select c.userid,c.product_id,sum(c.price) amt from
 (select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
 group by c.userid,c.product_id
 order by userid,product_id)d)e)f
 group  by f.userid)g
 
 
 -- Which product was purchased first by the customers , after they became a gold_user_member?
 select * from sales;
 select * from goldusers_signup;
 select userid,created_date from
 (select userid,created_date, rank() over (partition by userid order by created_date) rnk from
 (select c.* from 
 (select a.* , b.gold_signup_date from 
 sales a inner join goldusers_signup b
  on a.userid=b.userid)c
  where c.created_date>=gold_signup_date)d)e
  where rnk=1;
  
  -- What was the item purchased juist before a user became the member ?
  
  select userid,created_date from
 (select userid,created_date, rank() over (partition by userid order by created_date desc) rnk from
 (select c.* from 
 (select a.* , b.gold_signup_date from 
 sales a inner join goldusers_signup b
  on a.userid=b.userid)c
  where c.created_date<=gold_signup_date)d)e
  where rnk=1;
  
  -- What is the total orders and amount spent for each member before they became a member ?
select f.userid,count(f.product_id) total_no ,sum(f.price) total_amt from
(select d.*, e.price from 
(select c.* from 
 (select a.* , b.gold_signup_date from 
 sales a inner join goldusers_signup b
  on a.userid=b.userid)c
  where c.created_date<=gold_signup_date)d
  inner join product e 
  on d.product_id=e.product_id)f
  group by f.userid;
  
  
  -- In the first one year after the customer joins the gold programme (including their join date) irrespective of what the customers has purchased
  -- they earn 5 zomato points for every 10rs spent who earned more 1 or 3 , and what was their points earned in the 1st year after the membership
  select c.*, d.price*0.5 total_point_earned_by_gold from
(select a.* , b.gold_signup_date from 
 sales a inner join goldusers_signup b
  on a.userid=b.userid and created_date>=gold_signup_date and created_date <= date_add(gold_signup_date, INTERVAL 1 YEAR))c
  inner join product d on
  c.product_id=d.product_id;
  
   -- Rank all the transactions of the cutomers
   select a.*,rank() over (partition by userid order by created_date) rnk
   from sales a;
  

-- Rank all the transactions for each member whenever they are a zomato gold member for evry non gold user 
-- mark as na

select e.userid,e.created_date,e.product_id,e.gold_signup_date,case when rnk_char=0 then 'na' else rnk_char end as rnk_char2 from
(select d.userid,d.created_date,d.product_id,d.gold_signup_date, cast(rnk as CHAR) rnk_char from
(select c.*, case when gold_signup_date is null then 0 else 
rank() over (partition by userid order by created_date desc)end AS rnk from
(select a.* , b.gold_signup_date from 
 sales a left join goldusers_signup b
  on a.userid=b.userid and created_date>=gold_signup_date)c)d)e


select * from goldusers_signup;
select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;