SELECT shop_name
  FROM Shops INNER JOIN Reservations
    ON Shops.shop_id = Reservations.shop_id;

-- id  select_type  table         partitions  type    possible_keys  key      key_len  ref                        rows  filtered  Extra
-- --  -----------  ------------  ----------  ------  -------------  -------  -------  -------------------------  ----  --------  -----------
--  1  SIMPLE       Reservations              ALL                                                                   10       100  Using where
--  1  SIMPLE       Shops                     eq_ref  PRIMARY        PRIMARY  20       test.Reservations.shop_id     1       100  

-- EXPLAIN
-- -> Nested loop inner join  (cost=4.75 rows=10) (actual time=0.0501..0.0873 rows=10 loops=1)
--     -> Filter: (Reservations.shop_id is not null)  (cost=1.25 rows=10) (actual time=0.0297..0.0377 rows=10 loops=1)
--         -> Table scan on Reservations  (cost=1.25 rows=10) (actual time=0.0286..0.0347 rows=10 loops=1)
--     -> Single-row index lookup on Shops using PRIMARY (shop_id=Reservations.shop_id)  (cost=0.26 rows=1) (actual time=0.00445..0.00449 rows=1 loops=10)
