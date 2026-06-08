USE library_project_2;


-- BASIC SQL FUNCTIONS TEST
-- Q1) Cange the status of the book 
UPDATE books
SET status = 'Yes'
WHERE isbn = '978-0-307-58837-1'; 

-- Q2) Add a new return record
INSERT INTO return_status(return_id, issued_id, return_date)
	VALUES(
		'RS200', 
        'IS140', 
        CURRENT_DATE
        ); 
        
-- Q3) Shoe all books where status is 'No'
SELECT * FROM books
WHERE status = 'No'; 

-- Q4) Delete a return record with return_id = RS200
DELETE FROM return_status
WHERE return_id = 'RS200';

-- Q5) Create a table called students with: 
CREATE TABLE students_data(
	student_id VARCHAR(10) PRIMARY KEY, 
    student_name VARCHAR(50),
    age INT,
    major VARCHAR(30)
    
); 

-- Q6) Add a new column to studnets: 
ALTER TABLE students_data
ADD email VARCHAR(100); 

-- Q7) Update multiple columns 
UPDATE students_date
SET student_name = 'John', major = 'Science'
WHERE student_id = 'S101'; 

-- Q8) Count how many books are currently available (status = 'Yes')
SELECT COUNT(*) AS count_status
FROM books
WHERE status = 'Yes';

-- Q9) Show all unique book categories from books
SELECT * FROM books; 
SELECT DISTINCT category
FROM books; 

SELECT * FROM books;
SELECT * FROM issued_status; 

-- JOIN PROBLEMS INNER JOIN 
-- 1) Show book_title, issued_date from books and issued_status. 
SELECT b.book_title, ist.issued_date FROM books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn; 

-- 2) Show member_name, book_title, issued_date from tables members, issued_status, and books.
SELECT * FROM members; 
SELECT * FROM issued_status; 

SELECT m.member_name, b.book_title, ist.issued_date
FROM issued_status AS ist
JOIN books AS b
ON ist.issued_book_isbn = b.isbn
JOIN members AS m
ON ist.issued_member_id = m.member_id; 

-- 3) Show member_name, book_title, issued_date, emp_name from tables issued_status, members, books, employees
SELECT * FROM books;
SELECT * FROM employees; 

SELECT m.member_name, b.book_title, ist.issued_date, e.emp_name
FROM books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn
JOIN members AS m
ON ist.issued_member_id = m.member_id
JOIN employees AS e
ON ist.issued_emp_id = e.emp_id; 

-- 4) Show emp_name, total number of books each employee issued. 
SELECT e.emp_name, 
COUNT(ist.issued_book_isbn) AS total
FROM issued_status AS ist
JOIN employees AS e
ON ist.issued_emp_id = e.emp_id
GROUP BY 1
ORDER BY total DESC; 

SELECT e.emp_name, 
COUNT(*) AS total
FROM issued_status AS ist
JOIN employees AS e
ON ist.issued_emp_id = e.emp_id
GROUP BY 1
ORDER BY total DESC; 

-- 5) Show category, total number of times books from that category were issued from tables books and issued_status
SELECT b.category, 
COUNT(*) AS total
FROM books AS b
JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1; 

-- 6) Show category, total rental income from issued books in each category from tables books and issued_status
SELECT * FROM issued_status; 
SELECT * FROM books; 

SELECT b.category, 
SUM(b.rental_price) AS total_sum
FROM books AS b
JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1; 

-- 7) Show all books, even books that were never issued. 
SELECT b.book_title, ist.issued_id, ist.issued_date
FROM books AS b
LEFT JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1,2,3; 

-- 8) Show only books that were never issued. DISPLAY book_title, isbn. 
SELECT * FROM books; 
SELECT * FROM issued_status; 

SELECT b.book_title, b.isbn 
FROM books AS b
LEFT JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
WHERE ist.issued_book_isbn IS NULL; 

-- 9) Show each member and how many books they issued. 
SELECT * FROM issued_status; 
SELECT * FROM members; 

SELECT m.member_name, 
COUNT(ist.issued_member_id) AS total_books_issued
FROM members AS m
LEFT JOIN issued_status AS ist
ON m.member_id = ist.issued_member_id
GROUP BY 1; 

-- 10) Show only members who issued more than 2 books. Display member_name, total_books_issued
SELECT m.member_name, 
COUNT(ist.issued_member_id) AS total_books_issued
FROM members AS m
LEFT JOIN issued_status AS ist
ON m.member_id = ist.issued_member_id
GROUP BY 1
HAVING COUNT(ist.issued_member_id) > 2; 

-- 11) Show each employee and total rental income they generated 
SELECT * FROM employees; 
SELECT * FROM books; 
SELECT * FROM issued_status; 

SELECT e.emp_name, 
SUM(b.rental_price) AS total_income
FROM employees AS e
JOIN issued_status AS ist
ON e.emp_id = ist.issued_emp_id
JOIN books AS b
ON ist.issued_book_isbn = b.isbn
GROUP BY 1; 

-- 12) Show each employee's total rental income, but only employees who generated more than 50 income. 
SELECT e.emp_name, 
SUM(b.rental_price) AS total_income
FROM employees AS e
JOIN issued_status AS ist
ON e.emp_id = ist.issued_emp_id
JOIN books AS b
ON ist.issued_book_isbn = b.isbn
GROUP BY 1
HAVING SUM(b.rental_price) > 50; 












































    
    
    
    
    
	