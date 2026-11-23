--- 01. 부서별 계층형 쿼리 ---
SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL
  FROM departments
 START WITH parent_id IS NULL
CONNECT BY PRIOR department_id = parent_id;
 
--- 01. my_dep_hier_proc 프로시저 ---
CREATE OR REPLACE PROCEDURE my_dep_hier_proc
IS
    PROCEDURE print_child (p_parent_id NUMBER, p_level NUMBER)
    IS
        CURSOR c_dept (cp_parent_id NUMBER) IS
            SELECT department_id, department_name
              FROM departments
             WHERE parent_id = cp_parent_id
             ORDER BY department_id;
    BEGIN
        FOR rec IN c_dept(p_parent_id)
        LOOP
            DBMS_OUTPUT.PUT_LINE(rec.department_id || '  '
                                 || LPAD(' ', 3 * (p_level - 1)) || rec.department_name
                                 || '  ' || p_level);
            print_child(rec.department_id, p_level + 1);
        END LOOP;
    END;
BEGIN
    FOR rec IN (SELECT department_id, department_name
                  FROM departments
                 WHERE parent_id IS NULL
                 ORDER BY department_id)
    LOOP
        DBMS_OUTPUT.PUT_LINE(rec.department_id || '  ' || rec.department_name || '  1');
        print_child(rec.department_id, 2);
    END LOOP;
END;
/

--- 01. 확인 ---
EXEC my_dep_hier_proc;

--- 02. 연관 배열로 이메일 출력 ---
DECLARE
    TYPE av_type IS TABLE OF employees.email%TYPE
        INDEX BY employees.emp_name%TYPE;

    vav_email av_type;
BEGIN
    FOR rec IN (SELECT emp_name, email FROM employees)
    LOOP
        vav_email(rec.emp_name) := rec.email;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Elizabeth Bates 의 이메일 : ' || vav_email('Elizabeth Bates'));
    DBMS_OUTPUT.PUT_LINE('Kimberely Grant 의 이메일 : ' || vav_email('Kimberely Grant'));
END;
/

--- 03. nt_ch11_emp 타입 생성 ---
CREATE OR REPLACE TYPE nt_ch11_emp IS TABLE OF VARCHAR2(80);
/

--- 04. ch11_emp_proc 프로시저 ---
CREATE OR REPLACE PROCEDURE ch11_emp_proc (p_dep_id departments.department_id%TYPE)
IS
    CURSOR c_emp IS
        SELECT a.employee_id, a.emp_name, b.department_name
          FROM employees a, departments b
         WHERE a.department_id = b.department_id;

    TYPE nt_emp_type IS TABLE OF c_emp%ROWTYPE;

    vnt_emp nt_emp_type;
BEGIN
    SELECT a.employee_id, a.emp_name, b.department_name
      BULK COLLECT INTO vnt_emp
      FROM employees a, departments b
     WHERE a.department_id = b.department_id
       AND a.department_id = p_dep_id;

    IF vnt_emp.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE(p_dep_id || '번 부서에 속한 사원이 없습니다.');
        RETURN;
    END IF;

    FOR i IN 1..vnt_emp.COUNT
    LOOP
        DBMS_OUTPUT.PUT_LINE(vnt_emp(i).employee_id || '  '
                             || vnt_emp(i).emp_name || '  '
                             || vnt_emp(i).department_name);
    END LOOP;
END;
/

--- 04. 확인 ---
EXEC ch11_emp_proc(60);