select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from return_status;
select * from members;

-- CRUD Tasks
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books(isbn, book_title, category, rental_price, status, author, publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;

-- Task 2: Update an Existing Member's Address
set sql_safe_updates = 0; 
update members
set member_address = '125 Dhalpur St'
where member_id= 'C103';
select * from members;

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status
where issued_id = 'IS121';
select * from issued_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issued_status
where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_emp_id,
count(*) as counted 
from issued_status
group by issued_emp_id
having count(*)  > 1;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

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

-- Task 7: Retrieve book in specific category:

select * from books
where category = 'classic';

-- Task 8: Find Total Rental Income by Category:

select sum(rental_price) as sum_rent, b.category, count(*) 
from books as b
join issued_status as ist
on ist.issued_book_isbn= b.isbn
group by category;

-- Inserting some extra records

insert into members(member_id, member_name, member_address, reg_date)
values( 'C120', 'Kinshuk', 'Dhalpur', '2026-03-10'),
('C121', 'Ayan', 'Chennai', '2026-05-25');

update members 
set reg_date= '2026-04-30'
where member_id = 'C120';
select * from members;


-- Task 9: List Members Who Registered in the Last 180 Days:

select * from members
where reg_date >= current_date - interval 180 day;
select * from branch;
select * from employees;

-- List Employees with Their Branch Manager's Name and their branch details:

select b.branch_id, b.manager_id, b.branch_address, e.emp_name, e.emp_id, e2.emp_name as manager, e2.position
from employees as e
join 
branch as b
on b.branch_id= e.branch_id
join 
employees as e2
on b.manager_id = e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

create table books_price_above_7
as
select isbn, book_title, rental_price
from books
where rental_price > 7;
select * from books_price_above_7;

select * from return_status;
select * from issued_status;

-- Task 12: Retrieve the List of Books Not Yet Returned

select ist.issued_book_name
from issued_status as ist
left join return_status as rt
on ist.issued_id = rt.issued_id
where rt.return_id is null;

select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

-- Advance SQL problems

-- Task 13 Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.


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

------------------

-- Task 14 
-- Branch Performance Report
-- Create a query that generates a performance report for each branch, 
-- showing the number of books issued, the number of books returned, and the total revenue 
-- generated from book rentals.


select * from branch;
select * from return_status;
select * from issued_status;
select * from books;
select * from employees;

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

-- Task 16:
-- Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
-- who have issued at least one book in the last 2 months.


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

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.

    select  ist.issued_emp_id, em.emp_name,em.branch_id,
	count(
	issued_emp_id) as most_books_issued
	from issued_status as ist
    join employees as em
    on em.emp_id = ist.issued_emp_id
	group by issued_emp_id
	order by most_books_issued;
    
-- Store Procedure
-- Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library 
-- system. Description: Write a stored procedure that updates the status of a book in the library based on its 
-- issuance. The procedure should function as follows: The stored procedure should take the book_id as an 
-- input parameter. The procedure should first check if the book is available (status = 'yes'). 
-- If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
-- If the book is not available (status = 'no'), the procedure should return an error message indicating that 
-- the book is currently not available.

select * from books;
select * from issued_status;

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






