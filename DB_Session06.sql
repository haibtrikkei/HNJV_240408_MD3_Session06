create database db_session06;
use db_session06;

create table lop_hoc(
id char(10) not null primary key,
name varchar(100) not null unique,
total_student int,
status bit default 1);

create table sinh_vien(
id int auto_increment primary key,
name varchar(50),
gender bit,
birthday date,
address varchar(200),
class_id char(10),
foreign key (class_id) references lop_hoc(id));

-- them dl bang lop_hoc
insert into lop_hoc(id,name,status) values
('nv240408','Lập trình java fullstack',1),
('nv240501','Lập trình javascript fullstack',1);

select * from lop_hoc;

-- update set total_student = 0
update lop_hoc set total_student = 0;

-- cài đặt 1 trigger tự động cập nhật total_student = 0 khi thêm 1 lớp học mới

-- test thêm mới dữ liệu bảng lop_hoc
insert into lop_hoc(id,name,status) values
('jv250411','Lập trình java 250105 fullstack 333',1);

-- trigger dem so luong sinh vien khi them moi vao bang sinh vien
drop trigger if exists tg_count_student;
delimiter $$
create trigger tg_count_student
after insert on sinh_vien
for each row
begin 
    update lop_hoc set total_student = 0 where total_student is null;
    update lop_hoc set total_student = total_student+1 where id = new.class_id;
end;$$

-- test
select * from lop_hoc;
select * from sinh_vien;

insert into sinh_vien(name,gender,birthday,address,class_id) values
('Nguyễn Tuấn Anh 333',1,'2002-12-21','Hà Nội','jv250411');


-- bai tap 01
create table product(
pro_id int auto_increment primary key,
name varchar(100),
quantity int,
price double);

insert into product(name,quantity,price) values ('Tivi',10,2000000);

create table shopping_cart(
cart_id int auto_increment primary key,
pro_id int,
quantity int,
amount double,
foreign key(pro_id) references product(pro_id));

-- tao trigger: khi thay doi price trong product thi amount trong shopping_cart se thay doi theo
drop trigger if exists tg_update_price_cart;
delimiter $$
create trigger tg_update_price_cart
after update on product
for each row
begin
	if(old.price != new.price) then
		update shopping_cart set amount = quantity * new.price;
    end if; 
end;
$$

select * from product;
select * from shopping_cart;
insert into shopping_cart(pro_id,quantity) values (1,8);

update product set price = 1000000 where pro_id = 1;

-- tao trigger: khi thêm dữ liệu vào bảng shopping_cart thì quantity trong bảng product cũng sẽ giảm đi tương ứng
-- kiểm tra thêm ràng buộc quantity trong bảng shopping_cart phải nhỏ hơn quantity trong bảng product
drop trigger if exists tg_insert_shoping_cart;
delimiter $$
create trigger tg_insert_shoping_cart
before insert on shopping_cart
for each row
begin
	if exists (select * from product where pro_id=new.pro_id and new.quantity>quantity) then
		SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'số lượng đặt hàng lớn hơn số lượng hiện có';
    end if;
    update product set quantity = quantity - new.quantity;
end;
$$

-- transaction
start transaction;
	insert into shopping_cart(pro_id,quantity) values (1,8);
commit;
set autocommit=0;