# Welcome to my SQL Data Cleaning Project

## Requirements:
1. Remove Duplicates (if any)
2. Standardize the data (finding issues in the data and fixing it)
3. Deal with null Values or blank values
4. Remove columns or rows (if necessary) using a staging table

It's advisable not to make changes directly in the raw data file, so we'll create a new staging file inside our database.
```sql
CREATE TABLE tech_layoffs_2019.layoffs_staging
LIKE tech_layoffs_2019.layoffs;
```

Now, we'll insert all the data within layoffs into layoffs_staging
```sql
INSERT tech_layoffs_2019.layoffs_staging
SELECT *
FROM tech_layoffs_2019.layoffs ;
```
Let's use the window function in order to identify duplicate data in our table
```sql
SELECT *,
ROW_NUMBER()OVER(
PARTITION BY company, location, industry, percentage_laid_off, `date`, stage, country 
ORDER BY tech_layoffs_2019.layoffs_staging.company) AS row_num
FROM tech_layoffs_2019.layoffs_staging;
```
![Alt text](Window-function.png)

Another way to check is also via taking a company entry as follows:

![Alt text](Duplicate-check-via-company-entry.png)

We can clearly see under row_num column that there are dulplicate rows. However, if we want to be really sure about duplicate data and to practice our SQL we can use common table expressions (CTE) as follows:
```sql
WITH dulplicate_check AS
(SELECT *,
ROW_NUMBER()OVER(
PARTITION BY company, location, industry, percentage_laid_off, `date`, stage, country 
ORDER BY tech_layoffs_2019.layoffs_staging.company) AS row_num
FROM tech_layoffs_2019.layoffs_staging)
SELECT *
FROM dulplicate_check
WHERE row_num > 1;
```
![Alt text](CTE.png)

Now we're absolutely sure that duplicate rows does exist however, we can't just simply use DELETE query on the CTE and delete the rows, thereby we will CREATE a new table (new_layoffs_staging) where we can perform our desired operation. Also, we will insert all the columns in our new table from layoffs_staging.
```sql
ALTER TABLE new_layoffs_staging
ADD COLUMN row_num INT;

INSERT INTO new_layoffs_staging
SELECT *,
ROW_NUMBER()OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised 
ORDER BY tech_layoffs_2019.layoffs_staging.company) AS row_num
FROM tech_layoffs_2019.layoffs_staging;
```
Although it's the perfect time to delete duplicate data in our new table, we will first run the SELECT command and then do DELETE to implement best practice.
```sql
SELECT *
FROM new_layoffs_staging
WHERE row_num > 1;

DELETE 
FROM new_layoffs_staging
WHERE row_num > 1;
```

For other columns as well, we can check if there are some entries that need to be taken care of, perhaps by TRIM or an unnecessary character etc.
```sql
SELECT  DISTINCT industry
FROM new_layoffs_staging
ORDER BY industry;
```

Coming to the date column, we see that date is a text and not in date data structure (we can do that when we upload the file in our MySQL worspace) and that there are unnecessary timezone suceeding the date all with exactly same value.
![Alt text](5.date-select.png)
![Alt text](4.Date-Formatting.png)

Now, using substring we trim the unwanted part of the data as well as alter the date column with DATE data type.
```sql
UPDATE new_layoffs_staging
SET `date`= TRIM(SUBSTRING(date, 1, 10));

SELECT `date`,
str_to_date(`date`, '%Y-%m-%d')
FROM new_layoffs_staging;

UPDATE new_layoffs_staging
SET `date` = str_to_date(`date`, '%Y-%m-%d');

ALTER TABLE new_layoffs_staging
MODIFY COLUMN `date` DATE;
```
![Alt text](7.date-data-type-changed.png)

Finally, our purpose of removing duplicating data is done, hence we can DROP the row_num column.
```sql
ALTER TABLE new_layoffs_staging
DROP row_num;
```
