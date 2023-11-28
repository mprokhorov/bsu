--Лабораторная выполняется в СУБД  Oracle.
--Cкопируйте файл  EDU6.sql  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной.
--База данных имеет дополнительную таблицу t_error.
--Произведите запуск Oracle.  Запустите скрипты EDU6.sql на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Прохоров Михаил Андреевич, группа 3б, курс 4.
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных Вами программ после пунктов 1a, 1b, 1с, 2, 3, 4.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в каталоu.

--1. Имеются PL_SQL-блоки, содержащий следующие операторы:
--a)
/*declare
     empnum integer;
     begin
      insert into bonus values (505,11, 2016, 500, null);
end;*/
declare
  empnum integer;
begin
  begin
    insert into bonus values (505, 11, 2016, 500, null);
  exception
    when others then
      insert into t_error values (06512, 'check constraint', sysdate);
  end;
end;

--b)
/*declare
     empnum integer;
     begin
      insert into job values (1010, 'Accountant xxxxxxxxxx',5500);
end;*/
declare
  empnum integer;
begin
  begin
    insert into job values (1010, 'Accountant xxxxxxxxxx', 5500);
  exception
    when others then
      insert into t_error values (06512, 'value too large for column', sysdate);
  end;
end;

--c)
/*declare
     empnum integer;
     begin
      select empno into empnum from career where deptid='B02';
end;*/
declare
  empnum integer;
begin
  begin
    select empno into empnum from career where deptid = 'B02';
  exception
    when others then
      insert into t_error values (06512, 'exact fetch returns more than requested number of rows', sysdate);
  end;
end;

--Оператор исполняемого раздела в каждом из блоков вызывает предопределённое исключение со своими предопределёнными
--кодом и сообщением.
--Дополните блоки разделами обработки исключительных ситуаций.
--Обработка каждой ситуации состоит в занесении в таблицу t_error предопределённых кода ошибки,
--сообщения об ошибке и текущих даты и времени, когда ошибка произошла.

--2. Создайте анонимный блок, для анализа расходования премиального фонда по данным таблицы bonus с 2018 по 2022 годы. Анализ заключается в определении
--для каждого года поквартального роста начисляемых премий. То есть надо расчитать сумму премий начисленных в первом, во второй, в третьем и
--в четвёртом квартале каждого 2018, 2019, 2020, 2021, 2022 года. Результаты расчётов заносятся в таблицу t_analysis  с столбцами period (номер квартала,
--за которые вычисляется сумма начисленных премий), year (год начисления), amount (сумма начисленных премий в квартале, указанном в period).
--Блок должен содержать собственную исключительную ситуацию ex_one с кодом -20005 и сообщением
--'The amount of premiums in the n-th quarter of the k-th year is less than in the previous quarter', где n - номер квартала, k - год.
--Исключительная ситуация ex_one наступает при нарушении бизнес-правила: "Сумма всех премий (премии в столбце bonvalue), начисленных в n-ом квартале k-го года,
--не может быть меньше суммы премий, начисленных в (n-1)-ом квартале этого же года, 2018<=k<=2022, 1<= n<=4". Для первых кварталов исключительная ситуация не наступает
--(не с чем сравнивать). Обработка ситуации состоит в занесении кода ошибки, сообщения об ошибке и времени, когда ошибка произошла, в таблицу t_error.
DECLARE
  ex_one EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_one, -20005);

  v_year    INTEGER;
  v_quarter INTEGER;
  v_amount  REAL;

BEGIN
  FOR year_rec IN (SELECT DISTINCT year FROM bonus WHERE year BETWEEN 2018 AND 2022 ORDER BY year)
  LOOP
    v_year := year_rec.year;

    FOR quarter_rec IN 1..4
    LOOP
      SELECT NVL(SUM(bonvalue), 0)
      INTO v_amount
      FROM bonus
      WHERE year = v_year AND month BETWEEN (quarter_rec - 1) * 3 + 1 AND quarter_rec * 3;

      IF quarter_rec > 1 THEN
        DECLARE
          v_prev_amount REAL;
        BEGIN
          SELECT amount
          INTO v_prev_amount
          FROM t_analysis
          WHERE year = v_year AND period = quarter_rec - 1;

          IF v_amount < v_prev_amount THEN
            RAISE ex_one;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      INSERT INTO t_analysis (period, year, amount)
      VALUES (quarter_rec, v_year, v_amount);
    END LOOP;
  END LOOP;

EXCEPTION
  WHEN ex_one THEN
    INSERT INTO t_error (err_num, err_msg, err_time)
    VALUES (-20005, 'The amount of premiums in the n-th quarter of the k-th year is less than in the previous quarter', SYSDATE);

  WHEN OTHERS THEN
    INSERT INTO t_error (err_num, err_msg, err_time)
    VALUES (8888, 'Error occurred', SYSDATE);

END;
/
--Создайте select-предложения для просмотра таблиц t_analysis и t-error после выполнения (благополучного или прерванного возникновением  исключительной
--ситуацией) блока.
SELECT * FROM t_analysis;
SELECT * FROM t_error;
Rollback;

--3. Создайте анонимный блок для анализа записей в таблице Bonus, с собственной исключительной ситуацией ex_two с кодом -20006 и сообщением
--"The amount of premiums in the n-th half of the k-th year is more than 6000.". Анализ заключается в расчёте полугодовых (первое и второе полугодие)
--суммарных начислений премий в каждом 2018, 2019, 2020, 2021, 2022 году.
--Результаты заносятся в таблицу t_analysis (period - полугодие начисления, year - год начисления, amount - сумма начисленных за полугодие, указанное в period, премий).
--Исключительная ситуация ex_two наступает, при нарушении бизнес-правила: "Сумма всех премий за n-ое полугодие не может быть больше, чем 6000.
--При наступлении пользовательской исключительной ситуации ex_two обработка состоит в занесении данных о ней
--(аналогично 2) в таблицу t_error.
DECLARE
  ex_two EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_two, -20006);

  v_year       INTEGER;
  v_half_year  INTEGER;
  v_amount     REAL;
  v_total_bonus REAL := 0;

  CURSOR c_bonus IS
    SELECT year, month, SUM(bonvalue) AS total_bonus
    FROM bonus
    WHERE year BETWEEN 2018 AND 2022
    GROUP BY year, month
    ORDER BY year, month;

BEGIN
  FOR bonus_rec IN c_bonus LOOP
    v_year := bonus_rec.year;
    v_half_year := CASE WHEN bonus_rec.month <= 6 THEN 1 ELSE 2 END; -- Определение номера полугодия
    v_total_bonus := v_total_bonus + bonus_rec.total_bonus;

    IF v_half_year = 2 THEN
      IF v_total_bonus > 6000 THEN
        RAISE ex_two;
      END IF;

      INSERT INTO t_analysis (period, year, amount)
      VALUES (v_half_year, v_year, v_total_bonus);

      v_total_bonus := 0;
    END IF;

  END LOOP;

EXCEPTION
  WHEN ex_two THEN
    INSERT INTO t_error (err_num, err_msg, err_time)
    VALUES (-20006, 'The amount of premiums is more than 6000 for the second half-year', SYSDATE);

  WHEN OTHERS THEN
    INSERT INTO t_error (err_num, err_msg, err_time)
    VALUES (8888, 'Error occurred', SYSDATE);

END;
/
--Создайте select-предложение для просмотра таблиц t_analysis, t-error после выполнения блока.
SELECT * FROM t_analysis;
SELECT * FROM t_error;
Rollback;

--4. Создайте анонимный блок, для анализа премий в разрезе сотрудников (т.е. для каждого сотрудника, которому начислялись премии),
--с собственной исключительную ситуацию ex_three с кодом -20007 и сообщением "More than five times". Анализ заключается в расчёте годовых сумм премий в разрезе
--сотрудников, имеющих начисления в 2021, 2022 годах (одном из них или в обоих). Данные расчёта заносятся в таблицу t_eanalysis, имеющую схему
--(empno integer not null, year integer check(year>2017 and year<2024) not null, amount real).
--Исключительная ситуация ex_three наступает, при нарушении бизнес-правила: "Сотруднику в течении двух 2021, 2022 годов, может начисляться не более пяти премий".
--Рассматриваются только 2021, 2022 годы.
--При наступлении пользовательской исключительной ситуации ex_three обработка состоит в занесении данных о ней
--(аналогично 2) в таблицу t_error.
DECLARE
  ex_three EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_three, -20007);

  v_empno   INTEGER;
  v_year    INTEGER;
  v_amount  REAL;
  v_premium_count INTEGER := 0;

  CURSOR c_bonus IS
    SELECT empno, year, COUNT(*) AS premium_count
    FROM bonus
    WHERE year IN (2021, 2022)
    GROUP BY empno, year;

BEGIN
  -- Цикл по данным из курсора
  FOR bonus_rec IN c_bonus LOOP
    v_empno := bonus_rec.empno;
    v_year := bonus_rec.year;
    v_premium_count := bonus_rec.premium_count;

    IF v_premium_count > 5 THEN
      RAISE ex_three;
    END IF;

    INSERT INTO t_eanalysis (empno, year, amount)
    VALUES (v_empno, v_year, v_premium_count);

  END LOOP;

EXCEPTION
  WHEN ex_three THEN
    INSERT INTO t_error (err_num, err_msg, err_time)
    VALUES (-20007, 'Employee received more than five premiums in 2021, 2022', SYSDATE);

  WHEN OTHERS THEN
    INSERT INTO t_error (err_num, err_msg, err_time)
    VALUES (8888, 'Error occurred', SYSDATE);

END;
/
--Создайте select-предложение для просмотра таблиц t_eanalysis, t-error после выполнения блока.
SELECT * FROM t_eanalysis;
SELECT * FROM t_error;
Rollback;

--5. Создайте анонимный блок для подсчёта средних начисленных премий за каждый 2018,...,2022 год. Результаты заносятся в таблицу t_aanalysis, имеющую схему
--(year integer check(year>2017 and year<2024) not null, apremium real). Включите в блок исключительную ситуацию
--ex_four с кодом  - 20008 и сообщением "The average premium in the k-th year is less than in the previous one". Где k - первый из рассматриваемых год, для которого
--наступает исключительная Ситуация.
--Исключительная ситуация состоит в том, что размер средней начисленной премии в каждом году не может быть меньше чем в предыдущем. Для 2018 года ситуация не возникает
--( не с чем сравнивать).
--При наступлении пользовательской исключительной ситуации ex_four обработка состоит в занесении данных о ней (аналогично 2) в таблицу t_error.
DECLARE
  ex_four EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_four, -20008);

  v_year INTEGER;
  v_prev_avg_premium REAL := NULL;
  v_avg_premium REAL;

BEGIN
  FOR year_rec IN (SELECT DISTINCT year FROM bonus WHERE year BETWEEN 2018 AND 2022 ORDER BY year)
  LOOP
    v_year := year_rec.year;

    SELECT AVG(bonvalue) INTO v_avg_premium
    FROM bonus
    WHERE year = v_year;

    INSERT INTO t_aanalysis (year, apremium)
    VALUES (v_year, v_avg_premium);

    IF v_prev_avg_premium IS NOT NULL AND v_avg_premium < v_prev_avg_premium THEN
      RAISE ex_four;
    END IF;

    v_prev_avg_premium := v_avg_premium;
  END LOOP;

EXCEPTION
  WHEN ex_four THEN
    INSERT INTO t_error (err_num, err_msg, err_time)
    VALUES (-20008, 'The average premium in the k-th year is less than in the previous one', SYSDATE);

  WHEN OTHERS THEN
    INSERT INTO t_error (err_num, err_msg, err_time)
    VALUES (8888, 'Error occurred', SYSDATE);

END;
/

--Создайте select-предложение для просмотра таблиц t_aanalysis, t-error после выполнения блока.
SELECT * FROM t_aanalysis;
SELECT * FROM t_error;
Rollback;
