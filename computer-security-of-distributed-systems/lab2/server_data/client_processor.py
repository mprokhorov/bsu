import os
import time
from os import walk
import pickle
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.serialization import load_pem_public_key
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.kdf.hkdf import HKDF

from common.common import ClientRequests, register, CLIENT_REQUEST_LENGTH, ServerResponse, SESSION_KEY_LENGTH, SESSION_IV_LENGTH
from server_data.password_manager import PasswordManager

networkProcessors = {}

DIRECTORY_FILES = os.path.join(os.path.split(os.path.join(__file__))[0], 'files')

SESSION_LIVE_TIME = 100


def needEncription(func):
    def wrapper(*args, **kwargs):
        self = args[0]
        if not self.connection_key:
            return ServerResponse.SERVER_ERROR.to_bytes() + 'First you must ecrypt connection'.encode()

        return func(*args, **kwargs)

    return wrapper


def needLogin(func):
    def wrapper(*args, **kwargs):
        self = args[0]
        if not self.clientLogin:
            return ServerResponse.SERVER_ERROR.to_bytes() + 'First you must login'.encode()

        if self.clientLogin['timeout'] < time.time():
            self.clientLogin = None
            return ServerResponse.SESSION_TIMEOUT.to_bytes() + 'Session timeout'.encode()

        return func(*args, **kwargs)

    return wrapper


class ClientProcessor(object):
    def __init__(self, address):
        self.address = address
        self.connection_key = None
        self.clientLogin = None

    def processRequest(self, clientData):
        clientData = self.__decryptReceiveData(clientData)
        requestKey = ClientRequests.from_bytes(clientData[:CLIENT_REQUEST_LENGTH])
        result = networkProcessors[requestKey](self, clientData[CLIENT_REQUEST_LENGTH:])
        if requestKey == ClientRequests.ENCRYPT_CONNECTION:
            return result

        return self.__encryptSendData(result)

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.ENCRYPT_CONNECTION)
    def __createConnection(self, clientData):
        self.clientLogin = None

        private_key = ec.generate_private_key(
            ec.SECP384R1()
        )
        public_key = private_key.public_key().public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        symetric_key = private_key.exchange(ec.ECDH(), load_pem_public_key(clientData, default_backend()))
        symetric_key = HKDF(hashes.SHA256(), 32, None, None).derive(symetric_key)

        iv = os.urandom(16)
        self.connection_key = Cipher(algorithms.AES(symetric_key), modes.CBC(iv))
        return ServerResponse.OK.to_bytes() + pickle.dumps({
            'publicKey': public_key,
            'iv': iv
        })

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.LOGIN)
    @needEncription
    def __login(self, clientData):
        clientData = pickle.loads(clientData)
        if not PasswordManager.validateUser(clientData['login'], clientData['password']):
            return ServerResponse.SERVER_ERROR.to_bytes() + 'Invalid login or password'.encode()

        key = os.urandom(SESSION_KEY_LENGTH)
        iv = os.urandom(SESSION_IV_LENGTH)
        cipher = Cipher(algorithms._IDEAInternal(key), modes.CBC(iv))
        self.clientLogin = {
            'login': clientData['login'],
            'session': cipher,
            'timeout': SESSION_LIVE_TIME + time.time()
        }
        return ServerResponse.OK.to_bytes() + key + iv

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.REGISTER_USER)
    @needEncription
    def __register(self, clientData):
        clientData = pickle.loads(clientData)
        if not PasswordManager.createUser(clientData['login'], clientData['password']):
            return ServerResponse.SERVER_ERROR.to_bytes() + 'Can not create user'.encode()

        key = os.urandom(SESSION_KEY_LENGTH)
        iv = os.urandom(SESSION_IV_LENGTH)
        cipher = Cipher(algorithms._IDEAInternal(key), modes.CBC(iv))
        self.clientLogin = {
            'login': clientData['login'],
            'session': cipher,
            'timeout': SESSION_LIVE_TIME + time.time()
        }
        return ServerResponse.OK.to_bytes() + key + iv

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.LOGOUT)
    @needLogin
    def __logout(self, clientData):
        self.clientLogin = None
        return ServerResponse.OK.to_bytes()

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.SHOW_FILES)
    @needLogin
    def __showFiles(self, clientData):
        filenames = next(walk(DIRECTORY_FILES), (None, None, []))[2]
        return ServerResponse.OK.to_bytes() + pickle.dumps(filenames)

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.GET_FILE)
    @needLogin
    def __getFile(self, clientData):
        filenames = next(walk(DIRECTORY_FILES), (None, None, []))[2]
        filename = clientData.decode()
        if filename not in filenames:
            return ServerResponse.SERVER_ERROR.to_bytes() + 'No such file'.encode()

        with open(DIRECTORY_FILES + os.path.sep + filename, 'rb') as file:
            result = file.read()

        padder = padding.PKCS7(64).padder()
        result = padder.update(result) + padder.finalize()

        encryptor = self.clientLogin['session'].encryptor()
        return ServerResponse.OK.to_bytes() + encryptor.update(result) + encryptor.finalize()

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.SAVE_FILE)
    @needLogin
    def __saveFile(self, clientData):
        clientData = pickle.loads(clientData)
        decryptor = self.clientLogin['session'].decryptor()
        with open(DIRECTORY_FILES + os.path.sep + clientData['filename'], 'wb') as file:
            result = decryptor.update(clientData['file']) + decryptor.finalize()

            padder = padding.PKCS7(64).unpadder()
            file.write(padder.update(result) + padder.finalize())

        return ServerResponse.OK.to_bytes()

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.DELETE_FILE)
    @needLogin
    def __deleteFile(self, clientData):
        filename = clientData.decode()
        filenames = next(walk(DIRECTORY_FILES), (None, None, []))[2]
        if filename not in filenames:
            return ServerResponse.SERVER_ERROR.to_bytes() + 'No such file'.encode()

        os.remove(DIRECTORY_FILES + os.path.sep + filename)
        return ServerResponse.OK.to_bytes()

    #
    # --------------------------------------------------------------------------------------------------

    def __encryptSendData(self, clientData):
        if not self.connection_key:
            return clientData

        padder = padding.PKCS7(128).padder()
        clientData = padder.update(clientData) + padder.finalize()

        encryptor = self.connection_key.encryptor()
        return encryptor.update(clientData) + encryptor.finalize()

    def __decryptReceiveData(self, clientData):
        if not self.connection_key:
            return clientData

        decryptor = self.connection_key.decryptor()
        clientData = decryptor.update(clientData) + decryptor.finalize()

        padder = padding.PKCS7(128).unpadder()
        return padder.update(clientData) + padder.finalize()

    def closeConnection(self):
        self.address = None
        self.connection_key = None
        self.clientLogin = None
