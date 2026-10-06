-- 월별 일평균 매출, 월별 일평균 구매고객수,  월별 일평균 구매건수 추출
# 조건 부여해서 기존 데이터 필터링
WITH cleaned_data AS (    # 데이터 필터링
 SELECT
 InvoiceNo,
 StockCode,
 Description,
 Quantity,
 TIMESTAMP(InvoiceDate) AS InvoiceDate,   # 거래일자 TIMESTAMP로 변환
 UnitPrice,
 COALESCE(CAST(CustomerID AS STRING), 'Guest') AS CustomerID, 
 # 비회원칸 NULL값->GUEST로
 Country,
 Quantity * UnitPrice AS Revenue   # 수량*단가=수익
 FROM prime_career.ecommerce_data
 WHERE
 InvoiceNo NOT LIKE 'C%' -- 거래 취소 제거 # 문자열 필터링
 AND LENGTH(StockCode) >= 5 -- 5글자 미만 코드 제거 # 문자열 길이 5글자 이상
 AND Quantity > 0 -- 0 이하 수량 제거
 AND UnitPrice > 0 -- 0 이하 단가 제거
 AND Quantity NOT IN (80995, 74215) -- 이상치 제거
), 


# 날짜 데이터
date_series AS (
 -- 데이터 범위 내에서 모든 날짜 생성
 SELECT
 DATE_ADD('2010-12-01', INTERVAL n DAY) AS order_date
 FROM UNNEST(GENERATE_ARRAY(0, DATE_DIFF('2011-12-09', '2010-12-01', DAY)))
AS n
),



# 합계 구하고 JOIN 후 월별, 일별 집계 만들기
daily_stats AS (
 SELECT
 d.order_date,
 FORMAT_DATE('%Y-%m', d.order_date) AS order_month,
 COALESCE(SUM(c.Revenue), 0) AS daily_revenue,
 COALESCE(COUNT(DISTINCT c.CustomerID), 0) AS daily_customers,
 COALESCE(COUNT(DISTINCT c.InvoiceNo), 0) AS daily_orders
 FROM date_series d
 LEFT JOIN cleaned_data c
 ON DATE(c.InvoiceDate) = d.order_date
 GROUP BY order_date, order_month
)

# 실행하기
SELECT
 order_month,
 ROUND(AVG(daily_revenue), 2) AS avg_daily_revenue,
 ROUND(AVG(daily_customers), 2) AS avg_daily_customers,
 ROUND(AVG(daily_orders), 2) AS avg_daily_orders
FROM daily_stats
GROUP BY order_month
ORDER BY order_month;
