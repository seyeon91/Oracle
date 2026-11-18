--- 01. 전화번호 앞자리 02 ---
SELECT employee_id, emp_name, phone_number,
       LPAD(SUBSTR(phone_number, 5), 12, '(02)') AS new_phone
  FROM employees
 WHERE LENGTH(phone_number) = 12;
 
--- 02. 근속년수 10년 이상 사원 ---
SELECT employee_id                                      AS 사원번호,
       emp_name                                         AS 사원명,
       hire_date                                        AS 입사일자,
       TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12)   AS 근속년수
  FROM employees
 WHERE MONTHS_BETWEEN(SYSDATE, hire_date) / 12 >= 10
 ORDER BY 근속년수 DESC; 
 
--- 03. 전화번호 - 를 / 로 ---
SELECT cust_name, cust_main_phone_number,
       REPLACE(cust_main_phone_number, '-', '/') AS new_phone
  FROM customers;
  
--- 04. 전화번호 숫자를 다른 문자로 대체 ---
SELECT cust_name, cust_main_phone_number,
       TRANSLATE(cust_main_phone_number, '0123456789', 'abcdefghi') AS new_phone
  FROM customers;

--- 05. DECODE로 30, 40, 50대 구분 ---
SELECT cust_name, cust_year_of_birth,
       DECODE(TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10),
              3, '30대',
              4, '40대',
              5, '50대',
                 '기타') AS generation
  FROM customers;

--- 06. CASE로 모든 연령대 ---
SELECT cust_name, cust_year_of_birth,
       CASE WHEN age < 20 THEN '10대'
            WHEN age < 30 THEN '20대'
            WHEN age < 40 THEN '30대'
            WHEN age < 50 THEN '40대'
            WHEN age < 60 THEN '50대'
            WHEN age < 70 THEN '60대'
            WHEN age < 80 THEN '70대'
            WHEN age < 90 THEN '80대'
            WHEN age < 100 THEN '90대'
            ELSE '100세 이상'
       END AS generation
  FROM (SELECT cust_name, cust_year_of_birth,
               TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth AS age
          FROM customers);
