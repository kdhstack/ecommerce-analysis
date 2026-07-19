-- 1. CTE Practice
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT 
    customer_id,
    order_count
FROM customer_orders
WHERE order_count >= 3;

-- 2. GROUP BY -> CTE Practice
-- * Practice problem created for personal SQL study

-- orders 테이블
-- - order_id
-- - customer_id
-- - country
-- - amount

-- 요구사항
-- 1. 고객별 총 구매금액을 계산한다.
-- 2. 총 구매금액이 1,000 이상인 고객만 우수 고객으로 본다.
-- 3. 국가별 우수 고객 수를 구한다.
-- 4. 우수 고객 수가 많은 국가부터 정렬한다.
-- 5. 우수 고객 수가 같으면 국가명을 오름차순으로 정렬한다.

-- 결과 컬럼
-- country
-- vip_customer_count

-- Solution
SELECT country, COUNT(*) AS vip_customer_count
FROM (SELECT country, customer_id, SUM(amount) AS total_amount
    FROM orders
    GROUP BY country, customer_id
    HAVING SUM(amount) >= 1000) AS vip_customers
GROUP BY country
ORDER BY
    vip_customer_count DESC,
    country ASC;

-- 어려웠던 점: 
-- 집계를 두 번 사용해서 구해야 함

-- 배운 점: 
-- WHERE에서는 SUM() 함수 사용 불가(집계 전)
-- GROUP BY 내에 여러 개의 집계 기준 설정 가능

WITH vip_customers AS
    (SELECT country, customer_id, SUM(amount) AS total_amount
     FROM orders
     GROUP BY country, customer_id
     HAVING SUM(amount) >= 1000)
SELECT country, COUNT(*) AS vip_customer_count
FROM vip_customers
GROUP BY country
ORDER BY vip_customer_count DESC, country ASC;

-- 3. JOIN -> CTE
-- * Practice problem created for personal SQL study

-- customers 테이블
-- - customer_id
-- - customer_name
-- - country

-- orders 테이블
-- - order_id
-- - customer_id
-- - category
-- - amount
-- - order_date

-- 요구사항
-- 1. customers와 orders 테이블을 customer_id로 연결한다.
-- 2. 주문 금액이 100 이상인 주문만 대상으로 한다.
-- 3. 고객별·카테고리별 주문 횟수를 계산한다.
-- 4. 해당 카테고리에서 주문을 2회 이상 한 고객을 활성 고객으로 본다.
-- 5. 카테고리별 활성 고객 수를 구한다.
-- 6. 활성 고객 수가 많은 카테고리부터 정렬한다.
-- 7. 활성 고객 수가 같으면 카테고리명을 오름차순으로 정렬한다.

-- 결과 컬럼
-- category
-- active_customer_count

-- Solution
SELECT category, COUNT(*) AS active_customer_count 
FROM ( 
    SELECT C.customer_id, O.category, COUNT(order_id) AS order_count 
    FROM customers C JOIN orders O ON C.customer_id = O.customer_id 
    WHERE amount >= 100 
    GROUP BY C.customer_id, O.category 
    HAVING COUNT(order_id) >= 2) AS active_customer 
GROUP BY category 
ORDER BY active_customer_count DESC, category ASC;

-- 어려웠던 점:
-- - 고객/카테고리별 집계와 카테고리별 활성 고객 수 집계를 두 단계로 나누어 작성하는 과정을 떠올리기가 어려웠다.

-- 배운 점:
-- - 여러 단계의 집계가 필요할 때 서브쿼리나 CTE로 쿼리를 분리할 수 있다.
-- - JOIN한 테이블에 같은 이름의 컬럼이 있으면 컬럼의 출처를 명확히 해두는 것이 좋다.

WITH active_customers AS 
    (SELECT C.customer_id, O.category 
     FROM customers C JOIN orders O ON C.customer_id = O.customer_id 
     WHERE O.amount >= 100 
     GROUP BY C.customer_id, O.category 
     HAVING COUNT(O.order_id) >= 2 ) 
SELECT category, COUNT(*) AS active_customer_count 
FROM active_customers 
GROUP BY category 
ORDER BY active_customer_count DESC, category ASC;