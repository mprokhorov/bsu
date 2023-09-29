select tourist.full_name
from trip join route
on trip.route_id = route.id and route.name = 'Простая тропинка'
join trip_participant
on trip_participant.trip_id = trip.id
join tourist on trip_participant.tourist_id = tourist.id;

select distinct r1.name, r2.name
from route_point as rp1
join route_point as rp2
on rp1.point_id = rp2.point_id and rp1.route_id > rp2.route_id
join route as r1
on r1.id = rp1.route_id
join route as r2
on r2.id = rp2.route_id;

select difficulty_level.name from tourist
join difficulty_level on tourist.difficulty_level_id = difficulty_level.id and tourist.full_name = 'Жук Павел';
