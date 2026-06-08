USE library_project_2; 

-- 1) Create a new table called expensive_books containing books with rental price above 7
CREATE TABLE expensive_books AS 
SELECT rental_price
FROM books
WHERE rental_price > 7; 

SELECT * FROM expensive_books; 

DROP TABLE expensive_books; 
CREATE TABLE expensive_books AS 
SELECT * 
FROM books
WHERE rental_price > 7; 

-- 2) Create a new table called classic_books. It should contain only these columns: 
-- book_title, author, rental_price. Only include books where category = 'Classic'

CREATE TABLE classic_books AS 
SELECT book_title, author, rental_price
FROM books
WHERE category = 'Classic'; 

SELECT * FROM classic_books; 

-- 3) Create a table called book_issue_count. It should show isbn, book_title, issue_count.
SELECT * FROM issued_status; 

CREATE TABLE book_issued_count AS 
SELECT b.isbn, b.book_title, 
COUNT(ist.issued_book_isbn) AS issue_count
FROM books AS b
JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1,2; 

SELECT * FROM book_issued_count;

-- 4) Find books that were issued but not returned: 
SELECT * 
FROM issued_status AS ist
LEFT JOIN return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL; 

-- 5) Show all issued books that have been returned. 

SELECT * 
FROM issued_status AS ist
JOIN return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NOT NULL; 

-- 5) Show books that were returned with: book_title, return_date. 
select * from return_status; 

SELECT b.book_title, rs.return_date
FROM books AS b
JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
JOIN return_status AS rs
ON ist.issued_id = rs.issued_id
GROUP BY 1,2; 


-- 6) SHOW members who never issued any book. Display member_name, member_id
SELECT m.member_name, m.member_id
FROM members AS m
LEFT JOIN issued_status AS ist
ON m.member_id = ist.issued_member_id
WHERE ist.issued_member_id IS NULL; 


-- DATE ARITHMETIC
SELECT CURRENT_DATE; 

-- Go back to 30 days
SELECT CURRENT_DATE - INTERVAL 30 DAY; 

-- Find members registered in last 180 days
SELECT * 
FROM members 
WHERE reg_date >= CURRENT_DATE - INTERVAL 180 day; 

-- days between dates
-- suppose: issued_date = 2026-04-01, today = 2026-05-21

-- 1) show memebrs who registered in the last 90 days. 
select * from members; 
select *
from members 
where reg_date >= current_date - interval 90 day; 

-- 2) show issued books that were issued more than 30 days ago

select * from issued_status; 

select issued_id, issued_book_name, issued_date
FROM issued_status
where issued_date < current_date - interval 30 day; 

-- 3) show issued books and calculate how many days ago they were issued. 
-- Display: issued_id, issued_book_name, issued_date, days_since_issued
select issued_id,
issued_book_name,
 issued_date,
datediff(current_date, issued_date) AS days_since_issued
from issued_status; 

-- 4) show books that are not returned yet, issued more than 30 days ago. Display: 
	-- issued_id, issued_book_name, issued_date, days_overdue
    select ist.issued_id, 
		ist.issued_book_name, 
		ist.issued_date, 
		datediff(current_date, ist.issued_date) as overdue_book
    from issued_status as ist
    left join return_status as rs
    on ist.issued_id = rs.issued_id
    where rs.return_id is null
		and datediff(current_date, ist.issued_date) > 30; 
        
-- 5) show members with overdue books. Display member_id, memmber_name, issued_book_name, issud_date, days_overdue
-- Rules: not returned yet, issued more than 30 days ago
select m.member_id, m.member_name, ist.issued_book_name, ist.issued_date, 
datediff(current_date, issued_date) as days_overdue
from issued_status as ist
join members as m
on m.member_id = ist.issued_member_id
left join return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null 
and datediff(current_date, ist.issued_date) > 30; 

-- show books that are currently available. Table books, conditions status = 'yes'
select * from books
where status = 'Yes'; 

-- practice
delimiter $$

create procedure test_proc()
begin
	declare v_book_title varchar(80);
    
    select book_title
    into v_book_title
    from books
    where status = 'Yes'
    limit 1; 
    
end $$

delimiter ; 

call test_proc(); 

-- dropping the procedure because we needed to put some change 
drop procedure if exists test_proc;

delimiter $$

create procedure test_proc()
begin
	declare v_book_title varchar(80);
    
    select book_title
    into v_book_title
    from books
    where status = 'Yes'
    limit 1;
    
    select v_book_title as available_book; 
    
end $$

delimiter ; 

call test_proc(); 

select * from books; 


-- Now we learn with inputs paramenters. 
-- Right now call test_proc() takes no input. it just runs the same logic everytime. 


-- Now we make a procedure like this: call check_book_status('978-0-307-58837-1');

drop procedure if exists check_book_status;

delimiter $$

	create procedure check_book_status(p_isbn varchar(50))
    begin
		declare v_status varchar(10); 
        
        select status
        into v_status
        from books
        where isbn = p_isbn;
        
        select v_status as book_status;
	end $$
    
    delimiter ; 
    
    call check_book_status('978-0-06-025492-6'); 

select * from books; 

-- new 
drop procedure if exists print_title;

delimiter $$ 
create procedure print_title(p_category varchar(25)) 
begin 
    select book_title
    from books 
    where category = p_category;
end $$ 
delimiter ; 

call print_title('Classic'); 

select * from books; 


-- get the author of the book_title

drop procedure if exists book_author; 

delimiter $$
create procedure book_author(b_title varchar(50))
begin 
	select author 
    from books
    where book_title = b_title; 
end $$
delimiter ; 

call book_author('To Kill a Mockingbird'); 

-- new 
drop procedure if exists rental_p;

delimiter $$ 

create procedure rental_p(b_title varchar(50))
begin 
	declare r_price decimal(10,2);
    
    select rental_price
    into r_price
    from books
    where book_title = b_title; 
    
    select r_price as rental_price_book; 

end $$ 
delimiter ; 

call rental_p('To Kill a Mockingbird'); 

-- new 
drop procedure if exists rental_p;

delimiter $$ 

create procedure rental_p(b_title varchar(50))
begin 
	declare r_price decimal(10,2);
    
    select rental_price
    into r_price
    from books
    where book_title = b_title
    limit 1; 
    
    select r_price as rental_price_book; 

end $$ 
delimiter ; 

call rental_p('To Kill a Mockingbird'); 

-- new 
select * from books; 
drop table if exists get_category; 

delimiter $$ 

create procedure get_category(b_title varchar(80))
begin
	declare c_category varchar(25); 
    
    select category 
    into c_category
    from books
    where book_title = b_title
    limit 1; 
    
    select c_category as b_title_category; 

end $$ 
delimiter ;

call get_category('To Kill a Mockingbird'); 

-- if else
drop procedure if exists check_available; 

delimiter $$ 

create procedure check_available(p_status varchar(10))
begin
	if p_status = 'Yes' then
		select 'Book is available' as message;
	else 
		select 'Book is not available' as message;
	end if;
end $$ 

delimiter ; 

call check_available('Yes'); 
call check_available('No'); 


-- new 
drop procedure if exists check_book_available;

delimiter $$ 

create procedure check_book_available(p_isbn varchar(50))

begin 
	declare v_status varchar(10);
    
    select status
    into v_status
    from books
    where isbn = p_isbn;
    
    if v_status = "Yes" then
		select "Book is available" as message;
	else 
		select "Book is not available" as message; 
	end if; 
end $$ 

delimiter ;


CALL check_book_available('978-0-06-025492-6');

-- new 
drop table if exists rental_price_tracker; 

delimiter $$ 
create procedure rental_price_tracker(b_title varchar(80)) 

begin
	declare r_price decimal(10,2); 
    
    select rental_price
    into r_price
    from books
    where book_title = b_title
    limit 1; 
    
    if r_price > 7 then
		select "Book is expensive" as message; 
	else 
		select "Regular price book" as message; 
	end if; 
end $$ 
delimiter ; 

CALL rental_price_tracker('To Kill a Mockingbird'); 

-- create a procedure to check employee salary
select * from employees; 
drop procedure if exists check_salary;

delimiter $$ 
create procedure check_salary(p_emp_id varchar(10)) 

begin
	declare v_salary int;
    
    select salary
    into v_salary
    from employees
    where emp_id = p_emp_id; 
    
    if v_salary > 50000 then
		select "High salary employee" as message; 
	else 
		select "Normal salary employees" as message; 
	end if; 
end $$ 
delimiter ;

call check_salary('E101'); 

-- new 

drop procedure if exists mark_book_unavailable; 
delimiter $$ 
create procedure mark_book_unavailable(p_isbn VARCHAR(50))
begin
	declare v_status varchar(10); 
    
    select status 
    into v_status
    from books
    where isbn = p_isbn; 
    
    if v_status = "Yes" then
		update books 
		set status = "No" 
		where isbn = p_isbn; 
        select "Book marked unavailable" as message; 
	else 
		select "Book already unavailable" as message; 
	end if; 
end $$ 
delimiter ; 

select * from books; 
call mark_book_unavailable('978-0-06-025492-6'); 


-- new procedure
select * from issued_status; 
drop procedure if exists issue_book_simple; 
delimiter $$ 

create procedure issue_book_simple(p_issued_id varchar(10), p_member_id varchar(30), p_isbn varchar(50), p_emp_id varchar(10)) 
begin
	declare v_status varchar(10);
    
    select status 
    into v_status
    from books
    where isbn = p_isbn; 
    
    if v_status = 'Yes' then 
		insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		values(p_issued_id, p_member_id, current_date, p_isbn, p_emp_id); 
        
        update books 
        set status = 'No'
        where isbn = p_isbn; 
        select 'Book issued successfully' as message; 
        
	else 
		select 'Book is not available' as message;
	end if; 
end $$
delimiter ; 

CALL issue_book_simple('IS141', 'C109', '978-0-141-44171-6', 'E105');

select * from issued_status 
where issued_id = 'IS141'
limit 1; 

select isbn, status
from books
where isbn = '978-0-141-44171-6'; 


-- new procedure:
select * from return_status; 

drop procedure if exists return_book_simple;

delimiter $$ 
create procedure return_book_simple(p_return_id varchar(10), p_issued_id varchar(10), p_isbn varchar(50))
begin
	declare v_status varchar(10); 
    
    select status 
    into v_status
    from books
    where isbn = p_isbn; 
    
    if v_status = 'No' then
		insert into return_status(return_id, issued_id, return_date, return_book_isbn)
        values(p_return_id, p_issued_id, current_date, p_isbn); 
        
        update books
        set status = 'Yes' 
        where isbn = p_isbn;
        select 'Book returned successfully' as message; 
	
    else 
		select 'This book is already available' as message; 
	end if; 

end $$
delimiter ; 

CALL return_book_simple('RS999', 'IS141', '978-0-141-44171-6');

select * from return_status 
where return_id = 'RS999'; 

SELECT isbn, book_title, status
FROM books
WHERE isbn = '978-0-141-44171-6';

select * from issued_status; 
select * from return_status; 

select * from issued_status as ist
left join return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null; 


-- new procedure 

select * from return_status; 

drop procedure if exists return_book_auto;

delimiter $$ 
create procedure return_book_auto(p_return_id varchar(10), p_issued_id varchar(10))
begin
	declare v_status varchar(10); 
    declare v_isbn varchar(50); 
    
    select issued_book_isbn
    into v_isbn
    from issued_status
    where issued_id = p_issued_id; 
    
    select status 
    into v_status
    from books
    where isbn = v_isbn; 
    
    if v_status = 'No' then
		insert into return_status(return_id, issued_id, return_date, return_book_isbn)
        values(p_return_id, p_issued_id, current_date, v_isbn); 
        
        update books
        set status = 'Yes' 
        where isbn = v_isbn;
        select 'Book returned successfully' as message; 
	
    else 
		select 'This book is already available' as message; 
	end if; 

end $$
delimiter ; 

CALL return_book_auto('RS1000', 'IS136');

select 
	ist.issued_id, 
    ist.issued_book_isbn,
    b.book_title,
    b.status
from issued_status as ist
join books as b
on b.isbn = ist.issued_book_isbn
left join return_status as rs
on rs.issued_id = ist.issued_id
where rs.return_id is null
and b.status = 'No'; 


-- find a book that are issued but not returned
select * from books; 
select * from issued_status; 
select * from return_status; 

DROP TABLE IF EXISTS overdue_fines;

create table overdue_fines as 
select 
	b.isbn, 
    ist.issued_id, 
    ist.issued_book_isbn, 
    rs.return_id,
    ist.issued_date,
	datediff(current_date, ist.issued_date) as days_overdue, 
	(datediff(current_date, ist.issued_date ) - 30) * 0.50 as fine
from books as b
join issued_status as ist
on b.isbn = ist.issued_book_isbn
left join return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null 
and datediff(current_date, ist.issued_date) > 30 ; 

select * from overdue_fines; 

-- add member info and group by matter

drop table if exists member_overdue_fines; 

create table member_overdue_fines as 
select
	ist.issued_member_id,
    count(*) as number_of_overdue_books,
    sum(datediff(current_date, ist.issued_date) - 30) * 0.50 as total_fines
from issued_status as ist
left join return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null
and datediff(current_date, ist.issued_date) > 30
group by ist.issued_member_id; 

select * from member_overdue_fines; 

-- project task
select * from branch; 

create table branch_reports as 
select 
	b.branch_id, 
    b.manager_id,
	count(ist.issued_id) as no_issued, 
	count(rs.return_id) as b_returned, 
	sum(bk.rental_price) as total_rev
from branch as b
join employees as e
on b.branch_id = e.branch_id
join issued_status as ist
on e.emp_id = ist.issued_emp_id
join books as bk 
on ist.issued_book_isbn = bk.isbn
left join return_status as rs
on ist.issued_id = rs.issued_id
group by b.branch_id, b.manager_id; 

select * from branch_reports; 


-- Create a table of members who issued at least one book in the last 2 months. 

select * from members;
select * from books;
select * from issued_status;  

create table book_issued_last_2_months as 
select distinct 
	m.member_id, 
    m.member_name, 
    m.member_address, 
    m.reg_date
from members as m
join issued_status as ist
on m.member_id = ist.issued_member_id
where ist.issued_date >= current_date - interval 2 month; 

select * from book_issued_last_2_months; 

select * from issued_status 
where issued_member_id = 'C109'; 


-- top 3 employees who processed most book issues
select * from branch; 
select * from employees; 
select * from issued_status; 

select 
	e.emp_name,
    e.branch_id,
    count(ist.issued_emp_id) as no_issue
    from employees as e
    join issued_status as ist
    on e.emp_id = ist.issued_emp_id
    group by 1,2
    order by no_issue desc
    limit 3; 


-- new 
set sql_safe_updates = 0; 

select * 
from return_status
limit 5; 


alter table return_status 
add book_quality varchar(20); 

update return_status 
set book_quality = 'Damage'
where return_id = 'RS1000'; 

update return_status
set book_quality = 'Good'
where book_quality is null; 

set sql_safe_updates = 1; 


-- query

select 
	m.member_name,
    ist.issued_book_name, 
    count(*) as damanged_count
from return_status as rs
join issued_status as ist
on rs.issued_id = ist.issued_id
join members as m
on ist.issued_member_id = m.member_id
where rs.book_quality = 'Damage'
group by 1,2; 

-- query

-- find each member who has returned a damaged book
select * from books; 
select * from members; 
select * from issued_status; 
select * from return_status; 


select
	m.member_id, 
    m.member_name, 
    ist.issued_id, 
    b.book_title, 
    rs.book_quality,
    rs.return_date
from members as m
join issued_status as ist
on m.member_id = ist.issued_member_id
join books as b
on b.isbn = ist.issued_book_isbn
join return_status as rs
on rs.issued_id = ist.issued_id
where rs.book_quality = 'Damage'; 





































































































    
    
    
    
    
    
    
    
    
    
    






































































