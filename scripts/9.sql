-- 1 ------------------------------
-- index types:
-- heap index - неупорядоченный
-- bitmap indexes - не для частого обновления
-- heap index revers
-- compress
-- function based
-- section

-- create table
CREATE TABLE heap_index_table(
  ID NUMBER GENERATED ALWAYS AS IDENTITY,
  NAME VARCHAR2(20),
  SOME_DATE DATE,
  TEXT VARCHAR2(2000),
  CONSTRAINT heap_index_table_pk PRIMARY KEY (ID)
);

BEGIN
  FOR i in 1..100000 LOOP
    DBMS_OUTPUT.PUT_LINE(i);
    INSERT INTO heap_index_table (NAME, SOME_DATE, TEXT)
    VALUES (
      (select dbms_random.string('A', 20) str from dual),
      (
        SELECT TO_DATE(
          TRUNC(
            DBMS_RANDOM.VALUE(
              TO_CHAR(DATE '2014-01-01','J'),
              TO_CHAR(DATE '2020-01-01','J')
            )
          ),'J'
        ) FROM DUAL
      ),
      (select dbms_random.string('A', 2000) str from dual)
    );
  END LOOP;
END;

CREATE TABLE text_table(
  ID NUMBER GENERATED ALWAYS AS IDENTITY,
  TEXT VARCHAR2(2000),
  CONSTRAINT text_table_pk PRIMARY KEY (ID)
);

INSERT INTO text_table (TEXT)
VALUES (
'Я памятник себе воздвиг нерукотворный,
К нему не зарастет народная тропа,
Вознесся выше он главою непокорной
Александрийского столпа.
Нет, весь я не умру — душа в заветной лире
Мой прах переживет и тленья убежит —
И славен буду я, доколь в подлунном мире
Жив будет хоть один пиит.

Слух обо мне пойдет по всей Руси великой,
И назовет меня всяк сущий в ней язык,
И гордый внук славян, и финн, и ныне дикой
Тунгус, и друг степей калмык.

И долго буду тем любезен я народу,
Что чувства добрые я лирой пробуждал,
Что в мой жестокий век восславил я свободу
И милость к падшим призывал.

Веленью божию, о муза, будь послушна;
Обиды не страшась, не требуя венца,
Хвалу и клевету приемли равнодушно
И не оспоривай глупца.'
);

INSERT INTO text_table (TEXT)
VALUES (
'Сижу за решеткой в темнице сырой.
Вскормленный в неволе орел молодой,
Мой грустный товарищ, махая крылом,
Кровавую пищу клюет под окном,
Клюет, и бросает, и смотрит в окно,
Как будто со мною задумал одно.
Зовет меня взглядом и криком своим
И вымолвить хочет: «Давай, улетим!

Мы вольные птицы; пора, брат, пора!
Туда, где за тучей белеет гора,
Туда, где синеют морские края,
Туда, где гуляем лишь ветер... да я!..'
);

-- create index
CREATE INDEX hit_date_index ON heap_index_table(SOME_DATE);

BEGIN
  ctx_ddl.create_preference('tt_wordlist', 'BASIC_WORDLIST');
  ctx_ddl.create_preference('tt_lexer', 'AUTO_LEXER');
  ctx_ddl.set_attribute('tt_lexer', 'INDEX_STEMS','YES');
END;
CREATE INDEX tt_text_index ON text_table(TEXT)
INDEXTYPE IS ctxsys.context PARAMETERS ('LEXER tt_lexer WORDLIST tt_wordlist');

-- check hit_date_index
ALTER INDEX hit_date_index MONITORING USAGE;

SELECT *
FROM heap_index_table
WHERE SOME_DATE = to_date('2017-09-01', 'yyyy-mm-dd');

SELECT *
FROM heap_index_table
WHERE SOME_DATE = to_date('2016-09-01', 'yyyy-mm-dd');

SELECT *
FROM heap_index_table
WHERE SOME_DATE = to_date('2017-11-07', 'yyyy-mm-dd');

ALTER INDEX hit_date_index NOMONITORING USAGE;

SELECT index_name, used FROM v$object_usage
WHERE index_name = 'HIT_DATE_INDEX';

ALTER INDEX hit_date_index UNUSABLE;

EXPLAIN PLAN FOR
SELECT *
FROM heap_index_table
WHERE SOME_DATE = to_date('2017-11-06', 'yyyy-mm-dd');
SELECT * FROM TABLE (DBMS_XPLAN.DISPLAY);

-- check hit_text_index
SELECT * FROM text_table WHERE contains(TEXT, 'решетка') > 0;
-- --------------------------------

-- 2 ------------------------------
-- hints INDEX_DESC, INDEX_COMBINE, ORDERED, ROWID, FULL, CACHE, NOCACHE
CREATE INDEX product_name ON PRODUCT(NAME);


ALTER INDEX product_name MONITORING USAGE;

SELECT NAME AS PRODUCT_NAME_OF_TOP_3
FROM
  (
    SELECT /*+ INDEX(PRODUCT, PRODUCT_NAME) */
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

ALTER INDEX product_name NOMONITORING USAGE;

SELECT index_name, used FROM v$object_usage
WHERE index_name = 'PRODUCT_NAME';
-- --------------------------------


