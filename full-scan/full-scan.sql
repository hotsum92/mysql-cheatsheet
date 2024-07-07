-- full scan

SELECT *
  FROM Shops;

-- id  select_type  table  partitions  type  possible_keys  key  key_len  ref  rows  filtered  Extra
-- --  -----------  -----  ----------  ----  -------------  ---  -------  ---  ----  --------  -----
--  1  SIMPLE       Shops              ALL                                       60       100  

-- EXPLAIN
-- -> Table scan on Shops  (cost=6.25 rows=60) (actual time=0.0692..0.0825 rows=60 loops=1)
