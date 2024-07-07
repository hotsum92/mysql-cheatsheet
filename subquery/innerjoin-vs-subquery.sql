-- 結合する場合は、それぞれの行数が多いとパフォーマンスが落ちることを考慮する
-- 内部表より駆動表のほうが行数が少ないほうが良い。
-- 内部表は、インデックスでループをスキップできる
-- インデックスがない場合は、どちらが大きい場合もあまり関係ない

-- 先に結合してから集計する

SELECT C.co_cd, C.district,
       SUM(emp_nbr) AS sum_emp
  FROM Companies C
         INNER JOIN
           Shops S
    ON C.co_cd = S.co_cd
 WHERE main_flg = 'Y'
 GROUP BY C.co_cd;

-- id  select_type  table  partitions  type    possible_keys  key      key_len  ref           rows  filtered  Extra
-- --  -----------  -----  ----------  ------  -------------  -------  -------  ------------  ----  --------  ----------------------------
--  1  SIMPLE       S                  ALL     PRIMARY                                          10        10  Using where; Using temporary
--  1  SIMPLE       C                  eq_ref  PRIMARY        PRIMARY  12       test.S.co_cd     1       100  

-- 1 rows 7 loops

-- EXPLAIN
-- -> Table scan on <temporary>  (actual time=0.11..0.111 rows=4 loops=1)
--     -> Aggregate using temporary table  (actual time=0.109..0.109 rows=4 loops=1)
--         -> Nested loop inner join  (cost=1.6 rows=1) (actual time=0.0562..0.0741 rows=7 loops=1)
--             -> Filter: (S.main_flg = 'Y')  (cost=1.25 rows=1) (actual time=0.0378..0.0461 rows=7 loops=1)
--                 -> Table scan on S  (cost=1.25 rows=10) (actual time=0.0348..0.0407 rows=10 loops=1)
--             -> Single-row index lookup on C using PRIMARY (co_cd=S.co_cd)  (cost=0.35 rows=1) (actual time=0.00327..0.00333 rows=1 loops=7)

-- 集約してから結合する

SELECT C.co_cd, C.district, sum_emp
  FROM Companies C
         INNER JOIN
          (SELECT co_cd,
                  SUM(emp_nbr) AS sum_emp
             FROM Shops
            WHERE main_flg = 'Y'
            GROUP BY co_cd) CSUM
    ON C.co_cd = CSUM.co_cd;


-- id  select_type  table       partitions  type    possible_keys  key      key_len  ref         rows  filtered  Extra
-- --  -----------  ----------  ----------  ------  -------------  -------  -------  ----------  ----  --------  -----------
--  1  PRIMARY      <derived2>              ALL                                                     2       100  
--  1  PRIMARY      C                       eq_ref  PRIMARY        PRIMARY  12       CSUM.co_cd     1       100  
--  2  DERIVED      Shops                   index   PRIMARY        PRIMARY  24                     10        10  Using where

-- 1 rows 4 loops

-- EXPLAIN
-- -> Nested loop inner join  (cost=4.82 rows=1) (actual time=0.111..0.124 rows=4 loops=1)
--     -> Table scan on CSUM  (cost=4.22..4.22 rows=1) (actual time=0.0951..0.0963 rows=4 loops=1)
--         -> Materialize  (cost=1.71..1.71 rows=1) (actual time=0.0927..0.0927 rows=4 loops=1)
--             -> Group aggregate: sum(Shops.emp_nbr)  (cost=1.48 rows=1) (actual time=0.0441..0.0531 rows=4 loops=1)
--                 -> Filter: (Shops.main_flg = 'Y')  (cost=1.25 rows=1) (actual time=0.0342..0.0431 rows=7 loops=1)
--                     -> Index scan on Shops using PRIMARY  (cost=1.25 rows=10) (actual time=0.0313..0.0377 rows=10 loops=1)
--     -> Single-row index lookup on C using PRIMARY (co_cd=CSUM.co_cd)  (cost=0.3 rows=1) (actual time=0.00612..0.00618 rows=1 loops=4)

