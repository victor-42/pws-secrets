from django.core.files.base import ContentFile, File
from rest_framework import serializers
from django.conf import settings
from uuid import uuid4
from . import extract_uuid
from .models import SecretImage, Secret

type_choices = (
    ('p', 'Password'),
    ('n', 'Note'),
    ('i', 'Image')
)
from cryptography.fernet import Fernet, InvalidToken


class BaseSecretSerializer(serializers.Serializer):
    expiration_date = serializers.DateTimeField(format="%Y-%m-%d %H:%M:%S", required=True)
    type = serializers.ChoiceField(choices=type_choices, required=True)
    uuid = serializers.UUIDField(required=True)
    view_time = serializers.CharField(required=False, allow_null=True)

    def validate_uuid(self, value):
        value = str(value)
        if value is None:
            return value
        if extract_uuid(value) is None:
            raise serializers.ValidationError('Invalid UUID')
        if Secret.objects.filter(uuid=value).exists():
            raise serializers.ValidationError('Invalid UUID')
        return value

    def validate_view_time(self, value):
        if value in [None, '', 'null']:
            return None
        if isinstance(value, str):
            value = int(value)

        if value < 0:
            raise serializers.ValidationError('View time must be greater than 0')
        return value % 301

    def validate_expiration(self, value):
        if value is None:
            return value
        if value < self.initial_data['created_at']:
            raise serializers.ValidationError('Expiration must be after creation')
        return value

    def save(self):

        secret = Secret.objects.create(
            uuid=self.validated_data['uuid'],
            type=self.validated_data['type'],
            expiration=self.validated_data['expiration_date'],
            view_time=self.validated_data.get('view_time', None)
        )
        return secret


class LogInSecretSerializerMixin(serializers.Serializer):
    username = serializers.CharField(max_length=500, required=True, allow_blank=False)
    password = serializers.CharField(max_length=500, required=True, allow_blank=False)

    def clean_username(self, value):
        return value.replace(settings.SEPARATOR, settings.SEPARATOR_REPLACEMENT)

    def clean_password(self, value):
        return value.replace(settings.SEPARATOR, settings.SEPARATOR_REPLACEMENT)

    def save(self):
        secret = super().save()
        return settings.SEPARATOR.join([self.validated_data['username'], self.validated_data['password']]), secret

    @staticmethod
    def from_encryption_string(encryption_string):
        username, password = encryption_string.split(settings.SEPARATOR)
        serializer = LogInSecretSerializerMixin(data={'username': username, 'password': password})
        if serializer.is_valid(raise_exception=True):
            return serializer
        return None


class LogInSecretSerializer(LogInSecretSerializerMixin, BaseSecretSerializer):
    pass


class NoteSecretSerializerMixin(serializers.Serializer):
    note = serializers.CharField(max_length=1750, required=True, allow_blank=False)

    def save(self):
        secret = super().save()
        return self.validated_data['note'], secret

    @staticmethod
    def from_encryption_string(encryption_string):
        serializer = NoteSecretSerializerMixin(data={'note': encryption_string})
        if serializer.is_valid(raise_exception=True):
            return serializer
        return None


class NoteSecretSerializer(NoteSecretSerializerMixin, BaseSecretSerializer):
    pass


class ImageSecretSerializerMixin(BaseSecretSerializer):
    note = serializers.CharField(max_length=15000, allow_blank=True, allow_null=True)
    image = serializers.ImageField(required=True, allow_null=False, allow_empty_file=False)

    @staticmethod
    def encrypt(image, key):
        crypto = Fernet(key=key)
        return crypto.encrypt(image)

    @staticmethod
    def decrypt(image, key):
        crypto = Fernet(key=key)
        return crypto.decrypt(image)

    def save(self):
        secret = super().save()
        key = Fernet.generate_key()
        uuid = str(uuid4())
        if self.validated_data['note'] is not None:
            encrypted_note = str(
                self.encrypt(
                    self.validated_data['note'].encode('utf-8'), key),
                'utf-8')
        else:
            encrypted_note = None

        plain_image = self.validated_data['image'].file.read()
        encrypted_image = self.encrypt(plain_image, key)
        encrypted_name = self.encrypt(self.validated_data['image'].name.encode('utf-8'), key)

        SecretImage.objects.create(
            uuid=uuid,
            image=ContentFile(encrypted_image, name=str(encrypted_name, 'utf-8')),
            note=encrypted_note
        )
        return (str(uuid) + str(key, 'utf-8')), secret

    @staticmethod
    def from_encryption_string(encryption_string):
        image_uuid = str(extract_uuid(encryption_string).group(0))
        image_decryption_key = encryption_string.replace(image_uuid, '')
        if image_uuid is None or image_decryption_key is None:
            return None
        image = SecretImage.objects.filter(uuid=image_uuid).first()
        if image is None:
            return None

        try:
            image_decrypted = ImageSecretSerializerMixin.decrypt(image.image.file.read(), image_decryption_key)
            note_decrypted = ImageSecretSerializerMixin.decrypt(image.note, image_decryption_key)
            print('note decrypted')
            image_name_decrypted = ImageSecretSerializerMixin.decrypt(
                image.image.name.encode('utf-8'), image_decryption_key)
        except InvalidToken:
            return None

        serializer = ImageSecretSerializerMixin(data={'image': ContentFile(image_decrypted,
                                                                           name=image_name_decrypted),
                                                      'note': note_decrypted})
        return serializer

    class Meta:
        model = SecretImage
        fields = ['image', 'note']


class ImageSecretSerializer(ImageSecretSerializerMixin, BaseSecretSerializer):
    class Meta:
        model = SecretImage
        fields = ['image', 'note']


class SecretSerializer(serializers.ModelSerializer):
    class Meta:
        model = Secret
        fields = '__all__'
