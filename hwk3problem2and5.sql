-- PROBLEM 2
/*
Questions:
a.	How many databases are created by the script?
b.	List the database names and the tables created for each database.
c.	How many records does the script insert into the om.order_details table?
d.	How many records does the script insert into the ap.invoices table?
e.	How many records does the script insert into the ap.vendors table?
f.	Is there a foreign key between the ap.invoices and the ap.vendors table?
g.	How many foreign keys does the ap.vendors table have?
h.	What is the primary key for the om.customers table?
i.	Write a SQL command that will retrieve all values for all fields from the om.orders table
j.	Write a SQL command that will retrieve the fields: title and artist from the om.items table


Solutions:
a. 3.
b.
database name: ap
tables：general_ledger_accounts / terms / vendors / invoices / invoice_line_items / vendor_contacts / invoice_archive

name: ex
tables：null_sample / departments / employees / projects / customers / color_sample / string_sample / float_sample / date_sample / active_invoices / paid_invoices

name: om
tables：customers / items / orders / order_details
c. 68.
d. 114.
e. 122.
f. Yes, there is a foreign key names vendor_id from table vendors in table invoices.
g. 2.
h. customer_id.
i. select * from om.orders;
j. select title, artist from om.items;
*/


-- PROBLEM 5
/*
Questions:
a.	How many tables are created by the script?
b.	 List the names of the tables created for the Chinook database.
c.	How many records does the script insert into the Album table?
d.	What is the primary key for the Album table?
e.	Write a SQL SELECT command to retrieve all data from all columns and rows in the Artist table.
f.	Write a SQL SELECT command to retrieve the fields FirstName, LastName and Title from the Employee table

Solutions:
a. 11.
b. Album / Artist / Customer / Employee / Genre / Invoice / InvoiceLine / MediaType / Playlist / PlaylistTrack / Track
c. 347.
d. PK_Album.
e. select * from chinook.Artist
f. select FirstName, LastName, Title from chinook.Employee
*/


