use 图书管理系统;
select * from students;
select * from admins;
select * from books;

select 位置 from books where 书名 = '三体';

select 书名 from books where 书号 in (select 书号 from orders_detail 
where 订单号 = (select 订单号 from orders where 创建日期='2025-04-10' and 学号 = (select 学号 from students where 姓名='林晓月')));

select 借阅数量 from orders
where 创建日期='2025-04-10' and 学号 = (select 学号 from students where 姓名='林晓月');

select 价格 from orders_detail where 订单号 = (select 订单号 from orders 
where 创建日期='2025-04-10' and 学号 = (select 学号 from students where 姓名='林晓月')); 

select * from fines;
select * from orders_detail;


set sql_safe_updates = 0;
update students
set 可借书数 = 可借书数 + 1
where not exists(
select 1 from fines
where students.学号 = fines.学号
) 
and 学号 in (
select 学号
from orders where 订单号 in
(select 订单号
from orders_detail
where 订单状态 = '已归还')
group by 学号
having count(*) >= 2
);


select * from students;

update orders_detail set 订单状态= '已归还', 归还日期 = '2025-04-13'
where 订单号= 10016 and 书号= 'ISBN009';
delete from fines where 订单号= 10016 and 逾期书目= 'ISBN009';


select * from orders;

select 学号,sum(借阅数量)
from orders
group by 学号
order by sum(借阅数量) desc;

select * from admin_salaries;
select * from admin_attendences;


select 书名, 位置
from books 
where 书号 in
(select 书号 from borrow_rank);

create view borrow_rank as
select 书号,count(*)
from orders_detail
group by 书号
order by count(*) desc
limit 1;


create view total_borrow as  
select 书号 from orders_detail;

create view book_type as 
select 书号,类型 from books;

select 类型, count(*)
from total_borrow left join book_type on total_borrow.书号 = book_type.书号
group by 类型
order by count(*) desc;


select * from orders_detail;

create view year_rank as 
select 管理员号,年总收入 from admin_salaries;

create view admin_name as 
select 管理员号,姓名 from admins;

select 年总收入,姓名 from 
year_rank left join admin_name on year_rank.管理员号 = admin_name.管理员号
order by 年总收入 desc;

select * from year_rank;


create view stu_read as 
select 书号, count(*) as counts from orders_detail where 订单号 in(
select 订单号 from orders where 学号 in(
select 学号 from students where 姓名 in ('张明远','李思涵','张瑞轩','刘雨桐','陈一鸣')
)
)
group by 书号
order by count(*) desc;

select 书名, counts
from stu_read left join books on stu_read.书号 = books.书号;

select * from  stu_read2;


create view type_counts as
select counts,类型
from stu_read left join books on stu_read.书号 = books.书号;

select 类型, sum(counts) from type_counts
group by 类型
order by sum(counts) desc;



create view stu_read3 as 
select 书号, count(*) as counts from orders_detail where 订单号 in(
select 订单号 from orders where 学号 in(
select 学号 from students where 姓名 like '张%'
)
)
group by 书号
order by count(*) desc;

select 书名, counts
from stu_read3 left join books on stu_read3.书号 = books.书号;

create view type_counts3 as
select counts,类型
from stu_read3 left join books on stu_read3.书号 = books.书号;

select 类型, sum(counts) from type_counts3
group by 类型
order by sum(counts) desc;


alter table admin_salaries add primary key (管理员号);

show index from admin_salaries;

explain select * from admin_salaries where 管理员号=1;


explain select * from books where 书名 = '三体';


create fulltext index book_name_idx on books(书名);

select * from books where match(书名) against ("百年孤独");

show index from books;

explain select * from books where match(书名) against ("百年孤独");








