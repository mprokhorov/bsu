DROP TABLE BONUS;
DROP TABLE CAREER;
DROP TABLE EMP;
DROP TABLE DEPT;
DROP TABLE JOB;
/******************************************************/
/*          подразделения                             */
/******************************************************/
create table dept
(
    deptid      varchar(3) primary key not null,
    deptname    varchar(20)            not null,
    deptaddress varchar(25)            not null
);
commit;
insert into dept
values ('B02', 'Support', 'Belarus, Minsk');
insert into dept
values ('U03', 'Development', 'USA, San-Diego');
insert into dept
values ('B01', 'Administration', 'Belarus, Minsk');
insert into dept
values ('U01', 'Administration', 'USA, San-Diego');
insert into dept
values ('C02', 'Web-technology', 'Czechia,  Praga');
insert into dept
values ('B03', 'Personnel management', 'Belarus,  Minsk');
insert into dept
values ('U02', 'Research', 'USA, Dallas');
insert into dept
values ('C01', 'Accounting', 'Czechia, Praga');
insert into dept
values ('B04', 'Sales', 'Belarus, Minsk');
insert into dept
values ('U04', 'Operations', 'USA, Boston');
insert into dept
values ('B05', 'Production', 'Belarus, Minsk');
commit;
/******************************************************/
/*          работники                                 */
/******************************************************/
create table emp
(
    empno     integer primary key not null,
    empname   varchar(15)         not null,
    birthdate date                not null check (birthdate > to_date('01-01-1954', 'dd-mm-yyyy')),
    mstat     varchar(2) check (mstat in ('s', 'm', 'd', 'w')),
    nchild    number(2)
);
commit;
insert into emp
values (101, 'Steve Bobrowski', to_date('02-04-1983', 'dd-mm-yyyy'), 'm', 1);
insert into emp
values (102, 'Don Burleson', to_date('10-06-1973', 'dd-mm-yyyy'), 'm', 2);
insert into emp
values (103, 'Vera Rovdo', to_date('03.09.1980', 'dd-mm-yyyy'), 'd', 1);
insert into emp
values (104, 'Olga Buben', to_date('23.11.1982', 'dd-mm-yyyy'), 'm', 2);
insert into emp
values (105, 'Mark Gokman', to_date('21.11.1978', 'dd-mm-yyyy'), 'm', 3);
insert into emp
values (201, 'Jon Ingmar', to_date('14.01.1980', 'dd-mm-yyyy'), 'm', 3);
insert into emp
values (203, 'Irina Klimovich', to_date('25.07.1982', 'dd-mm-yyyy'), 'm', 2);
insert into emp
values (204, 'Svetlana Brich', to_date('17.11.1985', 'dd-mm-yyyy'), 'm', 2);
insert into emp
values (205, 'Larisa Usich', to_date('19.02.1975', 'dd-mm-yyyy'), 'd', 2);
insert into emp
values (209, 'Kevin Loney', to_date('06.08.1977', 'dd-mm-yyyy'), 'm', 1);
insert into emp
values (211, 'Grady Booch', to_date('23.05.1977', 'dd-mm-yyyy'), 'm', 2);
insert into emp
values (215, 'Frank Boumphrey', to_date('12.10.1979', 'dd-mm-yyyy'), 's', 0);
insert into emp
values (303, 'Nina Tihanovich', to_date('05.08.1976', 'dd-mm-yyyy'), 'm', 0);
insert into emp
values (304, 'Pavel Zuck', to_date('25.11.1981', 'dd-mm-yyyy'), 'm', 0);
insert into emp
values (311, 'Olivia Direnzo', to_date('13.03.1970', 'dd-mm-yyyy'), 'w', 0);
insert into emp
values (321, 'Jon Duckett', to_date('19.09.1971', 'dd-mm-yyyy'), 'm', 1);
insert into emp
values (322, 'Dave Hollander', to_date('13.05.1972', 'dd-mm-yyyy'), 'm', 0);
insert into emp
values (327, 'Trevor Jenkins', to_date('21.02.1972', 'dd-mm-yyyy'), 'm', 2);
insert into emp
values (329, 'Peter Jones', to_date('19.01.1982', 'dd-mm-yyyy'), 'm', 1);
insert into emp
values (401, 'Craig McQueen', to_date('29.12.1980', 'dd-mm-yyyy'), 'm', 0);
insert into emp
values (402, 'Stephen Mohr', to_date('25.05.1975', 'dd-mm-yyyy'), 'm', 1);
insert into emp
values (403, 'Jon Martin', to_date('15.07.1968', 'dd-mm-yyyy'), 'd', 1);
insert into emp
values (404, 'Richard Martin', to_date('23.02.1970', 'dd-mm-yyyy'), 'm', 2);
insert into emp
values (410, 'Robert Grishuk', to_date('15.07.1975', 'dd-mm-yyyy'), 'm', 1);
insert into emp
values (412, 'Vladimir Liss', to_date('18.10.1975', 'dd-mm-yyyy'), 's', 0);
insert into emp
values (414, 'Piter Mohov', to_date('25.12.1976', 'dd-mm-yyyy'), 'm', 0);
insert into emp
values (503, 'Alex Kuznetsov', to_date('14.09.1980', 'dd-mm-yyyy'), 's', 0);
insert into emp
values (504, 'Ivan Dudin', to_date('25.03.1981', 'dd-mm-yyyy'), 'm', 2);
insert into emp
values (505, 'Fedor Dikunov', to_date('12.07.1975', 'dd-mm-yyyy'), 'm', 1);
insert into emp
values (601, 'Anna Zlotnik', to_date('18.05.1979', 'dd-mm-yyyy'), 'm', 1);
commit;
/******************************************************/
/*          должности                                 */
/******************************************************/
create table job
(
    jobno     integer primary key not null,
    jobname   varchar(20)         not null,
    minsalary real                not null
);
commit;
insert into job
values (1000, 'Manager', 2500);
insert into job
values (1001, 'Financial Director', 7500);
insert into job
values (1003, 'Salesman', 1500);
insert into job
values (1002, 'Executive Director', 8000);
insert into job
values (1004, 'Clerk', 500);
insert into job
values (1005, 'Driver', 1800);
insert into job
values (1006, 'President', 15000);
insert into job
values (1007, 'Engineer', 7000);
insert into job
values (1008, 'Programmer', 7500);
insert into job
values (1009, 'Accountant', 5500);
commit;
/******************************************************/
/*          служебная карьера                         */
/******************************************************/
create table career
(
    jobno     integer references job (jobno)      not null,
    empno     integer references emp (empno)      not null,
    deptid    varchar(3) references dept (deptid) not null,
    startdate date                                not null,
    enddate   date,
    check (startdate < enddate)
);
commit;
insert into career
values (1008, 101, 'U03', to_date('01.05.2015', 'dd-mm-yyyy'), null);
insert into career
values (1002, 102, 'U01', to_date('01.01.2007', 'dd-mm-yyyy'), to_date('31.12.2012', 'dd-mm-yyyy'));
insert into career
values (1006, 102, 'U01', to_date('01.01.2013', 'dd-mm-yyyy'), null);
insert into career
values (1008, 103, 'B02', to_date('01.01.2016', 'dd-mm-yyyy'), null);
insert into career
values (1008, 104, 'B02', to_date('01.09.2016', 'dd-mm-yyyy'), null);
insert into career
values (1007, 105, 'U04', to_date('01.09.2016', 'dd-mm-yyyy'), to_date('31.03.2017', 'dd-mm-yyyy'));
insert into career
values (1008, 201, 'U02', to_date('01.06.2016', 'dd-mm-yyyy'), to_date('31.03.2017', 'dd-mm-yyyy'));
insert into career
values (1008, 203, 'U02', to_date('01.10.2013', 'dd-mm-yyyy'), to_date('31.03.2016', 'dd-mm-yyyy'));
insert into career
values (1007, 203, 'B05', to_date('01.07.2016', 'dd-mm-yyyy'), null);
insert into career
values (1007, 204, 'U02', to_date('01.06.2014', 'dd-mm-yyyy'), to_date('31.12.2016', 'dd-mm-yyyy'));
insert into career
values (1007, 204, 'B02', to_date('01.04.2017', 'dd-mm-yyyy'), null);
insert into career
values (1008, 205, 'B02', to_date('01.10.2015', 'dd-mm-yyyy'), to_date('31.12.2016', 'dd-mm-yyyy'));
insert into career
values (1008, 205, 'C01', to_date('01.02.2017', 'dd-mm-yyyy'), null);
insert into career
values (1004, 209, 'U01', to_date('01.01.2015', 'dd-mm-yyyy'), to_date('31.01.2017', 'dd-mm-yyyy'));
insert into career
values (1008, 211, 'U03', to_date('01.04.2016', 'dd-mm-yyyy'), null);
insert into career
values (1004, 215, 'U04', to_date('01.06.2014', 'dd-mm-yyyy'), to_date('31.03.2016', 'dd-mm-yyyy'));
insert into career
values (1004, 215, 'U03', to_date('01.04.2016', 'dd-mm-yyyy'), null);
insert into career
values (1009, 303, 'B01', to_date('01.01.2012', 'dd-mm-yyyy'), to_date('31.12.2015', 'dd-mm-yyyy'));
insert into career
values (1001, 303, 'B01', to_date('01.02.2016', 'dd-mm-yyyy'), null);
insert into career
values (1000, 304, 'B04', to_date('01.01.2016', 'dd-mm-yyyy'), to_date('31.12.2016', 'dd-mm-yyyy'));
insert into career
values (1004, 311, 'U04', to_date('01.06.2014', 'dd-mm-yyyy'), to_date('31.03.2016', 'dd-mm-yyyy'));
insert into career
values (1007, 321, 'U03', to_date('01.09.2012', 'dd-mm-yyyy'), to_date('31.12.2016', 'dd-mm-yyyy'));
insert into career
values (1008, 322, 'U02', to_date('01.09.2012', 'dd-mm-yyyy'), to_date('31.12.2016', 'dd-mm-yyyy'));
insert into career
values (1007, 322, 'U03', to_date('01.02.2017', 'dd-mm-yyyy'), null);
insert into career
values (1009, 327, 'U01', to_date('01.01.2014', 'dd-mm-yyyy'), null);
insert into career
values (1008, 329, 'U02', to_date('01.04.2014', 'dd-mm-yyyy'), to_date('31.05.2016', 'dd-mm-yyyy'));
insert into career
values (1008, 329, 'U02', to_date('01.09.2017', 'dd-mm-yyyy'), null);
insert into career
values (1009, 401, 'C01', to_date('01.09.2005', 'dd-mm-yyyy'), null);
insert into career
values (1002, 402, 'C02', to_date('01.02.2009', 'dd-mm-yyyy'), null);
insert into career
values (1008, 403, 'C02', to_date('01.09.2012', 'dd-mm-yyyy'), null);
insert into career
values (1001, 404, 'C01', to_date('01.01.2012', 'dd-mm-yyyy'), to_date('31.12.2015', 'dd-mm-yyyy'));
insert into career
values (1002, 404, 'U01', to_date('01.02.2016', 'dd-mm-yyyy'), null);
insert into career
values (1007, 410, 'B05', to_date('01.10.2010', 'dd-mm-yyyy'), to_date('31.03.2014', 'dd-mm-yyyy'));
insert into career
values (1007, 410, 'B02', to_date('01.09.2014', 'dd-mm-yyyy'), to_date('31.05.2016', 'dd-mm-yyyy'));
insert into career
values (1007, 410, 'B02', to_date('01.09.2016', 'dd-mm-yyyy'), to_date('31.05.2017', 'dd-mm-yyyy'));
insert into career
values (1002, 412, 'B02', to_date('01.02.2013', 'dd-mm-yyyy'), to_date('30.04.2015', 'dd-mm-yyyy'));
insert into career
values (1002, 412, 'B05', to_date('01.05.2015', 'dd-mm-yyyy'), to_date('31.12.2016', 'dd-mm-yyyy'));
insert into career
values (1002, 412, 'B02', to_date('01.02.2017', 'dd-mm-yyyy'), null);
insert into career
values (1008, 414, 'B02', to_date('01.04.2013', 'dd-mm-yyyy'), to_date('31.12.2016', 'dd-mm-yyyy'));
insert into career
values (1008, 503, 'B02', to_date('01.04.2016', 'dd-mm-yyyy'), null);
insert into career
values (1005, 504, 'B04', to_date('01.05.2012', 'dd-mm-yyyy'), to_date('30.08.2013', 'dd-mm-yyyy'));
insert into career
values (1005, 504, 'B05', to_date('01.01.2014', 'dd-mm-yyyy'), to_date('30.04.2016', 'dd-mm-yyyy'));
insert into career
values (1005, 504, 'B05', to_date('01.01.2017', 'dd-mm-yyyy'), null);
insert into career
values (1006, 505, 'B01', to_date('01.06.2007', 'dd-mm-yyyy'), null);
insert into career
values (1007, 601, 'B05', to_date('01.07.2013', 'dd-mm-yyyy'), null);
commit;
/******************************************************/
/*         премия                     */
/******************************************************/
create table bonus
(
    empno    integer references emp (empno) not null,
    month    smallint check (month > 0 and month < 13),
    year     integer check (year > 2017 and year <= 2024),
    bonvalue real,
    tax      real
);
commit;
insert into bonus
values (505, 1, 2018, 500, Null);
insert into bonus
values (505, 2, 2018, 500, Null);
insert into bonus
values (404, 3, 2018, 300, Null);
insert into bonus
values (404, 5, 2018, 300, Null);
insert into bonus
values (102, 4, 2018, 300, Null);
insert into bonus
values (102, 5, 2018, 300, Null);
insert into bonus
values (102, 9, 2018, 1000, Null);
insert into bonus
values (303, 6, 2018, 300, Null);
insert into bonus
values (504, 7, 2018, 100, Null);
insert into bonus
values (412, 7, 2018, 400, Null);
insert into bonus
values (412, 8, 2018, 400, Null);
insert into bonus
values (412, 12, 2018, 400, Null);
insert into bonus
values (601, 9, 2018, 200, Null);
insert into bonus
values (601, 12, 2018, 200, Null);
insert into bonus
values (414, 10, 2018, 350, Null);
insert into bonus
values (321, 11, 2018, 350, Null);
insert into bonus
values (322, 12, 2018, 350, Null);
insert into bonus
values (401, 12, 2018, 350, Null);
/****************************/
insert into bonus
values (102, 1, 2019, 500, Null);
insert into bonus
values (505, 2, 2019, 500, Null);
insert into bonus
values (102, 3, 2019, 500, Null);
insert into bonus
values (404, 4, 2019, 300, Null);
insert into bonus
values (504, 5, 2019, 150, Null);
insert into bonus
values (412, 6, 2019, 300, Null);
insert into bonus
values (601, 7, 2019, 250, Null);
insert into bonus
values (321, 8, 2019, 300, Null);
insert into bonus
values (322, 9, 2019, 300, Null);
insert into bonus
values (403, 10, 2019, 400, Null);
insert into bonus
values (402, 11, 2019, 450, Null);
insert into bonus
values (403, 12, 2019, 200, Null);
/*****************************/
insert into bonus
values (505, 1, 2020, 500, Null);
insert into bonus
values (102, 2, 2020, 500, Null);
insert into bonus
values (329, 3, 2020, 400, Null);
insert into bonus
values (401, 4, 2020, 300, Null);
insert into bonus
values (402, 5, 2020, 400, Null);
insert into bonus
values (403, 6, 2020, 350, Null);
insert into bonus
values (329, 5, 2020, 400, Null);
insert into bonus
values (403, 7, 2020, 400, Null);
insert into bonus
values (327, 7, 2020, 250, Null);
insert into bonus
values (303, 8, 2020, 450, Null);
insert into bonus
values (101, 9, 2020, 350, Null);
insert into bonus
values (504, 3, 2020, 150, Null);
insert into bonus
values (401, 11, 2020, 200, Null);
insert into bonus
values (303, 12, 2020, 350, Null);
/*************************/
insert into bonus
values (505, 1, 2021, 500, Null);
insert into bonus
values (102, 1, 2021, 350, Null);
insert into bonus
values (327, 2, 2021, 350, Null);
insert into bonus
values (103, 2, 2021, 350, Null);
insert into bonus
values (211, 3, 2021, 350, Null);
insert into bonus
values (503, 10, 2021, 350, Null);
insert into bonus
values (503, 5, 2021, 350, Null);
insert into bonus
values (505, 6, 2021, 300, Null);
insert into bonus
values (211, 7, 2021, 300, Null);
insert into bonus
values (503, 8, 2021, 350, Null);
insert into bonus
values (203, 9, 2021, 300, Null);
insert into bonus
values (211, 10, 2021, 300, Null);
insert into bonus
values (401, 11, 2021, 300, Null);
insert into bonus
values (403, 12, 2021, 350, Null);
insert into bonus
values (101, 12, 2021, 350, Null);
/*************************/
insert into bonus
values (505, 1, 2022, 500, Null);
insert into bonus
values (102, 1, 2022, 500, Null);
insert into bonus
values (102, 2, 2022, 500, Null);
insert into bonus
values (401, 3, 2022, 600, Null);
insert into bonus
values (402, 3, 2022, 600, Null);
insert into bonus
values (403, 4, 2022, 700, Null);
insert into bonus
values (104, 5, 2022, 500, Null);
insert into bonus
values (103, 6, 2022, 500, Null);
insert into bonus
values (102, 6, 2022, 500, Null);
insert into bonus
values (203, 7, 2022, 500, Null);
insert into bonus
values (205, 8, 2022, 300, Null);
insert into bonus
values (203, 9, 2022, 300, null);
insert into bonus
values (211, 10, 2022, 300, null);
insert into bonus
values (401, 11, 2022, 300, null);
insert into bonus
values (403, 12, 2022, 350, null);
insert into bonus
values (101, 12, 2022, 350, null);
/*************************/
insert into bonus
values (601, 1, 2023, 500, null);
insert into bonus
values (505, 1, 2023, 500, null);
insert into bonus
values (504, 2, 2023, 500, null);
insert into bonus
values (503, 2, 2023, 600, null);
insert into bonus
values (503, 3, 2023, 600, null);
insert into bonus
values (412, 3, 2023, 600, null);
insert into bonus
values (401, 4, 2023, 700, null);
insert into bonus
values (404, 5, 2023, 500, null);
insert into bonus
values (327, 6, 2023, 500, null);
insert into bonus
values (102, 6, 2023, 500, null);
insert into bonus
values (203, 7, 2023, 500, null);
insert into bonus
values (601, 8, 2023, 300, null);
insert into bonus
values (203, 9, 2023, 300, null);
commit;







