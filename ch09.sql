--- 01. REVERSE 9..1 실행 ---
DECLARE
    vn_base_num NUMBER := 3;
BEGIN
    FOR i IN REVERSE 9..1
    LOOP
        DBMS_OUTPUT.PUT_LINE(vn_base_num || '*' || i || '= ' || vn_base_num * i);
    END LOOP;
END;
/

--- 01. 수정 : REVERSE 1..9 ---
DECLARE
    vn_base_num NUMBER := 3;
BEGIN
    FOR i IN REVERSE 1..9
    LOOP
        DBMS_OUTPUT.PUT_LINE(vn_base_num || '*' || i || '= ' || vn_base_num * i);
    END LOOP;
END;
/

--- 02. my_initcap 함수 ---
CREATE OR REPLACE FUNCTION my_initcap (ps_string VARCHAR2)
    RETURN VARCHAR2
IS
    vs_return  VARCHAR2(4000);
    vs_char    VARCHAR2(1);
    vs_prev    VARCHAR2(1) := ' ';
BEGIN
    FOR i IN 1..LENGTH(ps_string)
    LOOP
        vs_char := SUBSTR(ps_string, i, 1);

        IF vs_prev = ' ' THEN
            vs_return := vs_return || UPPER(vs_char);
        ELSE
            vs_return := vs_return || LOWER(vs_char);
        END IF;

        vs_prev := vs_char;
    END LOOP;

    RETURN vs_return;
END;
/

--- 02. 확인 ---
SELECT my_initcap('hello oracle WORLD') AS my_func,
       INITCAP('hello oracle WORLD')    AS oracle_func
  FROM dual;
  
--- 03. my_last_day 함수 ---
CREATE OR REPLACE FUNCTION my_last_day (ps_date VARCHAR2)
    RETURN VARCHAR2
IS
    vs_date      VARCHAR2(8);
    vd_first_day DATE;
BEGIN
    vs_date := REPLACE(ps_date, '-', '');

    IF LENGTH(vs_date) <> 8 THEN
        RETURN '입력일자 오류';
    END IF;

    vd_first_day := TO_DATE(SUBSTR(vs_date, 1, 6) || '01', 'YYYYMMDD');

    RETURN TO_CHAR(ADD_MONTHS(vd_first_day, 1) - 1, 'YYYYMMDD');
END;
/

--- 03. 확인 ---
SELECT my_last_day('20261123')   AS nov,
       my_last_day('2024-02-10') AS feb_leap,
       my_last_day('20261215')   AS dec,
       TO_CHAR(LAST_DAY(TO_DATE('20261123', 'YYYYMMDD')), 'YYYYMMDD') AS oracle_func
  FROM dual;
  
--- 04. ch09_dept 테이블 생성 ---
CREATE TABLE ch09_dept (
    DEPARTMENT_ID    NUMBER,
    DEPARTMENT_NAME  VARCHAR2(100),
    LEVELS           NUMBER
);

--- 04. my_hier_dept_proc 프로시저 ---
CREATE OR REPLACE PROCEDURE my_hier_dept_proc
IS
BEGIN
    DELETE ch09_dept;

    INSERT INTO ch09_dept (department_id, department_name, levels)
    SELECT department_id,
           LPAD(' ', 3 * (LEVEL - 1)) || department_name,
           LEVEL
      FROM departments
     START WITH parent_id IS NULL
   CONNECT BY PRIOR department_id = parent_id;

    COMMIT;
END;
/

--- 04. 확인 ---
EXEC my_hier_dept_proc;

SELECT * FROM ch09_dept;

--- 05. my_new_job_proc2 프로시저 ---
CREATE OR REPLACE PROCEDURE my_new_job_proc2
    ( p_job_id    IN JOBS.JOB_ID%TYPE,
      p_job_title IN JOBS.JOB_TITLE%TYPE,
      p_min_sal   IN JOBS.MIN_SALARY%TYPE,
      p_max_sal   IN JOBS.MAX_SALARY%TYPE )
IS
BEGIN
    MERGE INTO jobs a
    USING (SELECT p_job_id AS job_id FROM dual) b
       ON (a.job_id = b.job_id)
     WHEN MATCHED THEN
          UPDATE SET a.job_title   = p_job_title,
                     a.min_salary  = p_min_sal,
                     a.max_salary  = p_max_sal,
                     a.update_date = SYSDATE
     WHEN NOT MATCHED THEN
          INSERT (a.job_id, a.job_title, a.min_salary, a.max_salary, a.create_date, a.update_date)
          VALUES (p_job_id, p_job_title, p_min_sal, p_max_sal, SYSDATE, SYSDATE);

    COMMIT;
END;
/

--- 05. 확인 ---
EXEC my_new_job_proc2('SM_JOB1', 'Sample JOB1', 1000, 5000);
EXEC my_new_job_proc2('SM_JOB1', 'Sample JOB1 수정', 2000, 6000);

SELECT * FROM jobs WHERE job_id = 'SM_JOB1';

--- 06. ch09_departments 테이블 생성 ---
CREATE TABLE ch09_departments AS
SELECT department_id, department_name, parent_id
  FROM departments;

--- 06. my_dept_manage_proc 프로시저 ---
CREATE OR REPLACE PROCEDURE my_dept_manage_proc
    ( p_department_id   IN ch09_departments.department_id%TYPE,
      p_department_name IN ch09_departments.department_name%TYPE,
      p_parent_id       IN ch09_departments.parent_id%TYPE,
      p_flag            IN VARCHAR2 )
IS
    vn_cnt NUMBER := 0;
BEGIN
    IF UPPER(p_flag) = 'UPSERT' THEN
        MERGE INTO ch09_departments a
        USING (SELECT p_department_id AS department_id FROM dual) b
           ON (a.department_id = b.department_id)
         WHEN MATCHED THEN
              UPDATE SET a.department_name = p_department_name,
                         a.parent_id       = p_parent_id
         WHEN NOT MATCHED THEN
              INSERT (a.department_id, a.department_name, a.parent_id)
              VALUES (p_department_id, p_department_name, p_parent_id);

        DBMS_OUTPUT.PUT_LINE(p_department_id || '번 부서 저장 완료');

    ELSIF UPPER(p_flag) = 'DELETE' THEN
        SELECT COUNT(*)
          INTO vn_cnt
          FROM ch09_departments
         WHERE department_id = p_department_id;

        IF vn_cnt = 0 THEN
            DBMS_OUTPUT.PUT_LINE(p_department_id || '번 부서가 없어 삭제할 수 없습니다.');
            RETURN;
        END IF;

        SELECT COUNT(*)
          INTO vn_cnt
          FROM employees
         WHERE department_id = p_department_id;

        IF vn_cnt > 0 THEN
            DBMS_OUTPUT.PUT_LINE('경고 : ' || p_department_id || '번 부서에 사원이 '
                                 || vn_cnt || '명 있어 삭제할 수 없습니다.');
            RETURN;
        END IF;

        DELETE ch09_departments
         WHERE department_id = p_department_id;

        DBMS_OUTPUT.PUT_LINE(p_department_id || '번 부서 삭제 완료');
    END IF;

    COMMIT;
END;
/

--- 06. 확인 ---
EXEC my_dept_manage_proc(300, '신규부서', 10, 'upsert');
EXEC my_dept_manage_proc(300, '신규부서(수정)', 10, 'upsert');
SELECT * FROM ch09_departments WHERE department_id = 300;

EXEC my_dept_manage_proc(50, NULL, NULL, 'delete');
EXEC my_dept_manage_proc(300, NULL, NULL, 'delete');