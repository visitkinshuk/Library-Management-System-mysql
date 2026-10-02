create database lms;
use lms;
drop table if exists branch;
create table branch(
	branch_id varchar(10) Primary Key,	
    manager_id	varchar(10),
    branch_address	varchar(255),
    contact_no varchar (15)
);
drop table if exists employees;
create table employees(
	emp_id	varchar(10) primary key,
    emp_name	varchar(100),
    position	varchar(20),
    salary		INT,
    branch_id	varchar(10)
);

drop table if exists books;
create table books(
	isbn	varchar(20) primary key,
    book_title	varchar(100),
    category	varchar(30),
    rental_price	float,
	status varchar(35),
    author	varchar(35),
    publisher varchar(55)
);

drop table if exists members;
create table members(
	member_id	varchar(20) primary key,
    member_name	varchar(50),
    member_address	varchar(255),
    reg_date date
);

drop table if exists issued_status;
create table issued_status(
	issued_id	varchar(20) primary key,
	issued_member_id varchar(20),	
    issued_book_name	varchar(100),
    issued_date	date,
    issued_book_isbn varchar(20),	
    issued_emp_id varchar(20)
);

Alter table issued_status
Modify column issued_book_name varchar(100);

drop table if exists return_status;
create table return_status(
	return_id	varchar(20) primary key,
    issued_id	varchar(20),
    return_book_name	varchar(75),
    return_date	date,
    return_book_isbn varchar(20)
);

alter table issued_status
add constraint fk_members
foreign key (issued_member_id)
references members(member_id);

alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn)
references books(isbn);

alter table issued_status
add constraint fk_employees
foreign key (issued_emp_id)
references employees(emp_id);

alter table return_status
add constraint fk_issued_id
foreign key (issued_id)
references issued_status(issued_id);

-- alter table return_status
-- drop foreign key fk_return_book_isbn,
-- drop index fk_return_book_isbn;

-- alter table employees
-- add constraint fk_branch_id
-- foreign key (branch_id)
-- references branch(branch_id);

alter table employees
add constraint fk_branch_id
foreign key (branch_id)
references branch(branch_id);













