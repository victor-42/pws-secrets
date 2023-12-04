import json
from datetime import datetime, timedelta
from django.conf import settings
from cryptography.fernet import Fernet


class AlreadyRotatedError(Exception):
    pass


class KeyManager(object):
    def __init__(self):
        # Load Key File
        with open(settings.KEY_FILE, 'r') as f:
            self.__keys = json.load(f)
        if not self.__keys:
            self.__keys = {}
        if self.__keys.get('current', None) is None:
            self.__keys['current'] = Fernet.generate_key()
            self.save_keys()
        super().__init__()

    def save_keys(self):
        with open(settings.KEY_FILE, 'w') as f:
            json.dump(self.__keys, f)

    def get_key(self, key: str = 'current'):
        return self.__keys.get(key)

    def rotate_keys(self):
        if self.__keys.get('old', None) is not None and self.__keys.get('old_expiration', None) is not None:
            expiration = datetime.fromisoformat(self.__keys['current_expiration'])
            if expiration > datetime.now():
                raise AlreadyRotatedError('Keys already rotated')

        self.__keys['old'] = self.__keys['current']
        self.__keys['old_expiration'] = (datetime.now() + timedelta(minutes=settings.MAX_EXPIRATION_MINUTES))\
            .isoformat()
        self.__keys['current'] = Fernet.generate_key()
        self.clean_keys()
        self.save_keys()
        return True

    def clean_keys(self):
        self.__keys = {
            'current': self.__keys['current'],
            'old': self.__keys.get('old', None),
            'old_expiration': self.__keys.get('old_expiration', None)
        }
