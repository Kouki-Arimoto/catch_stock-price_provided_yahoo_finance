CREATE DATABASE your_db;
\c your_db

CREATE TABLE stock_price_table (
  "code" VARCHAR (50) NOT NULL,
  "market" VARCHAR (50) NOT NULL,
  "Co.name" VARCHAR (50) NOT NULL,
  "datetime" TIMESTAMP NOT NULL,
  "stock_price" FLOAT NOT NULL
);      

-- INSERT INTO your_table VALUES('a');
-- INSERT INTO your_table VALUES('b');
-- INSERT INTO your_table VALUES('c');
