import asyncio
import socket
from common.common import recieveData, sendData
from client_data.command_dispatcher import CommandsDispatcher


async def main():
    try:
        clientSocket = socket.socket()
        clientSocket.connect(('10.160.46.207', 8000))
        commandProcessor = CommandsDispatcher()
        while True:
            data = commandProcessor.processRequest()
            await sendData(clientSocket, loop, data)
            data = await recieveData(clientSocket, loop)
            commandProcessor.processResponce(data)
    except ConnectionAbortedError:
        print(f"Connection with server was lost")
    except Exception as ex:
        print(f"Got exception({type(ex)}): {ex}")
    finally:
        commandProcessor.closeConnection()
        clientSocket.close()
        print("Connection with server was closed")


loop = asyncio.new_event_loop()
if __name__ == '__main__':
    loop.run_until_complete(main())
