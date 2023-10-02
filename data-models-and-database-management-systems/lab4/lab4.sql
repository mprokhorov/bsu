create or replace function check_tourist_level() returns trigger as $check_tourist_level$
    declare
        tourist_level integer;
        route_level integer;
    begin
        select tourist.difficulty_level_id into tourist_level from tourist
        where tourist.id = new.tourist_id;

        select difficulty_level_id into route_level from trip
        join route
        on route.id = trip.route_id and trip.id = new.trip_id;

        if new.is_leader and not (tourist_level > route_level or tourist_level = 3) then
            raise exception 'Leader level exception: tourist_level = %, route_level = %', tourist_level, route_level;
        end if;

        if not new.is_leader and not (tourist_level = route_level or tourist_level = route_level - 1) then
            raise exception 'Group member level exception: tourist_level = %, route_level = %', tourist_level, route_level;
        end if;

        return new;
    end;
$check_tourist_level$ language plpgsql;

create or replace function update_tourist_level() returns trigger as $update_tourist_level$
    declare
        tourist_level integer;
    begin
        select max(difficulty_level_id) into tourist_level from trip_participant
        join trip
        on trip.id = trip_participant.trip_id and trip_participant.tourist_id = new.tourist_id
        join route
        on trip.route_id = route.id;

        if tourist_level is null then
            tourist_level := 1;
        end if;

        update tourist set difficulty_level_id = tourist_level
        where tourist.id = new.tourist_id and tourist.difficulty_level_id < tourist_level;

        return new;
    end;
$update_tourist_level$ language plpgsql;

create or replace function check_tourists_amount() returns trigger as $check_tourists_amount$
    declare
        tourist_count integer;
        leader_count integer;
    begin
        select count(*) into tourist_count from trip_participant
        join tourist on trip_participant.trip_id = new.trip_id and trip_participant.trip_id = tourist.id
        and not trip_participant.is_leader;

        if tourist_count < 4 then
            raise exception 'Tourist amount can''t be less than 4';
        end if;

        select count(*) into leader_count from trip_participant
        join tourist on trip_participant.trip_id = new.trip_id and trip_participant.trip_id = tourist.id
        and trip_participant.is_leader;

        if leader_count != 1 then
            raise exception 'Group should contain exactly one leader';
        end if;

        return new;
    end;
$check_tourists_amount$ language plpgsql;

create or replace trigger check_tourist_level before insert or update on trip_participant
    for each row execute procedure check_tourist_level();

create or replace trigger update_tourist_level after insert or update on trip_participant
    for each row execute procedure update_tourist_level();

create or replace trigger check_tourists_amount before insert or update on trip_point
    for each row execute procedure check_tourists_amount();
