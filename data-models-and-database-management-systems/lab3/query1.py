import asyncio
import asyncpg


async def main():
    conn = await asyncpg.connect(host='localhost', database='postgres', user='postgres', password='547244')
    route_name = input('Введите название маршрута: ')
    tourist_names = await conn.fetch('''
        select tourist.full_name
        from trip join route
        on trip.route_id = route.id and route.name = $1
        join trip_participant
        on trip_participant.trip_id = trip.id
        join tourist on trip_participant.tourist_id = tourist.id;
    ''', route_name)
    print('\nСписок участников маршрута:')
    for r in tourist_names:
        print(r['full_name'])
    await conn.close()


asyncio.get_event_loop().run_until_complete(main())
