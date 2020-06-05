SET SERVEROUTPUT ON;

-- 4) Implement a few procedures for the database 
-- Insert Procedure
CREATE OR REPLACE PROCEDURE insert_emp IS
    p_emp_id NUMBER := SEQ_EMPLOYEE.nextval;
    p_position_id NUMBER := 1;
    p_address_id NUMBER := 1;
    p_first_name VARCHAR(25):= 'Manaf';
    p_last_name VARCHAR(30):= 'Agaev';
    p_email VARCHAR(40) := 'MANAFAGAEV@GMAIL.COM';
    p_birthdate DATE := to_date('12/03/2010','dd/mm/yyyy');
    p_gender CHAR(1) := 'M';
    check_email VARCHAR(40);
BEGIN
    INSERT INTO employee VALUES(p_emp_id, p_first_name, p_last_name, p_birthdate, p_gender, p_email, p_position_id, p_address_id);
END insert_emp;
/

-- 5) Use transaction in your procedures 
-- Increase Salary Procedure
CREATE OR REPLACE PROCEDURE inc_salary (percent NUMBER)
IS
BEGIN
    UPDATE employment_history
    SET salary = (salary * percent)/100 + salary
    WHERE salary < 2000;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO no_inc;
    RAISE;
END inc_salary;
/

-- Procedures call
BEGIN
  insert_emp;
END;
/

BEGIN
 inc_salary(10);
END;
/

-- 6) Implement at least two triggers
-- DML Trigger
CREATE OR REPLACE TRIGGER alter_emp
   BEFORE INSERT OR DELETE OR UPDATE ON employee
   FOR EACH ROW 
   DECLARE
   date_diff_in_years number;
   v_user varchar2(20);
   BEGIN  
    SELECT (sysdate-:new.birth_date)/365.0, user into date_diff_in_years, v_user from dual;
    IF date_diff_in_years < 18 THEN
        RAISE_APPLICATION_ERROR (num => -20000,msg => 'The Age should be greater than 18');
    ELSIF DELETING THEN
    DBMS_OUTPUT.PUT_LINE('DML Trigger called. One Row Deleted By ' ||v_user);
    ELSIF UPDATING THEN
        DBMS_OUTPUT.PUT_LINE('DML Trigger called. One Row Updated By ' ||v_user);
    ELSE
        DBMS_OUTPUT.PUT_LINE('DML Trigger called. One Row Inserted By ' ||v_user);
    END IF;
   END;
/
   
-- DDL Trigger
CREATE OR REPLACE TRIGGER audit_tr 
AFTER DDL ON SCHEMA
BEGIN
    INSERT INTO schema_audit VALUES (
sysdate, 
sys_context('USERENV','CURRENT_USER'), 
ora_dict_obj_type, 
ora_dict_obj_name, 
ora_sysevent);
END;
/

-- 7) Implement sample SQL queries to receive data from the database using select-from-join-where-group by-having-order by clauses

-- Employee's salary < 2000
SELECT employee.first_name AS name, employee.last_name AS surname, 
position.position_name AS position,employment_history.salary AS earnings 
FROM employee, position, employment_history WHERE employee_id = position_id 
AND position_id = emp_dept_id AND salary < 2000 ORDER BY salary;

-- Count Employee who has < 2000
SELECT salary, COUNT(*) AS salary_count FROM employment_history 
GROUP BY salary HAVING salary < 2000 ORDER BY salary_count;

-- Join Country, City, Address
SELECT country.country_name, city.city_name, address.street 
FROM country, city, address WHERE country_id = city_id 
AND city_id = address_id ORDER BY country_name;


-- Additional
-- 8) Display position and number of employees having a given position
SELECT p.position_name AS position, COUNT(*) AS empCount FROM position p 
INNER JOIN employee e ON p.position_id = e.position_position_id 
AND p.position_name LIKE '%Administration Assistant%' GROUP BY p.position_name;


-- 9) Get the oldest female and the oldest male and thier salary, department,
SELECT e.first_name AS name, e.last_name AS surname, e.birth_date AS birthday,e.gender as gender, 
h.salary AS earnings, d.department_name AS department FROM employee e, department d, 
employment_history h WHERE e.employee_id = h.employee_employee_id AND h.emp_dept_id = d.department_id 
AND e.birth_date IN (SELECT min(e.birth_date) FROM employment_history h INNER JOIN employee e 
ON h.employee_employee_id = e.employee_id GROUP BY e.gender);


--10) Get employees who changed department.
-- Option One
SELECT e.first_name as name, e.last_name FROM employee e, employment_history h, department d 
WHERE e.employee_id = h.employee_employee_id AND d.department_id = h.department_department_id 
AND h.department_department_id IN(SELECT h.employee_employee_id FROM employment_history h
GROUP BY h.employee_employee_id HAVING COUNT(h.employee_employee_id) > 1);

-- Option Second
SELECT e.first_name as name, e.last_name as surname, h.start_date, h.end_date, h.salary 
as salary, d.department_name as departament FROM employee e, employment_history h, 
department d WHERE e.employee_id = h.employee_employee_id AND d.department_id =
h.department_department_id AND h.employee_employee_id != h.department_department_id;

-- Option Third
SELECT e.first_name as name, e.last_name as surname, h.start_date, h.end_date, h.salary as salary, 
d.department_name as departament FROM employee e, employment_history h, department d 
WHERE e.employee_id = h.employee_employee_id AND d.department_id = h.department_department_id 
AND h.start_date IN (SELECT MAX(h.start_date) FROM employment_history h INNER JOIN employee e 
ON h.employee_employee_id = e.employee_id GROUP BY h.employee_employee_id HAVING COUNT(h.employee_employee_id) > 1);


-- 11) Get departments having the most employees.
SELECT d.department_name AS department, count(*) as employee FROM department d 
INNER JOIN employee e ON d.department_id = e.position_position_id GROUP BY d.department_name 
HAVING COUNT(*) = (SELECT MAX(myCount) FROM(SELECT count(*) as myCount FROM department d 
INNER JOIN employee e ON d.department_id = e.position_position_id GROUP BY d.department_name));

-- 12) Get employees (first name and last name) and their age who are the youngest.
-- The youngest
SELECT e.first_name AS name, e.last_name AS surname, e.birth_date 
FROM employee e WHERE birth_date = (SELECT max(birth_date) from employee);


-- UPDATE employee SET email= 'MANAFAGAEV@GMAIL.COM' WHERE employee_id = 11;
-- DELETE FROM employee WHERE employee_id = 11;
-- CREATE TABLE temp (temp NUMBER);
-- DROP TABLE temp;
-- SELECT * FROM employment_history;
-- DELETE FROM address;
-- DROP SEQUENCE SEQ_ADDRESS;
-- ALTER TABLE employee DROP CONSTRAINT position_pk;
-- DROP TRIGGER alter_emp;

-- UPDATE employment_history SET salary= 1500 WHERE emp_dept_id = 1;
-- UPDATE employment_history SET salary= 1700 WHERE emp_dept_id = 2;
-- UPDATE employment_history SET salary= 1800 WHERE emp_dept_id = 8;
-- UPDATE employment_history SET salary= 1500 WHERE emp_dept_id = 9;
-- UPDATE employment_history SET salary= 1300 WHERE emp_dept_id = 10;