SELECT *
FROM tech_layoffs_2019.layoffs;

CREATE TABLE tech_layoffs_2019.layoffs_staging
LIKE tech_layoffs_2019.layoffs;

INSERT tech_layoffs_2019.layoffs_staging
SELECT *
FROM tech_layoffs_2019.layoffs ;

WITH duplicate_check AS
(SELECT *,
ROW_NUMBER()OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised 
ORDER BY tech_layoffs_2019.layoffs_staging.company) AS row_num
FROM tech_layoffs_2019.layoffs_staging)
DELETE
FROM duplicate_check
WHERE row_num > 1;


ALTER TABLE new_layoffs_staging
ADD COLUMN row_num INT;

INSERT INTO new_layoffs_staging
SELECT *,
ROW_NUMBER()OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised 
ORDER BY tech_layoffs_2019.layoffs_staging.company) AS row_num
FROM tech_layoffs_2019.layoffs_staging;

SELECT *
FROM new_layoffs_staging;

SELECT *
FROM new_layoffs_staging
WHERE row_num > 1;

DELETE 
FROM new_layoffs_staging
WHERE row_num > 1;

SELECT company, TRIM(company)
FROM new_layoffs_staging;

UPDATE new_layoffs_staging
SET company = TRIM(company);

SELECT  DISTINCT industry
FROM new_layoffs_staging
ORDER BY industry;

SELECT DISTINCT location
FROM new_layoffs_staging
ORDER BY location;

SELECT DISTINCT country
FROM new_layoffs_staging
ORDER BY country;

SELECT `date`
FROM new_layoffs_staging;

UPDATE new_layoffs_staging
SET `date`= TRIM(SUBSTRING(date, 1, 10));

SELECT `date`,
str_to_date(`date`, '%Y-%m-%d')
FROM new_layoffs_staging;

UPDATE new_layoffs_staging
SET `date` = str_to_date(`date`, '%Y-%m-%d');

ALTER TABLE new_layoffs_staging
MODIFY COLUMN `date` DATE;

ALTER TABLE new_layoffs_staging
DROP row_num;

SELECT *
FROM new_layoffs_staging
WHERE percentage_laid_off IS NULL OR percentage_laid_off = '';


SELECT industry,
CASE
	WHEN industry = '' THEN NULL 
	ELSE industry         
END AS industry_cleaned
FROM new_layoffs_staging;

UPDATE new_layoffs_staging
SET industry = NULL
WHERE industry = '';







