--Лабораторная выполняется в СУБД  Oracle.
--Cкопируйте файл  edu7.sql  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной.
--Запустите скрипт edu7.sql на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Прохоров Михаил Андреевич, подгруппа 3б, курс 4.
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных
--Вами операторов после пунктов 1- 8.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt
--и отправляется в систему edufpmi.bsu.by.

--1. Модифицируйте таблицу emp, добавив столбец empaddr, содержащую сведения об адресе сотрудника.
--Данный столбец должно являться столбцом объектного типа empaddr_ty  с атрибутами
--country varchar (15), city varchar (15), street varchar (15), homenumber integer, postcode integer, startlifedate date (дата заселения), rental varchar (1) (вид съёма жилья).
--Последний атрибут может содержать только следующие символы 'p' (собственное), 'r'(арендное), 'o' (служебное).
--Объектный тип должен содержать метод , определяющий время проживания (в днях) сотрудника по указанному
--адресу от даты заселения до текущего момента, округлённое до дня, и суммарную компенсацию за комунальные услуги за всё время проживания по тарифу:
--0,1 рубль за день проживания в собственном жилье, 0,2 рубля за день проживания в арендном жилье, 0,25 рубля за день проживания в служебном жилье.
create or replace type empaddr_ty as object (
    country varchar(15),
    city varchar(15),
    street varchar(15),
    homenumber integer,
    postcode integer,
    startlifedate date,
    rental varchar(1),
    member function days_of_residence return integer,
    member function total_compensation return real
) not final;
/

alter table emp
add empaddr empaddr_ty;

create or replace type body empaddr_ty as
    member function days_of_residence return integer is
    begin
        return trunc(sysdate - startlifedate);
    end days_of_residence;

    member function total_compensation return real is
    begin
        if rental = 'p' then
            return days_of_residence * 0.1;
        elsif rental = 'r' then
            return days_of_residence * 0.2;
        elsif rental = 'o' then
            return days_of_residence * 0.25;
        else
            return null;
        end if;
    end total_compensation;
end;
/

--2. Дополните таблицу emp следующими данными для сотрудников:
--505	Belarus	Minsk	Chkalova 		2	220039		15.01.2017	p
--303	Belarus	Minsk	Brilevskaya		12	220039		16.05.2015	r
--205	Belarus	Minsk	Serova			14	220013		20.11.2018	o
--412	Belarus	Minsk	Serova			23	220013		14.12.2015	p
--503	Belarus	Minsk	Chkalova		6	220039		28.10.2018	o
--Для остальных сотрудников атрибуты поля  empaddr не определены.
update emp
set empaddr = empaddr_ty('Belarus', 'Minsk', 'Chkalova', 2, 220039, to_date('15.01.2017', 'dd.mm.yyyy'), 'p')
where empno = 505;

update emp
set empaddr = empaddr_ty('Belarus', 'Minsk', 'Brilevskaya', 12, 220039, to_date('16.05.2015', 'dd.mm.yyyy'), 'r')
where empno = 303;

update emp
set empaddr = empaddr_ty('Belarus', 'Minsk', 'Serova', 14, 220013, to_date('20.11.2018', 'dd.mm.yyyy'), 'o')
where empno = 205;

update emp
set empaddr = empaddr_ty('Belarus', 'Minsk', 'Serova', 23, 220013, to_date('14.12.2015', 'dd.mm.yyyy'), 'p')
where empno = 412;

update emp
set empaddr = empaddr_ty('Belarus', 'Minsk', 'Chkalova', 6, 220039, to_date('28.10.2018', 'dd.mm.yyyy'), 'o')
where empno = 503;

--3. Создайте запрос, определяющий номер сотрудника, его имя и  фамилию,  время проживания по данному в таблице  emp адресу
--для сотрудников 505, 303, 205, 412, 503. Использовать метод, созданный в п.1.
select empno, empname, e.empaddr.days_of_residence() as residence_days
from emp e
where empno in (505, 303, 205, 412, 503);

--4. Используя наследование, создайте объектный тип empaddres_ty на основе ранее созданного объектного типа
--empaddr_ty с дополнительными атрибутами
--houmtel varchar (15), mtstel varchar (15), A1 varchar (15), lifetel varchar (15).
create or replace type empaddress_ty under empaddr_ty (
    houmtel varchar(15),
    mtstel varchar(15),
    A1 varchar(15),
    lifetel varchar(15)
);
/

--5. Создайте таблицу emphouminf со столбцами empno, empaddres (объектного типа  empaddres_ty),
--связанную с таблицей emp по столбцу empno.
create table emphouminf (
    empno integer primary key references emp (empno),
    empaddres empaddress_ty
);
/

--6. Внесите в таблицу emphouminf следующие данные для сотрудников:
--505	Belarus	Minsk	Chkalova    	2    220039	15.01.2007	p	2241412	    7111111      6111111	5176512
--303	Belarus	Minsk	Brilevskaya  	12   220039	16.05.2005	r	2341516     Null         6137677	Null
--205	Belarus	Minsk	Serova	 	14   220013	20.11.2008   	o	Null	    Null         6276655	5879860
--412	Belarus	Minsk	Serova       	23   220013	14.12.2005	p	2351412	    Null         Null		5101112
--503	Belarus	Minsk	Chkalova    	6    220039	28.10.2008      o	Null	    7161512      6122334	Null
-- Внесение данных в таблицу emphouminf
insert into emphouminf (empno, empaddres)
values
(505, empaddress_ty('Belarus', 'Minsk', 'Chkalova', 2, 220039, to_date('15.01.2007', 'dd.mm.yyyy'), 'p', '2241412', '7111111', '6111111', '5176512'));

insert into emphouminf (empno, empaddres)
values
(303, empaddress_ty('Belarus', 'Minsk', 'Brilevskaya', 12, 220039, to_date('16.05.2005', 'dd.mm.yyyy'), 'r', '2341516', null, '6137677', null));

insert into emphouminf (empno, empaddres)
values
(205, empaddress_ty('Belarus', 'Minsk', 'Serova', 14, 220013, to_date('20.11.2008', 'dd.mm.yyyy'), 'o', null, null, '6276655', '5879860'));

insert into emphouminf (empno, empaddres)
values
(412, empaddress_ty('Belarus', 'Minsk', 'Serova', 23, 220013, to_date('14.12.2005', 'dd.mm.yyyy'), 'p', '2351412', null, null, '5101112'));

insert into emphouminf (empno, empaddres)
values
(503, empaddress_ty('Belarus', 'Minsk', 'Chkalova', 6, 220039, to_date('28.10.2008', 'dd.mm.yyyy'), 'o', null, '7161512', '6122334', null));

--7. Внесите в таблицу emphouminf следующую запись
--102	Belarus	Minsk	Surganova	9    220072	15.09.2021	r	3721414	    7121517	 6551419	5242321
--и используя полностью выше указанную запись дополните для сотрудника 102 запись в таблице emp.
insert into emphouminf (empno, empaddres)
values
(102, empaddress_ty('Belarus', 'Minsk', 'Surganova', 9, 220072, to_date('15.09.2021', 'dd.mm.yyyy'), 'r', '3721414', '7121517', '6551419', '5242321'));

update emp
set empaddr = (select empaddres from emphouminf where empno = 102)
where empno = 102;

--8. Создайте запрос, определяющий номер сотрудника, его имя, домашний телефон, время проживания и размер компенсации за всё время проживания
--для сотрудников,  имеющих служебное жильё. Использовать метод, созданный в п.1.
select e.empno, e.empname, (select eh.empaddres.houmtel from emphouminf eh where eh.empno = e.empno) as houmtel, e.empaddr.days_of_residence() as residence_days, e.empaddr.total_compensation() as total_compensation
from emp e
where e.empaddr.rental = 'o';

--9. Создайте запрос, выдающий имя и фамилию (empname) сотрудника по его телефону в сети A1 (если он имеется).
SELECT e.empname, ei.empaddres.A1 AS A1
FROM emp e
JOIN emphouminf ei ON e.empno = ei.empno
WHERE ei.empaddres.A1 = 6137677;

--10. Приведите таблицу emp в исходное состояние (удалите столбец empaddr). Удалите созданную таблицу и объектные типы.
alter table emp drop column empaddr;

drop table emphouminf;

drop type empaddress_ty;
drop type empaddr_ty;
