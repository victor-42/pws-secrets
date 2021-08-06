from rest_framework import serializers
from django.conf import settings
from .models import SecretImage


class LogInSecretSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=500, required=True, allow_blank=False)
    password = serializers.CharField(max_length=500, required=True, allow_blank=False)

    def clean_username(self, value):
        return value.replace(settings.SEPERATOR, settings.SEPERATOR_REPLACEMENT)

    def clean_password(self, value):
        return value.replace(settings.SEPERATOR, settings.SEPERATOR_REPLACEMENT)


class NoteSecretSerializer(serializers.Serializer):
    note = serializers.CharField(max_length=2000, required=True, allow_blank=False)

    def clean_note(self, value):
        return value.replace(settings.SEPERATOR, settings.SEPERATOR_REPLACEMENT)


class ImageSecretSerializer(serializers.ModelSerializer):
    note = serializers.CharField(max_length=20000, allow_blank=True, allow_null=True)

    class Meta:
        model = SecretImage
        fields = ['image', 'note']

    def clean_note(self, value):
        return value.replace(settings.SEPERATOR, settings.SEPERATOR_REPLACEMENT)

    def clean_image(self, value):
        value.name = value.name.replace(settings.SEPERATOR, settings.SEPERATOR_REPLACEMENT)
