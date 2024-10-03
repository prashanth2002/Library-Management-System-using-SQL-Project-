-- INSERT INTO book_issued in last 30 days
-- SELECT * from employees;
-- SELECT * from books;
-- SELECT * from members;
-- SELECT * from issued_status


INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;


/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

select * from books
select * from branch
select * from employees
select * from issued_status
select * from members
select * from return_status

SELECT 
ist.issued_member_id,
m.member_name,
bk.book_title,
ist.issued_date,
-- rs.return_date,
current_date- ist.issued_date as days_overdue
from issued_status as ist
join
members as m
on m.member_id = ist.issued_member_id
join
books as bk
on bk.isbn=ist.issued_book_isbn
left join
return_status as rs
on rs.issued_id= ist.issued_id
where 
rs.return_date is null
and
current_date- ist.issued_date >30
order by 1

/*
Task 14:
Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).
*/

select * from books
select * from branch
select * from employees
select * from issued_status
select * from members
select * from return_status

create or replace procedure add_return_orders(p_return_id varchar(10), p_issued_id VARCHAR(10), p_book_quality varchar(10))
language plpgsql
as $$
DECLARE
		v_isbn varchar(50);
		v_book_name varchar(80);
		

BEGIN 
		INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
		values (p_return_id, p_issued_id, current_date, p_book_quality);

		select 
				issued_book_isbn,
				issued_book_name
				into
				v_isbn,
				v_book_name
		from issued_status
		where issued_id= p_issued_id;


		UPDATE books
		set status ='yes'
		where isbn = v_isbn;
		
	RAISE NOTICE 'thank you for returning book : %',v_book_name;


END;
$$

is125
isbn= '978-0-06-112241-5'

select * from books
where isbn = '978-0-06-112241-5'

select * from issued_status
where issued_book_isbn = '978-0-06-112241-5'

update books
set status ='no'
where isbn= '978-0-06-112241-5'

select from return_status
where issued_id = 'IS125'

call add_return_orders('RS125','IS125','Good')

/*Task 15:
Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals.
*/
select * from books
select * from branch
select * from employees
select * from issued_status
select * from members
select * from return_status

create table branch_reports
as

select 
		b.branch_id,
		b.manager_id,
		count(ist.issued_id) as num_of_bk_issued,
		count(rs.return_id) as num_of_bk_returned,
		sum(bk.rental_price) as total_revenue_gnt_by_bk
from issued_status as ist
join
employees as e
on ist.issued_emp_id = e.emp_id
join
branch as b
on b.branch_id=e.branch_id
left join
return_status as rs
on ist.issued_emp_id=rs.issued_id
join
books as bk
on bk.isbn= ist.issued_book_isbn
group by 1,2

select * from branch_reports

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to
create a new table active_members containing members 
who have issued at least one book in the last 2 months.
*/
create table active_members
as
select * from members
where member_id in
						(select 
						distinct issued_member_id
						from issued_status
						where issued_date >= current_date - interval '2 month')


select * from active_members


/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/
 --  here we want top 3 emp
 -- which who took most of the books

 select * from employees
 select * from branch
 select * from issued_status

select 
e.emp_name,
b.*,
count(ist.issued_book_isbn) as num_books
from issued_status as ist
join 
employees as e
on ist.issued_emp_id= e.emp_id
join 
branch as b
on b.branch_id= e.branch_id
group by 1,2
limit 3



/*Task 19: 
Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/
select * from books
select * from issued_status

create or replace procedure issue_books(p_issued_id varchar(10),p_isssued_member_id varchar(30),p_issued_book_name varchar(80),p_issued_emp_id varchar(10))
language plpgsql
as $$
DECLARE 
		v_status varchar(10);
begin	
		-- chechking for the book availability
		select 
				status
			into
			v_status
		from books
		where isbn = p_issued_book_isbn;

	if v_status = 'yes' then 
		 insert into issued_status(issued_id,issued_member_id,issued_book_name,issued_date,issued_book_isbn,issued_emp_id)
		 values(p_issued_id,p_issued_member_id,p_issued_book_name,current_date,p_issued_book_isbn,p_issued_emp_id);
   
   update books 
	 set status = 'no'
	 where isbn = p_issued_book_isbn;
	 
	raise notice 'thanks for taking book : %',issued_book_isbn;
	ELSE
		raise notice 'sorry your book is not available for this moment : %',issued_book_isbn;
	end if;		
end;
$$

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-553-29698-2'



-- 

-- Task 18: 
-- Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table.
-- Display the member name, book title, and the number of times they've issued damaged books.

--  we need members table and issued_status and books


select * from books
select * from branch
select * from employees
select * from issued_status
select * from members
select * from return_status


from issued_status as ist
join 
books as bk
on bk.isbn = ist.issued_book_isbn
join 
members as m
on ist.member_id = m.member_id
where book_quality =''




SELECT 
    m.member_name,
    b.book_title,
    COUNT(*) AS damaged_issues_count
FROM 
    issued_status is
JOIN 
    books b ON is.book_id = b.book_id
JOIN 
    members m ON is.member_id = m.member_id
WHERE 
    is.status = 'damaged'
GROUP BY 
    m.member_name, b.book_title
HAVING 
    COUNT(*) > 2;
