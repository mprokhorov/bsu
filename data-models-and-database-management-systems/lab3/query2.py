import asyncio
import asyncpg


async def main():
    conn = await asyncpg.connect(host='localhost', database='postgres', user='postgres', password='547244')
    route_pairs = await conn.fetch('''
        select distinct r1.name as name_1, r2.name as name_2
        from route_point as rp1
        join route_point as rp2
        on rp1.point_id = rp2.point_id and rp1.route_id > rp2.route_id
        join route as r1
        on r1.id = rp1.route_id
        join route as r2
        on r2.id = rp2.route_id;
    ''')
    print('Список пересекающихся маршрутов:')
    for i, r in enumerate(route_pairs):
        print(str(i + 1) + '.', r['name_1'], '<->', r['name_2'])
    await conn.close()


asyncio.get_event_loop().run_until_complete(main())
