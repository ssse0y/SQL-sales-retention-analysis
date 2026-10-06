WITH Cleaned AS (
  SELECT 
  InvoiceNo,
  StockCode,
  Quantity,
  UnitPrice,
  CustomerID,
  FORMAT_DATE('%Y-%m', InvoiceDate) AS Month,
  (Quantity * UnitPrice) AS Revenue
  FROM prime_career.ecommerce_data
  WHERE 
  InvoiceNo NOT LIKE 'C%'
  AND LENGTH(StockCode)>=5
  AND Quantity >0
  AND Quantity NOT IN (80995, 74215)
  AND UnitPrice > 0)

SELECT
Month,
ROUND(COUNT(DISTINCT CASE WHEN CustomerID IS NULL THEN InvoiceNo END)/COUNT(DISTINCT InvoiceNo)*100,2) AS Nonmember_Transaction_Rate,
ROUND(SUM(CASE WHEN CustomerID IS NULL THEN InvoiceRevenue ELSE 0 END)/SUM(InvoiceRevenue)*100,2) AS Nonmember_Revenue_Rate,
ROUND(AVG(CASE WHEN CustomerID IS NULL THEN InvoiceRevenue ELSE NULL END),2) AS Nonmember_Avg_Revenue
FROM
(SELECT 
  Month,
  CustomerID,
  InvoiceNo,
  SUM(Revenue) AS InvoiceRevenue
FROM Cleaned
GROUP BY Month, InvoiceNo, CustomerID)
GROUP BY Month
ORDER BY Month;
