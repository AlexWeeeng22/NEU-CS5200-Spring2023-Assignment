-- 1.    (5 points)   
--  For each book (found in the book table) 
-- return the book’s ISBN, title, page count and publisher. 

-- SELECT ISBN, title, page_count, publisher_name FROM book;


-- 2.   (5 points)    
-- Determine the number of books that are checked out of the library. 
-- Rename the count books_on_loan.

-- SELECT count(current_holder) AS books_on_loan FROM book ;


-- 3.   (5 points)      
-- Determine the number of members who have books checked out. 
-- Rename the count num_members. 

-- SELECT count(distinct current_holder) AS num_members FROM book ;


-- 4.    (5 points)       
--  Make a separate table from the booktable – where the records are for the books on loan. 
-- Name the new table as books_on_loan. Remember, a table can only be created once. 
-- If you attempt to create the same table multiple times it will generate an error. 

-- CREATE TABLE books_on_loan
-- (
-- SELECT isbn,title,current_holder FROM book
-- 		WHERE current_holder IS NOT NULL
-- );


-- 5.    (5 points)   
--  For each book return the book’s ISBN, title, description, page count, publisher name and author. 
-- If a book has multiple authors, there should be multiple rows in your result.

SELECT book.isbn, book.title, book.description ,book.page_count, book.publisher_name, book_author.author 
      FROM book,book_author 
      WHERE(book.isbn = book_author.isbn);
     -- JOIN ? 
--       insert into book_author values ('aaaaaa', '9780486114354');
-- SELECT * FROM book WHERE isbn IN (SELECT isbn FROM book GROUP BY isbn HAVING COUNT(*)>1); 

-- 6.   (5 points) 
-- For each book (each ISBN in the book table)
-- create an aggregated field that contains a list of the genres for the book..  
-- The result set should contain the isbn, the book title  and the grouped list of genres.

--  SELECT book.isbn, book.title, book_genre.genre FROM book
--  LEFT JOIN book_genre
--  ON book.isbn = book_genre.isbn;


-- 7.   (5 points) 
-- Which are  the longest books  (in pages)? Return the book’s title  in the result. 
-- Return all books with the maximum number of pages. 

-- SELECT title,page_count FROM book
-- WHERE page_count=(SELECT max(page_count) FROM book);
 
 
-- 8.   (5 points) 
-- How many reading clubs are associated with each of the different librarians?
-- The result should contain the librarian’s user name and the count of the number of book clubs they have formed. 
-- Rename the count to num_clubs. All librarians must appear in the result. 

-- SELECT librarian, count(reading_club.name) AS num_clubs FROM reading_club
-- GROUP BY librarian;


-- 9.   (5 points) 
-- Find all books that are less than 300 pages.  
-- Return all fields from the book table and order the results by page count in descending order. 

-- SELECT * FROM book
-- WHERE book.page_count<300
-- ORDER BY page_count DESC;


-- 10. (5 points) 
-- For each genre  in the genre  table, determine the number of books associated with that genre. 
-- The result should contain the genre name and the count. Rename the count to num_books. 
-- Order the results by num_books in descending order. Make sure all genres  appear in the result. 
-- If a genre is not associated with any books,  then the count for the number of books should be 0. 

-- SELECT genre.name AS nenre_name ,count(book_genre.genre) AS num_books FROM genre 
-- LEFT JOIN book_genre 
-- ON genre.name = book_genre.genre
-- GROUP BY genre.name 
-- ORDER BY num_books DESC;


-- 11. (10  points) 
-- For each current book in a reading club, 
-- return the ISBN, the title, the publisher, the number of books published by the publisher, the author, the number of books written by the author, and the librarian’s first name and last name.

-- SELECT reading_club.current_book_isbn, book.title, book.publisher_name, publisher.books_published, book_author.author, author.books_written, librarian.first_name, librarian.last_name
-- FROM (((
-- (reading_club JOIN book ON reading_club.current_book_isbn=book.isbn) 
-- JOIN publisher ON book.publisher_name=publisher.name) 
-- JOIN book_author ON book.isbn=book_author.isbn)
-- JOIN author ON book_author.author=author.name)
-- JOIN librarian ON librarian.username=reading_club.librarian;


-- *12. (5 points) 
-- Return the member’s username,  who is a member in  all book clubs. 

-- SELECT member_username FROM reading_club_members
-- GROUP BY member_username
-- HAVING count(reading_club_members.member_username)=(
-- SELECT count(DISTINCT club_name) FROM reading_club_members );


-- *13. (5 points)  
-- Return the member’s first name and last name who is a member in  all book clubs. 

-- SELECT first_name,last_name FROM member 
-- WHERE member.username=(SELECT member_username FROM reading_club_members
-- GROUP BY member_username
-- HAVING count(reading_club_members.member_username)=(
-- SELECT count(DISTINCT club_name) FROM reading_club_members ));


-- 14. (5 points) 
-- Return all books published before the 21st century. 
-- The results should contain all fields from the book table. 

-- SELECT * FROM book 
-- WHERE publication_date BETWEEN '2001-01-01' AND '2100-12-31';


-- ***15. (10 points) 
-- Find members who are in the same book club. 
-- Each returned tuple should contain the user name for the 2 members in the same book club as well as the name of the book club. 
-- Order the results in ascending order by the book club name. 
-- Make sure you do not match a member with himself. Also, only report the same member pair once. 

-- SELECT club_name,member_username FROM reading_club_members
-- WHERE club_name IN(SELECT DISTINCT club_name FROM reading_club_members)
-- LIMIT 2 ;


-- 16. (5 points)  
-- For each author, determine the number of books they have written. 
-- The result should contain the author’s name and the count of books. Rename the count of books to num_books. 
-- Order the results in descending order by num_books. 

-- SELECT name,books_written AS num_books FROM author 
-- ORDER BY num_books DESC;


-- **17. (5 Points) 
-- Return the maximum number of books written by an author. 

SELECT max(books_written) FROM author;


-- 18. (5 Points) 
-- Return the name of the authors who have written the maximum number of books. 
-- The result should contain the author’s name and the book count. 

SELECT name, books_written AS max_book_count FROM author 
WHERE books_written=(SELECT max(books_written) FROM author );