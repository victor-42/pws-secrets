import json
import re
from datetime import datetime, timedelta
from django.conf import settings
from cryptography.fernet import Fernet, InvalidToken

from api.models import Secret

uuid_pattern = r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'


class AlreadyRotatedError(Exception):
    pass


class KeyManager(object):
    old_fernet = None
    fernet = None

    def __init__(self):
        # Load Key File
        try:
            with open(settings.KEYFILE_PATH, 'r') as f:
                self.__keys = json.load(f)
        except FileNotFoundError:
            self.__keys = {}
        if self.__keys.get('current', None) is None:
            self.__keys['current'] = str(Fernet.generate_key(), 'utf-8')
            self.save_keys()

        self.fernet = Fernet(self.__keys['current'])
        if self.__keys.get('old', None) is not None:
            self.old_fernet = Fernet(self.__keys['old'])
        super().__init__()

    @property
    def rotated(self):
        expiration = self.__keys.get('old_expiration', None)
        if expiration is None:
            return None

        self.clean_keys()
        expiration = self.__keys.get('old_expiration', None)
        return expiration

    def save_keys(self):
        self.fernet = Fernet(self.__keys['current'])
        if self.__keys.get('old', None) is not None:
            self.old_fernet = Fernet(self.__keys['old'])

        with open(settings.KEYFILE_PATH, 'w') as f:
            json.dump(self.__keys, f)

    def decrypt(self, data):
        try:
            value = str(self.fernet.decrypt(data), 'utf-8')
        except InvalidToken as e:
            if self.old_fernet is None:
                return None
            try:
                value = str(self.old_fernet.decrypt(data), 'utf-8')
            except InvalidToken as e:
                return None

        match = re.match(uuid_pattern, value)

        if match:
            uuid = match.group(0)
        else:
            return None

        secret = Secret.objects.filter(uuid=uuid).first()
        if secret is None or secret.opened_at is not None or secret.expiration < datetime.utcnow():
            return None

        secret.opened_at = datetime.utcnow()
        secret.save()

        return secret, value[len(uuid):]

    def encrypt(self, data, secret: Secret):
        return self.fernet.encrypt(bytes(str(secret.uuid) + data, 'utf-8'))

    def rotate_keys(self):
        if self.__keys.get('old', None) is not None and self.__keys.get('old_expiration', None) is not None:
            expiration = datetime.fromisoformat(self.__keys['old_expiration'])
            if expiration > datetime.now():
                raise AlreadyRotatedError('Keys already rotated')

        self.__keys['old'] = self.__keys['current']
        self.__keys['old_expiration'] = (datetime.now() + timedelta(minutes=settings.MAX_EXPIRATION_MINUTES))\
            .isoformat()
        self.__keys['current'] = str(Fernet.generate_key(), 'utf-8')
        self.clean_keys()
        self.save_keys()
        return True

    def clean_keys(self):
        expiration = self.__keys.get('old_expiration', None)
        if expiration is not None and datetime.fromisoformat(expiration) < datetime.utcnow():
            self.__keys['old'] = None

        self.__keys = {
            'current': self.__keys['current'],
            'old': self.__keys.get('old', None),
            'old_expiration': self.__keys.get('old_expiration', None)
        }
