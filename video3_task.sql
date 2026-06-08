USE library_project_2; 

-- 1) Create a new book record in the books table: 
insert into books(isbn, book_title, category, rental_price, status, author, publisher) 
	values('978-1-60129-500-3', 'To Kill a Mockingbird 2', 'Classic', 6.00, 'Yes', 'Harper Lee', 'J.B. Lippincott & Co.'); 
    
    
-- 2) Update an existing member's address
update members
set member_address = '125 Oak St'
where member_id = 'C103'; 

select * from members; 

-- 3) Delete the record from issued_status where: issued_id = 'IS121'
delete 
from issued_status 
where issued_id = 'IS121'; 

select * from issued_status 
where issued_id = 'IS121'; 

-- 4) Retrieve all books issued by employee: 
select * from issued_status
where issued_emp_id = 'E101'; 

-- 5) Find members who have issued more than one book. 
select issued_member_id, 
count(*) as total_count
from issued_status
group by 1
having count(*) > 1; 

-- 6) Createa a summary table named: book_issued_cnt. 
select * from books; 
select * from issued_status; 

create table book_issued_cnt as 
select 
	issued_book_isbn, 
    issued_book_name, 
    count(*) as total_count
from issued_status
group by 1,2; 

select * from book_issued_cnt; 

-- using join 
drop table if exists book_issued_cnt;
create table book_issued_cnt as 
select 
	b.isbn, 
    b.book_title, 
    count(ist.issued_book_isbn) as issue_count 
from books as b
join issued_status as ist
on b.isbn = ist.issued_book_isbn
group by 1,2; 


-- 7) Retrive all books in the category: classic
select * 
from books
where category = 'Classic'; 

-- 8) Find total rental income by category 
select * from books; 
select 
	b.category, 
    sum(b.rental_price) as total_rental_income, 
    count(ist.issued_id) as number_of_books_issued
from books as b
join issued_status as ist 
on b.isbn = ist.issued_book_isbn
group by 1; 
    
    
-- 9) List members who registered in the last 180 days: 
select * from members; 

select * 
from members
where reg_date >= current_date - interval 180 day; 

-- 10) list employees with employee details, branch details, manager name. 
select * from employees; 
select * from branch; 

select 
	e1.emp_id, 
    b.manager_id,
    e2.emp_name as manager
from employees as e1
join branch as b
on e1.branch_id = b.branch_id
join employees as e2
on b.manager_id = e2.emp_id; 

-- 11) create a table named expensive_books
create table expensive_books as 
select 
	*
from books
where rental_price > 7.00; 

select * from expensive_books; 

-- 12) Retrieve the list of books not returned 
select * from issued_status; 
select * from return_status; 

select * from issued_status as ist
left join return_status as rs 
on ist.issued_id = rs.issued_id
where rs.return_id is null; 

-- 13) identify members with overdue books. 
select 
	m.member_id, 
    m.member_name, 
    b.book_title, 
    ist.issued_date,
    datediff(current_date, ist.issued_date) as overdue
from issued_status as ist
join members as m
on ist.issued_member_id = m.member_id 
join books as b
on ist.issued_book_isbn = b.isbn
left join return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null
and  datediff(current_date, ist.issued_date) > 30; 

-- 14) Create a return procedure 
select * from books; 

drop procedure if exists first_proc; 
delimiter $$ 
create procedure first_proc(p_return_id varchar(15), p_issued_id varchar(15), p_book_quality varchar(25))
begin
	declare v_isbn varchar(50); 
    
    select issued_book_isbn
    into v_isbn
    from issued_status 
    where issued_id = p_issued_id; 
    
	insert into return_status (return_id, issued_id, return_date, book_quality) 
		values(p_return_id, p_issued_id, current_date, p_book_quality);
        
	update books
    set status = 'Yes'
    where isbn = v_isbn; 
    
end $$
delimiter ;


-- 15) Create a report for each branch showing: 
select * from branch; 
select * from issued_status; 
select * from employees; 
select * from books; 

select 
	br.branch_id,
    br.manager_id, 
    count(ist.issued_id) as total_book_issued, 
    count(rs.return_id) as total_books_returned,
    sum(b.rental_price) as total_revenue
from branch as br
join employees as e
on br.branch_id = e.branch_id
join issued_status as ist
on e.emp_id = ist.issued_emp_id
left join return_status as rs
on ist.issued_id = rs.issued_id
join books as b
on b.isbn = ist.issued_book_isbn
group by 1,2; 
    

-- 16) create a table named active members 
create table active_members as 
select * 
from members as m
join issued_status as ist
on m.member_id = ist.issued_member_id 
where ist.issued_date >= current_date - interval 2 month; 

select * from active_members; 

-- 17) Find the top 3 employees who processed the most book issues 
select * from employees; 
select * from issued_status; 

select
	e.emp_name, 
    e.branch_id,
    count(ist.issued_emp_id) as number_books
from issued_status as ist
join employees as e
on ist.issued_emp_id = e.emp_id
group by 1,2
order by number_books desc
limit 3; 

-- 18) Find members who issued damaged books 
select * from books; 
select * from members; 
select * from issued_status; 
select * from return_status; 

select 
	m.member_name, 
    b.book_title,
    count(*) as total_damaged
from issued_status as ist
join books as b
on ist.issued_book_isbn = b.isbn
join members as m
on ist.issued_member_id = m.member_id
join return_status as rs
on ist.issued_id = rs.issued_id
where rs.book_quality = 'Damage'
group by 1,2; 


-- 19) create a procedure that issues a book 
select * From members;
select * from issued_status;

delimiter $$ 
create procedure book_issue(p_issued_id varchar(10), p_issued_member_id varchar(15), p_issued_book_isbn varchar(50), p_issued_emp_id varchar(15))
begin
	declare v_status varchar(10);
    
    select status 
    into v_status 
    from books
    where isbn = p_issued_book_isbn;
    
    if v_status = 'Yes' then
		insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
			values(p_issued_id, p_issued_member_id, current_date, p_issued_book_isbn, p_issued_emp_id); 
		
        update books
        set status = 'No'
        where isbn = p_issued_book_isbn; 
        
        select 'Book has been successfully inserted' as message; 
        
	else 
		select 'Book is not available' as message; 
		
	end if; 
end $$ 
delimiter ;


call book_issue('IS151', 'C107', '978-0-14-118776-1', 'E105'); 


-- 20) create a table that shows overdue books and fines 
select * from issued_status; 
select * from return_status; 

create table overdue_fines as 
select 
	ist.issued_member_id,
    count(ist.issued_member_id) as overdue_books_count, 
    sum(datediff(current_date, ist.issued_date) - 30) * 0.50 as fine_overdue
from issued_status as ist 
left join return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null 
and datediff(current_date, ist.issued_date) > 30
group by ist.issued_member_id; 











































