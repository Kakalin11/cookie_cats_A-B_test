
-- First, we need to create a schema and table
DROP DATABASE IF EXISTS cookie_cats;
CREATE DATABASE IF NOT EXISTS cookie_cats;
USE cookie_cats;

DROP TABLE IF EXISTS data_table;


CREATE TABLE IF NOT EXISTS data_table (
    userid INT(50) NOT NULL,
    version VARCHAR(50) NOT NULL,
    sum_game_rounds INT(50) NOT NULL,
    retention_1 VARCHAR(50) NOT NULL,
    retention_7 VARCHAR(50) NOT NULL,
    PRIMARY KEY (userid)
);

-- Using below query, we can insert values to our table
LOAD DATA LOCAL INFILE '/Users/kursatakalin/Desktop/Kürşat/proje_fikirleri/cookie_cats_ab_testing/cookie_cats.csv' 
INTO TABLE cookie_cats.data_table
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



-- Check if we insert the data

SELECT 
    *
FROM
    cookie_cats.data_table;

-- Total row in the data
-- We have 90189 rows  
SELECT 
    COUNT(*)
FROM
    cookie_cats.data_table;
    
 -- There are two versions. One version for gate at round 30 and other at round 40 

SELECT DISTINCT
    VERSION
FROM
    cookie_cats.data_table;
    
 -- No null values for userid   
SELECT 
    COUNT(DISTINCT userid)
FROM
    cookie_cats.data_table;

-- Mean value for Gate at 30 is 52.46
-- Mean value for Gate at 40 is 51.29

SELECT 
    VERSION, AVG(sum_game_rounds) AS MEAN
FROM
    cookie_cats.data_table
GROUP BY VERSION;


SELECT 
	CASE WHEN MOD((SELECT COUNT(*) FROM cookie_cats.data_table),2)=1 THEN 'ODD'
    WHEN MOD((SELECT COUNT(*) FROM cookie_cats.data_table),2)=0 THEN 'EVEN'
    END AS MEDIAN,
    ROW_NUMBER() OVER() as row_num
 
FROM
	cookie_cats.data_table
WHERE 
	VERSION = 'gate_30'
ORDER BY 1 ASC;

-- Let's calculate the means round values for gate at 30

WITH median as (
SELECT 
	*,
    ROW_NUMBER() OVER() as row_num
FROM 
	cookie_cats.data_table
WHERE
	version='gate_30'
ORDER BY 
	sum_game_rounds asc)
    
	SELECT 
    DISTINCT version,
    CASE WHEN MOD((SELECT COUNT(*) FROM median),2)=1
    THEN 
    (
    SELECT 
		AVG(sum_game_rounds)
	FROM 
		median
     WHERE row_num = (SELECT (MAX(row_num)+1)/2 FROM median) 
   )
   ELSE
   (
    SELECT 
		AVG(sum_game_rounds)
	FROM 
		median
	WHERE row_num IN ((SELECT (MAX(row_num)/2) FROM median) , (SELECT (MAX(row_num)/2)+1 FROM median)) 
   )
   END as MEDIAN_at_gate40
   FROM median

    ;
    
-- Let's calculate the means round values for gate at 40


WITH median as (
SELECT 
	*,
    ROW_NUMBER() OVER() as row_num
FROM 
	cookie_cats.data_table
WHERE
	version='gate_30'
ORDER BY 
	sum_game_rounds asc)
    
	SELECT 
    DISTINCT version,
    CASE WHEN MOD((SELECT COUNT(*) FROM median),2)=1
    THEN 
    (
    SELECT 
		AVG(sum_game_rounds)
	FROM 
		median
     WHERE row_num = (SELECT (MAX(row_num)+1)/2 FROM median) 
   )
   ELSE
   (
    SELECT 
		AVG(sum_game_rounds)
	FROM 
		median
	WHERE row_num IN ((SELECT (MAX(row_num)/2) FROM median) , (SELECT (MAX(row_num)/2)+1 FROM median)) 
   )
   END as MEDIAN_at_gate30
   FROM median

    ;

/* Let us observe the given datas by version category
From the below query result, we can see that we have 44700 records for gate at 30 and 45489 record for gate at 40
Averages of them are 52.46 and 51.30 respectively
When we look at the Standard Deviations, we can clearly see there is sometihnig wrong about the data
Since, STD for gate at 30 is 256 and much more higher than 103 which is STD value for gate at 40
This is because MAX value for gate at 30 is 49854.
This is way much bigger than we may expect. Probobly it is becasue of an error or something
We may need to observe max 10 rows for gate at 30

*/

SELECT
	'SUMMARY TABLE' AS '',
    version,
	COUNT(sum_game_rounds) as COUNT,
    AVG(sum_game_rounds) as MEAN,
    STD(sum_game_rounds) as STD,
    MAX(sum_game_rounds)as MAX,
    MIN(sum_game_rounds) as MIN
FROM
	cookie_cats.data_table
GROUP BY
	version;
    
 -- Exactly! As I expect, there is only one record that is ridicilously higher than any other records   
    
SELECT
	*
FROM
	cookie_cats.data_table
WHERE
	version= 'gate_30'
ORDER BY sum_game_rounds DESC
LIMIT 10;

-- We have now removed that unwanted record

ALTER TABLE cookie_cats.data_table;
DELETE FROM cookie_cats.data_table WHERE userid='6390605';


-- Let's calculate the statistical summary table again


SELECT
	'SUMMARY TABLE' AS '',
    version,
	COUNT(sum_game_rounds) as COUNT,
    AVG(sum_game_rounds) as MEAN,
    STD(sum_game_rounds) as STD,
    MAX(sum_game_rounds)as MAX,
    MIN(sum_game_rounds) as MIN
FROM
	cookie_cats.data_table
GROUP BY
	version;
    
    
-- Let's update all 'True' values as 1 and 'False' values as 0


SET SQL_SAFE_UPDATES=0;

UPDATE cookie_cats.data_table
SET retention_1 = 1
WHERE retention_1 = 'TRUE';

UPDATE cookie_cats.data_table
SET retention_1 = 0
WHERE retention_1 = 'FALSE';


UPDATE cookie_cats.data_table
SET retention_7 = 1
WHERE retention_7 = ' TRUE'
;

UPDATE cookie_cats.data_table
SET retention_7 = 0
WHERE retention_7 = 'FALSE';

select distinct retention_7 from cookie_cats.data_table;

select sum(retention_7) from cookie_cats.data_table

;

select * from cookie_cats.data_table;


describe cookie_cats.data_table;



-- Retention rate at 1st day

SELECT 
	*
FROM
	cookie_cats.data_table
WHERE
	retention;
    
