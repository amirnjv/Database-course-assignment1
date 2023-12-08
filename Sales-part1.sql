-- Insepecting the data 
select * from [dbo].[sales_data_sample];

-- Checking the Unique values
select distinct status from
[dbo].[sales_data_sample]
order by 1;

select distinct Year_id from
[dbo].[sales_data_sample]
order by 1;

select distinct productline from
[dbo].[sales_data_sample]
order by 1;

select distinct country from
[dbo].[sales_data_sample]
order by 1;

select distinct DEALSIZE FROM
[dbo].[sales_data_sample]
order by 1;

select distinct s.MONTH_ID from 
[dbo].[sales_data_sample] s
where YEAR_ID = 2005
order by 1;

-- Analasis
-- let's grouping sales by productline

select s.PRODUCTLINE,round(sum(sales),2) as Revenue
from[dbo].[sales_data_sample] s
group by s.PRODUCTLINE
order by revenue desc;

select s.YEAR_ID,round(sum(sales),2) as Revenue
from[dbo].[sales_data_sample] s
group by s.YEAR_ID
order by revenue desc;

select s.DEALSIZE,round(sum(sales),2) as Revenue
from[dbo].[sales_data_sample] s
group by s.DEALSIZE
order by revenue desc;


-- what is the best month for sales in specific year? how much earned that month?
select  s.MONTH_ID,round(sum(sales),2) Revenue ,
count(s.ORDERNUMBER) Frequency
from [dbo].[sales_data_sample] s
where YEAR_ID = 2004
group by s.MONTH_ID
order by 2 desc;
 
-- November is the best month of sales ,so which products sold in that month?
select  s.MONTH_ID,productline,
round(sum(sales),2) Revenue ,
count(s.ORDERNUMBER) Frequency
from [dbo].[sales_data_sample] s
where YEAR_ID = 2004 and s.MONTH_ID = 11
group by s.MONTH_ID,s.PRODUCTLINE
order by 3 desc;

-- who is the best customer
WITH RFM AS(
select 
	CUSTOMERNAME,
	sum(Sales) sumOFSales,
	avg(Sales) averOfSales,
   count(ORDERNUMBER) freq,
	max(orderdate) lastorderdate,
	(select max(orderdate) from [dbo].[sales_data_sample]) max_order_date,
	DATEDIFF(day,max(orderdate),(select max(orderdate) from [dbo].[sales_data_sample])) recency
from [dbo].[sales_data_sample]
group by CUSTOMERNAME)

SELECT r.*,
	NTILE(4) OVER(ORDER BY recency DESC) AS receny_rfm,
	NTILE(4) OVER(ORDER BY  averOfSales) as rfm_average,
	NTILE(4) OVER (ORDER BY freq) as rfm_frequency
FROM RFM r
order by 4 desc;
