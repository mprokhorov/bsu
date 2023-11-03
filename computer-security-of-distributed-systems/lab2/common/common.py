import enum
import importlib

LENGTH_SIZE = 4
CLIENT_REQUEST_LENGTH = 1
SERVER_RESPONCE_LENGTH = 1
SESSION_KEY_LENGTH = 16
SESSION_IV_LENGTH = 8


async def recieveData(connection, loop):
    while data := await loop.sock_recv(connection, LENGTH_SIZE):
        while len(data) < LENGTH_SIZE:
            data += await loop.sock_recv(connection, LENGTH_SIZE - len(data))

        dataSize = int.from_bytes(data[:LENGTH_SIZE])
        while len(data) < dataSize + LENGTH_SIZE:
            data += await loop.sock_recv(connection, 1024)

        return data[LENGTH_SIZE:]

    raise ConnectionResetError('Connection was closed')


async def sendData(connection, loop, data):
    data = len(data).to_bytes(LENGTH_SIZE) + bytes(data)
    await loop.sock_sendall(connection, data)


class ClientRequests(enum.Enum):
    SHOW_FILES = 1
    GET_FILE = 2
    SAVE_FILE = 3
    LOGIN = 4
    LOGOUT = 5
    ENCRYPT_CONNECTION = 6
    DELETE_FILE = 7
    REGISTER_USER = 8

    def to_bytes(self):
        return self.value.to_bytes(CLIENT_REQUEST_LENGTH)

    @classmethod
    def from_bytes(cls, value: bytes):
        try:
            return cls(int.from_bytes(value))
        except ValueError:
            return None


class ServerResponse(enum.Enum):
    OK = 1
    SERVER_ERROR = 2
    SESSION_TIMEOUT = 3

    def to_bytes(self):
        return self.value.to_bytes(SERVER_RESPONCE_LENGTH)

    @classmethod
    def from_bytes(cls, value: bytes):
        try:
            return cls(int.from_bytes(value))
        except ValueError:
            return None


def register(cmdID):
    def wrapper(callback):
        this_module = importlib.import_module(callback.__module__)
        # Lookup or create module variable
        if not hasattr(this_module, 'networkProcessors'):
            setattr(this_module, 'networkProcessors', {})
        getattr(this_module, 'networkProcessors').setdefault(cmdID, callback)
        return callback

    return wrapper


def singlton(classObj):
    return classObj()
