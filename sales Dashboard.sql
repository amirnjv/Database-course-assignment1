-- Inspecting Data 
SELECT * FROM [dbo].[sales_data_sample];

-- Checking Unique Data
SELECT DISTINCT STATUS FROM [dbo].[sales_data_sample]; -- Nice to Plot
SELECT DISTINCT year_id  FROM [dbo].[sales_data_sample];
SELECT DISTINCT PRODUCTLINE FROM [dbo].[sales_data_sample]; -- Nice to Plot
SELECT DISTINCT COUNTRY FROM [dbo].[sales_data_sample]; -- Nice to Plot
SELECT DISTINCT Dealsize FROM [dbo].[sales_data_sample]; -- Nice to Plot
SELECT DISTINCT Territory FROM [dbo].[sales_data_sample]; -- Nice to Plot

SELECT DISTINCT MONTH_ID  FROM [dbo].[sales_data_sample]
WHERE year_id =2005;

-- Analysis
-- Grouping Data By Productline
SELECT PRODUCTLINE, SUM(SALES) Revenue
FROM [dbo].[sales_data_sample]
GROUP BY PRODUCTLINE
ORDER BY 2 DESC;

-- Grouping Sales By Year 
SELECT YEAR_ID, SUM(SALES) Revenue
FROM [dbo].[sales_data_sample]
GROUP BY YEAR_ID
ORDER BY 2 DESC;

-- best month for sale in specific year ? How much was Earned that month?
SELECT MONTH_ID ,SUM(SALES) Revenue , COUNT(ORDERNUMBER) Frequency
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID = 2004 -- Put specific Year 
GROUP BY MONTH_ID
ORDER BY 2 DESC;

-- November seems to be the best! so what products sold in November??
SELECT MONTH_ID ,PRODUCTLINE ,SUM(SALES) Revenue , COUNT(ORDERNUMBER) Frequency
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID = 2004 AND  MONTH_ID =11 -- Put specific Year 
GROUP BY MONTH_ID ,PRODUCTLINE
ORDER BY 3 DESC;

-- BEST customer with RFM (Recency ,frequency,Monetary)
IF OBJECT_ID('tempdb..#rfm') IS NOT NULL
    DROP TABLE #rfm;

WITH rfm AS (
    SELECT 
        CUSTOMERNAME,
        SUM(SALES) AS Revenue,
        AVG(SALES) AS Average_sales,
        COUNT(ORDERNUMBER) AS frequency,
        MAX(ORDERDATE) AS Last_order_date,
        (SELECT MAX(ORDERDATE) FROM [dbo].[sales_data_sample]) AS Max_order_date,
        DATEDIFF(DD, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM [dbo].[sales_data_sample])) AS Recency
    FROM [dbo].[sales_data_sample]
    GROUP BY CUSTOMERNAME
),
rfm_calc AS (
    SELECT 
        r.*,
        NTILE(4) OVER (ORDER BY Recency DESC) AS rfm_recency,
        NTILE(4) OVER (ORDER BY frequency) AS rfm_frequency,
        NTILE(4) OVER (ORDER BY Average_sales) AS rfm_monetary
    FROM rfm r
)
SELECT 
    c.*,
    rfm_recency + rfm_frequency + rfm_monetary AS rfm_cell,
    CAST(rfm_recency AS VARCHAR) + CAST(rfm_frequency AS VARCHAR) + CAST(rfm_monetary AS VARCHAR) AS rfm_cell_string
INTO #rfm
FROM rfm_calc c;

SELECT * FROM #rfm;

-- what products are often sold together??
-- 	SELECT * FROM [dbo].[sales_data_sample] WHERE ORDERNUMBER = 10411
SELECT PRODUCTCODE
FROM DBO.sales_data_sample
WHERE ORDERNUMBER IN(
SELECT ORDERNUMBER
FROM(
		SELECT ORDERNUMBER,COUNT(*) AS rn
		FROM [dbo].[sales_data_sample]
		WHERE STATUS ='shipped'
		GROUP BY ORDERNUMBER
	)sub
	WHERE rn = 2
	)