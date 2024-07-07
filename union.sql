-- ## UNION ALL

EXPLAIN
SELECT item_name, year, price_tax_ex AS price
  FROM Items
 WHERE year <= 2001
UNION ALL
SELECT item_name, year, price_tax_in AS price
  FROM Items
 WHERE year >= 2002;

-- id  select_type  table  partitions  type  possible_keys  key  key_len  ref  rows  filtered  Extra
-- --  -----------  -----  ----------  ----  -------------  ---  -------  ---  ----  --------  -----------
--  1  PRIMARY      Items              ALL                                       12     33.33  Using where
--  2  UNION        Items              ALL                                       12     33.33  Using where

EXPLAIN ANALYZE
SELECT item_name, year, price_tax_ex AS price
  FROM Items
 WHERE year <= 2001
UNION ALL
SELECT item_name, year, price_tax_in AS price
  FROM Items
 WHERE year >= 2002;

-- EXPLAIN
-- -> Append  (cost=2.9 rows=8) (actual time=0.0348..0.0566 rows=12 loops=1)
--     -> Stream results  (cost=1.45 rows=4) (actual time=0.0339..0.0427 rows=6 loops=1)
--         -> Filter: (Items.`year` <= 2001)  (cost=1.45 rows=4) (actual time=0.0313..0.0388 rows=6 loops=1)
--             -> Table scan on Items  (cost=1.45 rows=12) (actual time=0.0293..0.0351 rows=12 loops=1)
--     -> Stream results  (cost=1.45 rows=4) (actual time=0.00782..0.0112 rows=6 loops=1)
--         -> Filter: (Items.`year` >= 2002)  (cost=1.45 rows=4) (actual time=0.00711..0.00976 rows=6 loops=1)
--             -> Table scan on Items  (cost=1.45 rows=12) (actual time=0.00592..0.00808 rows=12 loops=1)

EXPLAIN
SELECT item_name, year, price_tax_ex, price_tax_in
  FROM Items
 WHERE year <= 2001 OR year >= 2002;

-- id  select_type  table  partitions  type  possible_keys  key  key_len  ref  rows  filtered  Extra
-- --  -----------  -----  ----------  ----  -------------  ---  -------  ---  ----  --------  -----------
--  1  SIMPLE       Items              ALL                                       12     55.55  Using where

EXPLAIN ANALYZE
SELECT item_name, year, price_tax_ex, price_tax_in
  FROM Items
 WHERE year <= 2001 OR year >= 2002;

-- EXPLAIN
-- -> Filter: ((Items.`year` <= 2001) or (Items.`year` >= 2002))  (cost=1.45 rows=6.67) (actual time=0.0333..0.041 rows=12 loops=1)
--     -> Table scan on Items  (cost=1.45 rows=12) (actual time=0.031..0.0367 rows=12 loops=1)

EXPLAIN
SELECT item_name, year,
       CASE WHEN year <= 2001 THEN price_tax_ex
            WHEN year >= 2002 THEN price_tax_in END AS price
  FROM Items;

-- id  select_type  table  partitions  type  possible_keys  key  key_len  ref  rows  filtered  Extra
-- --  -----------  -----  ----------  ----  -------------  ---  -------  ---  ----  --------  -----
--  1  SIMPLE       Items              ALL                                       12       100

EXPLAIN ANALYZE
SELECT item_name, year,
       CASE WHEN year <= 2001 THEN price_tax_ex
            WHEN year >= 2002 THEN price_tax_in END AS price
  FROM Items;

-- EXPLAIN
-- -> Table scan on Items  (cost=1.45 rows=12) (actual time=0.0329..0.0389 rows=12 loops=1)

-- ## UNION with GROUP BY

SELECT prefecture, SUM(pop_men) AS pop_men, SUM(pop_wom) AS pop_wom
  FROM ( SELECT prefecture, pop AS pop_men, null AS pop_wom
           FROM Population
          -- 男性
          WHERE sex = '1'
         UNION
         SELECT prefecture, NULL AS pop_men, pop AS pop_wom
           FROM Population
          -- 女性
          WHERE sex = '2') TMP
 GROUP BY prefecture;

-- id  select_type   table       partitions  type  possible_keys  key  key_len  ref  rows  filtered  Extra
-- --  ------------  ----------  ----------  ----  -------------  ---  -------  ---  ----  --------  ---------------
--  1  PRIMARY       <derived2>              ALL                                        4       100  Using temporary
--  2  DERIVED       Population              ALL                                       10        10  Using where
--  3  UNION         Population              ALL                                       10        10  Using where
--  4  UNION RESULT  <union2,3>              ALL                                                     Using temporary

-- EXPLAIN
-- -> Table scan on <temporary>  (actual time=0.106..0.107 rows=5 loops=1)
--     -> Aggregate using temporary table  (actual time=0.106..0.106 rows=5 loops=1)
--         -> Table scan on TMP  (cost=4.22..5.49 rows=2) (actual time=0.0789..0.0811 rows=10 loops=1)
--             -> Union materialize with deduplication  (cost=2.96..2.96 rows=2) (actual time=0.0775..0.0775 rows=10 loops=1)
--                 -> Filter: (Population.sex = '1')  (cost=1.25 rows=1) (actual time=0.0332..0.0415 rows=5 loops=1)
--                     -> Table scan on Population  (cost=1.25 rows=10) (actual time=0.0303..0.0363 rows=10 loops=1)
--                 -> Filter: (Population.sex = '2')  (cost=1.25 rows=1) (actual time=0.00612..0.00896 rows=5 loops=1)
--                     -> Table scan on Population  (cost=1.25 rows=10) (actual time=0.00535..0.00746 rows=10 loops=1)

EXPLAIN ANALYZE
SELECT prefecture,
       SUM(CASE WHEN sex = '1' THEN pop ELSE 0 END) AS pop_men,
       SUM(CASE WHEN sex = '2' THEN pop ELSE 0 END) AS pop_wom
  FROM Population
 GROUP BY prefecture;

-- id  select_type  table       partitions  type   possible_keys  key      key_len  ref  rows  filtered  Extra
-- --  -----------  ----------  ----------  -----  -------------  -------  -------  ---  ----  --------  -----
--  1  SIMPLE       Population              index  PRIMARY        PRIMARY  134             10       100  

--EXPLAIN
---> Group aggregate: sum((case when (Population.sex = '1') then Population.pop else 0 end)), sum((case when (Population.sex = '2') then Population.pop else 0 end))  (cost=3.55 rows=3.16) (actual time=0.0412..0.0497 rows=5 loops=1)
--    -> Index scan on Population using PRIMARY  (cost=1.25 rows=10) (actual time=0.0275..0.0334 rows=10 loops=1)

-- ## UNION with HAING

SELECT emp_name,
       MAX(team) AS team
  FROM Employees 
 GROUP BY emp_name
HAVING COUNT(*) = 1
UNION
SELECT emp_name,
       '2つを兼務' AS team
  FROM Employees 
 GROUP BY emp_name
HAVING COUNT(*) = 2
UNION
SELECT emp_name,
       '3つ以上を兼務' AS team
  FROM Employees 
 GROUP BY emp_name
HAVING COUNT(*) >= 3;

-- id  select_type   table         partitions  type  possible_keys  key  key_len  ref  rows  filtered  Extra
-- --  ------------  ------------  ----------  ----  -------------  ---  -------  ---  ----  --------  ---------------
--  1  PRIMARY       Employees                 ALL                                       11       100  Using temporary
--  2  UNION         Employees                 ALL                                       11       100  Using temporary
--  3  UNION         Employees                 ALL                                       11       100  Using temporary
--  4  UNION RESULT  <union1,2,3>              ALL                                                     Using temporary

-- EXPLAIN
-- -> Table scan on <union temporary>  (cost=2.5..2.5 rows=0) (actual time=0.287..0.288 rows=5 loops=1)
--     -> Union materialize with deduplication  (cost=0..0 rows=0) (actual time=0.286..0.286 rows=5 loops=1)
--         -> Filter: (`count(0)` = 1)  (actual time=0.139..0.14 rows=2 loops=1)
--             -> Table scan on <temporary>  (actual time=0.0987..0.103 rows=5 loops=1)
--                 -> Aggregate using temporary table  (actual time=0.0977..0.0977 rows=5 loops=1)
--                     -> Table scan on Employees  (cost=1.35 rows=11) (actual time=0.0384..0.0466 rows=11 loops=1)
--         -> Filter: (`count(0)` = 2)  (actual time=0.0916..0.0918 rows=1 loops=1)
--             -> Table scan on <temporary>  (actual time=0.0892..0.09 rows=5 loops=1)
--                 -> Aggregate using temporary table  (actual time=0.088..0.088 rows=5 loops=1)
--                     -> Table scan on Employees  (cost=1.35 rows=11) (actual time=0.0442..0.051 rows=11 loops=1)
--         -> Filter: (`count(0)` >= 3)  (actual time=0.0237..0.0249 rows=2 loops=1)
--             -> Table scan on <temporary>  (actual time=0.0229..0.0237 rows=5 loops=1)
--                 -> Aggregate using temporary table  (actual time=0.0226..0.0226 rows=5 loops=1)
--                     -> Table scan on Employees  (cost=1.35 rows=11) (actual time=0.00595..0.0082 rows=11 loops=1)


SELECT emp_name,
       CASE WHEN COUNT(*) = 1 THEN MAX(team)
            WHEN COUNT(*) = 2 THEN '2つを兼務'
            WHEN COUNT(*) >= 3 THEN '3つ以上を兼務'
        END AS team
  FROM Employees
 GROUP BY emp_name;

-- id  select_type  table      partitions  type  possible_keys  key  key_len  ref  rows  filtered  Extra
-- --  -----------  ---------  ----------  ----  -------------  ---  -------  ---  ----  --------  ---------------
--  1  SIMPLE       Employees              ALL                                       11       100  Using temporary

-- EXPLAIN
-- -> Table scan on <temporary>  (actual time=0.0767..0.0778 rows=5 loops=1)
--     -> Aggregate using temporary table  (actual time=0.0757..0.0757 rows=5 loops=1)
--         -> Table scan on Employees  (cost=1.35 rows=11) (actual time=0.0296..0.0358 rows=11 loops=1)

-- ## group by in subquery

SELECT Shops.shop_name, COUNT(*) AS num
  FROM Shops INNER JOIN Reservations
    ON Shops.shop_id = Reservations.shop_id
  GROUP BY Shops.shop_name;

-- id  select_type  table         partitions  type    possible_keys  key      key_len  ref                        rows  filtered  Extra
-- --  -----------  ------------  ----------  ------  -------------  -------  -------  -------------------------  ----  --------  ----------------------------
--  1  SIMPLE       Reservations              ALL                                                                   10       100  Using where; Using temporary
--  1  SIMPLE       Shops                     eq_ref  PRIMARY        PRIMARY  20       test.Reservations.shop_id     1       100  

SELECT shop_name, num
  FROM (SELECT shop_name, COUNT(*) AS num
          FROM Shops INNER JOIN Reservations
            ON Shops.shop_id = Reservations.shop_id
          GROUP BY Shops.shop_name) AS TMP;

-- id  select_type  table         partitions  type    possible_keys  key      key_len  ref                        rows  filtered  Extra
-- --  -----------  ------------  ----------  ------  -------------  -------  -------  -------------------------  ----  --------  ----------------------------
--  1  PRIMARY      <derived2>                ALL                                                                   10       100  
--  2  DERIVED      Reservations              ALL                                                                   10       100  Using where; Using temporary
--  2  DERIVED      Shops                     eq_ref  PRIMARY        PRIMARY  20       test.Reservations.shop_id     1       100  

