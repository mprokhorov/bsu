--Выбирите СУБД Oracle для выполнения лабораторной.
--Скопируйте файлы  EDU1.sql, EDU2.sql в каталог C:\TEMP .
--Раскройте файлы и ознакомтесь со скриптами создания и заполнения таблиц для выполнения лабораторной.
--Запустите скрипты EDU1.sql, EDU2.sql на выполнение.
--Вставте в эту строку Ваши ФИО, номер подгруппы, курса. ФИО Прохоров Михаил Андреевич, подгруппа 3б, курс 4.
--Файл с отчётом о выполнении лабораторной создаётся путём вставки соответсвующего DML-предложения после строки с текстом задания.
--Файл отчёта именуется фамилией студента в английской транскрипции, с расширением .txt и сохраняется в системе edufpmi.
--НЕ ДОПУСКАЕТСЯ УДАЛЕНИЕ ЛЮБЫХ (в том числе и первых) СТРОК ИЗ ДАННОГО ТЕКСТА И ОПЕРАТОРА ROLLBACK!!!
--РАБОТА ВЫПОЛНЯЕТСЯ ИНДИВИДУАЛЬНО!!!
--ПРИ НЕПРАВИЛЬНОМ ОФОРМЛЕНИИ ИЛИ КОПИРОВАНИИ У ДРУГОГО СТУДЕНТА, РАБОТА НЕ ПРОВЕРЯЕТСЯ И ПОЛУЧАЕТ ОЦЕНКУ 0!!!                   .
--Тексты заданий:
--1. Измените дату рождения сотрудника Kevin Loney на 14.12.1979 в таблице EMP.
UPDATE emp
SET birthdate = TO_DATE('14-12-1979', 'DD-MM-YYYY')
WHERE empname = 'Kevin Loney';
rollback;
--2. Установите минимальную зарплату в таблице JOB для продавца (Salesman) равной средней минимальной зарплате менеджера (Manager) и водителя (Driver).
UPDATE job
SET minsalary = (SELECT AVG(minsalary) FROM job WHERE jobname IN ('Manager', 'Driver'))
WHERE jobname = 'Salesman';
rollback;
--3. Поднимите минимальную зарплату в таблице JOB на 20% для водителей  (Driver) и опустите минимальную зарплату для исполнительных директоров (Executive Director) на 20%
--(одним оператором).
UPDATE job
SET minsalary = CASE
    WHEN jobname = 'Driver' THEN minsalary * 1.2
    WHEN jobname = 'Executive Director' THEN minsalary * 0.8
    ELSE minsalary
END;
rollback;
--4. Установите сотрудникам, получившим максимальную премию, в 2018 году, равной максимальной премии, начисленной в 2020 году.
UPDATE bonus
SET bonvalue = (
    SELECT MAX(b2.bonvalue)
    FROM bonus b2
    WHERE b2.year = 2020
)
WHERE (year, bonvalue) = (
    SELECT year, MAX(bonvalue)
    FROM bonus
    WHERE year = 2018
    GROUP BY year
);
rollback;
--5. Приведите в таблице JOB названия должностей, состоящих из одного слова, полностью к верхнему регистру.
UPDATE job
SET jobname = UPPER(jobname)
WHERE jobname NOT LIKE '% %';
rollback;
--6. Приведите в таблице EMP имена и фамилии служащих, имена которых начинаются на буквы 'M', ‘O’ и ‘F’, полностью к нижнему регистру.
UPDATE emp
SET empname = LOWER(empname)
WHERE SUBSTRING(empname FROM 1 FOR 1) IN ('M', 'O', 'F');
rollback;
--7. Приведите в таблице EMP имена служащих, с фамилиями Martin,  Mohov , полностью к верхнему регистру.
rollback;
--8. Оставте в таблице EMP только фамилии сотрудников (имена удалите).
UPDATE emp
SET empname = REGEXP_REPLACE(empname, '^[^ ]+ ', '');
rollback;
--9. Перенесите отдел продаж (Sales) по адресу отдела с кодом C02.
UPDATE dept
SET deptaddress = (SELECT deptaddress FROM dept WHERE deptid = 'C02')
WHERE deptname = 'Sales';
rollback;
--10. Добавьте нового сотрудника в таблицу EMP. Его номер равен  940, имя и фамилия ‘Frank Dibroff’, дата рождения ‘12-09-1978’.
INSERT INTO emp (empno, empname, birthdate)
VALUES (940, 'Frank Dibroff', TO_DATE('12-09-1978', 'dd-mm-yyyy'));
--11. Определите нового сотрудника (см. предыдущее задание) на работу в административный отдел (Administration) с адресом 'USA, San-Diego', начиная с текущей даты
--в должности водителя (Driver).
INSERT INTO career (jobno, empno, deptid, startdate)
VALUES ((SELECT jobno FROM job WHERE jobname = 'Driver'), 940, (SELECT deptid FROM dept WHERE deptname = 'Administration' AND deptaddress = 'USA, San-Diego'), CURRENT_DATE);
rollback;
--12. Удалите все записи из таблицы TMP_EMP. Добавьте в нее информацию о сотрудниках, которые работали инженерами (Engineer) или программистами (Programmer),
--но не работают на предприятии в настоящий момент.
DELETE FROM TMP_EMP;

INSERT INTO TMP_EMP (EMPNO, EMPNAME, BIRTHDATE)
SELECT empno, empname, birthdate
FROM emp
WHERE empno IN (SELECT empno FROM career WHERE jobno IN (SELECT jobno FROM job WHERE jobname IN ('Engineer', 'Programmer')) AND enddate IS NOT NULL);
rollback;
--13. Добавьте в таблицу TMP_EMP информацию о тех сотрудниках, которые трижды увольнялись, и не работают на предприятии в настоящий момент.
INSERT INTO TMP_EMP (EMPNO, EMPNAME, BIRTHDATE)
SELECT empno, empname, birthdate
FROM emp
WHERE empno IN (
    SELECT empno
    FROM career
    GROUP BY empno
    HAVING COUNT(DISTINCT enddate) = 3 AND COUNT(enddate IS NOT NULL) = 3
);
rollback;
--14. Добавьте в таблицу TMP_EMP информацию о тех сотрудниках, которые ни разу не увольнялись и работают на предприятии в настоящий момент.
INSERT INTO TMP_EMP (EMPNO, EMPNAME, BIRTHDATE)
SELECT empno, empname, birthdate
FROM emp
WHERE empno NOT IN (
    SELECT empno
    FROM career
    WHERE enddate IS NOT NULL
);
rollback;
--15. Удалите все записи из таблицы TMP_JOB и добавьте в нее информацию по тем должностям, на которых работает не более двух служащих  в  настоящий момент.
DELETE FROM TMP_JOB;

INSERT INTO TMP_JOB (JOBNO, JOBNAME, MINSALARY)
SELECT jobno, jobname, minsalary
FROM job
WHERE jobno IN (
    SELECT jobno
    FROM career
    GROUP BY jobno
    HAVING COUNT(empno) <= 2
);
rollback;
--16. Удалите всю информацию о начислениях премий сотрудникам в январе каждого года начислений.
DELETE FROM bonus
WHERE month = 1;
rollback;
--17. Начислите премию в размере 20% минимального должностного оклада всем сотрудникам, работающим на предприятии и имеющие минимальный оклад неменее 2500 .
--Зарплату начислять по должности, занимаемой сотрудником в настоящий момент и отнести ее на текущий месяц.
INSERT INTO bonus (empno, month, year, bonvalue)
SELECT e.empno, EXTRACT(MONTH FROM CURRENT_DATE), EXTRACT(YEAR FROM CURRENT_DATE), 0.2 * j.minsalary
FROM emp e
JOIN job j ON e.empno IN (SELECT empno FROM career WHERE enddate IS NULL) AND e.empno IN (SELECT empno FROM career WHERE jobno = j.jobno)
WHERE j.minsalary >= 2500;
rollback;
--18. Удалите данные о премиях  за все вторые полугодия в годы ачисления премий.
DELETE FROM bonus
WHERE month BETWEEN 7 AND 12;
rollback;
--19. Удалите информацию о карьере тех сотрудников, которые в настоящий момент не работают на предприятии.
DELETE FROM career
WHERE empno IN (
  SELECT empno
  FROM career
  GROUP BY empno
  HAVING MAX(enddate) IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM career cr
    WHERE cr.empno = career.empno
    AND cr.enddate IS NULL
  )
);
rollback;
--20. Удалите записи из таблицы EMP для тех сотрудников, которые не работают на предприятии в настоящий момент.
DELETE FROM emp
WHERE empno NOT IN (
  SELECT DISTINCT empno
  FROM career
  WHERE enddate IS NULL
);
rollback;