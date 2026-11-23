--- 01. ch10_departments 테이블 생성 ---
CREATE TABLE ch10_departments
AS
SELECT department_id, department_name
  FROM departments;

ALTER TABLE ch10_departments ADD CONSTRAINTS pk_ch10_departments PRIMARY KEY (department_id);

--- 01. ch10_iud_dep_proc 프로시저 ---
CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
    p_department_id    ch10_departments.department_id%TYPE,
    p_department_name  ch10_departments.department_name%TYPE,
    p_flag             VARCHAR2 )
IS
BEGIN
    IF p_flag = 'I' THEN
        INSERT INTO ch10_departments
        VALUES (p_department_id, p_department_name);

    ELSIF p_flag = 'U' THEN
        UPDATE ch10_departments
           SET department_name = p_department_name
         WHERE department_id   = p_department_id;

    ELSIF p_flag = 'D' THEN
        DELETE ch10_departments
         WHERE department_id = p_department_id;
    END IF;

    COMMIT;
END;
/

--- 02. 실행 ---
EXEC ch10_iud_dep_proc (10, '총무기획부', 'I');

--- 03. 시스템 예외 처리 추가 ---
CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
    p_department_id    ch10_departments.department_id%TYPE,
    p_department_name  ch10_departments.department_name%TYPE,
    p_flag             VARCHAR2 )
IS
BEGIN
    IF p_flag = 'I' THEN
        INSERT INTO ch10_departments
        VALUES (p_department_id, p_department_name);

    ELSIF p_flag = 'U' THEN
        UPDATE ch10_departments
           SET department_name = p_department_name
         WHERE department_id   = p_department_id;

    ELSIF p_flag = 'D' THEN
        DELETE ch10_departments
         WHERE department_id = p_department_id;
    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 코드 : ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('오류 내용 : ' || SQLERRM);
        ROLLBACK;
END;
/

--- 03. 확인 ---
EXEC ch10_iud_dep_proc (10, '총무기획부', 'I');

--- 04. 사용자 정의 예외 ---
CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
    p_department_id    ch10_departments.department_id%TYPE,
    p_department_name  ch10_departments.department_name%TYPE,
    p_flag             VARCHAR2 )
IS
    vn_cnt         NUMBER := 0;
    dept_exception EXCEPTION;
BEGIN
    IF p_flag = 'I' THEN
        INSERT INTO ch10_departments
        VALUES (p_department_id, p_department_name);

    ELSIF p_flag = 'U' THEN
        UPDATE ch10_departments
           SET department_name = p_department_name
         WHERE department_id   = p_department_id;

    ELSIF p_flag = 'D' THEN
        SELECT COUNT(*)
          INTO vn_cnt
          FROM employees
         WHERE department_id = p_department_id;

        IF vn_cnt > 0 THEN
            RAISE dept_exception;
        END IF;

        DELETE ch10_departments
         WHERE department_id = p_department_id;
    END IF;

    COMMIT;

EXCEPTION
    WHEN dept_exception THEN
        DBMS_OUTPUT.PUT_LINE('해당 부서에 할당된 사원이 존재해 삭제할 수 없습니다!');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 코드 : ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('오류 내용 : ' || SQLERRM);
        ROLLBACK;
END;
/

--- 04. 확인 ---
EXEC ch10_iud_dep_proc (50, NULL, 'D');

--- 05. 사용자 정의 예외를 -20000으로 매핑 ---
CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
    p_department_id    ch10_departments.department_id%TYPE,
    p_department_name  ch10_departments.department_name%TYPE,
    p_flag             VARCHAR2 )
IS
    vn_cnt         NUMBER := 0;
    dept_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT (dept_exception, -20000);
BEGIN
    IF p_flag = 'I' THEN
        INSERT INTO ch10_departments
        VALUES (p_department_id, p_department_name);

    ELSIF p_flag = 'U' THEN
        UPDATE ch10_departments
           SET department_name = p_department_name
         WHERE department_id   = p_department_id;

    ELSIF p_flag = 'D' THEN
        SELECT COUNT(*)
          INTO vn_cnt
          FROM employees
         WHERE department_id = p_department_id;

        IF vn_cnt > 0 THEN
            RAISE dept_exception;
        END IF;

        DELETE ch10_departments
         WHERE department_id = p_department_id;
    END IF;

    COMMIT;

EXCEPTION
    WHEN dept_exception THEN
        DBMS_OUTPUT.PUT_LINE('오류 코드 : ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('해당 부서에 할당된 사원이 존재해 삭제할 수 없습니다!');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 코드 : ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('오류 내용 : ' || SQLERRM);
        ROLLBACK;
END;
/

--- 05. 확인 ---
EXEC ch10_iud_dep_proc (50, NULL, 'D');

--- 06. RAISE_APPLICATION_ERROR ---
CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
    p_department_id    ch10_departments.department_id%TYPE,
    p_department_name  ch10_departments.department_name%TYPE,
    p_flag             VARCHAR2 )
IS
    vn_cnt NUMBER := 0;
BEGIN
    IF p_flag = 'I' THEN
        INSERT INTO ch10_departments
        VALUES (p_department_id, p_department_name);

    ELSIF p_flag = 'U' THEN
        UPDATE ch10_departments
           SET department_name = p_department_name
         WHERE department_id   = p_department_id;

    ELSIF p_flag = 'D' THEN
        SELECT COUNT(*)
          INTO vn_cnt
          FROM employees
         WHERE department_id = p_department_id;

        IF vn_cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20000, '해당 부서에 할당된 사원이 존재해 삭제할 수 없습니다!');
        END IF;

        DELETE ch10_departments
         WHERE department_id = p_department_id;
    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 코드 : ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('오류 내용 : ' || SQLERRM);
        ROLLBACK;
END;
/

--- 06. 확인 ---
EXEC ch10_iud_dep_proc (50, NULL, 'D');