SET SERVEROUTPUT ON
--- 01. 구구단 3단 출력 ---
BEGIN
    DBMS_OUTPUT.PUT_LINE('3 * 1 = ' || 3 * 1);
    DBMS_OUTPUT.PUT_LINE('3 * 2 = ' || 3 * 2);
    DBMS_OUTPUT.PUT_LINE('3 * 3 = ' || 3 * 3);
    DBMS_OUTPUT.PUT_LINE('3 * 4 = ' || 3 * 4);
    DBMS_OUTPUT.PUT_LINE('3 * 5 = ' || 3 * 5);
    DBMS_OUTPUT.PUT_LINE('3 * 6 = ' || 3 * 6);
    DBMS_OUTPUT.PUT_LINE('3 * 7 = ' || 3 * 7);
    DBMS_OUTPUT.PUT_LINE('3 * 8 = ' || 3 * 8);
    DBMS_OUTPUT.PUT_LINE('3 * 9 = ' || 3 * 9);
END;
/

--- 02. 201번 사원 이름과 이메일 ---
DECLARE
    vs_emp_name  employees.emp_name%TYPE;
    vs_email     employees.email%TYPE;
BEGIN
    SELECT emp_name, email
      INTO vs_emp_name, vs_email
      FROM employees
     WHERE employee_id = 201;

    DBMS_OUTPUT.PUT_LINE('사원명 : ' || vs_emp_name);
    DBMS_OUTPUT.PUT_LINE('이메일 : ' || vs_email);
END;
/

--- 03. 최대 사번 + 1로 신규 사원 입력 ---
DECLARE
    vn_max_empno  employees.employee_id%TYPE;
BEGIN
    SELECT MAX(employee_id)
      INTO vn_max_empno
      FROM employees;

    INSERT INTO employees (employee_id, emp_name, email, hire_date, department_id)
    VALUES (vn_max_empno + 1, 'Harrison Ford', 'HARRIS', SYSDATE, 50);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(vn_max_empno + 1 || '번 사원 입력 완료');
END;
/

--- 확인 ---
SELECT employee_id, emp_name, email, hire_date, department_id
  FROM employees
 WHERE emp_name = 'Harrison Ford';