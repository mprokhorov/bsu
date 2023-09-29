create table difficulty_level (
id serial primary key,
name varchar(16)
);

create table point (
id serial primary key,
name varchar(64),
latitude decimal(8, 6) check (latitude between -90.0 and 90.0),
longitude decimal(9, 6) check (longitude between -180.0 and 180.0)
);

create table tourist (
id serial primary key,
full_name varchar(256),
health_info text,
age integer check (age between 18 and 54),
address varchar(256),
phone_number varchar(32),
difficulty_level_id integer references difficulty_level (id)
);

create table route
(
id serial primary key,
difficulty_level_id integer references difficulty_level (id),
name varchar(64) NOT NULL
);

create table route_point (
    id serial primary key,
    route_id integer references route (id),
    point_id integer references point (id),
    sequential_number integer
);

create table trip (
id serial primary key,
route_id integer references route (id)
);

create table trip_participant (
    id serial primary key,
    trip_id integer references trip (id),
    tourist_id integer references tourist (id),
    is_leader boolean
);

create table trip_point (
    id serial primary key,
    trip_id integer references trip (id),
    route_point_id integer references route_point (id),
    necessary_help varchar(256),
    current_state varchar(256),
    date timestamp
);

insert into difficulty_level (name) values
('Начальный'),
('Средний'),
('Трудный');

insert into point (name, latitude, longitude) values
('Железнодорожная станция', 54.711463, 26.203544),
('Поляна', 54.980585, 26.551906),
('Бункер', 54.097445, 26.931746),
('Дом лесничего', 54.443986, 26.328721),
('305-й километр', 54.970873, 26.298425),
('Вершина холма', 54.962928, 26.936413),
('Заброшенная тюрьма', 54.416296, 26.95061),
('Бывшая школа', 54.12309, 26.46455),
('Магазин', 54.716118, 26.680472),
('Опушка', 54.827815, 26.21454);

insert into tourist (full_name, health_info, age, address, phone_number, difficulty_level_id) values
('Прохоров Михаил', 'Полностью здоров', 20, 'д. Боровляны', '+375293319353', 2),
('Жук Павел', 'Есть аллергия на сырость', 21, 'г. Минск', '+375291063636', 1),
('Бруцкий Владислав', 'Полностью здоров', 20, 'г. Минск', '+375291011904', 1),
('Раткевич Григорий', 'Две недели назад был перелом руки', 20, 'г. Лида', '+375294561904', 1),
('Баранов Никита', 'Полностью здоров', 20, 'г. Минск', '+375297890675', 1),
('Олешко Владислав', 'Полностью здоров', 21, 'г. Гродно', '+375291213905', 1),
('Шавнев Никита', 'Астма', 20, 'г. Минск', '+375292348765', 1),
('Жидович Максим', 'Полностью здоров', 21, 'г. Минск', '+375298906745', 1),
('Жданов Андрей', 'Аллергия на грибы', 20, 'г. Бобруйск', '+375443219343', 1),
('Зеленковский Виктор', 'Полностью здоров', 20, 'г. Минск', '+375293389067', 1);

insert into route (difficulty_level_id, name) values
(1, 'Простая тропинка'),
(2, 'Прогулка за грибами'),
(3, 'Экскурсия по тюрьме'),
(1, 'Исследовательский поход'),
(2, 'Сложная тропа'),
(3, 'Восхождение на холм'),
(3, 'Исследование бункера'),
(1, 'Поход за ягодами'),
(1, 'Прогулка'),
(2, 'Сложная прогулка');

insert into route_point (route_id, point_id, sequential_number) values
(1, 1, 1),
(1, 4, 2),
(1, 6, 3),
(1, 7, 4),
(1, 3, 5),
(2, 9, 1),
(2, 7, 2),
(2, 8, 3),
(2, 6, 4),
(2, 3, 5);

insert into trip (route_id) values
(1),
(2);

insert into trip_participant (trip_id, tourist_id, is_leader) values
(1, 1, true),
(1, 3, false),
(1, 4, false),
(1, 5, false),
(1, 6, false);

insert into trip_participant (trip_id, tourist_id, is_leader) values
(2, 1, true),
(2, 3, false),
(2, 7, false),
(2, 5, false),
(2, 6, false);

insert into trip_point (trip_id, route_point_id, necessary_help, current_state, date) values
(1, 1, null, 'Удовлетворительное', '2023-09-21 14:00:00'),
(1, 2, null, 'Удовлетворительное', '2023-09-21 16:20:00'),
(1, 3, null, 'Отличное', '2023-09-21 17:50:00'),
(1, 4, null, 'Усталое', '2023-09-21 18:55:00'),
(1, 5, null, 'Бодрое', '2023-09-21 19:00:00'),
(2, 6, null, 'Удовлетворительное', '2023-09-22 12:20:00'),
(2, 7, null, 'Измотанное', '2023-09-22 13:55:00'),
(2, 8, null, 'Хорошее', '2023-09-22 15:50:00'),
(2, 9, null, 'Весёлое', '2023-09-22 17:12:00'),
(2, 10, null, 'Удовлетворительное', '2023-09-22 18:34:00');
