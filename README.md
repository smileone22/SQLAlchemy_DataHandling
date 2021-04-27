# SQLAlchemy, Date Arithmetic, Functions, Indexes


## File Description 
* [Link to Dataset](https://data.cityofnewyork.us/Recreation/Directory-of-Eateries/8792-ebcp)
* `src/create_eateries.sql` 
    SQL DDL statements to create a table that stores the data from the json file
* `src/db.py` 
    functions and classes for reading config file, creating sessions and connections
* `src/load_eateries.py`
    adding data to the database 
* `src/eatery_queries.sql`
    SQL queries using functions, index, `EXPLAIN ANALYZE` and results 
* `src/extra_credit.ipynb`
    Data Visualization 
