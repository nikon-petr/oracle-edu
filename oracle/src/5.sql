-- 1 ------------------------------
CREATE VIEW CATEGORIES(PRODUCT_TYPE_ID, PRODUCT_TYPE_NAME) AS
  SELECT *
  FROM PRODUCT_TYPE;

INSERT INTO CATEGORIES (PRODUCT_TYPE_NAME)
VALUES ('TEA');

INSERT INTO CATEGORIES (PRODUCT_TYPE_NAME)
VALUES ('fish');

DELETE CATEGORIES
WHERE PRODUCT_TYPE_ID = 21;

UPDATE CATEGORIES
SET PRODUCT_TYPE_NAME = 'Tea'
WHERE PRODUCT_TYPE_ID = 22;
-- --------------------------------

-- 2 ------------------------------
CREATE VIEW DETAILED_SELLING(ID, FIST_NAME, LAST_NAME, PRODUCT, "DATE", PRODUCT_TYPE, QUANTITY, TARE) AS
  SELECT
    SELLING.ID,
    SELLER.FIRST_NAME,
    SELLER.LAST_NAME,
    PRODUCT.NAME,
    SELLING.SELE_DATE,
    PRODUCT_TYPE.NAME,
    SELLING.QUANTITY,
    TARE.NAME
  FROM SELLING
    LEFT JOIN SELLER
      ON SELLING.SELLER_ID = SELLER.ID
    LEFT JOIN PRODUCT
      ON SELLING.PRODUCT_ID = PRODUCT.ID
    LEFT JOIN PRODUCT_TYPE
      ON PRODUCT.PRODUCT_TYPE_ID = PRODUCT_TYPE.ID
    LEFT JOIN TARE
      ON PRODUCT.TARE_ID = TARE.ID;

-- error non key-preserved
INSERT INTO DETAILED_SELLING (FIST_NAME, LAST_NAME, PRODUCT, "DATE", PRODUCT_TYPE, QUANTITY, TARE)
VALUES ('Alfred', 'Wells', 'cherry', add_months(sysdate, -7), 'berries', 7, 'Small Packet');

-- error non key-preserved
UPDATE DETAILED_SELLING
SET PRODUCT_TYPE = 'sweet'
WHERE ID = 15;

-- success
UPDATE DETAILED_SELLING
SET QUANTITY = 10
WHERE ID = 1;

-- success
DELETE DETAILED_SELLING
WHERE ID = 15;
-- --------------------------------

-- 3 ------------------------------
CREATE OR REPLACE VIEW DETAILED_SELLING(ID, FIST_NAME, LAST_NAME, PRODUCT, "DATE", PRODUCT_TYPE, QUANTITY, TARE) AS
  SELECT
    SELLING.ID,
    SELLER.FIRST_NAME,
    SELLER.LAST_NAME,
    PRODUCT.NAME,
    SELLING.SELE_DATE,
    PRODUCT_TYPE.NAME,
    SELLING.QUANTITY,
    TARE.NAME
  FROM SELLING
    LEFT JOIN SELLER
      ON SELLING.SELLER_ID = SELLER.ID
    LEFT JOIN PRODUCT
      ON SELLING.PRODUCT_ID = PRODUCT.ID
    LEFT JOIN PRODUCT_TYPE
      ON PRODUCT.PRODUCT_TYPE_ID = PRODUCT_TYPE.ID
    LEFT JOIN TARE
      ON PRODUCT.TARE_ID = TARE.ID
  WITH READ ONLY;
-- --------------------------------

-- 4 ------------------------------
CREATE MATERIALIZED VIEW SELLING_FOR_LAST_10_DAYS(ID, FIST_NAME, LAST_NAME, PRODUCT, "DATE", PRODUCT_TYPE, QUANTITY, TARE) AS
  SELECT
    SELLING.ID,
    SELLER.FIRST_NAME,
    SELLER.LAST_NAME,
    PRODUCT.NAME,
    SELLING.SELE_DATE,
    PRODUCT_TYPE.NAME,
    SELLING.QUANTITY,
    TARE.NAME
  FROM SELLING
    LEFT JOIN SELLER
      ON SELLING.SELLER_ID = SELLER.ID
    LEFT JOIN PRODUCT
      ON SELLING.PRODUCT_ID = PRODUCT.ID
    LEFT JOIN PRODUCT_TYPE
      ON PRODUCT.PRODUCT_TYPE_ID = PRODUCT_TYPE.ID
    LEFT JOIN TARE
      ON PRODUCT.TARE_ID = TARE.ID
  WHERE SELE_DATE > sysdate - 10;
-- --------------------------------

-- 5 ------------------------------
CREATE OR REPLACE TYPE CAR AS OBJECT
(
  power       INTEGER,
  engine_size NUMBER(3, 1),
  body_color  VARCHAR2(20),
  body_type   VARCHAR2(20),
  weight      INTEGER,
  gears       INTEGER,
  CONSTRUCTOR FUNCTION CAR(power INTEGER, engine_size NUMBER, body_color VARCHAR2, body_type VARCHAR2, weight INTEGER,
                           gears INTEGER) RETURN SELF AS RESULT,
  MEMBER FUNCTION specific_power RETURN FLOAT,
  ORDER MEMBER FUNCTION compare(car CAR) RETURN INTEGER
);

CREATE OR REPLACE TYPE BODY CAR AS
  CONSTRUCTOR FUNCTION CAR(power INTEGER, engine_size NUMBER, body_color VARCHAR2, body_type VARCHAR2, weight INTEGER,
                           gears INTEGER) RETURN SELF AS RESULT IS
    BEGIN
      SELF.power := power;
      SELF.engine_size := engine_size;
      SELF.body_color := body_color;
      SELF.body_type := body_type;
      SELF.weight := weight;
      SELF.gears := gears;
      RETURN;
    END;
  MEMBER FUNCTION specific_power RETURN FLOAT IS
    BEGIN
      RETURN SELF.power / SELF.weight;
    END;
  ORDER MEMBER FUNCTION compare(car CAR) RETURN INTEGER IS
    ps1 FLOAT := SELF.power / SELF.weight;
    ps2 FLOAT := car.power / car.weight;
    BEGIN
      IF ps1 > ps2 THEN
        RETURN 1;
      ELSIF ps1 < ps2 THEN
        RETURN -1;
      ELSE
        RETURN 0;
      END IF;
    END;
  END;

DECLARE
  c1 CAR;
  c2 CAR;
  r BOOLEAN;
BEGIN
  c1 := CAR(92, 1.6, 'red', 'sedan', 1006, 5);
  c2 := CAR(92, 1.6, 'red', 'sedan', 1220, 5);
  r := c1 > c2;
  IF r THEN
    DBMS_OUTPUT.put_line('true');
  ELSE
    DBMS_OUTPUT.put_line('false');
  END IF;
END;
-- --------------------------------

-- 6 ------------------------------
CREATE TYPE name_list IS TABLE OF VARCHAR2(60);
CREATE TYPE product_list IS TABLE OF VARCHAR2(40);
CREATE TYPE date_list IS TABLE OF DATE;
CREATE TYPE quantity_list IS TABLE OF NUMBER;
CREATE TYPE price_list IS TABLE OF NUMBER(18, 2);
CREATE TYPE total_list IS TABLE OF NUMBER(18, 2);

DECLARE
  names name_list;
  products product_list;
  dates date_list;
  quantities quantity_list;
  prices product_list;
  totals total_list;
BEGIN
  SELECT
    SELLER.FIRST_NAME,
    PRODUCT.NAME,
    SELLING.SELE_DATE,
    SELLING.QUANTITY,
    SELLING.PRICE,
    SELLING.PRICE * SELLING.QUANTITY
  BULK COLLECT
  INTO names, products, dates, quantities, prices, totals
  FROM SELLING
    LEFT JOIN SELLER
      ON SELLING.SELLER_ID = SELLER.ID
    LEFT JOIN PRODUCT
      ON SELLING.PRODUCT_ID = PRODUCT.ID
    LEFT JOIN PRODUCT_TYPE
      ON PRODUCT.PRODUCT_TYPE_ID = PRODUCT_TYPE.ID
  WHERE SELE_DATE > add_months(sysdate, -1);

  FOR i IN 1 .. names.COUNT
  LOOP
    DBMS_OUTPUT.put_line(names(i) || ' ' || products(i) || ' ' || dates(i) || ' ' || quantities(i) || ' ' || prices(i) || ' ' || totals(i));
  END LOOP;
END;
-- --------------------------------

-- 7 ------------------------------
DECLARE
  CURSOR sellers_cursor IS SELECT SELLER.*, ROWID FROM SELLER;

  TYPE seller_list IS TABLE OF sellers_cursor%ROWTYPE INDEX BY BINARY_INTEGER;
  sellers seller_list;
  counter INTEGER := 0;
BEGIN
  FOR i IN sellers_cursor LOOP
    counter := counter + 1;
    sellers(counter) := i;
    DBMS_OUTPUT.put_line(sellers(counter).FIRST_NAME || ' ' || sellers(counter).LAST_NAME || ' ' || sellers(counter).ROWID);
  END LOOP;
END;
-- --------------------------------