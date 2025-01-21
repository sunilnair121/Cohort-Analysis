# Cohort Analysis Project

## Project Overview
This project involves performing a cohort analysis using transaction data from the `OnlineRetail` dataset in the `ProjectDB` database. The objective is to analyze customer retention patterns over time and measure cohort retention rates.

## Dataset Details

- **Total Records:** 541,909
- **Records with Customer IDs:** 406,829 (75.1%)
- **Records without Customer IDs:** 135,080 (24.9%)

### Cleaned Data

- Removed records with negative or zero values for `Quantity` and `UnitPrice`.
- Eliminated 5,125 duplicate records, resulting in **392,669 unique and valid records**.

## Key Steps in the Analysis

### 1. Data Cleaning

- Excluded records without `CustomerID`.
- Removed rows with non-positive `Quantity` and `UnitPrice`.
- Eliminated duplicates based on `InvoiceNo`, `StockCode`, and `Quantity`.

### 2. Cohort Analysis Preparation

- Identified the **cohort date** (month of first purchase) for each customer.
- Created a **cohort index** to track months since the first purchase for retention analysis.

### 3. Retention Table

- Created a pivot table summarizing retention percentages for each cohort over 13 months.
- **Formula Used:**

  ```
  Retention Percentage = (Customers in Month n / Customers in Month 1) x 100
  ```

## Results Summary

The cohort analysis results are summarized in the attached cohort chart (`Cohort Analysis.pdf`). Key insights include:

### Initial Cohort Size

- Varies across different months.

### Retention Rates

- **Month 1 retention rate:** Consistently 100%, representing the cohort’s initial purchase.
- **Month 2 retention rates:** Range between **40%-60%**, indicating moderate customer retention.
- **Month 6 retention rates:** Typically drop to **10%-20%**, highlighting a significant decrease in active customers.

## Key SQL Queries

### Data Cleaning
```sql
SELECT * 
FROM [ProjectDB].[dbo].[OnlineRetail]
WHERE CustomerID IS NOT NULL AND Quantity > 0 AND UnitPrice > 0;
```

### Cohort Date Calculation
```sql
SELECT 
    CustomerID,
    MIN(InvoiceDate) AS first_purchase_date,
    DATEFROMPARTS(YEAR(MIN(InvoiceDate)), MONTH(MIN(InvoiceDate)), 1) AS Cohort_Date
FROM #online_retail_main_data
GROUP BY CustomerID;
```

### Retention Table
```sql
SELECT Cohort_Date, 
    1.0*[1]/[1]*100 AS [1],
    1.0*[2]/[1]*100 AS [2],
    ...
    1.0*[13]/[1]*100 AS [13]
FROM #cohort_pivot
ORDER BY Cohort_Date;
```

## Usage Instructions

1. Run the provided SQL scripts in sequence on the `ProjectDB` database.
2. Review the cohort table and charts generated for retention trends.
3. Use the attached `Cohort Analysis.pdf` for visual insights and interpretation.

## Insights and Recommendations

- Retention strategies should focus on improving customer engagement during the first **2-3 months**.
- Analyze cohorts with higher retention rates to identify patterns or successful interventions.
- Consider offering incentives or loyalty programs to improve long-term retention.

## Attachments

- **Cohort Analysis.pdf:** Visual representation of retention trends.

---
This README serves as a comprehensive guide for understanding the project workflow, results, and actionable insights. Feel free to reach out for further clarifications or modifications!
