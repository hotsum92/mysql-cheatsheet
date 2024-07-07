
-- 重複したクエリが２回発生

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

-- EXPLAIN
-- -> Append  (cost=2.9 rows=8) (actual time=0.0348..0.0566 rows=12 loops=1)
--     -> Stream results  (cost=1.45 rows=4) (actual time=0.0339..0.0427 rows=6 loops=1)
--         -> Filter: (Items.`year` <= 2001)  (cost=1.45 rows=4) (actual time=0.0313..0.0388 rows=6 loops=1)
--             -> Table scan on Items  (cost=1.45 rows=12) (actual time=0.0293..0.0351 rows=12 loops=1)
--     -> Stream results  (cost=1.45 rows=4) (actual time=0.00782..0.0112 rows=6 loops=1)
--         -> Filter: (Items.`year` >= 2002)  (cost=1.45 rows=4) (actual time=0.00711..0.00976 rows=6 loops=1)
--             -> Table scan on Items  (cost=1.45 rows=12) (actual time=0.00592..0.00808 rows=12 loops=1)

SELECT item_name, year, price_tax_ex, price_tax_in
  FROM Items
 WHERE year <= 2001 OR year >= 2002;

-- id  select_type  table  partitions  type  possible_keys  key  key_len  ref  rows  filtered  Extra
-- --  -----------  -----  ----------  ----  -------------  ---  -------  ---  ----  --------  -----------
--  1  SIMPLE       Items              ALL                                       12     55.55  Using where

-- EXPLAIN
-- -> Filter: ((Items.`year` <= 2001) or (Items.`year` >= 2002))  (cost=1.45 rows=6.67) (actual time=0.0333..0.041 rows=12 loops=1)
--     -> Table scan on Items  (cost=1.45 rows=12) (actual time=0.031..0.0367 rows=12 loops=1)

-- CASEで一回にまとめる

SELECT item_name, year,
       CASE WHEN year <= 2001 THEN price_tax_ex
            WHEN year >= 2002 THEN price_tax_in END AS price
  FROM Items;

-- id  select_type  table  partitions  type  possible_keys  key  key_len  ref  rows  filtered  Extra
-- --  -----------  -----  ----------  ----  -------------  ---  -------  ---  ----  --------  -----
--  1  SIMPLE       Items              ALL                                       12       100

-- EXPLAIN
-- -> Table scan on Items  (cost=1.45 rows=12) (actual time=0.0329..0.0389 rows=12 loops=1)


-- サブクエストでの重複したクエリが２回発生

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

-- CASEで一回にまとめる

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
