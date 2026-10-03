Library Management System using MySQL

Project Overview

This project is a relational database-based Library Management System developed using MySQL. It is designed to manage key library operations including books, members, employees, branches, book issuance, and book returns.

The project demonstrates practical implementation of database design, SQL querying, data integrity constraints, reporting, and stored procedures.

<img width="1645" height="1035" alt="image" src="https://github.com/user-attachments/assets/f7d83878-2dd1-4262-a66b-40b405fe3613" />

Task 1: Database Creation: Created a database named lms.
		Table Creation: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and 				relationships.

```sql
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


alter table employees
add constraint fk_branch_id
foreign key (branch_id)
references branch(branch_id);

alter table employees
add constraint fk_branch_id
foreign key (branch_id)
references branch(branch_id);

```

Key Features

Created and managed relational database tables

Implemented primary key and foreign key constraints


**CRUD Operations
**
Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert into books(isbn, book_title, category, rental_price, status, author, publisher)
	values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;
```

Task 2: Update an Existing Member's Address

```sql
set sql_safe_updates = 0; 
update members
set member_address = '125 Dhalpur St'
where member_id= 'C103';
select * from members;
```
Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
delete from issued_status
where issued_id = 'IS121';
select * from issued_status;
```
Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select * from issued_status
where issued_emp_id = 'E101';
```
Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select issued_emp_id,
count(*) as counted 
from issued_status
group by issued_emp_id
having count(*)  > 1;
```
Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book issued count
```sql
drop table if exists book_counts;
create table book_counts 
as 
	select 
	b.isbn,
	b.book_title,
	count(ist.issued_id) as no_issued
	from books as b
	join issued_status as ist 
	on b.isbn = ist.issued_book_isbn
	group by 1, 2;
	select * from book_counts;
```
Task 7. Retrieve All Books in a Specific Category:
```sql
select * from books
where category = 'classic';
```
Task 8: Find Total Rental Income by Category:
```sql
select sum(rental_price) as sum_rent, b.category, count(*) 
from books as b
join issued_status as ist
on ist.issued_book_isbn= b.isbn
group by category;
```
Task 9: List Members Who Registered in the Last 180 Days:
```sql
select * from members
where reg_date >= current_date - interval 180 day;
select * from branch;
select * from employees;
```
Task 10: List Employees with Their Branch Manager's Name and their branch details:
```sql
select b.branch_id, b.manager_id, b.branch_address, e.emp_name, e.emp_id, e2.emp_name as manager, e2.position
from employees as e
join 
branch as b
on b.branch_id= e.branch_id
join 
employees as e2
on b.manager_id = e2.emp_id;
```
Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
```sql
create table books_price_above_7
as
select isbn, book_title, rental_price
from books
where rental_price > 7;
select * from books_price_above_7;
```
Task 12: Retrieve the List of Books Not Yet Returned
```sql
select ist.issued_book_name
from issued_status as ist
left join return_status as rt
on ist.issued_id = rt.issued_id
where rt.return_id is null;
```
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
```sql
select 
m.member_id,
m.member_name,
bk.book_title,
ist.issued_date,
curdate() - ist.issued_date as overdue_days
from issued_status as ist
join members as m
on ist.issued_member_id = m.member_id
join books as bk
on ist.issued_book_isbn = bk.isbn
left join return_status as rs
on rs.issued_id= ist.issued_id
where rs.return_date is null 
AND
(curdate() - ist.issued_date) > 200
order by overdue_days desc;
```
Task 14: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
create table branch_report
select 
	b.branch_id,
	b.manager_id,
	count(ist.issued_id) as no_book_issued,
	count(rs.return_id) as no_of_book_return,
	sum(bk.rental_price) as total_revenue
from issued_status as ist
join employees as em
on ist.issued_emp_id = em.emp_id
join branch as b
on b.branch_id = em.branch_id
left join 
return_status as rs
on rs.issued_id = ist.issued_id
join
books as bk
on ist.issued_book_isbn= bk.isbn
group by 1,2;
```
Task 16: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
```sql
create table active_members
as
	Select * from members
	where member_id 
	in (
		select issued_member_id
		from issued_status
		where issued_date >= curdate() - interval 6 month
		);
select * from active_members;
```
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
```sql
select  ist.issued_emp_id, em.emp_name,em.branch_id,
	count(issued_emp_id)
	as most_books_issued
	from issued_status as ist
join employees as em
on em.emp_id = ist.issued_emp_id
	group by issued_emp_id
	order by most_books_issued;
    
```
Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
```sql
Delimiter $$
drop procedure if exists issue_book;
create procedure issue_book(
	p_issued_id varchar(30), 
    p_issued_member_id varchar(30), 
    p_issued_book_isbn varchar(50), 
    p_issued_emp_id varchar(10))

Begin

-- declare variables
Declare
v_status varchar(10);

-- all the codes/ logic
-- if the book is available
    
	select status 
    into
    v_status
    from books
    where isbn = p_issued_book_isbn;
    
    if -- book is available
		v_status = 'yes' then
		insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		values(p_issued_id, p_issued_member_id, curdate(), p_issued_book_isbn, p_issued_emp_id);
		
        -- we need to update the book status in the main table
        update books
        set status = 'no'
        where isbn = p_issued_book_isbn;
        
		select 'Book added successfully' as message;
    
    else  -- not available logic
		select 'Sorry, book not available' as message;
    end if;
    
    
End $$
Delimiter ;


select * from issued_status;

-- Call Procedure
call issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');

call issue_book('IS156', 'C108', '978-0-553-29698-2', 'E107')
```

Learning Outcomes

Through this project, I developed practical experience in designing relational databases, maintaining referential integrity, writing SQL queries for business problems, and automating database operations using stored procedures.

The project also strengthened my understanding of how SQL can be used not only for data storage and retrieval but also for reporting and operational decision support.
