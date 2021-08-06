from cryptography.fernet import Fernet
from django.conf import settings


class PWSCrypto(object):
    def __init__(self, key=settings.ENCRYPTION_KEY, separator=settings.KEY_SEPARATOR):
        self.sep = separator
        self.key = key
        self.fernet = Fernet(self.key)

    def decrypt(self, kid, ttl=settings.KEY_MAX_AGE):
        """
        First the message will be decrypted with the Max Age given,
        second the ttl gets extracted from the message and is being used to
        decrypt the message one more time with the specified ttl.
        :param kid: Encrypted Message
        :param ttl: Maximum Message Age
        :return: Decrypted Message
        """
        kid = bytes(kid, 'ascii')
        value = str(self.fernet.decrypt(kid, ttl), 'utf8')
        ttl = int(value.rsplit(self.sep, 1)[1])

        value = str(self.fernet.decrypt(kid, ttl), 'utf8')
        data, ttl = value.rsplit(self.sep, 1)
        return data

    def encrypt(self, data, ttl):
        """
        Main encryption method.
        :param data: Data to encrypt
        :param ttl: Time-To-Live in seconds
        :return:
        """
        kid = bytes(('%s%s%s' % (data, self.sep, ttl)).encode('utf8'))
        return str(self.fernet.encrypt(kid), 'ascii')

    def plain_encrypt(self, data):
        """
        Plain encryption method for file encryption
        :param data: Data to encrypt
        :return: Encrypted Data
        """
        return self.fernet.encrypt(data)

    def plain_decrypt(self, data):
        """
        Plain decryption method for file encryption
        :param data: Encrypted Data
        :return: Bytes Object with decrypted data
        """
        return self.fernet.decrypt(data)
