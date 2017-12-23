-- 1 ------------------------------
CREATE OR REPLACE FUNCTION salling_for_last_month(s IN NUMBER)
  RETURN NUMBER IS

  selling_sum NUMBER(18, 2);

  BEGIN
    SELECT sum(PRICE * QUANTITY)
    INTO selling_sum
    FROM SELLING
    WHERE SELLER_ID = s;

    IF SQL%NOTFOUND THEN
      selling_sum := 0;
    END IF;

    RETURN selling_sum;
  END;

BEGIN
  dbms_output.put_line(salling_for_last_month(2));
END;
-- --------------------------------

-- 2 ------------------------------
CREATE OR REPLACE FUNCTION get_categories_cursor
  RETURN SYS_REFCURSOR IS
  pt_cur SYS_REFCURSOR;
  BEGIN
    OPEN pt_cur FOR SELECT
                      PRODUCT_TYPE.ID,
                      PRODUCT_TYPE.NAME,
                      CURSOR (SELECT PRODUCT.NAME
                              FROM PRODUCT
                              WHERE PRODUCT_TYPE.ID = PRODUCT.PRODUCT_TYPE_ID)
                    FROM PRODUCT_TYPE;
    RETURN pt_cur;
  END;

DECLARE
  pt_cur SYS_REFCURSOR := get_categories_cursor();

  TYPE REFCURSOR IS REF CURSOR;

  pt_id   PRODUCT_TYPE.ID%TYPE;
  pt_name PRODUCT_TYPE.NAME%TYPE;

  pr_cur  REFCURSOR;
  pr_name PRODUCT.NAME%TYPE;
BEGIN
  LOOP
    FETCH pt_cur INTO pt_id, pt_name, pr_cur;
    EXIT WHEN pt_cur%NOTFOUND;

    dbms_output.put_line(pt_name);

    LOOP
      FETCH pr_cur INTO pr_name;
      EXIT WHEN pr_cur%NOTFOUND;

      dbms_output.put_line('~~~ ' || pr_name);

    END LOOP;
  END LOOP;
  CLOSE pt_cur;
END;
-- --------------------------------

-- 3 ------------------------------
INSERT INTO SELLING
  (SELLER_ID, PRODUCT_ID, SELE_DATE, QUANTITY, PRICE)
VALUES
  (8, 7, add_months(sysdate, -24), 2, 2.03);

CREATE OR REPLACE PROCEDURE delete_selling_before(before_date IN DATE)
  AS
  BEGIN
    DELETE SELLING
    WHERE SELLING.ID IN (SELECT SELLING.ID FROM SELLING WHERE SELE_DATE < before_date);

    IF SQL%ROWCOUNT = 0 THEN
      dbms_output.put_line('0 rows deleted');
    END IF;
  END;

BEGIN
  delete_selling_before(to_date('1-1-2016', 'dd-mm-yyyy'));
END;
-- --------------------------------