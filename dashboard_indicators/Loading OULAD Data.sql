SET GLOBAL local_infile = 'ON';
GRANT FILE ON *.* TO 'root'@'localhost';
Show variables like "local_infile";

CREATE TABLE vle(
id_site integer,
code_module varchar(45),
code_presentation varchar(45),
activity_type varchar(45),
week_from integer,
week_to integer
);

LOAD DATA LOCAL INFILE '/Users/home/Documents/projects/Analysis/OULAD/data/vle.csv'
INTO TABLE oulad.vle
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id_site, @code_module, @code_presentation, @activity_type, @week_from, @week_to)
SET
  id_site = NULLIF(TRIM(BOTH '"' FROM @id_site), '') + 0,
  code_module = NULLIF(TRIM(BOTH '"' FROM @code_module), ''),
  code_presentation = NULLIF(TRIM(BOTH '"' FROM @code_presentation), ''),
  activity_type = NULLIF(TRIM(BOTH '"' FROM @activity_type), ''),
  week_from = NULLIF(TRIM(BOTH '"' FROM @week_from), ''),
  week_to = NULLIF(TRIM(BOTH '"' FROM @week_to), '');

ALTER TABLE vle MODIFY COLUMN week_from INT;
ALTER TABLE vle MODIFY COLUMN week_to INT;
  
SELECT * FROM oulad.vle LIMIT 5;

#When trying to initially load the data files into mySQL Workbench where I planned to do the initial data cleaning using SQL, LOAD DATA LOCAL INFILE did not work because mySQL is trying to handle a blank in ,"", format, it reads them as some kind of infinite variable, truncates and converts it to BIGINT