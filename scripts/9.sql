-- index types:
-- heap index - неупорядоченный
-- bitmap indexes - не для частого обновления
-- heap index revers
-- compress
-- function based
-- section
-- 1 ------------------------------
CREATE INDEX salling_quantity_price ON SELLING(QUANTITY, PRICE);
CREATE INDEX salling_date ON SELLING(SELE_DATE);
CREATE INDEX product_name ON PRODUCT(NAME);

ALTER INDEX product_name MONITORING USAGE;

SELECT PRODUCT_TYPE.NAME AS PRODUCT_TYPE_NAME

FROM PRODUCT_TYPE
INNER JOIN PRODUCT
ON PRODUCT_TYPE.ID = PRODUCT.PRODUCT_TYPE_ID
GROUP BY PRODUCT_TYPE.NAME;

ALTER INDEX product_name NOMONITORING USAGE;

SELECT index_name, used FROM v$object_usage
WHERE index_name = 'product_name';

ALTER INDEX salling_quantity_price REBUILD;
-- --------------------------------

-- hints INDEX_DESC, INDEX_COMBINE, ORDERED, ROWID, FULL, CACHE, NOCACHE
-- 2 ------------------------------

BEGIN
  FOR i in 1..500000 LOOP

  END LOOP;
END;
INSERT INTO product (name, price, receipt_date, expiration_date, quantity_in_stock, tare_id, product_type_id)
VALUES ('apples', 37.20, to_date('1-9-2017', 'dd-mm-yyyy'), to_date('01-12-2017', 'dd-mm-yyyy'), 500, 4, 7);

SELECT NAME AS PRODUCT_NAME_OF_TOP_3
FROM
(
  SELECT /* INDEX(PRODUCT, PRODUCT_NAME) */
  PRODUCT.NAME,
  count(PRODUCT.NAME)
  FROM SELLING
    INNER JOIN PRODUCT
      ON SELLING.PRODUCT_ID = PRODUCT.ID
  WHERE SELE_DATE BETWEEN add_months(sysdate, -1) AND sysdate
  GROUP BY PRODUCT.NAME
  ORDER BY count(PRODUCT.NAME) DESC
)
WHERE ROWNUM <= 3;

SELECT /* INDEX(SELLING, SALLING_DATE) */
  nvl(PRODUCT_TYPE.NAME, 'All Types')                                AS PRODUCT_TYPE_NAME,
  nvl((SELLER.FIRST_NAME || ' ' || SELLER.LAST_NAME), 'All Sellers') AS SELLER_NAME,
  sum(SELLING.PRICE * SELLING.QUANTITY)                              AS AMOUNT
FROM PRODUCT_TYPE
  INNER JOIN PRODUCT
    ON PRODUCT_TYPE.ID = PRODUCT.PRODUCT_TYPE_ID
  INNER JOIN SELLING
    ON PRODUCT.ID = SELLING.PRODUCT_ID
  INNER JOIN SELLER
    ON SELLING.SELLER_ID = SELLER.ID
WHERE SELLING.SELE_DATE BETWEEN add_months(sysdate, -1) AND sysdate
GROUP BY ROLLUP (PRODUCT_TYPE.NAME, (SELLER.FIRST_NAME || ' ' || SELLER.LAST_NAME))
ORDER BY PRODUCT_TYPE.NAME, (SELLER.FIRST_NAME || ' ' || SELLER.LAST_NAME);
-- --------------------------------


