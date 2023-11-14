--Лабораторная выполняется в СУБД  Oracle.
--Cкопируйте файл  EDU4.sql  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной.
--Таблица Emp имеет дополнительные столбцы mstat (семейное положение), Nchild (количество несовершеннолетних детей).
--Столбец mstat имеет домен (s,m,d,w). s (single) - холост(ая), m (married) - женат, замужем, d (divorced) - разведен(а),
--w (widower) - вдовец, вдова.
--Произведите запуск Oracle и соеденитесь с БД.  Запустите скрипт EDU4.sql на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Прохоров Михаил Андреевич, подгруппа 3б, курс 4.
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных Вами программ после пунктов 1, 2, 3.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в  edufpmi.bsu.by (при возникновении непредвиденной ситуации,
--приводящей к невозможности сохранения в edufpmi.bsu.by, высылается на почту преподавателя до дедлайна).
--НЕ ДОПУСКАЕТСЯ УДАЛЕНИЕ ЛЮБЫХ (в том числе и первых) СТРОК ИЗ ДАННОГО ТЕКСТА!!!
--НЕ ЗАБУДТЕ ЗАКРЫТЬ И СПЕЦИФИКАЦИЮ И ТЕЛО ПАКЕТА СИМВОЛОМ "/"!!!
--РАБОТА ВЫПОЛНЯЕТСЯ ИНДИВИДУАЛЬНО!!!
--ПРИ НЕПРАВИЛЬНОМ ОФОРМЛЕНИИ ИЛИ КОПИРОВАНИИ У ДРУГОГО СТУДЕНТА, РАБОТА НЕ ПРОВЕРЯЕТСЯ И ПОЛУЧАЕТ ОЦЕНКУ 0!!!

--1.1. Создайте пакет PackChild, включающий в свой состав процедуры ChildBonus и функцию EmpChildBonus.
--Процедура ChildBonus должна вычислять ежегодную материнскую добавку к зарплате сотрудниц (женщин) на детей за 2023 год и заносить её в виде дополнительной премии
--(с указанием значений empno, month, year, bonvalue) в декабре 2023 календарного года в поле Bonvalue таблицы Bonus.
--Женщинам не имеющим несовершеннолетних детей начислять добавку и заносить в таблицу Bonus не надо. Пол сотрудника определяется по имени.
--В таблице сотрудников имеются следующие женские имена: Vera, Olga, Irina, Svetlana, Larisa, Nina, Olivia, Anna.
--В качестве параметров процедуре передаются проценты в зависимости от количества детей (см. правило начисления добавки).
--Функция EmpChildBonus должна вычислять ежегодную добавку за 2023 год на детей к  зарплате конкретной сотрудницы
--(номер сотрудницы - параметр передаваемый функции) без занесения в таблицу. Если сотрудница не имеет детей,значение функции
--равно 0.

-- ПРАВИЛО ВЫЧИСЛЕНИЯ ДОБАВКИ

--Добавка к заработной плате на детей  вычисляется только для принятых на работу до 01.01.2023 года сотрудниц по следующему правилу:
--добавка равна X% от суммы должностного месячного оклада (поле minsalary таблицы job) по занимаемой в ноябре 2023 года должности и всех начисленных
--за 2023 год премий (поле bonvalue таблицы bonus), где:
--X% равны X1% , если сотрудница имеет одного ребёнка;
--X% равны X2% , если сотрудница имеет двух детей;
--X% равны X3% , если сотрудница имеет трёх и более детей.
--X1%<X2%<X3%  являются передаваемыми процедуре и функции параметрами. Кроме этого, функции в качестве параметра передаётся номер сотрудницы (empno).
CREATE OR REPLACE PACKAGE PackChild AS
  PROCEDURE ChildBonus(X1 IN NUMBER, X2 IN NUMBER, X3 IN NUMBER);
  FUNCTION EmpChildBonus(empno_param IN INTEGER, X1 IN NUMBER, X2 IN NUMBER, X3 IN NUMBER) RETURN REAL;
END PackChild;
/

CREATE OR REPLACE PACKAGE BODY PackChild AS
  PROCEDURE ChildBonus(X1 IN NUMBER, X2 IN NUMBER, X3 IN NUMBER) IS
    bonus_value REAL;
    job_salary REAL;
    bonus_sum REAL;
  BEGIN
    FOR emp_rec IN (SELECT empno, empname, mstat, nchild FROM emp WHERE mstat IN ('m', 'd') AND empname IN ('Vera', 'Olga', 'Irina', 'Svetlana', 'Larisa', 'Nina', 'Olivia', 'Anna'))
    LOOP
      IF emp_rec.nchild > 0 THEN
        bonus_sum := 0;

        SELECT COALESCE(SUM(bonvalue), 0) INTO bonus_sum FROM bonus WHERE empno = emp_rec.empno AND year = 2023;

        SELECT minsalary INTO job_salary
        FROM job
        WHERE jobno = (SELECT jobno FROM career WHERE empno = emp_rec.empno AND enddate IS NULL AND ROWNUM = 1);

        CASE emp_rec.nchild
          WHEN 1 THEN bonus_value := X1 / 100 * (job_salary + bonus_sum);
          WHEN 2 THEN bonus_value := X2 / 100 * (job_salary + bonus_sum);
          WHEN 3 THEN bonus_value := X3 / 100 * (job_salary + bonus_sum);
        END CASE;

        INSERT INTO bonus (empno, month, year, bonvalue) VALUES (emp_rec.empno, 12, 2023, bonus_value);
      END IF;
    END LOOP;
  END ChildBonus;

  FUNCTION EmpChildBonus(empno_param IN INTEGER, X1 IN NUMBER, X2 IN NUMBER, X3 IN NUMBER) RETURN REAL IS
    bonus_value REAL := 0;
  BEGIN
    SELECT COALESCE(
             CASE nchild
               WHEN 1 THEN X1 / 100 * (SELECT minsalary FROM job WHERE jobno = (SELECT jobno FROM career WHERE empno = empno_param AND enddate IS NULL AND ROWNUM = 1))
               WHEN 2 THEN X2 / 100 * (SELECT minsalary FROM job WHERE jobno = (SELECT jobno FROM career WHERE empno = empno_param AND enddate IS NULL AND ROWNUM = 1))
               WHEN 3 THEN X3 / 100 * (SELECT minsalary FROM job WHERE jobno = (SELECT jobno FROM career WHERE empno = empno_param AND enddate IS NULL AND ROWNUM = 1))
             END,
             0)
    INTO bonus_value
    FROM emp
    WHERE empno = empno_param AND mstat IN ('m', 'd');

    RETURN bonus_value;
  END EmpChildBonus;
END PackChild;
/

--1.2. Выполните процедуру ChildBonus пакета PackChild с параметрами X1=30%, X2=40%, X3=50%.
EXEC PackChild.ChildBonus(30, 40, 50);

--1.3. Создайте запрос для просмотра записей таблицы Bonus за декабрь 2023 года.
SELECT * FROM bonus WHERE month = 12 AND year = 2023;
Rollback;

--1.4. Вычислите функцию EmpChildBonus пакета PackChild с параметрами X1=30%, X2=40%, X3=50%, номер сортудницы 205. и вставте запись в таблицу Bonus.
DECLARE
  bonus_value_emp205 REAL;
BEGIN
  bonus_value_emp205 := PackChild.EmpChildBonus(205, 30, 40, 50);
  INSERT INTO bonus (empno, month, year, bonvalue) VALUES (205, 12, 2023, bonus_value_emp205);
END;
/

--1.5. Создайте запрос для просмотра записей таблицы Bonus за декабрь 2023 года для сотрудницы 205.
SELECT * FROM bonus WHERE empno = 205 AND month = 12 AND year = 2023;
Rollback;

--2. Измените в пакете категорию сотрудников для начисления добавки, дополнив его требованием "Добавка начисляется также мужчинам вдовцам (w)".
--При этом правила по приёму на работу и правила вычисления добавки для вдовцов остаются теже, что и для сотрудниц.
CREATE OR REPLACE PACKAGE PackChild AS
  PROCEDURE ChildBonus(X1 IN NUMBER, X2 IN NUMBER, X3 IN NUMBER);
  FUNCTION EmpChildBonus(empno_param IN INTEGER, X1 IN NUMBER, X2 IN NUMBER, X3 IN NUMBER) RETURN REAL;
END PackChild;
/

CREATE OR REPLACE PACKAGE BODY PackChild AS
  PROCEDURE ChildBonus(X1 IN NUMBER, X2 IN NUMBER, X3 IN NUMBER) IS
    bonus_value REAL;
    job_salary REAL;
    bonus_sum REAL;
  BEGIN
    FOR emp_rec IN (SELECT empno, empname, mstat, nchild FROM emp WHERE mstat IN ('m', 'd', 'w') AND empname IN ('Vera', 'Olga', 'Irina', 'Svetlana', 'Larisa', 'Nina', 'Olivia', 'Anna'))
    LOOP
      IF emp_rec.nchild > 0 THEN
        bonus_sum := 0;

        SELECT COALESCE(SUM(bonvalue), 0) INTO bonus_sum FROM bonus WHERE empno = emp_rec.empno AND year = 2023;

        SELECT minsalary INTO job_salary
        FROM job
        WHERE jobno = (SELECT jobno FROM career WHERE empno = emp_rec.empno AND enddate IS NULL AND ROWNUM = 1);

        CASE emp_rec.nchild
          WHEN 1 THEN bonus_value := X1 / 100 * (job_salary + bonus_sum);
          WHEN 2 THEN bonus_value := X2 / 100 * (job_salary + bonus_sum);
          WHEN 3 THEN bonus_value := X3 / 100 * (job_salary + bonus_sum);
        END CASE;

        INSERT INTO bonus (empno, month, year, bonvalue) VALUES (emp_rec.empno, 1, 2023, bonus_value);
      END IF;
    END LOOP;
  END ChildBonus;

  FUNCTION EmpChildBonus(empno_param IN INTEGER, X1 IN NUMBER, X2 IN NUMBER, X3 IN NUMBER) RETURN REAL IS
    bonus_value REAL := 0;
  BEGIN
    SELECT COALESCE(
             CASE nchild
               WHEN 1 THEN X1 / 100 * (SELECT minsalary FROM job WHERE jobno = (SELECT jobno FROM career WHERE empno = empno_param AND enddate IS NULL AND ROWNUM = 1))
               WHEN 2 THEN X2 / 100 * (SELECT minsalary FROM job WHERE jobno = (SELECT jobno FROM career WHERE empno = empno_param AND enddate IS NULL AND ROWNUM = 1))
               WHEN 3 THEN X3 / 100 * (SELECT minsalary FROM job WHERE jobno = (SELECT jobno FROM career WHERE empno = empno_param AND enddate IS NULL AND ROWNUM = 1))
             END,
             0)
    INTO bonus_value
    FROM emp
    WHERE empno = empno_param AND mstat IN ('m', 'd', 'w');

    RETURN bonus_value;
  END EmpChildBonus;
END PackChild;
/

--2.2. Выполните процедуру ChildBonus пакета PackChild с параметрами X1=30%, X2=40%, X3=50%.
EXEC PackChild.ChildBonus(30, 40, 50);

--2.3. Создайте запрос для просмотра записей таблицы Bonus за январь 2023 года.
SELECT * FROM bonus WHERE month = 1 AND year = 2023;
Rollback;

--2.4. Вычислите функцию EmpChildBonus пакета PackChild с параметрами X1=30%, X2=40%, X3=50%, номер сортудника 102. и вставте запись в таблицу Bonus.
DECLARE
  bonus_value_emp102 REAL;
BEGIN
  bonus_value_emp102 := PackChild.EmpChildBonus(102, 30, 40, 50);
  INSERT INTO bonus (empno, month, year, bonvalue) VALUES (102, 12, 2023, bonus_value_emp102);
END;
/

--2.5. Создайте запрос для просмотра записей таблицы Bonus за декабрь 2023 года для сотрудника 102.
SELECT * FROM bonus WHERE empno = 102 AND month = 12 AND year = 2023;
Rollback;

--3. Удалите пакет PackChild.
DROP PACKAGE PackChild;
