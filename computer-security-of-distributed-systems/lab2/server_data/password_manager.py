from os import path
import shelve
import sys
from common.common import singlton
from cryptography.hazmat.primitives import hashes

DATABASE_FOLDER = path.normpath(path.join(path.split(__file__)[0], '..', 'database'))
PASSWORDS_FILE = 'passwords.txt'


@singlton
class PasswordManager:
    def __init__(self):
        self.__passwordsFile = shelve.open(path.join(DATABASE_FOLDER, PASSWORDS_FILE))

    def validateUser(self, login, password):
        if login not in self.__passwordsFile:
            return False

        digest = hashes.Hash(hashes.SHA256())
        digest.update(password.encode())

        if digest.finalize() != self.__passwordsFile[login]:
            return False

        return True

    def createUser(self, login, password):
        if login in self.__passwordsFile:
            return False

        digest = hashes.Hash(hashes.SHA256())
        digest.update(password.encode())
        self.__passwordsFile[login] = digest.finalize()
        return True

    def closeSession(self):
        self.__passwordsFile.close()
