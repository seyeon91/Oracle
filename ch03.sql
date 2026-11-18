--- 01. ex3_6 테이블 생성 + INSERT ---
CREATE TABLE ex3_6 (
    employee_id  NUMBER(6),
    emp_name     VARCHAR2(80),
    salary       NUMBER(8,2),
    manager_id   NUMBER(6)
);

INSERT INTO ex3_6 (employee_id, emp_name, salary, manager_id)
SELECT employee_id, emp_name, salary, manager_id
  FROM employees
 WHERE manager_id = 124
   AND salary BETWEEN 2000 AND 3000;

COMMIT;

SELECT * FROM ex3_6 ORDER BY employee_id;

--- 02. MERGE ---
--- ex3_3 테이블 생성 ---
CREATE TABLE ex3_3 (
    employee_id NUMBER,
    bonus_amt   NUMBER DEFAULT 0
);

-- 문제 문장 ---
DELETE ex3_3;

INSERT INTO ex3_3 (employee_id)
SELECT e.employee_id
  FROM employees e, sales s
 WHERE e.employee_id = s.employee_id
   AND s.SALES_MONTH BETWEEN '200010' AND '200012'
 GROUP BY e.employee_id;

COMMIT;

--- 답 ---
MERGE INTO ex3_3 d
     USING (SELECT employee_id, salary, manager_id
              FROM employees
             WHERE manager_id = 145) b
        ON (d.employee_id = b.employee_id)
 WHEN MATCHED THEN
      UPDATE SET d.bonus_amt = d.bonus_amt + b.salary * 0.01
 WHEN NOT MATCHED THEN
      INSERT (d.employee_id, d.bonus_amt)
      VALUES (b.employee_id, b.salary * 0.005);

COMMIT;

SELECT * FROM ex3_3 ORDER BY employee_id;

--- 03. 커미션 없는 사원 ---
SELECT employee_id, emp_name
  FROM employees
 WHERE commission_pct IS NULL
 ORDER BY employee_id;
 
--- 04. BETWEEN 논리 연산자 ---
SELECT employee_id, salary
  FROM employees
 WHERE salary >= 2000
   AND salary <= 2500
 ORDER BY employee_id;
 
--- 05. IN -> ANY ---
SELECT employee_id, salary
  FROM employees
 WHERE salary = ANY (2000, 3000, 4000)
 ORDER BY employee_id;

--- 05. NOT IN -> ALL ---
SELECT employee_id, salary
  FROM employees
 WHERE salary <> ALL (2000, 3000, 4000)
 ORDER BY employee_id;
 
 
 
 
 
 
 