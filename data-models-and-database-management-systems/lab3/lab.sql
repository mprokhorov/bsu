--Лабораторная выполняется в СУБД  Oracle.
--Скопируйте файлы EDU3.txt  в каталог C:\TEMP.
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной. Таблица Bonus имеет дополнительный столбец tax (налог) со значениями null.
--Произведите запуск инструментария Oracle и соеденитесь с БД.  Запустите скрипты EDU3.txt на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Прохоров Михаил Андреевич, группа 3, курс 4.
--Файл с отчётом о выполнении лабораторной создаётся путём вставки, созданных Вами скриптов.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в  edufpmi.bsu.by (при возникновении непредвиденной ситуации,
--приводящей к невозможности сохранения в edufpmi.bsu.by, высылается на почту преподавателя до дедлайна).
--НЕ ДОПУСКАЕТСЯ УДАЛЕНИЕ ЛЮБЫХ (в том числе и первых) СТРОК ИЗ ДАННОГО ТЕКСТА, И ОПЕРАТОРА ROLLBACK!!!
--РАБОТА ВЫПОЛНЯЕТСЯ ИНДИВИДУАЛЬНО!!!
--ПРИ НЕПРАВИЛЬНОМ ОФОРМЛЕНИИ ИЛИ КОПИРОВАНИИ У ДРУГОГО СТУДЕНТА, РАБОТА НЕ ПРОВЕРЯЕТСЯ И ПОЛУЧАЕТ ОЦЕНКУ 0!!!
--Вам необходимо создать представления, занести в первом из них данные за октябрь текущего года о начислении премий, создать
--ананимные (не хранимые) блоки для начисления помесячного налога на прибыль  за все годы (c 2018 по 2023 включительно) и занесения его в соответсвующие записи таблицы Bonus.
--Налог вычисляется в месяц начисления премии по следующему правилу (налогообложение обратнопропорционально стажу работы от даты последнего приёма на работу в организацию)):
--налог равен 0%, если стаж работы сотрудника от даты последнего приёма на работу до начала рассматриваемого месяца и года больше или равен 15 годам,
--равен 5%, если стаж работы сотрудника от даты последнего приёма на работу до начала рассматриваемого месяца и года меньше 15 лет, но больше или равен 10 годам,
--равен 10%, если стаж работы сотрудника от даты последнего приёма на работу до начала рассматриваемого месяца и года меньше 10 лет, но больше или равен 5 годам,
--равен 25%, если стаж работы сотрудника от даты последнего приёма на работу до начала рассматриваемого месяца и года меньше 5 лет.
--Тексты заданий:
--1. a)	Создайте представление с именем ViewBonus, содержащее четыре первых столбца (Empno, Month, Year, Bonvalue) таблицы Bonus
--и сведения о премиях только за 2021, 2022, 2023 годы.
create view ViewBonus as
select empno, month, year, bonvalue
from bonus
where year in (2021, 2022, 2023);

--b) Вставте в таблицу Bonus через представление ViewBonus следующие записи
--(503, 10, 2023, 700)
--(601, 10, 2023, 1200)
insert into ViewBonus (empno, month, year, bonvalue)
values (503, 10, 2023, 700), (601, 10, 2023, 1200);

--c) Cоздайте запрос, выдающий информацию из таблицы Bonus за октябрь 2023 год.
select *
from bonus
where month = 10 and year = 2023;

--d) Удалите представление ViewBonus.
drop view ViewBonus;

--2. a) Создайте  представление с именем AIEMP, содержащее полную информацию о работающих в настоящее время в организации сотрудниках (номер сотрудника,
--имя и фамилию сотрудника, дату рождения, название должности сотрудника, название отдела, где работает сотрудник, дату приёма на работу) в отделах U01, U02, U03, U04.
--Отключить в представлении возможность работы с ним DML операторам.
create view AIEMP as
select e.empno, e.empname, e.birthdate, j.jobname, d.deptname, c.startdate
from emp e
join career c on e.empno = c.empno
join job j on c.jobno = j.jobno
join dept d on c.deptid = d.deptid
where c.enddate is null and c.deptid in ('U01', 'U02', 'U03', 'U04')
with read only;

--b) Постройте запрос, выдающий всю информацию из представления.
SELECT *
FROM AIEMP;

--c) Удалите представление AIEMP.
DROP VIEW IF EXISTS AIEMP;

--3. Составьте программы (в виде ананимных блоков PL/SQL!!!)  вычисления налога за всё время его начисления (2018-2023 годы)
--и вставки его в таблицу Bonus (столбец tax):
--a) с помощью простого цикла (loop) с курсором и оператора if или опретора case для определения условия выхода из цикла;
DECLARE
  v_empno bonus.empno%TYPE;
  v_month smallint;
  v_year  integer;
  v_bonvalue real;
  v_tax real;
  v_experience integer;
  v_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_cursor FOR
    SELECT empno, month, year, bonvalue
    FROM bonus
    WHERE year BETWEEN 2018 AND 2023;

  LOOP
    FETCH v_cursor INTO v_empno, v_month, v_year, v_bonvalue;
    EXIT WHEN v_cursor%NOTFOUND;

    SELECT EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM MAX(startdate)) INTO v_experience
    FROM career
    WHERE empno = v_empno;

    CASE
      WHEN v_experience >= 15 THEN v_tax := 0;
      WHEN v_experience >= 10 THEN v_tax := 0.05;
      WHEN v_experience >= 5  THEN v_tax := 0.1;
      ELSE v_tax := 0.25;
    END CASE;

    UPDATE bonus
    SET tax = v_tax
    WHERE empno = v_empno AND month = v_month AND year = v_year;
  END LOOP;

  CLOSE v_cursor;
END;
/

--выполните программу и создайте запрос для просмотра результатов её выполнения.
SELECT * FROM bonus;
rollback;
-- b)   с помощью курсорного цикла FOR;
DECLARE
  v_empno bonus.empno%TYPE;
  v_month smallint;
  v_year  integer;
  v_bonvalue real;
  v_tax real;
BEGIN
  FOR bonus_rec IN (SELECT empno, month, year, bonvalue
                    FROM bonus
                    WHERE year BETWEEN 2018 AND 2023)
  LOOP
    SELECT EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM MAX(startdate)) INTO v_experience
    FROM career
    WHERE empno = bonus_rec.empno;

    CASE
      WHEN v_experience >= 15 THEN v_tax := 0;
      WHEN v_experience >= 10 THEN v_tax := 0.05;
      WHEN v_experience >= 5  THEN v_tax := 0.1;
      ELSE v_tax := 0.25;
    END CASE;

    UPDATE bonus
    SET tax = v_tax
    WHERE empno = bonus_rec.empno AND month = bonus_rec.month AND year = bonus_rec.year;
  END LOOP;
END;
/

--выполните программу и создайте запрос для просмотра результатов её выполнения.
SELECT * FROM bonus;

rollback;
-- c) с помощью курсора с параметром, передавая номер сотрудника, для которого необходимо посчитать налог.
DECLARE
  v_empno bonus.empno%TYPE := 401;
  v_month smallint;
  v_year  integer;
  v_bonvalue real;
  v_tax real;
  v_experience integer;
  v_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_cursor FOR
    SELECT empno, month, year, bonvalue
    FROM bonus
    WHERE empno = v_empno AND year BETWEEN 2018 AND 2023;

  LOOP
    FETCH v_cursor INTO v_empno, v_month, v_year, v_bonvalue;
    EXIT WHEN v_cursor%NOTFOUND;

    SELECT EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM MAX(startdate)) INTO v_experience
    FROM career
    WHERE empno = v_empno;

    CASE
      WHEN v_experience >= 15 THEN v_tax := 0;
      WHEN v_experience >= 10 THEN v_tax := 0.05;
      WHEN v_experience >= 5  THEN v_tax := 0.1;
      ELSE v_tax := 0.25;
    END CASE;

    UPDATE bonus
    SET tax = v_tax
    WHERE empno = v_empno AND month = v_month AND year = v_year;
  END LOOP;

  CLOSE v_cursor;
END;
/


--выполните программу для сотрудника с номером 401  и создайте запрос для просмотра результатов её выполнения.
SELECT * FROM bonus;


rollback;
--
--4.   Создайте хранимую процедуру ProCountTax, вычисления налога и вставки его в таблицу Bonus за всё время начислений для конкретного сотрудника.
--В качестве параметров передать проценты налога (стаж не менее 15 лет; стаж не менее 10 лет, но меньше 15 лет; стах не менее 5, но меньше 10 лет;
--стаж меньше 5 лет ), номер сотрудника.
CREATE OR REPLACE PROCEDURE ProCountTax(
  p_tax15 IN REAL,
  p_tax10 IN REAL,
  p_tax5  IN REAL,
  p_tax25 IN REAL,
  p_empno IN bonus.empno%TYPE
) AS
  v_month SMALLINT;
  v_year  INTEGER;
  v_bonvalue REAL;
  v_tax REAL;
  v_experience INTEGER;
  CURSOR bonus_cursor IS
    SELECT month, year, bonvalue
    FROM bonus
    WHERE empno = p_empno AND year BETWEEN 2018 AND 2023;

BEGIN
  FOR bonus_rec IN bonus_cursor
  LOOP
    SELECT EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM MAX(startdate)) INTO v_experience
    FROM career
    WHERE empno = p_empno;

    CASE
      WHEN v_experience >= 15 THEN v_tax := p_tax15;
      WHEN v_experience >= 10 THEN v_tax := p_tax10;
      WHEN v_experience >= 5  THEN v_tax := p_tax5;
      ELSE v_tax := p_tax25;
    END CASE;

    UPDATE bonus
    SET tax = v_tax
    WHERE empno = p_empno AND month = bonus_rec.month AND year = bonus_rec.year;
  END LOOP;
END ProCountTax;
/

--выполните процедуру, задав значения параметров 3%, 6%, 9%, 12%, 404 и создайте запрос для просмотра результатов её выполнения.
EXEC ProCountTax(3, 6, 9, 12, 404);

SELECT * FROM bonus WHERE empno = 404;


rollback;
--5.   Создайте хранимую функцию FunCountTax, вычисляющую суммарный налог на премии сотрудника за всё время начислений. В качестве параметров передать
--процент налога (стаж не менее 15 лет; стаж не менее 10 лет, но меньше 15 лет; стах не менее 5, но меньше 10 лет;
--стаж меньше 5 лет ), номер сотрудника. Возвращаемое значение – суммарный налог.
CREATE OR REPLACE FUNCTION FunCountTax(
  p_tax15 IN REAL,
  p_tax10 IN REAL,
  p_tax5  IN REAL,
  p_tax25 IN REAL,
  p_empno IN bonus.empno%TYPE
) RETURN REAL AS
  v_total_tax REAL := 0;
  v_month SMALLINT;
  v_year  INTEGER;
  v_bonvalue REAL;
  v_tax REAL;
  v_experience INTEGER;
  CURSOR bonus_cursor IS
    SELECT month, year, bonvalue
    FROM bonus
    WHERE empno = p_empno AND year BETWEEN 2018 AND 2023;

BEGIN
  FOR bonus_rec IN bonus_cursor
  LOOP
    SELECT EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM MAX(startdate)) INTO v_experience
    FROM career
    WHERE empno = p_empno;

    CASE
      WHEN v_experience >= 15 THEN v_tax := p_tax15;
      WHEN v_experience >= 10 THEN v_tax := p_tax10;
      WHEN v_experience >= 5  THEN v_tax := p_tax5;
      ELSE v_tax := p_tax25;
    END CASE;

    v_total_tax := v_total_tax + (v_tax * bonus_rec.bonvalue);
  END LOOP;

  RETURN v_total_tax;
END FunCountTax;
/

--создайте блок для  вычисления функции, с заданными значениями параметров 1%, 5%, 9%, 13%, 505  и создайте запрос для просмотра результатов его выполнения.
DECLARE
  v_result REAL;
BEGIN
  v_result := FunCountTax(1, 5, 9, 13, 505);
  DBMS_OUTPUT.PUT_LINE('Total Tax: ' || v_result);
END;
/

rollback;
--6. Удалите процедуру ProCountTax и функцию FunCountTax.
DROP PROCEDURE IF EXISTS ProCountTax;
/

DROP FUNCTION IF EXISTS FunCountTax;
/

--7. Удалите из талюицы Bonus записи за октябрь 2023 года.
DELETE FROM bonus
WHERE month = 10 AND year = 2023;
