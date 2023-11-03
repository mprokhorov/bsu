import pickle
from functools import partial
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.serialization import load_pem_public_key
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import padding

from common.common import ClientRequests, register, SERVER_RESPONCE_LENGTH, ServerResponse, SESSION_KEY_LENGTH

networkProcessors = {}


class ServerProcessor:
    def __init__(self):
        self.connection_key = None
        self.session = None
        self.callback = None

    def processRequest(self, command, clientData=''):
        result = networkProcessors[command](self, clientData)
        return self.__encryptSendData(result)

    def processResponse(self, clientData):
        clientData = self.__decryptReceiveData(clientData)
        serverResponce = ServerResponse.from_bytes(clientData[:SERVER_RESPONCE_LENGTH])
        if ServerResponse.OK != serverResponce:
            self.callback = None
            if serverResponce == ServerResponse.SESSION_TIMEOUT:
                self.session = None

            return clientData[SERVER_RESPONCE_LENGTH:].decode(), serverResponce

        responce = self.callback(clientData[SERVER_RESPONCE_LENGTH:]) if self.callback else None
        self.callback = None
        return None, responce

    @register(ClientRequests.ENCRYPT_CONNECTION)
    def __encryptConnection(self, clientData):
        private_key = ec.generate_private_key(
            ec.SECP384R1()
        )
        public_key = private_key.public_key().public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        self.callback = partial(self.__encryptConnectionResponse, private_key)
        return ClientRequests.ENCRYPT_CONNECTION.to_bytes() + public_key

    def __encryptConnectionResponse(self, privateKey, clientData):
        clientData = pickle.loads(clientData)
        public_key = load_pem_public_key(clientData['publicKey'], default_backend())
        symetric_key = privateKey.exchange(ec.ECDH(), public_key)
        symetric_key = HKDF(hashes.SHA256(), 32, None, None).derive(symetric_key)
        self.connection_key = Cipher(algorithms.AES(symetric_key), modes.CBC(clientData['iv']))

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.LOGIN)
    def __login(self, clientData):
        self.callback = self.__loginResponse
        return ClientRequests.LOGIN.to_bytes() + pickle.dumps(clientData)

    def __loginResponse(self, clientData):
        session_key = clientData[:SESSION_KEY_LENGTH]
        session_iv = clientData[SESSION_KEY_LENGTH:]
        self.session = Cipher(algorithms._IDEAInternal(session_key), modes.CBC(session_iv))

    @register(ClientRequests.REGISTER_USER)
    def __register(self, clientData):
        self.callback = self.__loginResponse
        return ClientRequests.REGISTER_USER.to_bytes() + pickle.dumps(clientData)

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.LOGOUT)
    def __logout(self, clientData):
        self.callback = None
        return ClientRequests.LOGOUT.to_bytes()

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.SHOW_FILES)
    def __getFiles(self, clientData):
        self.callback = self.__getFilesResponse
        return ClientRequests.SHOW_FILES.to_bytes()

    def __getFilesResponse(self, clientData):
        return pickle.loads(clientData)

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.SAVE_FILE)
    def __saveFile(self, clientData):
        fileData = clientData['file']

        padder = padding.PKCS7(64).padder()
        fileData = padder.update(fileData) + padder.finalize()

        encryptor = self.session.encryptor()
        clientData['file'] = encryptor.update(fileData) + encryptor.finalize()

        self.callback = self.__saveFilesResponse
        return ClientRequests.SAVE_FILE.to_bytes() + pickle.dumps(clientData)

    def __saveFilesResponse(self, clientData):
        pass

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.DELETE_FILE)
    def __deleteFile(self, clientData):
        self.callback = self.__deleteFilesResponse
        return ClientRequests.DELETE_FILE.to_bytes() + clientData.encode()

    def __deleteFilesResponse(self, clientData):
        pass

    #
    # --------------------------------------------------------------------------------------------------

    @register(ClientRequests.GET_FILE)
    def __getFile(self, clientData):
        self.callback = self.__getFileResponse
        return ClientRequests.GET_FILE.to_bytes() + clientData.encode()

    def __getFileResponse(self, clientData):
        decryptor = self.session.decryptor()
        clientData = decryptor.update(clientData) + decryptor.finalize()

        padder = padding.PKCS7(64).unpadder()
        return padder.update(clientData) + padder.finalize()

    #
    # --------------------------------------------------------------------------------------------------

    def __encryptSendData(self, data):
        if not self.connection_key:
            return data

        padder = padding.PKCS7(128).padder()
        data = padder.update(data) + padder.finalize()

        encryptor = self.connection_key.encryptor()
        return encryptor.update(data) + encryptor.finalize()

    def __decryptReceiveData(self, data):
        if not self.connection_key:
            return data

        decryptor = self.connection_key.decryptor()
        data = decryptor.update(data) + decryptor.finalize()

        padder = padding.PKCS7(128).unpadder()
        return padder.update(data) + padder.finalize()
