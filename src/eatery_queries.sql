--1. What is the average permit duration? Which eatery has the longest permit?
--calculate the permit duration in years as numeric
create or replace function cal_duration(end_date Date, start_date Date)
returns Integer as
    'select extract(year from end_date)-extract(year from start_date);'
language sql;
select cal_duration(end_date , start_date) from eatery;
'''
cal_duration 
--------------
            4
            4
            4
            4
            4
            4
            4
            4
            4
            4
            3
            4
            4
'''

--use the function in a query to calculate the average duration of permits
select sum(foo.duration)/count(foo.duration) from 
(select cal_duration(end_date , start_date) as duration from eatery) as foo;
'''
 ?column? 
----------
        5
'''
--display the name and permit number of the eatery with the longest permit without using LIMIT (that is, use a subquery)
select name, permit_number
from eatery where cal_duration(end_date , start_date)=(select max(cal_duration(end_date , start_date)) from eatery);
'''
             name              | permit_number 
-------------------------------+---------------
 The Vanderbilt at South Beach | R46-R
'''


-- 2. What is the count of eateries per year based on permit start date?
-- show the year and number of eateries in the dataset for that year, based on start date
-- sort by the year ascending
SELECT extract(year from start_date) AS year , count(*) from eatery
GROUP BY year 
ORDER BY year asc; 
'''
 year | count 
------+-------
 2000 |     1
 2002 |     1
 2004 |     1
 2005 |     2
 2007 |     2
 2008 |     1
 2009 |     2
 2010 |     4
 2011 |     3
 2012 |     7
 2013 |     3
 2014 |     9
 2015 |    20
 2016 |    46
 2017 |    25
 2018 |    46
 2019 |    63
      |     1
'''

-- 3. What are the names and eatery types of every eatery in the dataset?

-- instead of a single eatery_table, move out type_name into its own table
-- call this new table eatery_type
-- it should only have two columns: a surrogate key, eatery_type_id… and name
-- the original eatery table should reference theh rows in this new table by using a foreign key
DROP TABLE IF EXISTS eatery_type;
CREATE TABLE eatery_type(
    eatery_type_id SERIAL,
    name TEXT,
    PRIMARY KEY(eatery_type_id)
);
--using an INSERT statement with a subquery, add rows to the eatery_type table based on the distinct values of the type_name column in the eatery table
INSERT INTO eatery_type(name) (SELECT DISTINCT type_name FROM eatery);
--use an ALTER table statement to add a new foreign key column to eatery called eatery_type_id that references the primary key of the eatery_type table
ALTER TABLE eatery ADD COLUMN eatery_type_id Integer;
ALTER TABLE eatery ADD CONSTRAINT etfk FOREIGN KEY (eatery_type_id) REFERENCES eatery_type(eatery_type_id);
--write an UPDATE statement to populate the foreign key in eatery, 
--but do this using an UPDATE with a FROM clause… that essentially results in a join 
UPDATE eatery as e
SET eatery_type_id = et.eatery_type_id
FROM eatery_type AS et    -- join with this table
WHERE et.name = e.type_name;
-- use an ALTER TABLE statement to remove the type_name column from eatery so that the type only lives in the referenced table, eatery_type… and only the fk exists in eatery
ALTER TABLE eatery
DROP COLUMN type_name;
-- finally, write a SELECT statement to test out your two tables; 
-- show the name and type of every eatery by using a join
SELECT e.name, et.name 
FROM eatery e
INNER JOIN eatery_type et on et.eatery_type_id=e.eatery_type_id;
'''

                       name                        |          name          
---------------------------------------------------+------------------------
 Sunset Park Food Cart                             | Food Cart
 Olmsted Cafeteria                                 | Snack Bar
 Central Park Food Cart                            | Food Cart
 Central Park Food Cart                            | Food Cart
 Central Park Food Cart                            | Food Cart
 Central Park Food Cart                            | Food Cart
 Central Park Food Cart                            | Food Cart
 Central Park Food Cart                            | Food Cart
 Central Park Food Cart                            | Food Cart
 Central Park Food Cart                            | Food Cart
 Battery Park Food Cart                            | Food Cart

'''

-- 4. Which eateries are a cart, and which eateries aren't a cart?
-- using the two tables created from the previous part, show every eatery
-- show the eatery's: eatery_id, name, permit_number … and whether or not it's a cart (look up the type name in the referenced table, eatery_type, and if it has the word cart as a case insensitive substring, use the value Cart, otherwise, use the value in the column)
-- for example, instead of of Specialty Cart or Food Cart, show Cart… but for Snack Bar or Restaurant, leave the value as is
-- to do this use one of the conditional expressions in the slides
-- the results will only include the following eatery type names: Cart, Restaurant, Snack Bar, and Mobile Food Truck
SELECT e.eatery_id,e.name, CASE WHEN et.name ILIKE '%cart%' THEN 'Cart' ELSE et.name END, permit_number 
FROM eatery e
INNER JOIN eatery_type et on et.eatery_type_id=e.eatery_type_id;
'''
 eatery_id |       name        |    permit_number     
-----------+-------------------+----------------------
        51 | Cart              | B87-C
       203 | Snack Bar         | Q99-J-SB
         1 | Cart              | M10-72-1A-C
         2 | Cart              | M10-72-3-C
         3 | Cart              | M10-72-ED-C
         4 | Cart              | M10-74-WD-C
         5 | Cart              | M10-81-WD-C
         6 | Cart              | M10-84-ED-C
         7 | Cart              | M10-W65-C
         8 | Cart              | M10-W67-C
         9 | Cart              | M5-C
        10 | Cart              | Q98-C
        11 | Cart              | Q99-(1)-C
        12 | Cart              | Q99-2-C
'''

-- 5. Can this be easier / how many are carts, and how many are every other type?
-- imagine trying to group by whether or not an eatery is a cart… that would require rewriting the conditional!
-- to avoid this, capture the result of the query in a view
-- write a query to make a view out of the previous statement; name the view eatery_report

CREATE VIEW eatery_report AS
    SELECT e.eatery_id,CASE WHEN et.name ILIKE '%cart%' THEN 'Cart' ELSE et.name END, permit_number 
    FROM eatery e
    INNER JOIN eatery_type et on et.eatery_type_id=e.eatery_type_id;

-- write a second query that counts the number of each eatery type… 
-- but count every type with the word Cart in it simply as Cart… the results may look like:
SELECT name ,count(name)
FROM eatery_report er
GROUP BY er.name ;
'''
       name        | count 
-------------------+-------
 Restaurant        |    14
 Cart              |    98
 Snack Bar         |    28
 Mobile Food Truck |    97
'''

-- 6. How many eateries are there per borough?
-- reread the data dictionary
-- following the same pattern as the previous two questions write a series of SQL statements / queries that eventually shows each borough and the number of eateries per borough

CREATE VIEW borough_report AS
    SELECT eatery_id, CASE 
    WHEN park_id ilike '%X%' THEN 'Bronx' 
    WHEN park_id ilike '%B%'  THEN  'Brooklyn'
    WHEN park_id ilike '%M%'  THEN  'Manhattan'
    WHEN park_id ilike '%Q%'  THEN  'Queens'
    WHEN park_id ilike '%R%'  THEN  'Staten Island' 
    END 
    FROM eatery  ; 

SELECT br.case as borough, count(*) from borough_report br
GROUP BY br.case ;
'''
    borough    | count 
---------------+-------
 Brooklyn      |    32
 Bronx         |    48
 Manhattan     |    90
 Queens        |    51
 Staten Island |    16
'''

-- 7. Can this be faster? YES. 
-- Use EXPLAIN ANALYZE to show how much time it takes to search for every eatery named Pushcart
EXPLAIN ANALYZE SELECT *
FROM eatery
WHERE name = 'Pushcart';
'''
                                            QUERY PLAN                                             
---------------------------------------------------------------------------------------------------
 Seq Scan on eatery  (cost=0.00..15.96 rows=1 width=590) (actual time=0.032..0.116 rows=1 loops=1)
   Filter: (name = 'Pushcart'::text)
   Rows Removed by Filter: 236
 Planning Time: 0.223 ms
 Execution Time: 0.163 ms
'''
-- Add an index to make your query run faster
CREATE INDEX idx_pushcart 
ON eatery(name);

-- Use EXPLAIN ANALYZE again; there should be a very minor improvement in time
EXPLAIN ANALYZE SELECT *
FROM eatery
WHERE name = 'Pushcart';
'''
                                                      QUERY PLAN                                                       
-----------------------------------------------------------------------------------------------------------------------
 Index Scan using idx_pushcart on eatery  (cost=0.27..8.29 rows=1 width=590) (actual time=0.088..0.090 rows=1 loops=1)
   Index Cond: (name = 'Pushcart'::text)
 Planning Time: 0.502 ms
 Execution Time: 0.121 ms
'''
-- Notice that an Index Scan is used in EXPLAIN ANALYZE

-- Write a 3rd query, a SELECT statement that involves name in the WHERE clause, that will cause the query planner to do a sequential scan
--that is, try to formulate a query that will make it not use the index
EXPLAIN ANALYZE SELECT *
FROM eatery
WHERE name = 'Rockaway Beach Snack Bars'
'''
                                                      QUERY PLAN                                                       
-----------------------------------------------------------------------------------------------------------------------
 Index Scan using idx_pushcart on eatery  (cost=0.27..8.29 rows=1 width=590) (actual time=0.022..0.024 rows=1 loops=1)
   Index Cond: (name = 'Rockaway Beach Snack Bars'::text)
 Planning Time: 0.124 ms
 Execution Time: 0.051 ms
'''