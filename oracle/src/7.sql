-- 1-2 ----------------------------
-- default transaction type - read write
-- transaction types: read only, read write
-- transaction isolation levels: serializable, read committed
SET TRANSACTION NAME 'tare_update';

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

-- 3-4 ----------------------------
ALTER TABLE PRODUCT DROP CONSTRAINT TARE_ID_FK;
ALTER TABLE PRODUCT ADD CONSTRAINT TARE_ID_FK FOREIGN KEY (TARE_ID) REFERENCES TARE(ID) INITIALLY IMMEDIATE;

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

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- serializable level
SET TRANSACTION NAME 'updater';

UPDATE PRODUCT
SET QUANTITY_IN_STOCK = 1
WHERE ID = 3;

COMMIT;

SET TRANSACTION NAME 'inserter';

INSERT INTO PRODUCT
  (NAME, PRICE, RECEIPT_DATE, EXPIRATION_DATE, QUANTITY_IN_STOCK, TARE_ID, PRODUCT_TYPE_ID)
VALUES
  ('rice', 28.03, sysdate, to_date('1-9-2020', 'dd-mm-yyyy'), 4000, 3, NULL);

COMMIT;
-- --------------------------------

-- 7 ------------------------------
-- default read write (not supported for the user SYS)
SET TRANSACTION READ ONLY NAME 'read_only_transaction';

UPDATE PRODUCT
SET QUANTITY_IN_STOCK = 1
WHERE ID = 3;

DELETE PRODUCT
WHERE ID = 24;

COMMIT;
-- --------------------------------


