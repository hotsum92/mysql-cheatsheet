SELECT *
  FROM Shops
 WHEREhop_id = '00050';

-- id  select_type  table  partitions  type   possible_keys  key      key_len  ref    rows  filtered  Extra
-- --  -----------  -----  ----------  -----  -------------  -------  -------  -----  ----  --------  -----
--  1  SIMPLE       Shops              const  PRIMARY        PRIMARY  20       const     1       100  

-- EXPLAIN
-- -> Rows fetched before execution  (cost=0..0 rows=1) (actual time=128e-6..238e-6 rows=1 loops=1)
