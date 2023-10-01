import asyncio
import asyncpg


async def main():
    conn = await asyncpg.connect(host='localhost', database='postgres', user='postgres', password='547244')
    tourist_name = input('Введите участника: ')
    tourist_level = await conn.fetch('''
        select difficulty_level.name from tourist
        join difficulty_level on tourist.difficulty_level_id = difficulty_level.id and tourist.full_name = $1;
    ''', tourist_name)
    print('\nУровень участника:')
    for r in tourist_level:
        print(r['name'])
    await conn.close()


asyncio.get_event_loop().run_until_complete(main())
