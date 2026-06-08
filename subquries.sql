USE library_project_2; 

-- SUBQUERIES 

-- Examples: 
-- 1) Show books whose rental price is greater than the average rental price. 
SELECT * FROM books; 

SELECT 
AVG(rental_price)
FROM books; 

SELECT book_title, rental_price, 
(SELECT ROUND(AVG(rental_price), 2) FROM books) AS avg_price
FROM books
WHERE rental_price > (
	SELECT AVG(rental_price) 
    FROM books
); 

-- 2) Show books that have the highest rental price and DISPLAY book_title, rental_price

SELECT book_title, ROUND(rental_price, 2) AS rental_price
FROM books
WHERE rental_price = (
	SELECT 
	MAX(rental_price) AS highest
	FROM books
); 

-- 3) Show members who have issused at least one book. Display member_name, member_id.

SELECT * FROM members; 
SELECT * FROM issued_status; 

-- join version 
SELECT m.member_name, m.member_id,
COUNT(ist.issued_member_id) AS total_book
FROM members AS m
JOIN issued_status AS ist
ON m.member_id = ist.issued_member_id
GROUP BY 1,2
HAVING COUNT(ist.issued_member_id) >= 1; 

-- subquery version: 
SELECT member_name, member_id
FROM members
WHERE member_id IN (
	SELECT issued_member_id
    FROM issued_status
); 
    
-- 4) Show members who have never issued a book. Display member_name, member_id
SELECT member_name, member_id
FROM members
WHERE member_id NOT IN(
	SELECT issued_member_id 
    FROM issued_status
); 
-- WITH JOIN 

SELECT m.member_name, m.member_id
FROM members AS m
LEFT JOIN issued_status AS ist
ON m.member_id = ist.issued_member_id
WHERE ist.issued_member_id IS NULL; 

-- 5) Show books that were issued more than once. Display book_title, isbn
SELECT * FROM books; 
SELECT * FROM issued_status; 

SELECT book_title, isbn
FROM books
WHERE isbn IN(
	SELECT issued_book_isbn
    FROM issued_status
    GROUP BY issued_book_isbn
    HAVING COUNT(*) > 1
); 

-- 6) Show the member or members who issued the most books. Display issued_member_id, total_books
SELECT issued_member_id, 
COUNT(*) AS total_books
FROM issued_status
GROUP BY 1
HAVING COUNT(*) = ( 
	SELECT MAX(total_books)
	FROM (
		SELECT issued_member_id, 
		COUNT(*) AS total_books
		FROM issued_status
		GROUP BY 1
	) AS member_counts
); 


-- 7) Show the member name of the person/people who issued the most books. Display member_name, total_books
SELECT m.member_name,
COUNT(*) AS total_books
FROM members AS m
JOIN issued_status AS ist
ON m.member_id = ist.issued_member_id
GROUP BY 1
HAVING COUNT(*) = (
	SELECT MAX(total_books)
    FROM (
		SELECT issued_member_id, 
        COUNT(*) AS total_books
        FROM issued_status
        GROUP BY 1
	) AS member_counts
); 

-- 8) Show book titles that were issued by members who issued more than 2 books. Display book_title, issued_member_id

SELECT * FROM books;
SELECT * FROM members;
SELECT * FROM issued_status; 

SELECT b.book_title, ist.issued_member_id
FROM books AS b
JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
WHERE ist.issued_member_id IN (
	SELECT issued_member_id
    FROM issued_status
    GROUP BY 1
    HAVING COUNT(*) > 2
); 


-- 9) SHOW books that were never issued. Display book_title, isbn

SELECT book_title, isbn
FROM books
WHERE isbn NOT IN(
	SELECT issued_book_isbn
    FROM issued_status
); 


-- 10) Show members who issued more books than the average member. Display member_id, total_books
SELECT * FROM members; 
SELECT * FROM issued_status; 


SELECT AVG(total_books)
FROM (
	SELECT issued_member_id,
	COUNT(*) AS total_books
	FROM issued_status
	GROUP BY 1
) AS member_counts; 

SELECT issued_member_id AS member_id,
COUNT(*) As total_books
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > (
	SELECT AVG(total_books)
    FROM (
		SELECT issued_member_id,
		COUNT(*) AS total_books
		FROM issued_status
		GROUP BY 1
	) AS member_counts
); 


-- 11) Show members who have issued at least one book. Display member_name, member_id
SELECT * FROM issued_status;
SELECT * FROM members;  

SELECT member_name, member_id
FROM members
WHERE member_id IN(
	SELECT issued_member_id
	FROM issued_status
	GROUP BY 1
); 

-- Other way: 
SELECT m.member_name, m.member_id
FROM members AS m
WHERE EXISTS (
	SELECT * 
    FROM issued_status AS ist
    WHERE m.member_id = ist.issued_member_id
); 


-- 12) Show members who issued more than 1 book. Display member_name, member_id. 

SELECT m.member_name, m.member_id
FROM members AS m
WHERE (
	SELECT COUNT(*) 
    FROM issued_status AS ist
    WHERE ist.issued_member_id = m.member_id
) > 1; 


    





    
    
    
    
    
    
    



















