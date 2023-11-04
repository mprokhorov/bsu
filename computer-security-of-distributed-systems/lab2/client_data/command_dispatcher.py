import enum
import os
import sys
from functools import partial
from .server_processor import ServerProcessor
from common.common import register, ClientRequests, ServerResponse

networkProcessors = {}


class ClientStates(enum.Enum):
    WAITING = 0
    CREATE_CONNECTION = 1
    LOGIN = 2
    LOGOUT = 3
    EXIT = 4
    REGISTER = 5
    MAIN_FUNCTIONS = 6
    SHOW_FILES = 7
    GET_FILE = 8
    SET_FILE = 9
    DELETE_FILE = 10


class CommandsDispatcher(object):
    def __init__(self):
        self.login = None
        self.state = ClientStates.CREATE_CONNECTION
        self.serverProcessor = ServerProcessor()
        self.callBack = None

    def processRequest(self):
        while True:
            os.system('cls' if os.name == 'nt' else 'clear')
            print('*' * 50 + f' Текущий аккаунт: {self.login}')
            print('\n'.join(cmdOutput[self.state][0]))
            answer = input("Введите необходимый номер: ")
            try:
                answer = int(answer)
            except ValueError:
                continue

            if not (1 <= answer <= len(cmdOutput[self.state][1])):
                continue

            self.state = cmdOutput[self.state][1][answer - 1]
            os.system('cls' if os.name == 'nt' else 'clear')
            data = networkProcessors[self.state](self)
            if data is not None:
                self.state = ClientStates.WAITING
                print("Ожидаем ответ от сервера.")
                return data

    def processResponce(self, serverData):
        error, result = self.serverProcessor.processResponse(serverData)
        if error and result == ServerResponse.SESSION_TIMEOUT:
            print("Истекло время жизни сессии. Сейчас необходимо будет снова войти в аккаунт.")
            self.login = None
            self.callBack = None
            self.state = ClientStates.LOGIN

        if self.callBack:
            self.callBack(error, result)
        input('Нажмите enter чтобы продолжить!\n')

    def closeConnection(self):
        self.login = None
        self.state = ClientStates.CREATE_CONNECTION
        self.serverProcessor = None
        self.callBack = None

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientStates.CREATE_CONNECTION)
    def __createConnection(self):
        print("Начинаем шифрование соединения.")
        data = self.serverProcessor.processRequest(ClientRequests.ENCRYPT_CONNECTION)
        self.callBack = self.__completeCreateConnection
        return data

    def __completeCreateConnection(self, error, serverData):
        print("Соединение успешно зашифровано.")
        self.state = ClientStates.LOGIN

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientStates.LOGIN)
    def __login(self):
        name = input("Введите имя: ")
        password = input("Введите пароль: ")
        clientData = {
            'login': name,
            'password': password
        }
        self.callBack = partial(self.__completelogin, name)
        return self.serverProcessor.processRequest(ClientRequests.LOGIN, clientData)

    @register(ClientStates.REGISTER)
    def __register(self):
        name = input("Введите новое имя: ")
        password = input("Введите новый пароль: ")
        clientData = {
            'login': name,
            'password': password
        }
        self.callBack = partial(self.__completelogin, name)
        return self.serverProcessor.processRequest(ClientRequests.REGISTER_USER, clientData)

    def __completelogin(self, login, error, serverData):
        if error:
            print(f"Вход под логином {login} не выполнен: {error}")
            self.state = ClientStates.LOGIN
            return

        print(f"Вы успешно вошли под логином: {login}")
        self.login = login
        self.state = ClientStates.MAIN_FUNCTIONS

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientStates.LOGOUT)
    def __logout(self):
        print(f"Начинаем процедуру выхода c аккаунта {self.login}")
        self.callBack = partial(self.__completelogout, self.login)
        return self.serverProcessor.processRequest(ClientRequests.LOGOUT)

    def __completelogout(self, login, error, serverData):
        if error:
            print(f"Выход под логином {login} не выполнен: {error}")
            self.state = ClientStates.MAIN_FUNCTIONS
            return

        print(f"Вы успешно вышли из аккаунта: {login}")
        self.login = None
        self.state = ClientStates.LOGIN

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientStates.SHOW_FILES)
    def __showFiles(self):
        self.callBack = self.__completeShowFiles
        return self.serverProcessor.processRequest(ClientRequests.SHOW_FILES, '')

    def __completeShowFiles(self, error, serverData):
        print("Файлы на сервере: ")
        print('\n'.join(serverData))
        self.state = ClientStates.MAIN_FUNCTIONS

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientStates.SET_FILE)
    def __saveFile(self):
        filenameF = input("Введите имя исходного файла: ")
        filenameT = input("Введите имя конечного файла: ")
        if not os.path.exists(filenameF):
            print('Такого файла не существует!')
            input('Нажмите enter чтобы продолжить!\n')
            self.state = ClientStates.MAIN_FUNCTIONS
            return None

        with open(filenameF, 'rb') as file:
            data = file.read()

        result = {
            'filename': filenameT,
            'file': data
        }
        self.callBack = self.__completeSaveFile
        return self.serverProcessor.processRequest(ClientRequests.SAVE_FILE, result)

    def __completeSaveFile(self, error, serverData):
        print("Файл успешно сохранён")
        self.state = ClientStates.MAIN_FUNCTIONS

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientStates.DELETE_FILE)
    def __deleteFile(self):
        filename = input("Введите имя файла: ")
        self.callBack = partial(self.__completeDeleteFile, filename)
        return self.serverProcessor.processRequest(ClientRequests.DELETE_FILE, filename)

    def __completeDeleteFile(self, filename, error, serverData):
        if error:
            print(f"Удаление файла ({filename}) не выполнено: {error}")
        else:
            print(f"Файл ({filename}) успешно удалён")

        self.state = ClientStates.MAIN_FUNCTIONS

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientStates.GET_FILE)
    def __getFile(self):
        filename = input("Введите имя файла: ")
        self.callBack = partial(self.__completeGetFile, filename)
        return self.serverProcessor.processRequest(ClientRequests.GET_FILE, filename)

    def __completeGetFile(self, filename, error, serverData):
        self.state = ClientStates.MAIN_FUNCTIONS
        if error:
            print(f"Файл не удалось скачать: {error}")
            return

        with open(filename, 'wb') as file:
            file.write(serverData)

        print(f"Файл {filename} успешно добавлен")

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientStates.EXIT)
    def __showFiles(self):
        sys.exit(0)


#
# --------------------------------------------------------------------------------------------------


cmdOutput = {
    ClientStates.CREATE_CONNECTION: (
        [
            "1) Создать соединение",
            "2) Завершить программу",
        ],
        (ClientStates.CREATE_CONNECTION, ClientStates.EXIT)
    ),

    ClientStates.LOGIN: (
        [
            "1) Войти под логином и паролем",
            "2) Зарегистрироваться",
            "3) Завершить программу",
        ],
        (ClientStates.LOGIN, ClientStates.REGISTER, ClientStates.EXIT)
    ),

    ClientStates.MAIN_FUNCTIONS: (
        [
            "1) Посмотреть файлы",
            "2) Скачать файл",
            "3) Отправить файл",
            "4) Удалить файл",
            "5) Выйти"
        ],
        (ClientStates.SHOW_FILES, ClientStates.GET_FILE, ClientStates.SET_FILE, ClientStates.DELETE_FILE,
         ClientStates.LOGOUT)
    )
}
