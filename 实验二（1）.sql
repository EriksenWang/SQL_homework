create database 图书管理系统;
use 图书管理系统;
create table students(
学号 int primary key,
姓名 varchar(10) not null,
性别 enum('男','女') not null,
学院 varchar(10) default '未知',
可借书数 int default 2
) comment '学生表';

create table books(
书号 varchar(20) primary key,
作者 varchar(20) not null,
书名 varchar(40) not null,
位置 varchar(40) default '未知',
价格 float(10,1) unsigned not null,
类型 varchar(20) default '未知'
) comment '书籍表';


create table admins(
管理员号 int primary key,
姓名 varchar(20) not null,
性别 enum('男','女') not null
) comment '管理员表';

create table orders(
订单号 int primary key,
学号 int not null,
管理员号 int not null,
创建日期 date not null,
借阅数量 int not null,
foreign key(学号) references students(学号),
foreign key(管理员号) references admins(管理员号)
) comment '订单表';

create table orders_detail(
订单号 int not null,
书号 varchar(20) not null,
价格 float(10,1) not null,
借出日期 date not null,
应还日期 date not null,
归还日期 date,
续借次数 int default 0,
订单状态 enum('借阅中','已归还','续借中','逾期未还') default '借阅中',
foreign key(订单号) references orders(订单号),
foreign key(书号) references books(书号)
) comment '订单明细表';

alter table orders_detail
modify column 订单状态 enum('借阅中','已归还','续借中','逾期未还','逾期归还') default '借阅中';


create table fines(
罚单号 int primary key,
学号 int not null,
逾期书目 varchar(40),
逾期天数 int not null,
罚款金额 float(10,1) not null,
是否缴纳 enum('是','否') not null,
foreign key(学号) references students(学号)
) comment '罚款表';

alter table fines add 订单号 int not null;
alter table fines add constraint 订单号 foreign key(订单号) references orders(订单号);
alter table fines drop primary key;
alter table fines modify column 罚单号 int auto_increment primary key;
alter table fines auto_increment= 90001;

alter table fines modify column 学号 int;
alter table fines modify column 逾期天数 int default 0;
alter table fines modify column 罚款金额 int default 0;
alter table fines modify column 是否缴纳 enum('是','否') default '否';

alter table fines add 应还日期 date;


create table admin_salaries(
管理员号 int not null,
总工资 float(10,1),
底薪 float(10,1) default 5000,
奖金 float(10,1) ,
工作时长排名 int,
工作总天数 float(10,1) default 0,
foreign key(管理员号) references admins(管理员号)
) comment '管理员工资表';

alter table admin_salaries
add 年总收入 float(10,1) default 0;


create table admin_attendences(
管理员号 int not null,
打卡日期 date not null,
签到时间 time,
签退时间 time,
是否迟到或早退 enum('是','否') not null,
foreign key(管理员号) references admins(管理员号)
) comment '管理员考勤表';


SHOW TRIGGERS;
drop trigger admin_salaries_update;

delimiter $$
create trigger admin_salaries_update
after insert on admin_attendences
for each row
begin

update admin_salaries 
set 工作总天数 = if(new.是否迟到或早退 = '否',  工作总天数 + 1,  工作总天数 + 0.5) 
where 管理员号 = new.管理员号;

update admin_salaries t
join(
    select 
	  管理员号,
      dense_rank() over (order by 工作总天数 desc) as cal_rank
    from admin_salaries
  ) as tr on t.管理员号 = tr.管理员号 
  set t.工作时长排名 = tr.cal_rank;

update admin_salaries
set 奖金 = 2000/工作时长排名;

update admin_salaries
set 总工资 = 底薪 + 奖金;

end $$
delimiter ;




set sql_safe_updates = 0;
SET GLOBAL event_scheduler = ON;

insert into admins(管理员号,姓名,性别)
values (001,'王建国','男'),(002,'李萍','女'),(003,'张德福','男'),(004,'陈淑芬','女'),(005,'刘志强','男');

insert into students(学号,姓名,性别,学院)
values ('20230001', '张明远', '男', '计算机学院'),
('20230002', '李思涵', '女', '文学院'),
('20230003', '张瑞轩', '男', '工程学院'),
('20230004', '刘雨桐', '女', '外国语学院'),
('20230005', '陈一鸣', '男', '医学院'),
('20230006', '林晓月', '女', '艺术学院'),
('20230007', '赵天宇', '男', '计算机学院'),
('20230008', '周雅婷', '女', '经济学院'),
('20230009', '吴子轩', '男', '法学院'),
('20230010', '黄梦琪', '女', '管理学院'),
('20230011', '徐浩然', '男', '工程学院'),
('20230012', '孙佳怡', '女', '医学院'),
('20230013', '郑文博', '男', '计算机学院'),
('20230014', '高诗涵', '女', '文学院'),
('20230015', '方志远', '男', '经济学院');

INSERT INTO books (书号, 作者, 书名, 位置, 价格, 类型) VALUES
('ISBN001', '刘慈欣', '三体', 'A区3排2架', 45.90, '科幻小说'),
('ISBN002', '余华', '活着', 'B区1排5架', 39.80, '文学经典'),
('ISBN003', 'J.K.罗琳', '哈利波特与魔法石', 'C区2排1架', 59.00, '外国文学'),
('ISBN004', '马尔克斯', '百年孤独', 'A区4排3架', 49.90, '外国文学'),
('ISBN005', '东野圭吾', '解忧杂货店', 'B区2排4架', 42.50, '悬疑推理'),
('ISBN006', '钱钟书', '围城', 'A区1排6架', 36.00, '文学经典'),
('ISBN007', '路遥', '平凡的世界', 'C区3排2架', 128.00, '文学经典'),
('ISBN008', '毛姆', '月亮与六便士', 'B区4排1架', 34.90, '外国文学'),
('ISBN009', '卡勒德·胡赛尼', '追风筝的人', 'A区2排5架', 41.00, '外国文学'),
('ISBN010', '斯蒂芬·金', '肖申克的救赎', 'D区1排3架', 38.50, '文学经典'),
('ISBN011', '村上春树', '挪威的森林', 'B区3排6架', 43.80, '外国文学'),
('ISBN012', '乔治·奥威尔', '1984', 'C区4排4架', 29.90, '科幻小说'),
('ISBN013', '老舍', '骆驼祥子', 'A区5排2架', 27.00, '文学经典'),
('ISBN014', '丹·布朗', '达芬奇密码', 'D区2排5架', 52.00, '悬疑推理'),
('ISBN015', '张爱玲', '倾城之恋', 'B区5排3架', 32.80, '文学经典'),
('ISBN016', '托尔斯泰', '安娜·卡列尼娜', 'C区5排1架', 68.00, '外国文学'),
('ISBN017', '海明威', '老人与海', 'A区6排4架', 25.00, '外国文学'),
('ISBN018', '曹雪芹', '红楼梦', 'D区3排2架', 99.00, '文学经典'),
('ISBN019', '梭罗', '瓦尔登湖', 'B区6排5架', 37.50, '人文社科'),
('ISBN020', '三毛', '撒哈拉的故事', 'C区6排3架', 33.00, '文学经典'),
('ISBN021', '阿加莎·克里斯蒂', '无人生还', 'A区7排1架', 40.00, '悬疑推理'),
('ISBN022', '雨果', '悲惨世界', 'D区4排6架', 89.00, '外国文学'),
('ISBN023', '王小波', '沉默的大多数', 'B区7排2架', 35.60, '人文社科'),
('ISBN024', '加缪', '局外人', 'C区7排4架', 31.20, '外国文学'),
('ISBN025', '沈从文', '边城', 'A区8排3架', 28.50, '文学经典');


insert into admin_salaries(管理员号) values (001),(002),(003),(004),(005);

truncate table admin_attendences;
truncate table admin_salaries;


insert into admin_attendences(管理员号,打卡日期,是否迟到或早退) values
(001, '2023-10-01', '否'),
(002, '2023-10-01', '否'),
(003, '2023-10-01', '否'),
(004, '2023-10-01', '是'),
(005, '2023-10-01', '否'),

(001, '2023-10-02', '是'),
(002, '2023-10-02', '否'),
(003, '2023-10-02', '否'),
(004, '2023-10-02', '否'),

(001, '2023-10-03', '否'),
(002, '2023-10-03', '是'),
(003, '2023-10-03', '否'),
(004, '2023-10-03', '否'),
(005, '2023-10-03', '否'),

(001, '2023-10-04', '否'),
(003, '2023-10-04', '是'),
(004, '2023-10-04', '否'),
(005, '2023-10-04', '否'),

(002, '2023-10-05', '否'),
(003, '2023-10-05', '否'),
(004, '2023-10-05', '是'),
(005, '2023-10-05', '是');


show triggers;

select * from admin_salaries;
select * from admin_attendences;

update admin_salaries
set 年总收入 = 年总收入 + 总工资;



INSERT INTO orders (订单号, 学号, 管理员号, 创建日期, 借阅数量) VALUES
('10001', '20230001', '003', '2025-03-01', 2),
('10002', '20230002', '001', '2025-03-03', 1),
('10003', '20230003', '004', '2025-03-05', 1),
('10004', '20230004', '002', '2025-03-07', 2),
('10005', '20230005', '005', '2025-03-09', 1),
('10006', '20230006', '003', '2025-03-11', 2),
('10007', '20230007', '001', '2025-03-13', 1),
('10008', '20230008', '004', '2025-03-15', 2),
('10009', '20230009', '002', '2025-03-17', 1),
('10010', '20230010', '005', '2025-03-19', 1),
('10011', '20230011', '003', '2025-03-21', 2),
('10012', '20230012', '001', '2025-03-23', 1),
('10013', '20230013', '004', '2025-03-25', 2),
('10014', '20230014', '002', '2025-03-27', 1),
('10015', '20230015', '005', '2025-03-29', 1),
('10016', '20230001', '003', '2025-03-31', 2),
('10017', '20230002', '001', '2025-04-02', 1),
('10018', '20230003', '004', '2025-04-04', 1),
('10019', '20230004', '002', '2025-04-06', 2),
('10020', '20230005', '005', '2025-04-08', 1),
('10021', '20230006', '003', '2025-04-10', 2),
('10022', '20230007', '001', '2025-04-12', 1),
('10023', '20230008', '004', '2025-04-14', 1),
('10024', '20230009', '002', '2025-04-16', 2),
('10025', '20230010', '005', '2025-04-16', 1);

truncate table orders_detail;
INSERT INTO orders_detail (订单号, 书号, 价格, 借出日期, 应还日期, 归还日期, 续借次数, 订单状态) VALUES
('10001', 'ISBN003', 59.00, '2025-03-01', '2025-03-15', '2025-03-14', 0, '已归还'),
('10001', 'ISBN012', 29.90, '2025-03-01', '2025-03-15', NULL, 1, '逾期未还'), 

('10002', 'ISBN007', 128.00, '2025-03-03', '2025-03-17', '2025-03-18', 0, '逾期归还'),

('10003', 'ISBN014', 52.00, '2025-03-05', '2025-03-19', '2025-03-20', 0, '逾期归还'),

('10004', 'ISBN005', 42.50, '2025-03-07', '2025-03-21', '2025-03-25', 0, '逾期归还'),
('10004', 'ISBN019', 37.50, '2025-03-07', '2025-03-21', NULL, 0, '逾期未还'),

('10005', 'ISBN018', 99.00, '2025-03-09', '2025-03-23', '2025-03-22', 0, '已归还'),

('10006', 'ISBN008', 34.90, '2025-03-11', '2025-03-25', NULL, 1, '逾期未还'), 
('10006', 'ISBN015', 32.80, '2025-03-11', '2025-04-22', NULL, 1, '续借中'), -- 4月22日续借应还

('10007', 'ISBN021', 40.00, '2025-03-13', '2025-03-27', NULL, 0, '逾期未还'),

('10008', 'ISBN002', 39.80, '2025-03-15', '2025-03-29', '2025-03-30', 0, '逾期归还'),
('10008', 'ISBN017', 25.00, '2025-03-15', '2025-03-29', NULL, 0, '逾期未还'),

('10009', 'ISBN013', 27.00, '2025-03-17', '2025-03-31', '2025-03-30', 0, '已归还'),

('10010', 'ISBN006', 36.00, '2025-03-19', '2025-04-02', '2025-04-01', 0, '已归还'),

('10011', 'ISBN004', 49.90, '2025-03-21', '2025-04-04', NULL, 0, '逾期未还'),
('10011', 'ISBN023', 35.60, '2025-03-21', '2025-04-04', NULL, 0, '逾期未还'),

('10012', 'ISBN011', 43.80, '2025-03-23', '2025-04-06', '2025-04-05', 0, '已归还'),

('10013', 'ISBN016', 68.00, '2025-03-25', '2025-04-08', NULL, 0, '逾期未还'),
('10013', 'ISBN024', 31.20, '2025-03-25', '2025-04-08', NULL, 0, '逾期未还'),

('10014', 'ISBN009', 41.00, '2025-03-27', '2025-04-10', NULL, 0, '逾期未还'),

('10015', 'ISBN020', 33.00, '2025-03-29', '2025-04-12', NULL, 0, '逾期未还'),

('10016', 'ISBN009', 41.00, '2025-03-31', '2025-04-14', NULL, 0, '逾期未还'),
('10016', 'ISBN022', 89.00, '2025-03-31', '2025-04-14', NULL, 0, '逾期未还'),

('10017', 'ISBN001', 45.90, '2025-04-02', '2025-04-16', NULL, 0, '借阅中'), 

('10018', 'ISBN010', 38.50, '2025-04-04', '2025-04-18', NULL, 0, '借阅中'),

('10019', 'ISBN001', 45.90, '2025-04-06', '2025-04-20', NULL, 0, '借阅中'),
('10019', 'ISBN020', 33.00, '2025-04-06', '2025-04-20', NULL, 0, '借阅中'),

('10020', 'ISBN005', 42.50, '2025-04-08', '2025-04-22', NULL, 0, '借阅中'),

('10021', 'ISBN014', 52.00, '2025-04-10', '2025-04-24', NULL, 0, '借阅中'),
('10021', 'ISBN022', 89.00, '2025-04-10', '2025-04-24', NULL, 0, '借阅中'),

('10022', 'ISBN016', 68.00, '2025-04-12', '2025-04-26', NULL, 0, '借阅中'),

('10023', 'ISBN007', 128.00, '2025-04-14', '2025-04-28', NULL, 0, '借阅中'),

('10024', 'ISBN001', 45.90, '2025-04-16', '2025-04-30', NULL, 0, '借阅中'),
('10024', 'ISBN025', 28.50, '2025-04-16', '2025-04-30', NULL, 0, '借阅中'),

('10025', 'ISBN004', 49.90, '2025-04-16', '2025-04-30', NULL, 0, '借阅中');

select * from orders_detail;
select * from orders;

delimiter $$
create event check_return
on schedule every 1 day
starts '2025-04-18 00:00:00'
do
  begin
    update orders_detail
    set 订单状态 = '逾期未还'
    where 订单状态 = '借阅中' and current_date > 应还日期 ;
    
	update orders_detail
    set 订单状态 = '逾期未还'
    where 订单状态 = '续借中' and current_date > 应还日期 ;
    
    INSERT INTO fines(逾期书目, 订单号,应还日期)
    SELECT 书号, 订单号 , 应还日期
    FROM orders_detail 
    WHERE 订单状态 = '逾期未还' 
    AND NOT EXISTS (
    SELECT 1 
    FROM fines 
    WHERE 
        fines.逾期书目 = orders_detail.书号 
        AND fines.订单号 = orders_detail.订单号 
    );
    
    update fines
    set 逾期天数 = datediff(current_date, 应还日期) ;
    
    update fines
    set 罚款金额 = 0.1*(select 价格 from books where books.书号 = fines.逾期书目)
    where 逾期天数 > 7 and  逾期天数 < 30; 
    
    update fines
    set 罚款金额 = 0.6*(select 价格 from books where books.书号 = fines.逾期书目)
    where 逾期天数 >= 30;
    
    update fines
    set 学号 = (select 学号 from orders where orders.订单号 = fines.订单号)
    where 1=1;

    
  end $$
delimiter ;

ALTER EVENT check_return ENABLE;

truncate table fines;
select * from fines;
select curdate();
select current_date;
select * from orders_detail;

show events;

ALTER EVENT check_return
ON SCHEDULE EVERY 1 DAY
STARTS '2025-04-19 00:00:00';




