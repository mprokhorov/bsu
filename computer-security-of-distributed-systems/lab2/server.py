import asyncio
from aioconsole import ainput
from asyncio import AbstractEventLoop
import socket
from server_data import password_manager
from typing import List
from common.common import recieveData, sendData
from server_data.client_processor import ClientProcessor

NEED_SHUTDOWN = False


async def echo(connection: socket, loop: AbstractEventLoop) -> None:
    client = ClientProcessor(connection.getsockname())
    try:
        while not NEED_SHUTDOWN:
            data = await recieveData(connection, loop)
            data = client.processRequest(data)
            await sendData(connection, loop, data)

    except ConnectionResetError:
        print(f"Connection with client {connection.getsockname()} was lost")
    except Exception as ex:
        print(f"Got exception({type(ex)}): {ex}")
    finally:
        clientName = client.address
        client.closeConnection()
        connection.close()
        print(f"Connection with client {clientName} was closed")


echo_tasks = []


async def connection_listener(server_socket, loop):
    while not NEED_SHUTDOWN:
        connection, address = await loop.sock_accept(server_socket)
        connection.setblocking(False)
        print(f"New connection from {address}")
        echo_task = asyncio.create_task(echo(connection, loop))
        echo_tasks.append(echo_task)

    password_manager.PasswordManager.closeSession()


async def shutdown():
    global NEED_SHUTDOWN
    while not NEED_SHUTDOWN:
        data = await ainput("Input 'hack' to close server: ")
        if data == 'hack':
            NEED_SHUTDOWN = True

    waiters = [asyncio.wait_for(task, 2) for task in echo_tasks]
    for task in waiters:
        try:
            await task
        except asyncio.exceptions.TimeoutError:
            # Здесь мы ожидаем истечения тайм-аута
            pass

    password_manager.PasswordManager.closeSession()


async def main():
    server_socket = socket.socket()
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_address = ('127.0.0.1', 8000)
    server_socket.setblocking(False)
    server_socket.bind(server_address)
    server_socket.listen()
    # asyncio.create_task(shutdown())
    await connection_listener(server_socket, loop)


loop = asyncio.new_event_loop()

try:
    loop.run_until_complete(main())
finally:
    loop.close()
