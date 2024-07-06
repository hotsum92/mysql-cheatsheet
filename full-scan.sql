
-- full scan
EXPLAIN
SELECT *
  FROM Shops;

-- id  select_type  table  partitions  type  possible_keys  key  key_len  ref  rows  filtered  Extra
-- --  -----------  -----  ----------  ----  -------------  ---  -------  ---  ----  --------  -----
--  1  SIMPLE       Shops              ALL                                       60       100  

-- index scan
EXPLAIN
SELECT *
  FROM Shops
 WHERE ShopID = '00050';

-- id  select_type  table  partitions  type   possible_keys  key      key_len  ref    rows  filtered  Extra
-- --  -----------  -----  ----------  -----  -------------  -------  -------  -----  ----  --------  -----
--  1  SIMPLE       Shops              const  PRIMARY        PRIMARY  20       const     1       100  

-- conjunction
SELECT shop_name
  FROM Shops INNER JOIN Reservations
    ON Shops.shop_id = Reservations.shop_id;

-- id  select_type  table         partitions  type    possible_keys  key      key_len  ref                        rows  filtered  Extra
-- --  -----------  ------------  ----------  ------  -------------  -------  -------  -------------------------  ----  --------  -----------
--  1  SIMPLE       Reservations              ALL                                                                   10       100  Using where
--  1  SIMPLE       Shops                     eq_ref  PRIMARY        PRIMARY  20       test.Reservations.shop_id     1       100  

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
