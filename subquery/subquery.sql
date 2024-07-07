-- 集計した値以外の項目を表示する場合は、サブクエリが必要

SELECT R1.cust_id, R1.seq, R1.price
  FROM Receipts R1
         INNER JOIN
           (SELECT cust_id, MIN(seq) AS min_seq
              FROM Receipts
             GROUP BY cust_id) R2
    ON R1.cust_id = R2.cust_id
   AND R1.seq = R2.min_seq;


-- id  select_type  table       partitions  type    possible_keys  key      key_len  ref                    rows  filtered  Extra
-- --  -----------  ----------  ----------  ------  -------------  -------  -------  ---------------------  ----  --------  ------------------------
--  1  PRIMARY      <derived2>              ALL                                                                5       100  Using where
--  1  PRIMARY      R1                      eq_ref  PRIMARY        PRIMARY  8        R2.cust_id,R2.min_seq     1       100  
--  2  DERIVED      Receipts                range   PRIMARY        PRIMARY  4                                  5       100  Using index for group-by

-- EXPLAIN
-- -> Nested loop inner join  (cost=4.81 rows=5) (actual time=0.085..0.0953 rows=4 loops=1)
--     -> Filter: (R2.min_seq is not null)  (cost=2.73..3.06 rows=5) (actual time=0.0743..0.0758 rows=4 loops=1)
--         -> Table scan on R2  (cost=3.16..5.21 rows=5) (actual time=0.0731..0.0741 rows=4 loops=1)
--             -> Materialize  (cost=2.65..2.65 rows=5) (actual time=0.0711..0.0711 rows=4 loops=1)
--                 -> Covering index skip scan for grouping on Receipts using PRIMARY  (cost=1.5 rows=5) (actual time=0.0333..0.0469 rows=4 loops=1)
--     -> Single-row index lookup on R1 using PRIMARY (cust_id=R2.cust_id, seq=R2.min_seq)  (cost=0.27 rows=1) (actual time=0.00414..0.00419 rows=1 loops=4)

-- 相関サブクエリでも、二回アクセスが発生する

SELECT cust_id, seq, price
  FROM Receipts R1
 WHERE seq = (SELECT MIN(seq)
                FROM Receipts R2
               WHERE R1.cust_id = R2.cust_id);

-- id  select_type         table  partitions  type  possible_keys  key      key_len  ref              rows  filtered  Extra
-- --  ------------------  -----  ----------  ----  -------------  -------  -------  ---------------  ----  --------  -----------
--  1  PRIMARY             R1                 ALL                                                       13       100  Using where
--  2  DEPENDENT SUBQUERY  R2                 ref   PRIMARY        PRIMARY  4        mydb.R1.cust_id     3       100  Using index


-- EXPLAIN
-- -> Filter: (R1.seq = (select #2))  (cost=1.55 rows=13) (actual time=0.0366..0.0697 rows=4 loops=1)
--     -> Table scan on R1  (cost=1.55 rows=13) (actual time=0.0165..0.0179 rows=13 loops=1)
--     -> Select #2 (subquery in condition; dependent)
--         -> Aggregate: min(R2.seq)  (cost=0.901 rows=1) (actual time=0.00308..0.0031 rows=1 loops=13)
--             -> Covering index lookup on R2 using PRIMARY (cust_id=R1.cust_id)  (cost=0.576 rows=3.25) (actual time=0.00195..0.00259 rows=3.92 loops=13)



-- ただし、項目が一つだけの場合は、集計関数を使えば表示できる
SELECT cust_id, MIN(seq), MAX(name)
  FROM Receipts
  GROUP BY cust_id;
