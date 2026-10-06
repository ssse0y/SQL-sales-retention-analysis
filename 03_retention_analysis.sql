WITH CleanedData AS (
 SELECT *
 FROM prime_career.ecommerce_data
 WHERE
 InvoiceNo NOT LIKE 'C%' -- 취소된 거래 제거
 AND LENGTH(StockCode) >= 5 -- 5글자 미만 상품 코드 제거
 AND Quantity > 0 -- 거래 수량이 0 이하인 데이터 제거
 AND Quantity NOT IN (80995, 74215) -- 최댓값 2건 제거
 AND UnitPrice > 0 -- 상품 단가가 0 이하인 데이터 제거
 AND CustomerID IS NOT NULL -- 비회원 거래 제거
),



FirstPurchase AS (
 -- 고객별 최초 구매월 추출
 SELECT
 CustomerID,
 FORMAT_DATE('%Y-%m', MIN(InvoiceDate)) AS FirstPurchaseMonth
 FROM CleanedData
 GROUP BY CustomerID
),



MonthlyPurchase AS (
 -- 고객별 구매 월 추출
 SELECT
 CustomerID,
 FORMAT_DATE('%Y-%m', InvoiceDate) AS PurchaseMonth
 FROM CleanedData
 GROUP BY CustomerID, FORMAT_DATE('%Y-%m', InvoiceDate)
),

Retention AS (
 SELECT
 fp.FirstPurchaseMonth AS CohortMonth,
 mp.PurchaseMonth,
 COUNT(DISTINCT mp.CustomerID) AS RetainedCustomers # 재구매한 고객 수 구하기
 FROM FirstPurchase fp
 JOIN MonthlyPurchase mp
 ON fp.CustomerID = mp.CustomerID # ID기준으로 조인, 첫구매월, 재구매월 같이 확인
 GROUP BY fp.FirstPurchaseMonth, mp.PurchaseMonth
)

SELECT
 r.CohortMonth,
 r.PurchaseMonth,
 r.RetainedCustomers,
 ROUND(r.RetainedCustomers /
 (SELECT COUNT(DISTINCT CustomerID) # 재구매율= 해당월 재구매고객/첫구매고객 *100
 FROM FirstPurchase fp
 WHERE fp.FirstPurchaseMonth = r.CohortMonth)*100, 2)
 AS RetentionRate
FROM Retention r
WHERE r.CohortMonth != '2011-11' -- 2011년 11월 Cohort 제거
AND r.PurchaseMonth != '2011-12' -- 2011년 12월 구매이력 제거
ORDER BY r.CohortMonth, r.PurchaseMonth;
