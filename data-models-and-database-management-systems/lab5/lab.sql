--Лабораторная выполняется в СУБД  Oracle.
--Cкопируйте файл  EDU5.txt  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной.
--Произведите запуск Oracle.  Запустите скрипт EDU5.txt на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Прохоров Михаил Андреевич, подгруппа 3б, курс 4.
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных Вами программ после пунктов 1-10.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в  edufpmi.bsu.by
--(при возникновении непредвиденной ситуации, приводящей к невозможности сохранения в edufpmi.bsu.by, высылается на почту преподавателя до дедлайна).
--НЕ ДОПУСКАЕТСЯ УДАЛЕНИЕ ЛЮБЫХ (в том числе и первых) СТРОК ИЗ ДАННОГО ТЕКСТА!!!
--РАБОТА ВЫПОЛНЯЕТСЯ ИНДИВИДУАЛЬНО!!!
--ПРИ НЕПРАВИЛЬНОМ ОФОРМЛЕНИИ ИЛИ КОПИРОВАНИИ У ДРУГОГО СТУДЕНТА, РАБОТА НЕ ПРОВЕРЯЕТСЯ И ПОЛУЧАЕТ ОЦЕНКУ 0!!!

--1. Создайте триггер, который при обновлении записи в таблице CAREER
-- должен отменять действие и сообщать об ошибке
-- a) если код должности Programmer работающего сотрудника  изменяется на код должности Driver.
CREATE OR REPLACE TRIGGER check_job_update
BEFORE UPDATE ON career
FOR EACH ROW
BEGIN
    IF :NEW.jobno = 1005 AND :OLD.jobno = 1008 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot change job from Programmer to Driver');
    END IF;
END;
/


-- b) измените запись в таблице CAREER для сотрудника с номером 403, указав код должности 1005.
UPDATE career
SET jobno = 1005
WHERE empno = 403;


-- c) измените запись в таблице CAREER для сотрудника с номером 201, указав код должности 1005.
UPDATE career
SET jobno = 1005
WHERE empno = 201;


-- d) удалите триггер.
DROP TRIGGER check_job_update;


rollback;

--2. Создайте триггер, который при обновлении записи в таблице EMP должен отменять действие и сообщать об ошибке:
-- a) если для сотрудника c семейным положением вдовец/вдова (w), увеличивается количество детей.
CREATE OR REPLACE TRIGGER check_child_update
BEFORE UPDATE ON emp
FOR EACH ROW
BEGIN
    IF :OLD.mstat = 'w' AND :NEW.nchild > :OLD.nchild THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot increase the number of children for a widowed employee');
    END IF;
END;
/


-- b) измените запись в таблицу EMP для сотрудника 'Olivia Direnzo', указав количество детей равным 1;.
UPDATE emp
SET nchild = 1
WHERE empname = 'Olivia Direnzo';


-- d) удалите триггер.
DROP TRIGGER check_child_update;


rollback;

--3. Создайте триггер, который при обновлении записи в таблице EMP
-- a) должен отменять действие и сообщать об ошибке, если для сотрудника (сотрудницы), родившегося (родившейся) до 01.01.1975 и находящегося
-- (находящейся) в браке (m) число детей увеличивается.
CREATE OR REPLACE TRIGGER check_child_update_age_married
BEFORE UPDATE ON emp
FOR EACH ROW
BEGIN
    IF :NEW.birthdate < TO_DATE('01-01-1975', 'DD-MM-YYYY') AND
       :NEW.mstat = 'm' AND
       :NEW.nchild > :OLD.nchild THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot increase the number of children for an employee born before 01.01.1975 and currently married');
    END IF;
END;
/


-- b) измените запись в таблицу EMP для сотрудника с номером 401, указав количество детей равным 1.
UPDATE emp
SET nchild = 1
WHERE empno = 401;


-- c) удалите триггер.
DROP TRIGGER check_child_update_age_married;


rollback;

--4. Создать триггер, который
-- a) отменяет начисление премии (таблица bonus)
-- неработающим в настоящий момент в организации сотрудникам и сообщает об ошибке.
CREATE OR REPLACE TRIGGER check_bonus_for_inactive_employees
BEFORE INSERT ON bonus
FOR EACH ROW
DECLARE
    v_emp_status VARCHAR(2);
BEGIN
    SELECT mstat INTO v_emp_status
    FROM emp
    WHERE empno = :NEW.empno;

    IF v_emp_status != 'w' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot award bonus to inactive employees');
    END IF;
END;
/


-- b) вставте запись в таблицу bonus  (209, 11, 2022, 300, Null).
INSERT INTO bonus (empno, month, year, bonvalue, tax)
VALUES (209, 11, 2022, 300, NULL);


-- c) вставте запись в таблицу bonus  (329, 11, 2022, 300, Null).
INSERT INTO bonus (empno, month, year, bonvalue, tax)
VALUES (329, 11, 2022, 300, NULL);


-- d) удалите триггер.
DROP TRIGGER check_bonus_for_inactive_employees;


rollback;

--5. Создайте триггер, который
-- a) после выполнения действия (вставка, обновление, удаление) с таблицей dept
-- создаёт запись в таблице temp_table, с указанием названия действия (delete, update, insert) активизирующего триггер.
CREATE OR REPLACE TRIGGER dept_action_trigger
AFTER INSERT OR UPDATE OR DELETE ON dept
FOR EACH ROW
DECLARE
    v_action VARCHAR2(6);
BEGIN
    IF INSERTING THEN
        v_action := 'insert';
    ELSIF UPDATING THEN
        v_action := 'update';
    ELSIF DELETING THEN
        v_action := 'delete';
    END IF;

    INSERT INTO temp_table (msg) VALUES (v_action);
END;
/


-- b) добавте запись о новом отделе ('B09', 'Maintenance', 'Belarus, Minsk');.
INSERT INTO dept (deptid, deptname, deptaddress)
VALUES ('B09', 'Maintenance', 'Belarus, Minsk');


-- c) удалите добавленную (пункт b) запись.
DELETE FROM dept
WHERE deptid = 'B09';


-- d) удалите триггер.
DROP TRIGGER dept_action_trigger;


rollback;

--6. Создайте триггер, который
-- a) до выполнения обновления в таблице job столбца minsalary в записях, относящихся к должностям Manager, Salesman, Clerk, Driver, отменяет действие,
-- сообщает об ошибке и создаёт запись в таблице temp_table c указанием "more than 15%", если должностной оклад изменяется более чем на 15% (увеличивается или уменьшается).
CREATE OR REPLACE TRIGGER check_salary_update
BEFORE UPDATE ON job
FOR EACH ROW
DECLARE
    v_old_salary real;
    v_percent_change real;
BEGIN
    IF :NEW.jobname IN ('Manager', 'Salesman', 'Clerk', 'Driver') THEN
        SELECT minsalary INTO v_old_salary
        FROM job
        WHERE jobno = :NEW.jobno;

        v_percent_change := ABS((:NEW.minsalary - v_old_salary) / v_old_salary) * 100;

        IF v_percent_change > 15 THEN
            INSERT INTO temp_table (msg) VALUES ('more than 15%');
            RAISE_APPLICATION_ERROR(-20001, 'Salary change more than 15% is not allowed');
        END IF;
    END IF;
END;
/


-- b) измените минимальную (minsalary) зарплату продавца (Salesman) в таблице job, положив её равной 1800.
UPDATE job
SET minsalary = 1800
WHERE jobname = 'Salesman';


-- c) удалите триггер.
DROP TRIGGER check_salary_update;


rollback;

--7. Создайте триггер, который
-- a) при добавлении записи в таблице Bonus отменяет действие, сообщает об ошибке
-- и создаёт запись в таблице temp_table с указанием "more than three times",
-- если сотруднику, указанному в новой записи, в год, к которому относится вставляемая запись, премия уже начислялась трижды.
CREATE OR REPLACE TRIGGER check_bonus_limit
BEFORE INSERT ON bonus
FOR EACH ROW
DECLARE
    v_bonus_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_bonus_count
    FROM bonus
    WHERE empno = :NEW.empno
    AND year = :NEW.year;

    IF v_bonus_count >= 3 THEN
        INSERT INTO temp_table (msg) VALUES ('more than three times');
        RAISE_APPLICATION_ERROR(-20001, 'Cannot award bonus more than three times in a year');
    END IF;
END;
/


-- b) вставте новую запись в таблицу Bonus (601, 11, 2023, 500, Null).
INSERT INTO bonus (empno, month, year, bonvalue, tax)
VALUES (601, 11, 2023, 500, NULL);


-- c) удалите триггер.
DROP TRIGGER check_bonus_limit;


rollback;

--8. Создайте триггер, который
-- a) запрещает создание отдела (таблица Dept) по адресу, по которому уже существует отдел с тем же названием (столбец Deptname),
-- сообщает об ошибке и заносит в таблицу temp_table запись с указанием "such a department already exists at the address".
CREATE OR REPLACE TRIGGER check_dept_duplicate
BEFORE INSERT ON dept
FOR EACH ROW
DECLARE
    v_existing_deptname varchar2(20);
BEGIN
    SELECT deptname
    INTO v_existing_deptname
    FROM dept
    WHERE deptaddress = :NEW.deptaddress;

    IF v_existing_deptname = :NEW.deptname THEN
        INSERT INTO temp_table (msg) VALUES ('such a department already exists at the address');
        RAISE_APPLICATION_ERROR(-20001, 'such a department already exists at the address');
    END IF;
END;
/


-- b) вставте в таблицу Dept новую запись 'U09', 'Research', 'USA, Dallas'
INSERT INTO dept (deptid, deptname, deptaddress)
VALUES ('U09', 'Research', 'USA, Dallas');

-- c) удалите триггер.
DROP TRIGGER check_dept_duplicate;


rollback;

--9. Создайте триггер, который
-- a) запрещает удалять из таблицы Dept запись, имеющую уникальное (не входящее в другие записи) название отдела (Deptname),
-- сообщает об ошибке и заносит в таблицу temp_table запись с фразой "the department cannot be deleted".
CREATE OR REPLACE TRIGGER prevent_dept_delete
BEFORE DELETE ON dept
FOR EACH ROW
DECLARE
    v_deptname_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_deptname_count
    FROM dept
    WHERE deptname = :OLD.deptname
    AND deptid != :OLD.deptid;

    IF v_deptname_count = 0 THEN
        INSERT INTO temp_table (msg) VALUES ('the department cannot be deleted');
        RAISE_APPLICATION_ERROR(-20001, 'the department cannot be deleted');
    END IF;
END;
/


-- b) удалить из таблицы Dept запись об отделе U01;
DELETE FROM dept WHERE deptid = 'U01';

-- c)  удалить из таблицы Dept запись об отделе B05.
DELETE FROM dept WHERE deptid = 'B05';

-- e) удалите триггер.
DROP TRIGGER prevent_dept_delete;


rollback;

--10. Создайте триггер, который
-- a) в таблице Career запрещает изменять любые данные уже не работающего сотрудника , и сообщает об ошибке.
CREATE OR REPLACE TRIGGER prevent_career_update
BEFORE UPDATE ON career
FOR EACH ROW
DECLARE
    v_employment_status varchar2(1);
BEGIN
    SELECT mstat
    INTO v_employment_status
    FROM emp
    WHERE empno = :NEW.empno;

    IF v_employment_status = 'w' THEN
        RAISE_APPLICATION_ERROR(-20001, 'cannot update data for an inactive employee');
    END IF;
END;
/


-- b) измените в записи для сотрудника с номером 105 (Empno) id отдела (Deptid) на B02.
UPDATE career
SET deptid = 'B02'
WHERE empno = 105;


-- с) удалите триггер.
DROP TRIGGER prevent_career_update;


rollback;

