from cryptography.fernet import InvalidToken
from rest_framework import serializers
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.exceptions import ParseError, ValidationError

from .keys import KeyManager, AlreadyRotatedError
from .serializer import LogInSecretSerializer, NoteSecretSerializer, ImageSecretSerializer, SecretSerializer, \
    NoteSecretSerializerMixin, LogInSecretSerializerMixin, ImageSecretSerializerMixin
from .models import Secret

key_manager = KeyManager()

serializer_map = {
    'p': LogInSecretSerializer,
    'n': NoteSecretSerializer,
    'i': ImageSecretSerializer
}

serializer_mixin_map = {
    'p': LogInSecretSerializerMixin,
    'n': NoteSecretSerializerMixin,
    'i': ImageSecretSerializerMixin
}


class SecretsView(APIView):
    class SecretsRetrieveSerializer(serializers.Serializer):
        ids = serializers.ListField(child=serializers.UUIDField())

    def get_ids(self, request):
        """
        Get ids from request
        :param request:
        :return:
        """
        serializer = self.SecretsRetrieveSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return serializer.data['ids']

    def put(self, request):
        """
        Get all Secret Meta Information of the user
        :param request:
        :return:
        """
        ids = self.get_ids(request)
        secrets = Secret.objects.filter(uuid__in=ids)
        serializer = SecretSerializer(secrets, many=True)
        return Response(serializer.data, status=200)

    def patch(self, request):
        """
        Delete all Secret Meta Information of the user
        :param request:
        :return:
        """
        ids = self.get_ids(request)
        secrets = Secret.objects.filter(uuid__in=ids)
        secrets.delete()
        return Response(status=204)


class KeyRotateView(APIView):
    def get(self, request):
        # Returns status of key rotation
        return Response(status=200, data={'rotated_at': key_manager.rotated})

    def post(self, request):
        """
        Rotate the Key
        :param request:
        :return:
        """
        try:
            key_manager.rotate_keys()
        except AlreadyRotatedError:
            return Response(status=403, data={'detail': 'Key already rotated. Wait...'})
        return Response(status=200, data={'detail': 'Key rotated'})


class SecretView(APIView):

    def invalid(self):
        return Response(status=404, data={'detail': 'Secret not found'})

    def post(self, request):
        """
        Create a new Secret
        :param request:
        :return:
        """
        typ = request.data.get('type')
        if typ not in serializer_map:
            Response(status=400, data={'detail': 'Invalid Secret Type'})

        try:
            serializer = serializer_map[typ](data=request.data)
            serializer.is_valid(raise_exception=True)
            to_encrypt, secret_obj = serializer.save()
            cryptic = key_manager.encrypt(to_encrypt, secret_obj)
        except Exception as e:
            return Response(status=400, data={'detail': 'Error'})

        return Response(status=201, data={'enc': cryptic.decode('ascii')})

    def get(self, request, cryptic):
        """
        Get a Secret
        :param cryptic: Encrypted Secret Message
        :param request:
        :return:
        """
        if cryptic is None:
            return self.invalid()

        cryptic = bytes(cryptic, 'ascii')
        response = key_manager.decrypt(cryptic)
        if response is None:
            return self.invalid()

        secret, value = response
        serializer = serializer_mixin_map[secret.type].from_encryption_string(value)

        if serializer is None:
            return self.invalid()

        repr = {}
        repr['secret'] = serializer.data
        repr['view_time'] = secret.view_time
        repr['type'] = secret.type
        return Response(repr, status=200)
