-- Create tables ------------------
CREATE TABLE product
(
  id                NUMBER GENERATED ALWAYS AS IDENTITY,
  name              VARCHAR2(40)  NOT NULL,
  price             NUMBER(18, 2) NOT NULL,
  receipt_date      DATE          NOT NULL,
  expiration_date   DATE          NOT NULL,
  quantity_in_stock NUMBER        NOT NULL,
  CONSTRAINT product_id_pk PRIMARY KEY (id),
  CONSTRAINT valid_expiration_date CHECK (expiration_date > receipt_date)
);

CREATE TABLE tare
(
  id          NUMBER GENERATED ALWAYS AS IDENTITY,
  name        VARCHAR2(40)  NOT NULL,
  capacity    NUMBER        NOT NULL,
  description VARCHAR2(400) NOT NULL,
  CONSTRAINT tare_id_pk PRIMARY KEY (id),
  CONSTRAINT valid_capacity CHECK (capacity > 0)
);

CREATE TABLE product_type
(
  id   NUMBER GENERATED ALWAYS AS IDENTITY,
  name VARCHAR2(40) NOT NULL,
  CONSTRAINT product_type_id_pk PRIMARY KEY (id)
);

ALTER TABLE product
  ADD tare_id NUMBER;
ALTER TABLE product
  ADD CONSTRAINT tare_id_fk FOREIGN KEY (tare_id)
REFERENCES tare (id)
ON DELETE CASCADE;

ALTER TABLE product
  ADD product_type_id NUMBER;
ALTER TABLE product
  ADD CONSTRAINT product_type_id_fk FOREIGN KEY (product_type_id)
REFERENCES product_type (id)
ON DELETE CASCADE;

CREATE TABLE seller
(
  id              NUMBER GENERATED ALWAYS AS IDENTITY,
  first_name      VARCHAR2(30) NOT NULL,
  last_name       VARCHAR2(30) NOT NULL,
  employment_date DATE         NOT NULL,
  dismissal_date  DATE         NULL,
  category        VARCHAR2(10) NOT NULL,
  CONSTRAINT seller_id_pk PRIMARY KEY (id),
  CONSTRAINT valid_category CHECK (category IN ('a', 'b', 'c'))
);

CREATE TABLE selling (
  id         NUMBER GENERATED ALWAYS AS IDENTITY,
  seller_id  NUMBER               NOT NULL,
  product_id NUMBER               NOT NULL,
  sele_date  DATE DEFAULT sysdate NOT NULL,
  quantity   NUMBER               NOT NULL,
  price      NUMBER(18, 2)        NOT NULL,
  CONSTRAINT selling_id_pk PRIMARY KEY (id),
  CONSTRAINT seller_id_fk FOREIGN KEY (seller_id)
  REFERENCES seller (id),
  CONSTRAINT product_id_fk FOREIGN KEY (product_id)
  REFERENCES product (id)
);
-- --------------------------------

-- Queries ------------------------
ALTER TABLE seller
  DISABLE CONSTRAINT valid_category;

-- insert into tare ---------------
-- alter session set nls_date_format = 'dd-MON-yyyy hh24:mi:ss';

INSERT INTO tare (name, capacity, description)
VALUES ('Small Corrugated Box', 0.5, 'Several layers of paper fibre give the corrugated box the strength properties.');

INSERT INTO tare (name, capacity, description)
VALUES ('Medium Corrugated Box', 1, 'Several layers of paper fibre give the corrugated box the strength properties.');

INSERT INTO tare (name, capacity, description)
VALUES ('Large Corrugated Box', 1.5, 'Several layers of paper fibre give the corrugated box the strength properties.');

INSERT INTO tare (name, capacity, description)
VALUES ('Small Boxboard', 0.1, 'It does not have the wavy middle layer (corrugating medium) to add box strength.');

INSERT INTO tare (name, capacity, description)
VALUES ('Medium Boxboard', 0.15, 'It does not have the wavy middle layer (corrugating medium) to add box strength.');

INSERT INTO tare (name, capacity, description)
VALUES ('Large Boxboard', 0.3, 'It does not have the wavy middle layer (corrugating medium) to add box strength.');
-- --------------------------------

-- insert into product_type -------
INSERT INTO product_type (name) VALUES ('Fruits');
INSERT INTO product_type (name) VALUES ('Vegetable');
INSERT INTO product_type (name) VALUES ('Сereals');
INSERT INTO product_type (name) VALUES ('Condiments');
INSERT INTO product_type (name) VALUES ('Sweets');
INSERT INTO product_type (name) VALUES ('Bakery products');
INSERT INTO product_type (name) VALUES ('Soft drinks');
INSERT INTO product_type (name) VALUES ('Alcohol');
-- --------------------------------

-- insert into product ------------
INSERT INTO product (name, price, receipt_date, expiration_date, quantity_in_stock, tare_id, product_type_id)
VALUES ('apples', 37.20, to_date('1-9-2017', 'dd-mm-yyyy'), to_date('01-12-2017', 'dd-mm-yyyy'), 500, 4, 7);

INSERT INTO product (name, price, receipt_date, expiration_date, quantity_in_stock, tare_id, product_type_id)
VALUES ('apples', 80.00, to_date('1-9-2017', 'dd-mm-yyyy'), to_date('1-12-2017', 'dd-mm-yyyy'), 280, NULL, 1);

INSERT INTO product (name, price, receipt_date, expiration_date, quantity_in_stock, tare_id, product_type_id)
VALUES ('tomato', 28.20, to_date('1-9-2017', 'dd-mm-yyyy'), to_date('1-12-2017', 'dd-mm-yyyy'), 2304, 5, 2);

INSERT INTO product (name, price, receipt_date, expiration_date, quantity_in_stock, tare_id, product_type_id)
VALUES ('potato', 24.7, to_date('1-2-2017', 'dd-mm-yyyy'), to_date('1-10-2017', 'dd-mm-yyyy'), 35, 5, 2);

INSERT INTO product (name, price, receipt_date, expiration_date, quantity_in_stock, tare_id, product_type_id)
VALUES ('sugar', 32.52, to_date('1-2-2016', 'dd-mm-yyyy'), to_date('1-2-2018', 'dd-mm-yyyy'), 23000, 5, NULL);

INSERT INTO product (name, price, receipt_date, expiration_date, quantity_in_stock, tare_id, product_type_id)
VALUES ('sugar', 64.35, to_date('20-2-2017', 'dd-mm-yyyy'), to_date('20-2-2019', 'dd-mm-yyyy'), 3000, 3, NULL);

INSERT INTO product (name, price, receipt_date, expiration_date, quantity_in_stock, tare_id, product_type_id)
VALUES ('apple juice', 2.03, to_date('1-8-2017', 'dd-mm-yyyy'), to_date('1-3-2018', 'dd-mm-yyyy'), 800, 5, 7);
-- --------------------------------

-- insert into seller -------------
INSERT INTO seller (first_name, last_name, employment_date, dismissal_date, category)
VALUES ('Jay', 'Christensen', to_date('2-6-2012', 'dd-mm-yyyy'), NULL, 'a');

INSERT INTO seller (first_name, last_name, employment_date, dismissal_date, category)
VALUES ('Ramona', 'Cooper', to_date('5-11-2012', 'dd-mm-yyyy'), NULL, 'c');

INSERT INTO seller (first_name, last_name, employment_date, dismissal_date, category)
VALUES ('Andrea', 'Mccormick', to_date('14-10-2012', 'dd-mm-yyyy'), NULL, 'b');

INSERT INTO seller (first_name, last_name, employment_date, dismissal_date, category)
VALUES ('Sidney', 'Obrien', to_date('2-5-2013', 'dd-mm-yyyy'), to_date('30-7-2016', 'dd-mm-yyyy'), 'b');

INSERT INTO seller (first_name, last_name, employment_date, dismissal_date, category)
VALUES ('Christian', 'Nguyen', to_date('7-2-2014', 'dd-mm-yyyy'), NULL , 'c');

INSERT INTO seller (first_name, last_name, employment_date, dismissal_date, category)
VALUES ('Oleg', 'Raskin', to_date('1-9-2015', 'dd-mm-yyyy'), to_date('2-9-2015', 'dd-mm-yyyy') , 'c');

INSERT INTO seller (first_name, last_name, employment_date, dismissal_date, category)
VALUES ('Kay', 'Simpson', to_date('4-12-2016', 'dd-mm-yyyy'), NULL , 'b');

INSERT INTO seller (first_name, last_name, employment_date, dismissal_date, category)
VALUES ('Pam', 'Frank', to_date('23-6-2017', 'dd-mm-yyyy'), NULL , 'a');
-- --------------------------------

-- insert into selling ------------
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (5, 3, 2, (SELECT price from product WHERE id = 3));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (1, 1, 3, (SELECT price from product WHERE id = 1));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (5, 1, 4, (SELECT price from product WHERE id = 1));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (2, 3, 3, (SELECT price from product WHERE id = 3));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (5, 5, 3, (SELECT price from product WHERE id = 5));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (2, 2, 1, (SELECT price from product WHERE id = 2));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (1, 6, 2, (SELECT price from product WHERE id = 6));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (7, 2, 3, (SELECT price from product WHERE id = 2));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (8, 6, 3, (SELECT price from product WHERE id = 6));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (1, 1, 2, (SELECT price from product WHERE id = 1));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (3, 5, 4, (SELECT price from product WHERE id = 5));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (3, 2, 4, (SELECT price from product WHERE id = 2));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (1, 2, 2, (SELECT price from product WHERE id = 2));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (8, 7, 2, (SELECT price from product WHERE id = 7));
INSERT INTO selling (seller_id, product_id, quantity, price) VALUES (5, 5, 3, (SELECT price from product WHERE id = 5));
-- --------------------------------

-- Change category a to b ---------
SELECT * FROM seller WHERE category = 'a';
UPDATE seller SET category = 'b' WHERE category = 'a';
-- --------------------------------

-- Capitalize product name --------
UPDATE product SET name = initcap(name);
-- or
UPDATE product SET name = concat(upper(substr(name, 1, 1)), substr(name, 2));
-- --------------------------------

-- Delete expired products --------
SELECT * FROM product WHERE expiration_date < sysdate;
DELETE product WHERE expiration_date < sysdate;
-- --------------------------------

-- Truncate tare ------------------
ALTER TABLE product DISABLE CONSTRAINT product_type_id_fk;
TRUNCATE TABLE tare;
ALTER TABLE product ENABLE CONSTRAINT product_type_id_fk;
-- --------------------------------

ALTER TABLE seller
  ENABLE CONSTRAINT valid_category;