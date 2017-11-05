-- 1 ------------------------------
DECLARE
  to_search PRODUCT_TYPE.NAME%TYPE := 'sweets';
  to_update PRODUCT_TYPE.NAME%TYPE := 'Sweets';
BEGIN

  UPDATE PRODUCT_TYPE
  SET NAME = to_update
  WHERE lower(NAME) = to_search;

  IF SQL%ROWCOUNT = 1 THEN
    DBMS_OUTPUT.put_line('UPDATE');
  ELSIF SQL%NOTFOUND THEN
    DBMS_OUTPUT.put_line('INSERT');
    INSERT INTO PRODUCT_TYPE (NAME)
    VALUES (to_update);
  ELSE
    DBMS_OUTPUT.put_line('ROLLBACK');
    ROLLBACK;
  END IF;
  COMMIT;
END;
-- --------------------------------

-- 2 ------------------------------
BEGIN
  FOR i IN (SELECT PRODUCT_TYPE.ID, PRODUCT_TYPE.NAME FROM PRODUCT_TYPE INNER JOIN PRODUCT ON PRODUCT_TYPE.ID = PRODUCT.PRODUCT_TYPE_ID) LOOP
    DBMS_OUTPUT.put_line(i.NAME);
    FOR j IN (SELECT PRODUCT.NAME FROM PRODUCT WHERE PRODUCT_TYPE_ID = i.ID) LOOP
      DBMS_OUTPUT.put_line('~~~~ ' || j.NAME);
    END LOOP;
  END LOOP;
END;