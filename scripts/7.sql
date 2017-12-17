-- 1-2 ----------------------------
-- default transaction type - read write
-- transaction types: read only, read write
-- transaction isolation levels: serializable, read committed
BEGIN
  COMMIT;

  UPDATE PRODUCT
  SET TARE_ID = 4
  WHERE ID = 3;

  SAVEPOINT first_save;

  INSERT INTO PRODUCT
    (ID, NAME, PRICE, RECEIPT_DATE, EXPIRATION_DATE, QUANTITY_IN_STOCK, TARE_ID, PRODUCT_TYPE_ID)
  VALUES
    (3, 'potato', 24.7, to_date('1-2-2017', 'dd-mm-yyyy'), to_date('1-10-2017', 'dd-mm-yyyy'), 35, 5, 2);

  UPDATE PRODUCT
  SET TARE_ID = 4
  WHERE ID = 3;

  EXCEPTION WHEN OTHERS
  THEN
  ROLLBACK TO first_save;
  DBMS_OUTPUT.PUT_LINE('Update rolled back');
  COMMIT;
END;
-- --------------------------------

-- 3-4 ----------------------------
ALTER TABLE PRODUCT DROP CONSTRAINT TARE_ID_FK;
ALTER TABLE PRODUCT ADD CONSTRAINT TARE_ID_FK FOREIGN KEY (TARE_ID) REFERENCES TARE(ID) INITIALLY DEFERRED;
COMMIT;

SET TRANSACTION NAME 'tare_update';

SET CONSTRAINT TARE_ID_FK DEFERRED;

UPDATE PRODUCT
SET TARE_ID = 5
WHERE ID = 3;

UPDATE PRODUCT
SET TARE_ID = 100
WHERE ID = 3;

UPDATE PRODUCT
SET TARE_ID = 4
WHERE ID = 3;

COMMIT;
-- --------------------------------

-- 5 ------------------------------

-- default read committed
-- read committed level
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET TRANSACTION NAME 'updater';

UPDATE PRODUCT
SET QUANTITY_IN_STOCK = 1000000
WHERE ID = 3;

ROLLBACK;

-- non-repeatable read
SET TRANSACTION NAME 'updater';

UPDATE PRODUCT
SET QUANTITY_IN_STOCK = 1000000
WHERE ID = 3;

COMMIT;

-- phantom read
SET TRANSACTION NAME 'inserter';

INSERT INTO PRODUCT
  (NAME, PRICE, RECEIPT_DATE, EXPIRATION_DATE, QUANTITY_IN_STOCK, TARE_ID, PRODUCT_TYPE_ID)
VALUES
  ('rice', 28.03, sysdate, to_date('1-9-2020', 'dd-mm-yyyy'), 4000, 3, NULL);

COMMIT;
-- --------------------------------

-- 6 ------------------------------
-- serialization error
-- 1 transaction
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

UPDATE PRODUCT
SET QUANTITY_IN_STOCK = 2
WHERE ID = 3;

COMMIT;

-- 2 transaction
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

UPDATE PRODUCT
SET QUANTITY_IN_STOCK = 1
WHERE ID = 3;

COMMIT;
-- --------------------------------

-- 7 ------------------------------
-- default read write (not supported for the user SYS)
BEGIN
  COMMIT;
  SET TRANSACTION READ ONLY;

  UPDATE PRODUCT
  SET QUANTITY_IN_STOCK = 10
  WHERE ID = 3;

  COMMIT;
END;
-- --------------------------------


