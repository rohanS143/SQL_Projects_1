USE library_project_2;

-- ADVANCED SQL Operations 
-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT * FROM members; 
SELECT * FROM books; 
SELECT * FROM issued_status;
SELECT * FROM return_status; 

SELECT 
	ist.issued_member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    rs.return_date, 
    
   DATEDIFF(CURRENT_DATE, ist.issued_date) - 30 AS days_overdue
    

FROM issued_status AS ist
JOIN 
members AS m
ON m.member_id = ist.issued_member_id
JOIN 
books AS b
ON b.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE return_date IS NULL
AND 
DATEDIFF(CURRENT_DATE, ist.issued_date) > 30
ORDER BY 1
; 

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" 
-- when they are returned (based on entries in the return_status table).


SELECT * FROM books; 
SELECT * FROM issued_status; 
SELECT * FROM return_status; 

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-451-52994-2'; 

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2'; 

UPDATE books
SET status = 'No'
WHERE isbn = '978-0-451-52994-2'; 

SELECT * FROM return_status
WHERE issued_id = 'IS130' ; 

INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES
    ('RS124', 'IS130', CURRENT_DATE); 

UPDATE books
SET status = 'Yes'
WHERE isbn = (
	SELECT issued_book_isbn
    FROM issued_status
    WHERE issued_id = 'IS130'
); 


-- STORE procedures
DROP PROCEDURE IF EXISTS add_return_records;

DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);

    SELECT issued_book_isbn
    INTO v_isbn
    FROM issued_status
    WHERE issued_id = p_issued_id;

    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE);

    UPDATE books
    SET status = 'Yes'
    WHERE isbn = v_isbn;
END $$

DELIMITER ;

CALL add_return_records('RS139', 'IS135');

SELECT * FROM books; 
SELECT * FROM issued_status;
SELECT * FROM return_status;  
-- '978-0-307-58837-1', 'Sapiens: A Brief History of Humankind', 'History', '8', 'No', 'Yuval Noah Harari', 'Harper Perennial'

-- 'IS135', 'C107', 'Sapiens: A Brief History of Humankind', '2024-04-08', '978-0-307-58837-1', 'E108'



































