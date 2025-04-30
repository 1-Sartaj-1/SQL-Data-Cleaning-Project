#Welcome to my SQL Data Cleaning Project

##Requirements:
1.Remove Duplicates (if any)
2. Standardize the data (spellcheck etc.)
3. Deal with null Values or blank values
4. Remove columns or rows (if necessary) using a staging table

We should have an identifiable column such as a row number hence we 
will use row number.

'''SQL
CREATE TABLE tech_layoffs_2019.layoffs_staging
LIKE tech_layoffs_2019.layoffs;
