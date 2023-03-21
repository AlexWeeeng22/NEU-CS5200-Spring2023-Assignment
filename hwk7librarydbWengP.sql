-- 1.      Write a function num_genres(isbn_p) that 
-- returns the number of genres given an ISBN for a book.(5 points) 

USE librarydb;

DELIMITER $$
CREATE FUNCTION num_genres(isbn_p CHAR(13)) RETURNS INT DETERMINISTIC
BEGIN     
    DECLARE num_of_genres INT;
    SELECT COUNT(*) INTO num_of_genres FROM book_genre WHERE isbn = isbn_p;
    RETURN num_of_genres;
END 
DELIMITER $$

-- SHOW CREATE FUNCTION num_genres;$$

SELECT num_genres('9781429989817'); $$




-- 2. Write a procedure all_genres(isbn_p) that accepts an isbn string and 
-- returns a result set of all genres for the book. (5 points) 

DELIMITER $$
CREATE PROCEDURE all_genres(IN isbn_p CHAR(13))
BEGIN
    SELECT genre FROM book_genre WHERE isbn = isbn_p;
END $$
DELIMITER $$

-- CALL all_genres('9780749460211');$$



-- 3.      Write a procedure named book_has_genre(genre_p)  
-- that accepts a book genre and  returns a result set of the books with that genre. 
-- The result should contain the ISBN, the author, number of pages and publisher.
--  If a genre is provided that is not found in the genre table, 
--  generate an error from the procedure stating that the passed genre is not valid 
--  and use SIGNAL to throw an error .  Each book should only contain 1 tuple in the result.  (10 points)

-- SELECT book.isbn, book.title, genre AS genre_type 
-- FROM book 
-- LEFT JOIN book_genre 
-- ON book.isbn = book_genre.isbn
-- WHERE genre = 'Accounting';

DELIMITER $$
CREATE PROCEDURE book_has_genre(IN genre_p VARCHAR(255))
BEGIN
	IF (genre_p NOT IN (SELECT NAME FROM genre)) 
		THEN  SELECT 'Error! The passed genre is not valid!';
	ELSE 
		SELECT BG.isbn, BA.author, B.page_count, B.publisher_name 
        FROM (book_genre BG LEFT JOIN book_author BA ON BG.isbn = BA.isbn)
		LEFT JOIN book B ON B.isbn = BG.isbn
		WHERE BG.genre = genre_p;
	END IF;
END $$
DELIMITER $$

SHOW PROCEDURE STATUS; $$
DROP PROCEDURE book_has_genre; $$
CALL book_has_genre('Accounting'); $$
CALL book_has_genre('000g'); $$


--  4.      Write a function named book_length(length_p)  that accepts one parameter, 
--  a count of pages and returns the number of books with that length (5 points)

DELIMITER $$
CREATE FUNCTION book_length(length_p INT(255))
RETURNS INT DETERMINISTIC READS SQL DATA
BEGIN
	DECLARE book_num INT DEFAULT 0;
		SELECT count(B.isbn) INTO book_num 
		FROM book B
		WHERE B.page_count = length_p;
	RETURN(book_num);
END $$
DELIMITER $$

DROP FUNCTION book_length;$$
SELECT book_length(451);$$


-- 5.    Write a procedure  named check_books_by_author( ) that accepts no arguments  
-- and returns a row for each author tuple in the author table. 
-- The result contains the number of books written by the author, 
-- the author's name and the calculated number of books written by the author using the book_author table. (5 points)

-- 5.    Write a procedure  named check_books_by_author( ) that accepts no arguments  
-- and returns a row for each author tuple in the author table. 
-- The result contains the number of books written by the author, 
-- the author's name and the calculated number of books written by the author using the book_author table. (5 points)

DELIMITER $$
CREATE PROCEDURE check_books_by_author()
	BEGIN
		SELECT BA.author, COUNT(B.title) AS book_num
        FROM book B
			LEFT JOIN book_author BA
            ON B.isbn = BA.isbn
		GROUP BY BA.author;
	END $$
    
DELIMITER ;

DROP PROCEDURE check_books_by_author;
CALL check_books_by_author; 



-- 6.   Write a function named moreBooks(author1,author2). 
-- It accepts 2 author names and returns 1 if author1 has written more books than author2, 
-- 0 if they have written the same number of books , 
-- and -1 if author2 has wriiten more books than author1. (10 points)

DELIMITER $$

CREATE FUNCTION moreBooks(author1 VARCHAR(50),author2 VARCHAR(50))
RETURNS INT DETERMINISTIC READS SQL DATA
BEGIN
	DECLARE NUM1 INT DEFAULT 0;
    DECLARE NUM2 INT DEFAULT 0;
    DECLARE state INT DEFAULT 3;
    
    SELECT COUNT(B.isbn) INTO NUM1
    FROM book B
    LEFT JOIN book_author BA ON B.isbn = BA.isbn
    WHERE BA.author = author1;
    
	SELECT COUNT(B.isbn) INTO NUM2
    FROM book B
    LEFT JOIN book_author BA ON B.isbn = BA.isbn
    WHERE BA.author = author2;
    
    IF author1 > author2 THEN
		SELECT 1 INTO state;
    ELSEIF author1 = author2 THEN
		SELECT 0 INTO state;
	ELSE
		SELECT -1 INTO state;
    END IF;
    RETURN state;
END $$

DELIMITER ;

DROP FUNCTION moreBooks;

SELECT moreBooks('David Hume','Peter V. Brett');


--  7.      Create a procedure 
--  named create_book( isbn_p, title_p, author_p, description_p, page_count_p, publisher_name_p, publication_date_p ) 
--  that inserts a book  into the database . 
--  Make sure you create the appropriate tuples in the author, and publisher  table. 
--  Also, ensure the number of books for an author is consistent with the additional tuple you are inserting.  
--  Insert the following book  into the book table.
--  ISBN = 1482576155, 
--  Title = “Pride and Prejudice” , 
--  Author = “Jane Austen”,  
--  number of pages = 254, 
--  Description = “ Classic novel on the plight and limitations for women in the nineteenth century” 
--  publisher = “CreateSpace Independent Publishing Platform “ 
--  publication date = ‘2013-02-19’ using the create_book procedure as well as another book. 
--  Please also provide SELECT statements that verify the tuples have been inserted into the appropriate tables.  (10 points)



DELIMITER $$

CREATE PROCEDURE create_book(
	in isbn_p CHAR(13), 
	in title_p VARCHAR(500), 
	in author_p VARCHAR(50), 
	in description_p VARCHAR(10000), 
	in page_count_p INT, 
	in publisher_name_p VARCHAR(80), 
	in publication_date_p DATE
)
BEGIN

	INSERT INTO author(name) VALUES(author_p)
    ON DUPLICATE KEY UPDATE books_written = books_written + 1;
    
    INSERT INTO publisher(name) VALUES (publisher_name_p)
    ON DUPLICATE KEY UPDATE books_published = books_published + 1;

	INSERT INTO book (isbn, title, description, page_count, publisher_name, publication_date)
	VALUES (isbn_p, title_p, description_p, page_count_p, publisher_name_p, publication_date_p);
    
	INSERT INTO book_author (isbn, author)
	VALUES (isbn_p, author_p);

END $$

DELIMITER ;

DROP PROCEDURE create_book;

CALL create_book('1482576155', 'Pride and Prejudice', 'Jane Austen', 'Classic novel on the plight and limitations for women in the nineteenth century', 254, 'CreateSpace Independent Publishing Platform', '2013-02-19');

-- Verify book insertion
SELECT * FROM book WHERE isbn = '1482576155';

-- Verify author insertion
SELECT * FROM author WHERE name = 'Jane Austen';

-- Verify publisher insertion
SELECT * FROM publisher WHERE name = 'CreateSpace Independent Publishing Platform';

-- Verify book_author mapping
SELECT * FROM book_author WHERE isbn = '1482576155';


-- IN CASE OF DUPLICATE
-- DELIMITER $$
-- CREATE PROCEDURE update_book(isbn_p CHAR(13), title_p VARCHAR(500), author_p VARCHAR(50), description_p VARCHAR(10000), page_count_p INT, publisher_name_p VARCHAR(80), publication_date_p DATE)
-- BEGIN
--     DECLARE publisher_id INT;
--     DECLARE author_id INT;
--     
--     -- Get publisher_id from publisher table
--     SELECT publisher_id INTO publisher_id
--     FROM publisher
--     WHERE publisher_name = publisher_name_p;
--     
--     -- If publisher_id is null, insert a new tuple into the publisher table and get the new publisher_id
--     IF publisher_id IS NULL THEN
--         INSERT INTO publisher (publisher_name) VALUES (publisher_name_p);
--         SET publisher_id = LAST_INSERT_ID();
--     END IF;
--     
--     -- Get author_id from author table
--     SELECT author_id INTO author_id
--     FROM author
--     WHERE author_name = author_p;
--     
--     -- If author_id is null, insert a new tuple into the author table and get the new author_id
--     IF author_id IS NULL THEN
--         INSERT INTO author (author_name, num_books) VALUES (author_p, 1);
--         SET author_id = LAST_INSERT_ID();
--     ELSE
--         -- Increment num_books for the author
--         UPDATE author SET num_books = num_books + 1 WHERE author_id = author_id;
--     END IF;
--     
--     -- Update the book table
--     UPDATE book
--     SET title = title_p,
--         description = description_p,
--         page_count = page_count_p,
--         publisher_id = publisher_id,
--         publication_date = publication_date_p
--     WHERE isbn = isbn_p;
--     
--     -- Update the book_author table
--     UPDATE book_author
--     SET author_id = author_id
--     WHERE isbn = isbn_p;
-- END $$
-- DELIMITER ;


-- 8. Write a procedure named checked_out_books()  
-- that returns the unavailable books and the members who have checked them out. 

-- (book)
--  The result should contain 
--  the book isbn,
--  the book title, 
--  the description, 
--  the number of pages, 
--  the  publisher, (publisher)

--  the author, (book_author)

--  the user name, (books_on_loan)

--  the first name and last name of the person who has the book checked out. (member)

--  Each book should only contain 1 tuple in the result. (5 points)


-- the book isbn, 
-- the book title, 
-- the author, 
-- the description, 
-- the number of pages, 
-- the  publisher,
-- the user name, 
-- the first name and last name

DELIMITER $$

CREATE PROCEDURE checked_out_books()
	BEGIN
        SELECT B.isbn, B.title, BA.author, B.description, B.page_count, B.publisher_name, BOL.current_holder, M.first_name, M.last_name
        FROM book B
			JOIN book_author BA ON B.isbn = BA.isbn
			JOIN books_on_loan BOL ON B.isbn = BOL.isbn
			JOIN member M ON M.username = BOL.current_holder
		WHERE B.current_holder IS NOT NULL;
	END $$

DELIMITER ;

DROP PROCEDURE checked_out_books;
CALL checked_out_books;



 -- 9. Write a trigger that updates the author table when a book_author tuple is inserted into the database. 
--  The trigger will need to update the  author.books_written field or create a new tuple for the author, 
--  if the author does not yet exist. Name the trigger author_before_insert_book_author(). 
--  Insert a book into the book table and the book_author table to verify your trigger is working;  
--  ISBN = “1953649327”, 
--  TITLE = “Emma”, 
--  Author = “Jane Austen”, 
--  publisher = “SeaWolf Press”,  
--  publication date =  2020-10-31 number of pages = 408, 
--  description = “Austen explores the concerns and difficulties of genteel women living in Georgian–Regency England. Emma is spoiled, headstrong, and self-satisfied”.  
--  (Note do not use your create_books procedure)  R

DELIMITER $$
CREATE TRIGGER author_before_insert_book_author
BEFORE INSERT ON book_author
FOR EACH ROW
	BEGIN
	  DECLARE author_exists INT;

	  SELECT COUNT(*) INTO author_exists 
	  FROM author 
	  WHERE name = NEW.author;

	  IF author_exists = 0 THEN
		INSERT INTO author (name, books_written) 
		VALUES (NEW.author, 1);
	  ELSE
		UPDATE author SET books_written = books_written + 1 
		WHERE name = NEW.author;
	  END IF;
	END $$

DELIMITER ;

insert into publisher (name) 
values ('SeaWolf Press');

insert into book (isbn,title,description,page_count,publisher_name,publication_date) 
values (1953649327,'Emma','Austen explores the concerns and difficulties of genteel women living in
Georgian–Regency England. Emma is spoiled, headstrong, and self-satisfied',408,'SeaWolf Press','2020-10-31');

insert into book_author (author,isbn) 
values ('Jane Austen',1953649327);

select * from book where isbn=1953649327;
select * from book_author where isbn=1953649327;
select * from publisher where name='SeaWolf Press';



--  10. Write a trigger that updates the publisher table when a book is added to the book table. 
--  The trigger will need to update the  publisher.books_published count or create a new tuple for the publisher, 
--  if the publisher does not exist. Call the trigger, publisher_before_book_insert().  
--  
--  Insert a book into the book table to verify your trigger is working;  
--  ISBN = “1955529868”, 
--  TITLE = “Sense and Sensibility”, 
--  Author = “Jane Austen”, 
--  publisher = “SeaWolf Press”,  
--  publication date =  2021-07-08, 
--  number of pages = 340, 
--  description = “Sense and Sensibility is a novel by Jane Austen, initially published anonymously in 1811. 
--  It tells the story of the Dashwood sisters, Elinor and Marianne as they come of age. ”.  
--  (Note do not use your create_books procedure)   
--  Remove book from the database as well as any other tuples associated with it. (10 points)


delimiter $$
CREATE TRIGGER publisher_before_book_insert BEFORE INSERT ON book
FOR EACH ROW
	BEGIN
	DECLARE publisher_exists INT;
	SELECT count(*) INTO publisher_exists FROM publisher WHERE NAME=NEW.publisher_name;
		IF publisher_exists=0 THEN
			INSERT INTO publisher (name) VALUES (NEW.publisher_name);
		ELSE
			UPDATE publisher SET books_published = books_published + 1 WHERE name = NEW.publisher_name;
		END IF;
	end $$

DELIMITER ;

DROP TRIGGER publisher_before_book_insert;

insert into book (isbn, title, description, page_count, publisher_name, publication_date) 
values (1955529868,'Sense and Sensibility','Sense and Sensibility is a novel by Jane Austen, initially published anonymously in 1811.
It tells the story of the Dashwood sisters, Elinor and Marianne as they come of age.',340,'SeaWolf Press','2021-07-08');

select * from book where isbn=1955529868;
select * from book_author where isbn=1955529868;
select * from publisher where name='SeaWolf Press';





-- 11. Now that you have written triggers to handle the updates of the author 
-- and publisher table when a book is inserted into the database, 
-- simplify create_books to take advantage of the work done by the  triggers. 
-- Name the procedure create_books_simpler( isbn_p, title_p, author_p, description_p, page_count_p, publisher_name_p, publication_date_p ) 
-- Insert both books from problems 9 and 10 and also write the SELECT statements 
-- to verify the tuples are in the database as well as the updates done by the triggers . (5 points)


DELIMITER $$
CREATE PROCEDURE create_books_simpler(IN isbn_p CHAR(13), 
									  IN title_p VARCHAR(500), 
									  IN author_p VARCHAR(50) , 
									  IN description_p VARCHAR(10000), 
								      IN page_count_p INT, 
									  IN publisher_name_p VARCHAR(80), 
									  IN publication_date_p DATE)

BEGIN
INSERT INTO book (isbn, title, description, page_count, publisher_name, publication_date) 
VALUES (isbn_p, title_p, description_p, page_count_p, publisher_name_p, publication_date_p);
INSERT INTO book_author (author, isbn) VALUES (author_p, isbn_p);
END $$

DELIMITER ;

-- test code 
call create_books_simpler(1953649327,'Emma','Jane Austen','Austen explores the concerns and difficulties of genteel women living in
Georgian–Regency England. Emma is spoiled, headstrong, and self-satisfied',408,'SeaWolf Press','2020-10-31');
call create_books_simpler(1955529868,'Sense and Sensibility','Jane Austen','Sense and Sensibility is a novel by Jane Austen, initially published anonymously in 1811.
It tells the story of the Dashwood sisters, Elinor and Marianne as they come of age.',340,'SeaWolf Press','2021-07-08');

select * from author where name='Jane Austen';
select * from publisher where name='SeaWolf Press';
select * from book where isbn=1953649327 or isbn=1955529868;
select * from book_author where isbn=1953649327 or isbn=1955529868;


 
 
-- 12.Create and execute a prepared statement from the SQL workbench that calls the function moreBooks(author1,author2). 
-- Use 2 user session variables to pass the two arguments to the function. 
-- Pass the values “Billy Connolly” and “Barbara Allan” as the author values.  (5 points)

SET @a='Billy Connolly';
SET @b='Barbara Allan';
PREPARE stml FROM 'select morebooks(?,?)';
EXECUTE stml USING @a,@b;


-- 13.  Create and execute a prepared statement from the SQL workbench that calls the function book_length(length_p)
-- Use a user session variable to pass the length to the function. Pass the value 400 as the length  (5 points)

SET @d=400;
PREPARE stml1 FROM 'select book_length(?)';
EXECUTE stml1 USING @d;


-- 14. Create a procedure named update_all_publishers( ) that assigns the publisher.
-- books_published field to the correct value. 
-- The correct value is determined by the number of books published by the publisher found in the book table.  (5 points)

DELIMITER $$
CREATE PROCEDURE update_all_publishers()
BEGIN
  UPDATE publisher P SET P.books_published = (
    SELECT COUNT(*) FROM book B WHERE B.publisher_name = P.name
  );
END $$

CALL update_all_publishers();
SELECT * FROM publisher;



-- 15. Create a procedure named update_all_authors( ) 
-- that assigns the author.books_written field to the correct value. 
-- The correct value is determined by the number of books found in the book_author  table for the author.  (5 points)

DELIMITER $$
CREATE PROCEDURE update_all_authors()
BEGIN
  UPDATE author A SET A.books_written = (
    SELECT COUNT(*) FROM book_author BA WHERE BA.author = A.name
  );
END $$

CALL update_all_authors();
SELECT * FROM author;