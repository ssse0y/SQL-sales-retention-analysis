-- ============================================================
-- 1. 스키마 및 데이터 타입 확인
-- ============================================================

-- 컬럼명, 데이터 타입, NULL 허용 여부 확인
SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM `prime_career.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'ecommerce_data'
ORDER BY ordinal_position;


-- ============================================================
-- 2. 결측치 확인
-- ============================================================

-- INFORMATION_SCHEMA를 활용하여 모든 컬럼의 NULL 개수를 동적으로 집계
DECLARE sql STRING;

SET sql = (
    SELECT STRING_AGG(
        FORMAT("""
            SELECT
                '%s' AS column_name,
                COUNTIF(`%s` IS NULL) AS null_count
            FROM `prime_career.ecommerce_data`
        """, column_name, column_name),
        '\nUNION ALL\n'
    )
    FROM `prime_career.INFORMATION_SCHEMA.COLUMNS`
    WHERE table_name = 'ecommerce_data'
);

EXECUTE IMMEDIATE sql;


-- ============================================================
-- 3. 컬럼별 데이터 특성 확인
-- ============================================================

-- 컬럼별 예시 값 확인
ARRAY_AGG(
    DISTINCT CAST(`%s` AS STRING)
    IGNORE NULLS
    LIMIT 5
) AS sample_values

-- 컬럼별 고유값 개수 확인
APPROX_COUNT_DISTINCT(
    CAST(`%s` AS STRING)
) AS distinct_count


-- ============================================================
-- 4. 수치형 컬럼 분포 확인
-- ============================================================

-- Quantity의 최솟값, 사분위수, 평균, 최댓값 확인
SELECT
    MIN(Quantity) AS min_value,
    APPROX_QUANTILES(Quantity, 100)[OFFSET(25)] AS q1,
    APPROX_QUANTILES(Quantity, 100)[OFFSET(50)] AS median,
    AVG(Quantity) AS avg_value,
    APPROX_QUANTILES(Quantity, 100)[OFFSET(75)] AS q3,
    MAX(Quantity) AS max_value
FROM `prime_career.ecommerce_data`;


-- ============================================================
-- 5. 날짜형 컬럼 범위 확인
-- ============================================================

-- 거래 데이터의 전체 기간 확인
SELECT
    MIN(InvoiceDate) AS min_date,
    MAX(InvoiceDate) AS max_date
FROM `prime_career.ecommerce_data`;


-- ============================================================
-- 6. 이상치 및 비정상 값 확인
-- ============================================================

-- 길이가 짧은 StockCode를 확인하여 비정상 코드 여부 점검
SELECT *
FROM `prime_career.ecommerce_data`
WHERE LENGTH(CAST(StockCode AS STRING)) <= 5
ORDER BY StockCode;
