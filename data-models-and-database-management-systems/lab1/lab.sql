--Выбирите СУБД Oracle для выполнения лабораторной.
--Cкопируйте файл EDU1.sql в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной.
--Произведите запуск SQLPlus. или PLSQLDeveloper. или другого инструментария Oracle и соеденитесь с БД.  Запустите скрипт EDU1.sql на выполнение.
--Вставте в эту строку Ваши ФИО, номер подлгруппы. ФИО Прохоров Михаил Андреевич, группа 3б, курс 4.
--Файл с отчётом о выполнении лабораторной создаётся путём вставки соответсвующего select-предложения после строки с текстом задания.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и отправляется в систему edufpmi как ответ к заданию.
--НЕ ДОПУСКАЕТСЯ ИЗМЕНЕНИЕ ТЕКСТОВ ЗАДАНИЙ, НЕПРАВИЛЬНОЕ ИМЕНОВАНИЕ ФАЙЛА И ОТПРАВКА ВЫПОЛНЕННОЙ РАБОТЫ В ФАЙЛЕ ДРУГОГО ФОРМАТА!!!
--Тексты заданий:
--1.	Выдать информацию о периодах (дата приёма,  дата увольнения)  работы сотрудника Vladimir Liss без включения периода с отсутствующей
--	датой увольнения.
SELECT startdate, enddate
FROM career
JOIN emp ON career.empno = emp.empno
WHERE emp.empname = 'Vladimir Liss' AND enddate IS NOT NULL;

--2.	Выдать информацию обо всех сотрудниках, родившихся до 01.01.1970.
SELECT *
FROM emp
WHERE birthdate < to_date('01-01-1970', 'dd-mm-yyyy');

--3.	Найти должности (номер должности, название, минимальный оклад) с минимальными окладами, входящими в интервал [2000,5500].
SELECT jobno, jobname, minsalary
FROM job
WHERE minsalary BETWEEN 2000 AND 5500;

--4.	Подсчитать число сотрудников, не работавших в компании ни одного дня в период с 01.04.2014 по 31.08.2014 (включая начальную и конечную дату периода).
SELECT COUNT(DISTINCT empno) AS employees_count
FROM emp
WHERE empno NOT IN (
    SELECT empno
    FROM career
    WHERE (startdate <= TO_DATE('31-08-2014', 'dd-mm-yyyy') AND (enddate IS NULL OR enddate >= TO_DATE('01-04-2014', 'dd-mm-yyyy')))
);

--5.	Найти средние премии, начисленные в  2018, 2020, 2022 годах (указать год и среднюю премию в хронологическом порядке).
SELECT year, AVG(bonvalue) AS avg_bonus
FROM bonus
WHERE year IN (2018, 2020, 2022)
GROUP BY year
ORDER BY year;

--6.	Выдать информацию о количестве различных отделов,  в которых работал сотрудник Ivan Dudin. Если Ivan Dudin работает в настоящее время - отдел также включается.
SELECT COUNT(DISTINCT career.deptid) AS dept_count
FROM career
JOIN emp ON emp.empno = career.empno
WHERE emp.empname = 'Ivan Dudin';

--7.	Выдать информацию о кодах, названиях и адресах различных отделов (отделы ,имеющие одинаковое название, но разные адреса также считаются различными),
--	в которых работали сотрудники Richard Martin и Nina Tihanovich. Если один из них или оба  работают в настоящее время -
--	отдел также включается в искомый список. Код, название и адрес отдела выдаётся вместе с ФИО (empname) работника.
SELECT DISTINCT dept.deptid, dept.deptname, dept.deptaddress, emp.empname
FROM emp
JOIN career ON emp.empno = career.empno
JOIN dept ON career.deptid = dept.deptid
WHERE emp.empname IN ('Richard Martin', 'Nina Tihanovich');

-- 8.	Найти фамилии, названия должностей, периоды времени (даты приема и даты увольнения) для всех финансовых (Financial Director) и исполнительных Executive Director) директоров,
--	 работавших или работающих в компании. Если сотрудник работает в настоящий момент, то дата увольнения должна отсутсвовать.
SELECT emp.empname, job.jobname, career.startdate, career.enddate
FROM emp
JOIN career ON emp.empno = career.empno
JOIN job ON career.jobno = job.jobno
WHERE job.jobname IN ('Financial Director', 'Executive Director');

-- 9.	Найти фамилии, коды должностей, периоды времени (даты приема и даты увольнения) для менеджеров (Manager) и бухгалтеров (Accountant),  работавших или работающих
--	в компании. Если сотрудник работает в настоящий момент, то дата увольнения отсутствует.
SELECT emp.empname, job.jobno, career.startdate, career.enddate
FROM emp
JOIN career ON emp.empno = career.empno
JOIN job ON career.jobno = job.jobno
WHERE job.jobname IN ('Manager', 'Accountant');

-- 10.	Найти количество различных сотрудников, работавших в отделе U03 хотя бы один день в период до 01.01.2014 и после 31.12.2022.
SELECT COUNT(DISTINCT emp.empno)
FROM emp
JOIN career ON emp.empno = career.empno
WHERE career.deptid = 'U03' AND ((career.startdate < to_date('01-01-2014', 'dd-mm-yyyy') AND career.enddate > to_date('01-01-2014', 'dd-mm-yyyy'))
                                     OR (career.startdate < to_date('31-12-2022', 'dd-mm-yyyy') AND career.enddate > to_date('31-12-2022', 'dd-mm-yyyy')));
-- WHERE career.deptid = 'U03' AND ((career.startdate < to_date('01-01-2014', 'dd-mm-yyyy') )
--                                      OR (career.startdate < to_date('31-12-2022', 'dd-mm-yyyy') AND (career.enddate > to_date('31-12-2022', 'dd-mm-yyyy') OR career.enddate IS NULL)));

-- 11.	Найти фамилии и даты рождения этих сотрудников.
SELECT empname, birthdate
FROM emp
JOIN career ON emp.empno = career.empno
WHERE career.deptid = 'U03' AND ((career.startdate < to_date('01-01-2014', 'dd-mm-yyyy') AND career.enddate > to_date('01-01-2014', 'dd-mm-yyyy'))
                                     OR (career.startdate < to_date('31-12-2022', 'dd-mm-yyyy') AND career.enddate > to_date('31-12-2022', 'dd-mm-yyyy')));
-- WHERE career.deptid = 'U03' AND ((career.startdate < to_date('01-01-2014', 'dd-mm-yyyy') )
--                                      OR (career.startdate < to_date('31-12-2022', 'dd-mm-yyyy') AND (career.enddate > to_date('31-12-2022', 'dd-mm-yyyy') OR career.enddate IS NULL)));

--12.	Найти номера и названия отделов, в которых в период до 01.01.2014 и после 31.12.2022  работал хотя бы один сотрудник.
SELECT DISTINCT dept.deptid, dept.deptname
FROM dept
JOIN career ON dept.deptid = career.deptid
WHERE ((career.startdate < to_date('01-01-2014', 'dd-mm-yyyy') AND career.enddate > to_date('01-01-2014', 'dd-mm-yyyy'))
                                     OR (career.startdate < to_date('31-12-2022', 'dd-mm-yyyy') AND career.enddate > to_date('31-12-2022', 'dd-mm-yyyy')));
-- WHERE career.deptid = 'U03' AND ((career.startdate < to_date('01-01-2014', 'dd-mm-yyyy') )
--                                      OR (career.startdate < to_date('31-12-2022', 'dd-mm-yyyy') AND (career.enddate > to_date('31-12-2022', 'dd-mm-yyyy') OR career.enddate IS NULL)));

--13.	Найти информацию об отделах (номер, название), всем сотрудникам которых не начислялась премия в период с 01.01.2021 по  31.12.2021.
SELECT dept.deptid, dept.deptname
FROM dept
WHERE NOT EXISTS (
    SELECT 1
    FROM career
    JOIN bonus ON career.empno = bonus.empno
    WHERE career.deptid = dept.deptid AND ((bonus.month BETWEEN 1 AND 12 AND bonus.year = 2021)));


--14.	Найти количество сотрудников, работавших или работающих в исследовательском  (Research) отделе, но не работавших и не работающих в отделе поддержки (Support).
SELECT COUNT(DISTINCT empno)
FROM career
JOIN dept ON career.deptid = dept.deptid
WHERE (dept.deptname = 'Research') AND dept.deptid NOT IN (SELECT deptid FROM dept WHERE deptname = 'Support');

-- 15	Найти коды и фамилии сотрудников, работавших ровно в двух отделах (естественно в разные периоды). Период без увольнения (сотрудник работает) также включается.
SELECT emp.empno, emp.empname
FROM emp
JOIN career ON emp.empno = career.empno
GROUP BY emp.empno
HAVING COUNT(DISTINCT career.deptid) = 2;

-- 16	Найти коды и фамилии сотрудников, работавших ровно на двух должностях (естественно в разные периоды), но не работающих в настоящее время в компании.
SELECT c1.empno, e.empname
FROM career c1
INNER JOIN emp e ON c1.empno = e.empno
WHERE (
    SELECT COUNT(DISTINCT c2.jobno)
    FROM career c2
    WHERE c2.empno = c1.empno
) = 2
AND c1.enddate IS NOT NULL;

-- 17	Найти коды  и фамилии сотрудников, суммарный стаж работы которых в компании начиная с 01.01.2014 до настоящего времени не менее 6-и лет.
SELECT emp.empno, emp.empname, SUM(CASE WHEN career.enddate IS NOT NULL THEN career.enddate - career.startdate ELSE CURRENT_DATE - career.startdate END)
FROM emp
JOIN career ON emp.empno = career.empno
GROUP BY emp.empno, emp.empname
HAVING SUM(CASE WHEN career.enddate IS NOT NULL THEN career.enddate - career.startdate ELSE CURRENT_DATE - career.startdate END) >= 6 * 365;

-- 18	Найти всех сотрудников (коды и фамилии), увольнявшихся ровно три раза из компании.
SELECT emp.empno, emp.empname
FROM emp
JOIN career ON emp.empno = career.empno AND career.enddate IS NOT NULL
GROUP BY emp.empno, emp.empname
HAVING COUNT(career.enddate) = 3;

--19.	Найти суммарные премии, начисленные за период в три 2018, 2019, 2020 года и за период в три 2020, 2021, 2022 года, в разрезе сотрудников
--	(т.е. для сотрудников, имевших начисления хотя бы в одном месяце трёхгодичного периода). Вывести номер, имя и фимилию сотрудника, период, суммарную премию.

--20.	Найти отделы (id, название, адрес), в которых есть начисления премий в феврале или сентябре  2021 года.
SELECT DISTINCT dept.deptid, dept.deptname, dept.deptaddress
FROM bonus
JOIN career ON bonus.empno = career.empno
JOIN dept ON career.deptid = dept.deptid
WHERE (bonus.month = 2 OR bonus.month = 9) AND bonus.year = 2021;