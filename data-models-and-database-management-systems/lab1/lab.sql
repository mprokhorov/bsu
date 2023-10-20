-- Задание 1: Выдать информацию об дате рождения работника Robert Grishuk.
SELECT birthdate
FROM emp
WHERE empname = 'Robert Grishuk';

-- Задание 2: Выдать информацию обо всех работниках, родившихся в период с 1.01.1980 по 31.12.1982.
SELECT *
FROM emp
WHERE birthdate BETWEEN to_date('01-01-1980', 'dd-mm-yyyy') AND to_date('31-12-1982', 'dd-mm-yyyy');

-- Задание 3: Найти минимальный оклад, предусмотренный для бухгалтера (Accountant).
SELECT MIN(minsalary) AS min_accountant_salary
FROM job
WHERE jobname = 'Accountant';

-- Задание 4: Подсчитать число работников, работавших в компании до 31 мая 2018 года включительно хотя бы один день.
SELECT COUNT(*) AS num_employees_before_may_2018
FROM career
WHERE startdate <= to_date('31-05-2018', 'dd-mm-yyyy');

-- Задание 5: Найти максимальные премии, начисленные в 2018, 2019, 2020, 2021, 2022 годах (указать год и максимальную премию в хронологическом порядке).
SELECT year, MAX(bonvalue) AS max_bonus
FROM bonus
WHERE year BETWEEN 2018 AND 2022
GROUP BY year
ORDER BY year;

-- Задание 6: Выдать информацию о кодах отделов, в которых работал работник Robert Grishuk. Если Robert Grishuk работает в настоящее время - отдел также включается в искомый список.
SELECT DISTINCT deptid
FROM career
WHERE empno = (SELECT empno FROM emp WHERE empname = 'Robert Grishuk')
   OR (empno IS NULL AND enddate IS NULL);

-- Задание 7: Выдать информацию о названиях должностей, на которых работали работники Vera Rovdo и Dave Hollander. Если один из них или оба работают в настоящее время - должность также включается в искомый список. Должность выдаётся вместе с ФИО (empname) работника.
SELECT e.empname, j.jobname
FROM emp e
JOIN career c ON e.empno = c.empno
JOIN job j ON c.jobno = j.jobno
WHERE e.empname IN ('Vera Rovdo', 'Dave Hollander')
   OR (e.empname IS NULL AND enddate IS NULL);

-- Задание 8: Найти фамилии, коды должностей, периоды времени (даты приема и даты увольнения) для всех инженеров (Engineer) и программистов (Programmer), работавших или работающих в компании. Если работник работает в настоящий момент, то дата увольнения должна выдаваться как Null.
SELECT e.empname, j.jobno, j.jobname, c.startdate, c.enddate
FROM emp e
JOIN career c ON e.empno = c.empno
JOIN job j ON c.jobno = j.jobno
WHERE j.jobname IN ('Engineer', 'Programmer')
   OR (e.empname IS NULL AND enddate IS NULL);

-- Задание 9: Найти фамилии, названия должностей, периоды времени (даты приема и даты увольнения) для бухгалтеров (Accountant) и продавцов (Salesman), работавших или работающих в компании. Если работник работает в настоящий момент, то дата увольнения отсутствует.
SELECT e.empname, j.jobname, c.startdate, c.enddate
FROM emp e
JOIN career c ON e.empno = c.empno
JOIN job j ON c.jobno = j.jobno
WHERE j.jobname IN ('Accountant', 'Salesman')
   OR (e.empname IS NULL AND enddate IS NULL);

-- Задание 10: Найти количество различных работников, работавших в отделе B02 хотя бы один день в период с 01.01.2017 по настоящий момент.
SELECT COUNT(DISTINCT e.empno) AS num_employees_in_B02
FROM emp e
JOIN career c ON e.empno = c.empno
WHERE c.deptid = 'B02' AND c.startdate <= CURRENT_DATE;

-- Задание 11: Найти фамилии этих работников.
SELECT DISTINCT e.empname
FROM emp e
JOIN career c ON e.empno = c.empno
WHERE c.deptid = 'B02' AND c.startdate <= CURRENT_DATE;

-- Задание 12: Найти номера и названия отделов, в которых в период с 01.01.2019 по 31.12.2020 работало не более пяти работников.
SELECT c.deptid, d.deptname
FROM career c
JOIN dept d ON c.deptid = d.deptid
WHERE c.startdate BETWEEN to_date('01-01-2019', 'dd-mm-yyyy') AND to_date('31-12-2020', 'dd-mm-yyyy')
GROUP BY c.deptid, d.deptname
HAVING COUNT(DISTINCT c.empno) <= 5;

-- Задание 13: Найти информацию об отделах (номер, название), всем работникам которых не начислялась премия в период с 01.01.2019 по 31.12.2019.
SELECT c.deptid, d.deptname
FROM career c
JOIN dept d ON c.deptid = d.deptid
WHERE NOT EXISTS (
    SELECT 1
    FROM bonus b
    WHERE b.empno = c.empno
      AND b.month BETWEEN 1 AND 12
      AND b.year = 2019
);

-- Задание 14: Найти количество работников, никогда не работавших и не работающих в исследовательском (Research) отделе, но работавших или работающих в отделе поддержки (Support).
SELECT COUNT(DISTINCT e.empno) AS num_support_not_research
FROM emp e
JOIN career c ON e.empno = c.empno
WHERE c.deptid = 'Support'
   AND e.empno NOT IN (
        SELECT c.empno
        FROM career c
        WHERE c.deptid = 'Research'
    );

-- Задание 15: Найти коды и фамилии работников, работавших в двух и более отделах, но не работающих в настоящее время в компании.
SELECT e.empno, e.empname
FROM emp e
JOIN career c ON e.empno = c.empno
WHERE c.enddate IS NOT NULL
   AND e.empno IN (
        SELECT empno
        FROM career
        GROUP BY empno
        HAVING COUNT(DISTINCT deptid) >= 2
    );

-- Задание 16: Найти коды и фамилии работников, работавших в двух и более должностях, но не работающих в настоящее время в компании.
SELECT e.empno, e.empname
FROM emp e
JOIN career c ON e.empno = c.empno
WHERE c.enddate IS NOT NULL
   AND e.empno IN (
        SELECT empno
        FROM career
        GROUP BY empno
        HAVING COUNT(DISTINCT jobno) >= 2
    );

-- Задание 17: Найти коды и фамилии работников, суммарный стаж работы которых в компании на текущий момент не более 8 лет.
SELECT e.empno, e.empname
FROM emp e
JOIN career c ON e.empno = c.empno
GROUP BY e.empno, e.empname
HAVING COALESCE(SUM(EXTRACT(YEAR FROM c.enddate - c.startdate)), 0) <= 8;

-- Задание 18: Найти всех работников (коды и фамилии), увольнявшихся хотя бы один раз.
SELECT e.empno, e.empname
FROM emp e
JOIN career c ON e.empno = c.empno
WHERE c.enddate IS NOT NULL;

-- Задание 19: Найти средние премии, начисленные за период в три 2018, 2019, 2020 года, за период в три 2019, 2020, 2021 года и за период в три 2020, 2021, 2022 года, в разрезе работников (т.е. для работников, имевших начисления хотя бы в одном месяце трёхгодичного периода). Вывести код, имя и фамилию работника, период, среднюю премию.
SELECT b.empno, e.empname,
       CONCAT(b.year - 2, '-', b.year) AS period,
       AVG(b.bonvalue) AS avg_bonus
FROM bonus b
JOIN emp e ON b.empno = e.empno
WHERE (b.year = 2018 AND b.month BETWEEN 1 AND 3)
   OR (b.year = 2019 AND b.month BETWEEN 1 AND 3)
   OR (b.year = 2020 AND b.month BETWEEN 1 AND 3)
GROUP BY b.empno, e.empname, period;

-- Задание 20: Найти отделы (id, название, адрес), в которых есть начисления премий в апреле и марте 2021 года.
SELECT d.deptid, d.deptname, d.deptaddress
FROM dept d
JOIN career c ON d.deptid = c.deptid
JOIN bonus b ON c.empno = b.empno
WHERE b.year = 2021 AND b.month IN (3, 4);