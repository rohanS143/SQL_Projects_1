USE library_project_2;

SELECT * FROM book_above_7;
SELECT * FROM book_counts;
SELECT * FROM books; 
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status; 

-- PROJECT TASK; 

-- Task 1. Create a New Book Record -- '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes',
--  'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES 
	('978-1-60129-456-3', 'To Kill a FlyingBird', 'Classic', 6.00, 'Yes', 'Harper Lee', 'J.B. Lippincott & Co.');
    
SELECT * FROM books; 

-- Task 2: Update an Existing Member's Address

UPDATE members 
SET member_address = '900 Bockstoce Ave'
WHERE member_id = 'C101'; 

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status; 

DELETE FROM issued_status
WHERE issued_id = 'IS106'; 

DELETE FROM issued_status
WHERE issued_id = 'IS107'; 
-- we cannot delete this issued_id because this is being used in return_status, 
-- to delete this we need to first delete from child table which is return_status and we can delete it from here 

SELECT * FROM return_status WHERE issued_id = 'IS107'; 


-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'; 

-- Task 5: List Members Who Have Issued More Than One Book
 -- Objective: Use GROUP BY to find members who have issued more than one book.
 
 SELECT issued_emp_id,
 COUNT(issued_id) AS total_book_issued
 FROM issued_status
 GROUP BY 1
 HAVING COUNT(issued_id) > 1; 

-- 3. CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: 
-- Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

SELECT * FROM books;
SELECT * FROM issued_status; 

CREATE TABLE book_counts2
AS 
	SELECT b.isbn,
	b.book_title,
	COUNT(ist.issued_id) AS no_issued
	FROM books as b
	JOIN
	issued_status AS ist
	ON ist.issued_book_isbn = b.isbn
	GROUP BY 1,2; 
    
SELECT * FROM book_counts2; 


-- Find each member’s name and how many books they have issued.
SELECT * FROM members;
SELECT * FROM issued_status; 


SELECT member_name, member_id,
COUNT(ist.issued_member_id) AS total_book
FROM members AS m
JOIN
issued_status AS ist
ON ist.issued_member_id = m.member_id
GROUP BY 1,2; 

-- Find each employee’s name and how many books they issued.
SELECT * FROM employees; 

SELECT emp_id, emp_name, 
COUNT(ist.issued_id) AS total_emp_issued
FROM employees AS e
JOIN
issued_status AS ist
ON ist.issued_emp_id = e.emp_id
GROUP BY 1,2; 

-- Find all books that were issued by the member named "Bob Smith"
SELECT * FROM issued_status; 
SELECT * FROM members; 

SELECT member_name,b.book_title, ist.issued_book_name
FROM members AS m
JOIN issued_status AS ist
ON ist.issued_member_id = m.member_id
JOIN books AS b
ON ist.issued_book_isbn = b.isbn
WHERE m.member_name = 'Bob Smith'; 


-- 4. Data Analysis & Findings
-- The following SQL queries were used to address specific questions:

-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic'; 

-- Task 8: Find Total Rental Income by Category:
SELECT * FROM issued_status; 
SELECT * FROM books; 

SELECT b.category,
SUM(b.rental_price) AS total_income,
COUNT(*)
FROM books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn 
GROUP BY b.category; 

-- Task 9: List Members Who Registered in the Last 180 Days:
SELECT * FROM members; 

SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 180 DAY; 


-- Taks 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT * FROM branch; 
SELECT * FROM employees; 

SELECT e.*, e2.emp_name AS manager, b.manager_id
FROM employees AS e
JOIN 
branch AS  b
ON b.branch_id = e.branch_id
JOIN 
employees AS e2
ON b.manager_id = e2.emp_id; 

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7 dollar:

CREATE TABLE books_price_greater_than_seven
AS 
SELECT * FROM books
WHERE rental_price > 7; 

SELECT * FROM books_price_greater_than_seven; 


-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT * FROM books; 
SELECT * FROM issued_status;
SELECT * FROM return_status; 

SELECT DISTINCT ist.issued_book_name FROM issued_status AS ist
LEFT JOIN 
return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL; 




















-- Find a book that was issued, who issued it, and which employee issued it. 

SELECT * FROM books;
SELECT * FROM issued_status;
SELECT * FROM employees; 

SELECT * 
FROM issued_status AS ist
JOIN books AS b
ON ist.issued_book_isbn = b.isbn
JOIN members AS m
ON ist.issued_member_id = m.member_id
JOIN employees AS e
ON ist.issued_emp_id = e.emp_id; 


SELECT issued_status.issued_book_name 
FROM issued_status 
INNER JOIN employees 
ON issued_status.issued_emp_id = employees.emp_id;



-- SHOW issued book name, employee name for every issued book. 
SELECT issued_status.issued_book_name, employees.emp_name
FROM issued_status
JOIN employees
ON issued_status.issued_emp_id = employees.emp_id;

-- SHOW issued_id, issued_book_name, emp_name, position
SELECT issued_status.issued_book_name, employees.emp_name, issued_status.issued_id, employees.position
FROM issued_status
JOIN employees
ON issued_status.issued_emp_id = employees.emp_id;

-- COUNT books issued by each employee'
-- SHOW employee name, total number of books issued
SELECT employees.emp_name, 
COUNT(issued_id) AS total_count
FROM issued_status
JOIN employees
ON issued_status.issued_emp_id = employees.emp_id
GROUP BY 1; 

-- SHOW issued_book_name, emp_name, where position = clerk
SELECT issued_status.issued_book_name, employees.emp_name, employees.position
FROM employees
JOIN issued_status
ON issued_status.issued_emp_id = employees.emp_id
WHERE employees.position = 'Clerk';


-- Highest salary employee who issued books
-- SHOW employee name, salary, issued_book_name, order from highest salary to lowest. 
SELECT e.emp_name, e.salary, ist.issued_book_name
FROM issued_status AS ist
JOIN employees AS e
ON ist.issued_emp_id = e.emp_id
ORDER BY salary DESC; 


-- Question 7 — Count Books by Position

-- Show:
-- employee position
-- total books issued

-- Example output idea:

-- position	total_books
-- Clerk	5
-- Manager	3

SELECT * FROM issued_status; 
SELECT * FROM employees; 

SELECT e.position, 
COUNT(ist.issued_id) AS total_count
FROM issued_status AS ist
JOIN employees AS e
ON ist.issued_emp_id = e.emp_id
GROUP BY 1; 

-- Question 8 — LEFT JOIN Practice

-- Show ALL employees,
-- even if they never issued a book.

-- Display:

-- emp_name
-- issued_book_name

-- (This is perfect LEFT JOIN practice.)
SELECT e.emp_name, ist.issued_book_name
FROM employees AS e
LEFT JOIN issued_status AS ist
ON ist.issued_emp_id = e.emp_id; 

-- Question 9 — Find Employees from Branch B001

-- Show:

-- emp_name
-- branch_id
-- issued_book_name

-- Only for branch B001.
SELECT * FROM employees;
SELECT * FROM issued_status; 

SELECT e.emp_name, e.branch_id, ist.issued_book_name
FROM employees AS e
JOIN issued_status AS ist
ON ist.issued_emp_id = e.emp_id
WHERE e.branch_id = 'B001'; 




-- Question 10 — Latest Issued Book Per Employee

-- Show:

-- employee name
-- latest issued_date

-- (Hint: MAX(issued_date))

SELECT e.emp_name, 
MAX(ist.issued_date) AS latest_issued_date
FROM employees AS e
JOIN issued_status AS ist
ON ist.issued_emp_id = e.emp_id
GROUP BY 1; 












































































































