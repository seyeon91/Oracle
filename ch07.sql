--- 01. LISTAGG 함수 ---
SELECT department_id,
       LISTAGG(emp_name, ',') WITHIN GROUP (ORDER BY emp_name) AS empnames
  FROM employees
 WHERE department_id IS NOT NULL
 GROUP BY department_id;
 
--- 01. 계층형 쿼리, 분석 함수 ---
SELECT department_id,
       SUBSTR(SYS_CONNECT_BY_PATH(emp_name, ','), 2) AS empnames
  FROM (SELECT emp_name, department_id,
               COUNT(*)     OVER (PARTITION BY department_id)                   AS cnt,
               ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY emp_name) AS rowseq
          FROM employees
         WHERE department_id IS NOT NULL)
 WHERE rowseq = cnt
 START WITH rowseq = 1
CONNECT BY PRIOR rowseq + 1 = rowseq
       AND PRIOR department_id = department_id
 ORDER BY department_id;
 
--- 02. LEAD로 다음 입사일을 퇴사일로 ---
SELECT employee_id, emp_name, hire_date,
       LEAD(hire_date) OVER (ORDER BY hire_date) AS retire_date
  FROM employees
 WHERE job_id = 'SH_CLERK'
 ORDER BY hire_date;
 
--- 03. 연령대별 매출금액 (200112) ---
SELECT TRUNC(TO_CHAR(SYSDATE, 'YYYY') - c.cust_year_of_birth, -1) || '대' AS 연령대,
       SUM(s.amount_sold)                                                AS 매출금액
  FROM sales s, customers c
 WHERE s.sales_month = '200112'
   AND s.cust_id     = c.cust_id
 GROUP BY TRUNC(TO_CHAR(SYSDATE, 'YYYY') - c.cust_year_of_birth, -1)
 ORDER BY TRUNC(TO_CHAR(SYSDATE, 'YYYY') - c.cust_year_of_birth, -1);
 
--- 04. 월별 매출 최하위 대륙 ---
WITH basis AS (
    SELECT s.sales_month, c.country_region, SUM(s.amount_sold) AS amt
      FROM sales s, customers b, countries c
     WHERE s.cust_id    = b.cust_id
       AND b.country_id = c.country_id
     GROUP BY s.sales_month, c.country_region
),
ranked AS (
    SELECT sales_month, country_region, amt,
           RANK() OVER (PARTITION BY sales_month ORDER BY amt) AS rnk
      FROM basis
)
SELECT sales_month    AS 매출월,
       country_region AS "지역(대륙)",
       amt            AS 매출금액
  FROM ranked
 WHERE rnk = 1
 ORDER BY sales_month;
 
--- 05. 지역별, 대출종류별, 월별 잔액과 비율 ---
WITH basis AS (
    SELECT region, gubun,
           SUM(CASE WHEN period = '201111' THEN loan_jan_amt ELSE 0 END) AS amt1,
           SUM(CASE WHEN period = '201112' THEN loan_jan_amt ELSE 0 END) AS amt2,
           SUM(CASE WHEN period = '201210' THEN loan_jan_amt ELSE 0 END) AS amt3,
           SUM(CASE WHEN period = '201211' THEN loan_jan_amt ELSE 0 END) AS amt4,
           SUM(CASE WHEN period = '201212' THEN loan_jan_amt ELSE 0 END) AS amt5,
           SUM(CASE WHEN period = '201310' THEN loan_jan_amt ELSE 0 END) AS amt6,
           SUM(CASE WHEN period = '201311' THEN loan_jan_amt ELSE 0 END) AS amt7
      FROM kor_loan_status
     GROUP BY region, gubun
)
SELECT region AS 지역,
       gubun  AS 대출종류,
       amt1 || '(' || ROUND(RATIO_TO_REPORT(amt1) OVER (PARTITION BY region) * 100) || '%)' AS "201111",
       amt2 || '(' || ROUND(RATIO_TO_REPORT(amt2) OVER (PARTITION BY region) * 100) || '%)' AS "201112",
       amt3 || '(' || ROUND(RATIO_TO_REPORT(amt3) OVER (PARTITION BY region) * 100) || '%)' AS "201210",
       amt4 || '(' || ROUND(RATIO_TO_REPORT(amt4) OVER (PARTITION BY region) * 100) || '%)' AS "201211",
       amt5 || '(' || ROUND(RATIO_TO_REPORT(amt5) OVER (PARTITION BY region) * 100) || '%)' AS "201212",
       amt6 || '(' || ROUND(RATIO_TO_REPORT(amt6) OVER (PARTITION BY region) * 100) || '%)' AS "201310",
       amt7 || '(' || ROUND(RATIO_TO_REPORT(amt7) OVER (PARTITION BY region) * 100) || '%)' AS "201311"
  FROM basis
 ORDER BY region, gubun;