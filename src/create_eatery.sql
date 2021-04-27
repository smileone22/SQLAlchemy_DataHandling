DROP TABLE IF EXISTS eatery;
CREATE TABLE eatery(
    eatery_id SERIAL,
    name TEXT, 
    location TEXT,
    park_id TEXT,
    start_date DATE,
    end_date DATE,
    description TEXT,
    permit_number TEXT,
    phone TEXT,
    website TEXT,
    type_name TEXT,
    PRIMARY KEY(eatery_id)
);


