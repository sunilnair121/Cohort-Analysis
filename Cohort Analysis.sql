--DATABASE ProjectDB
USE ProjectDB;
GO

/**** TOTAL RECORDS = 541909 ROWS****/
	--135080 RECORDS HAVE NO CustomerID
	--406829 RECORDS HAVE CustomerID
WITH online_retail AS 
(
	SELECT [InvoiceNo]
		  ,[StockCode]
		  ,[Description]
		  ,[Quantity]
		  ,[InvoiceDate]
		  ,[UnitPrice]
		  ,[CustomerID]
		  ,[Country]
	  FROM [ProjectDB].[dbo].[OnlineRetail]
	  WHERE CustomerID IS NOT NULL
), quantity_unit_price as
(

	--397884 RECORDS WITH QUANTITY AND UNIT PRICE
	SELECT * 
	FROM online_retail
	WHERE Quantity > 0 AND UnitPrice > 0
), dup_check as
(
	--- DUPLICATE CHECK 
	SELECT * ,
	ROW_NUMBER () OVER (PARTITION BY InvoiceNo, StockCode, Quantity ORDER BY InvoiceDate) as dup_flag
	FROM quantity_unit_price
)
--392669 CLEAN DATA
-- 5125 DUPLICATE RECORDS
SELECT * 
INTO #online_retail_main_data
FROM dup_check
WHERE dup_flag = 1

---CLEAN DATA
---BEGIN COHORT ANALYSIS
---UNIQUE IDENTIFIER (CustomerID)
---INTITAL START DATE (First Invoice date)
---REVENUE DATA 

SELECT 
	CustomerID,
	MIN(InvoiceDate) as first_purchase_date,
	DATEFROMPARTS(YEAR(MIN(InvoiceDate)),MONTH(MIN(InvoiceDate)),1) as Cohort_Date
INTO #cohort
FROM #online_retail_main_data
GROUP BY CustomerID

SELECT * 
FROM #cohort

---CREATE COHORT INDEX
WITH cohortData AS 
(
	SELECT 
		M.*, 
		C.Cohort_Date,
		YEAR(M.InvoiceDate) as invoice_year,
		MONTH(M.InvoiceDate) as invoice_month,
		YEAR(C.Cohort_Date) as cohort_year,
		MONTH(C.Cohort_Date) as cohort_month
	FROM #online_retail_main_data M
	LEFT JOIN #cohort C
	ON M.CustomerID = C.CustomerID
),
diff AS
(
	SELECT *,
		   year_diff = (invoice_year - cohort_year),
		   month_diff = (invoice_month - cohort_month)
	FROM cohortData
)

SELECT *,
	   cohort_index = year_diff*12 + month_diff + 1
INTO #cohort_retention
FROM diff

---PIVOT DATA TO SEE  THE COHORT TABLE
SELECT *
INTO #cohort_pivot
FROM (
		SELECT DISTINCT 
			CustomerID,
			Cohort_Date,
			cohort_index
		FROM #cohort_retention
	) tb1
PIVOT (
		COUNT(CustomerId)
		FOR cohort_index IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13]) 
		) AS pivot_table
ORDER BY Cohort_Date

SELECT Cohort_Date, 
	1.0*[1]/[1]* 100 AS [1],
	1.0*[2]/[1]* 100 AS [2],
	1.0*[3]/[1]* 100 AS [3],
	1.0*[4]/[1]* 100 AS [4],
	1.0*[5]/[1]* 100 AS [5],
	1.0*[6]/[1]* 100 AS [6],
	1.0*[7]/[1]* 100 AS [7],
	1.0*[8]/[1]* 100 AS [8],
	1.0*[9]/[1]* 100 AS [9],
	1.0*[10]/[1]* 100 AS [10],
	1.0*[11]/[1]* 100 AS [11],
	1.0*[12]/[1]* 100 AS [12],
	1.0*[13]/[1]* 100 AS [13]
FROM #cohort_pivot
ORDER BY Cohort_Date


		