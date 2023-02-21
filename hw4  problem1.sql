CREATE DATABASE IF NOT EXISTS Stellar_Markets;

-- select the database
use Stellar_Markets;

-- create the tables for entity
CREATE TABLE chain
(
	chain_id              INT           NOT NULL   PRIMARY KEY     ,
    -- address
    street_number         VARCHAR(8)    NOT NULL,
    street_name           VARCHAR(64)   NOT NULL,
    zip_code              VARCHAR(5)    NOT NULL,
    state_abbreviation    VARCHAR(4)    NOT NULL,
    open_time             TIME          NOT NULL,
    close_time            TIME          NOT NULL,
    
    normal_staff          INT           NOT NULL,
    manager_staff         INT           NOT NULL,
    product_number        VARCHAR(50)   NOT NULL,
    
    FOREIGN KEY (normal_staff) REFERENCES staff(staff_no)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (manager_staff) REFERENCES staff(staff_no)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (product_number) REFERENCES product_types(product_numbers)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE staff
(
	staff_no    	INT             PRIMARY KEY,
    fisrt_name      VARCHAR(50)		NOT NULL,
    last_name       VARCHAR(50)		NOT NULL,
    is_manager      BOOLEAN         NOT NULL,
    responsibility	VARCHAR(300)            ,
    
    work_chain      INT            NOT NULL,
    
    FOREIGN KEY (work_chain) REFERENCES chain(chain_id)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE product_genres
(	
    bakery             boolean		NOT NULL,
    non_perishable     boolean		NOT NULL,
    produce            boolean		NOT NULL,
    meat               boolean		NOT NULL,
    dairy_products     boolean		NOT NULL,
    PRIMARY KEY(bakery, non_perishable, produce, meat, dairy_products),
    
    product_types      char(50)     NOT NULL,
    
	FOREIGN KEY (product_tpyes) REFERENCES product_types(product_name)
		ON UPDATE CASCADE ON DELETE CASCADE    
);

CREATE TABLE product_types
(
	product_name	char(50)	    primary key   NOT NULL,
    product_numbers VARCHAR(50)	DEFAULT 0	  NOT NULL,
    
    product_genres		BOOLEAN     NOT NULL,
    in_which_chain		INT         NOT NULL,
    
	FOREIGN KEY (product_genres) REFERENCES product_genres(bakery, non_perishable, produce, meat, dairy_products)
		ON UPDATE CASCADE ON DELETE CASCADE, 
	FOREIGN KEY (in_which_chain) REFERENCES chain(chain_id)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE customer
(
	customer_id     VARCHAR(64)     NOT NULL	PRIMARY KEY,
    first_name      VARCHAR(64)     NOT NULL,
    last_name       VARCHAR(64)     NOT NULL,
    -- address
    street          VARCHAR(64)     NOT NULL,
    city            VARCHAR(64)     NOT NULL, 
    state           VARCHAR(64)		NOT NULL,
    country         VARCHAR(64)		NOT NULL,
    zip_code        VARCHAR(64)		NOT NULL,
    
    credit_card_number     VARCHAR(20)     NOT NULL,
    legal_id_type			char()        NOT NULL,
    
    FOREIGN KEY (credit_card_number) REFERENCES credit_card(credit_card_number)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (legal_id_type) REFERENCES legal_identification_type(credit_card, driving_license, passport)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE credit_card
(
	credit_card_number     VARCHAR(20)     PRIMARY KEY     NOT NULL,
    expiration_date        DATE         NOT NULL,
    
    customer            VARCHAR(64)     NOT NULL,
    credit_card_type	VARCHAR(64)     NOT NULL,
    
	FOREIGN KEY (customer) REFERENCES customer(customer_id)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (credit_card_type) REFERENCES credit_card_type_info(visa, amex, mastercard)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE credit_card_type_info
(
	visa	   BOOLEAN,
    amex       BOOLEAN,
    mastercard BOOLEAN,
    PRIMARY KEY(visa, amex, mastercard)
);

CREATE TABLE legal_identification_type
(
	credit_card         BOOLEAN,
    driving_license     BOOLEAN,
    passport            BOOLEAN,
    PRIMARY KEY(credit_card, driving_license, passport),
    
    customer_id		VARCHAR(64)     NOT NULL,
    
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
		ON UPDATE CASCADE ON DELETE CASCADE
);

-- relationships
CREATE TABLE register
(
	customer_first_name        VARCHAR(64)		NOT NULL,
    customer_last_name         VARCHAR(64)		NOT NULL,
    customer_local_address     VARCHAR(200)		NOT NULL,
    -- credit_card_info
    credit_card_type             BOOLEAN		NOT NULL,
    credit_card_number			 VARCHAR(20)    NOT NULL,
    credit_card_expiration_date  DATE           NOT NULL,
    PRIMARY KEY(customer_first_name, customer_last_name, customer_local_address, credit_card_type, credit_card_number, credit_card_expiration_date),
	
    FOREIGN KEY (customer_first_name) REFERENCES customer(first_name)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (customer_last_name) REFERENCES customer(last_name)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (customer_local_address) REFERENCES customer(street, city, state, country, zip_code)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (credit_card_type) REFERENCES credit_card(credit_card_type)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (credit_card_number) REFERENCES credit_card(credit_card_number)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (credit_card_expiration_date) REFERENCES credit_card(expiration_date)
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE place_order
(
	valid_id	BOOLEAN                            NOT NULL,
    chain_id    INT                                NOT NULL,
    product_name	char(50)	                   NOT NULL,
    product_numbers VARCHAR(50)	DEFAULT 0	       NOT NULL,
    customer_id     VARCHAR(64)     			   NOT NULL,
    credit_card         BOOLEAN                    NOT NULL,
    driving_license     BOOLEAN                    NOT NULL,
    passport            BOOLEAN                    NOT NULL,
    
    FOREIGN KEY (valid_id) REFERENCES customer(legal_id_type)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (chain_id) REFERENCES chain(chain_id)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (product_name) REFERENCES product_types(product_name)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (product_numbers) REFERENCES product_types(product_numbers)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (credit_card) REFERENCES legal_identification_type(credit_card )
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (driving_license) REFERENCES legal_identification_type(driving_license)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (passport) REFERENCES legal_identification_type(passport)
		ON UPDATE CASCADE ON DELETE CASCADE
);