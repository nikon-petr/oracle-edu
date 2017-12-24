-- 1 ------------------------------
CREATE OR REPLACE TRIGGER ununique_product_name_alert
  BEFORE
    INSERT
  ON PRODUCT FOR EACH ROW
DECLARE
  name_count NUMBER;
BEGIN
  SELECT count(NAME) INTO name_count FROM PRODUCT WHERE :NEW.NAME = NAME;
  IF name_count > 0 THEN
    DBMS_OUTPUT.put_line('ALERT: product with name ' || :NEW.NAME || 'elready exists');
  END IF;
END;

INSERT INTO product (name, price, receipt_date, expiration_date, quantity_in_stock, tare_id, product_type_id)
VALUES ('apples', 80.00, to_date('1-9-2017', 'dd-mm-yyyy'), to_date('1-12-2017', 'dd-mm-yyyy'), 280, NULL, 1);

select *
from
   user_errors
where
   type = 'TRIGGER'
and
   name = 'UNUNIQUE_PRODUCT_NAME_ALERT';
-- --------------------------------

-- 2 ------------------------------
CREATE TABLE log_table(
  ID NUMBER GENERATED ALWAYS AS IDENTITY,
  SUBJECT VARCHAR2(50) NOT NULL ,
  LOG_DATE DATE NOT NULL ,
  OBJECT_NAME VARCHAR2(50) NOT NULL ,
  OBJECT_TYPE VARCHAR2(50) NOT NULL ,
  CONSTRAINT log_table_pk PRIMARY KEY (ID)
);

CREATE TABLE delete_test_table(
  id NUMBER GENERATED ALWAYS AS IDENTITY
);

CREATE OR REPLACE TRIGGER delete_log
  AFTER DROP
ON SCHEMA
BEGIN
  INSERT INTO log_table (SUBJECT, LOG_DATE, OBJECT_NAME, OBJECT_TYPE)
  VALUES (ora_login_user, sysdate, ora_dict_obj_name, ora_dict_obj_type);
END;

DROP TABLE delete_test_table;
SELECT * FROM log_table;
-- --------------------------------

-- 3 ------------------------------
CREATE OR REPLACE PACKAGE cursor_package IS
  CURSOR some_cursor IS SELECT NAME FROM PRODUCT;
  PROCEDURE open_some_cursor;
  PROCEDURE extract_some_cursor;
END cursor_package;

CREATE OR REPLACE PACKAGE BODY cursor_package IS

  PROCEDURE open_some_cursor AS
    BEGIN
      OPEN some_cursor;
    END open_some_cursor;

  PROCEDURE extract_some_cursor AS
      product_name PRODUCT.NAME%TYPE;
      some_cursor_is_not_open EXCEPTION;
    BEGIN
      IF NOT some_cursor%ISOPEN THEN
        RAISE some_cursor_is_not_open;
      END IF;
      LOOP
        FETCH some_cursor INTO product_name;
        EXIT WHEN some_cursor%NOTFOUND;

        DBMS_OUTPUT.put_line(product_name);
      END LOOP;
      CLOSE some_cursor;
    END extract_some_cursor;

END cursor_package;

BEGIN
  cursor_package.EXTRACT_SOME_CURSOR();
END;

BEGIN
  cursor_package.OPEN_SOME_CURSOR();
  cursor_package.EXTRACT_SOME_CURSOR();
END;
-- --------------------------------
