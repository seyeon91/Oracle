--- 01. 101번 사원의 이력 ---
SELECT a.employee_id     AS 사번,
       a.emp_name        AS 사원명,
       d.job_title       AS job명칭,
       b.start_date      AS job시작일자,
       b.end_date        AS job종료일자,
       c.department_name AS job수행부서명
  FROM employees a, job_history b, departments c, jobs d
 WHERE a.employee_id   = b.employee_id
   AND b.department_id = c.department_id
   AND b.job_id        = d.job_id
   AND a.employee_id   = 101;
   
--- 02. 오류 발생 쿼리 ---
SELECT a.employee_id, a.emp_name, b.job_id, b.department_id
  FROM employees a, job_history b
 WHERE a.employee_id      = b.employee_id(+)
   AND a.department_id(+) = b.department_id;

--- 02. 수정한 쿼리 ---
SELECT a.employee_id, a.emp_name, b.job_id, b.department_id
  FROM employees a, job_history b
 WHERE a.employee_id   = b.employee_id(+)
   AND a.department_id = b.department_id(+);

--- 03. IN 절 값이 1개일 때 (+) 사용 ---
SELECT a.employee_id, a.emp_name, b.department_name
  FROM employees a, departments b
 WHERE a.department_id = b.department_id(+)
   AND b.department_id(+) IN (10);
   
--- 04. 변경 전 (오라클) ---
SELECT a.department_id, a.department_name
  FROM departments a, employees b
 WHERE a.department_id = b.department_id
   AND b.salary > 3000
 ORDER BY a.department_name;

--- 04. 변경 후 (ANSI) ---
SELECT a.department_id, a.department_name
  FROM departments a
 INNER JOIN employees b
    ON a.department_id = b.department_id
 WHERE b.salary > 3000
 ORDER BY a.department_name;
 
 --- 05. 변경 전 : 연관성 있는 서브 쿼리 ---
SELECT a.department_id, a.department_name
  FROM departments a
 WHERE EXISTS (SELECT 1
                 FROM job_history b
                WHERE a.department_id = b.department_id);

--- 05. 변경 후 : 연관성 없는 서브 쿼리 ---
SELECT a.department_id, a.department_name
  FROM departments a
 WHERE a.department_id IN (SELECT department_id
                             FROM job_history);
                             
--- 06. 연도별 이탈리아 최대/최소 매출액과 사원 ---
SELECT emp.years,
       CASE WHEN emp.amount_sold = sale.max_sold THEN '최대'
            ELSE '최소' END AS 구분,
       emp.employee_id,
       emp2.emp_name,
       emp.amount_sold
  FROM (SELECT SUBSTR(a.sales_month, 1, 4) AS years,
               a.employee_id,
               SUM(a.amount_sold) AS amount_sold
          FROM sales a, customers b, countries c
         WHERE a.cust_id    = b.cust_id
           AND b.country_id = c.country_id
           AND c.country_name = 'Italy'
         GROUP BY SUBSTR(a.sales_month, 1, 4), a.employee_id) emp,
       (SELECT years,
               MAX(amount_sold) AS max_sold,
               MIN(amount_sold) AS min_sold
          FROM (SELECT SUBSTR(a.sales_month, 1, 4) AS years,
                       a.employee_id,
                       SUM(a.amount_sold) AS amount_sold
                  FROM sales a, customers b, countries c
                 WHERE a.cust_id    = b.cust_id
                   AND b.country_id = c.country_id
                   AND c.country_name = 'Italy'
                 GROUP BY SUBSTR(a.sales_month, 1, 4), a.employee_id)
         GROUP BY years) sale,
       employees emp2
 WHERE emp.years = sale.years
   AND (emp.amount_sold = sale.max_sold OR emp.amount_sold = sale.min_sold)
   AND emp.employee_id = emp2.employee_id
 ORDER BY emp.years, 구분; 