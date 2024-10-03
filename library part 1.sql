select * from books
select * from branch
select * from employees
select * from issued_status
select * from members
select * from return_status

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books(isbn,book_title,category,rental_price,status,author,publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

-- Task 2: Update an Existing Member's Address

update members
set member_address = '125 Main St'
where member_id = 'C101'

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
select * from issued_status

delete from issued_status
where issued_id = 'IS121'

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issued_status
where issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

select 
issued_emp_id,
count(*) as total_issued_numbers
from issued_status
group by 1
having count(*) >1

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results
-- - each book and total book_issued_cnt**
CREATE TABLE book_issued_cnt AS
select 
		b.book_title,b.isbn,
		count(ist.issued_id) as issued_count
from issued_status as ist
JOIN books as b
on ist.issued_book_isbn=b.isbn
group by 1,2

-- Task 7. Retrieve All Books in a Specific Category:
select * from books
where category = 'Classic'

select * from books

-- Task 8: Find Total Rental Income by Category:
select * from books
select * from branch
select * from employees
select * from issued_status
select * from members
select * from return_status

SELECT 
		b.category,
		sum(b.rental_price) as total_rental_prices,
		count(*)
from books as b
join issued_status as ist
on b.isbn= ist.issued_book_isbn
group by 1

--Task 9 List Members Who Registered in the Last 180 Days:

select * from members
where reg_date >= current_date - interval '180 days'

-- List Employees with Their Branch Manager's Name and their branch details:
select * from books
select * from branch
select * from employees
select * from issued_status
select * from members
select * from return_status


select 
		e1.emp_id,
		e1.emp_name,
		e1.position,
		e1.salary,
		b.*,
		e2.emp_name as manager
from employees as e1
join branch as b
on e1.branch_id=b.branch_id
join employees as e2
on e2.emp_id=b.manager_id



-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
create table exp_books as
select * from books
where rental_price >7.00


-- Task 12: Retrieve the List of Books Not Yet Returned
select *
from issued_status as ist
right join return_status as rs
on ist.issued_id=rs.issued_id
where  rs.issued_id is null


