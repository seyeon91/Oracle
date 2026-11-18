--- 01. 입사년도별 사원 수 ---
SELECT TO_CHAR(hire_date, 'YYYY') AS hire_year,
       COUNT(*)                   AS emp_cnt
  FROM employees
 GROUP BY TO_CHAR(hire_date, 'YYYY')
 ORDER BY hire_year;
 
--- 02. 2012년도 월별, 지역별 대출 총 잔액 ---
SELECT period, region, SUM(loan_jan_amt) AS total_jan
  FROM kor_loan_status
 WHERE period LIKE '2012%'
 GROUP BY period, region
 ORDER BY period, region;
 
--- 03. 분할 ROLLUP 쿼리 ---
SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%'
 GROUP BY period, ROLLUP(gubun);
 
--- 03. 답 ---
SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%'
 GROUP BY period, gubun
UNION
SELECT period, NULL, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%'
 GROUP BY period;
 
--- 04. CASE로 대출 종류별 금액 분리 ---
SELECT period,
       CASE WHEN gubun = '주택담보대출' THEN SUM(loan_jan_amt) ELSE 0 END 주택담보대출액,
       CASE WHEN gubun = '기타대출'     THEN SUM(loan_jan_amt) ELSE 0 END 기타대출액
  FROM kor_loan_status
 WHERE period = '201311'
 GROUP BY period, gubun;

--- 04. 답 ---
SELECT period, SUM(loan_jan_amt) 주택담보대출액, 0 기타대출액
  FROM kor_loan_status
 WHERE period = '201311'
   AND gubun = '주택담보대출'
 GROUP BY period
UNION ALL
SELECT period, 0 주택담보대출액, SUM(loan_jan_amt) 기타대출액
  FROM kor_loan_status
 WHERE period = '201311'
   AND gubun = '기타대출'
 GROUP BY period;
 
 --- 05. 지역별, 월별 대출 총 잔액 ---
SELECT region AS 지역,
       SUM(CASE WHEN period = '201111' THEN loan_jan_amt ELSE 0 END) AS "201111",
       SUM(CASE WHEN period = '201112' THEN loan_jan_amt ELSE 0 END) AS "201112",
       SUM(CASE WHEN period = '201210' THEN loan_jan_amt ELSE 0 END) AS "201210",
       SUM(CASE WHEN period = '201211' THEN loan_jan_amt ELSE 0 END) AS "201211",
       SUM(CASE WHEN period = '201212' THEN loan_jan_amt ELSE 0 END) AS "201212",
       SUM(CASE WHEN period = '201310' THEN loan_jan_amt ELSE 0 END) AS "201310",
       SUM(CASE WHEN period = '201311' THEN loan_jan_amt ELSE 0 END) AS "201311"
  FROM kor_loan_status
 GROUP BY region
 ORDER BY region;