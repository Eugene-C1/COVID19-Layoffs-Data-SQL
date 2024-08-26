-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. NULL Values or Blank Values
-- 4. Remove any Columns or rows

-- 1. Remove Duplicates
-- Creating staging table
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

-- Inserting data from raw table to staging table
INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Checking if there are duplicates in the table
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Creating 2nd staging table
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Inserting data from staging1 table to staging2 table
INSERT layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
;

-- Deleting duplicated data
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Checking if there are duplicated data
SELECT *
FROM layoffs_staging2;

-- 2. Standardizing Data
-- Checking company column
SELECT DISTINCT company
FROM layoffs_staging2
;

-- Checking for trailing white spaces
SELECT company, TRIM(company)
FROM layoffs_staging2
;

-- Removing trailing white spaces
UPDATE layoffs_staging2
SET company = TRIM(company)
;

-- Checking industry column
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;

-- Checking Crypto industry column
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
;

-- Updating 
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

-- Checking the country column
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1
;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%'
;

-- Checking for trailing '.'
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1
;

-- Updating to remove trailing '.'
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1
;

-- Checking date column
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2
;

-- Updating the date column into correct date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

SELECT *
FROM layoffs_staging2
;

-- Modifying the column into date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. NULL Values or Blank Values
-- Checking for NULL values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

-- Checing the industry column
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'
;

-- Finding companies that share the same data, but one of them has a blank industry
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
;

-- Setting blank data into NULL data
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''
;

-- Populating the industry by finding a company that share the same name
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
; 
-- Checking for remaining blank or NULL industry
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
;

-- 4. Remove Columns or rows
-- Checking for NULL data in 2 columns
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

-- Remove unreliable data from the table
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

SELECT *
FROM layoffs_staging2
;

-- Removing unnecessary column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;
































