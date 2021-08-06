# -*- coding: utf-8 -*-
import time
import hashlib
import json
import uuid
import datetime
import io

from cryptography.fernet import InvalidToken
from django.conf import settings
from django.http import HttpResponse
from django.shortcuts import render
from django.views import View
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.exceptions import ParseError
from rest_framework.parsers import FileUploadParser, MultiPartParser
from cryptography.fernet import Fernet
from django.core.files.base import ContentFile

from .crypting import PWSCrypto
from .serializer import LogInSecretSerializer, NoteSecretSerializer, ImageSecretSerializer
from .models import SecretImage


class PwsViewMixin(object):
    permission_classes = []

    def __init__(self, *args, **kwargs):
        self.crypto = PWSCrypto()
        super(PwsViewMixin, self).__init__(*args, **kwargs)

    def perform_authentication(self, request):
        """
        Disable standard authentication method to prevent startup fail.
        (Without this the startup can fail, because there are no authentication MiddlewareClasses used)
        :param request: DjangoRequest
        :return:
        """
        return None

    def expired(self):
        raise ParseError(detail={'detail': 'The msg is expired or invalid'}, code=498)

    def get_timedelta(self):
        time_delta = self.request.data.get('time_delta', None)
        if time_delta:
            try:
                time_delta = int(time_delta)
            except ValueError:
                raise ParseError(detail={'time_delta': 'Invalid number.'}, code=400)

            if time_delta > settings.KEY_MAX_AGE:
                time_delta = settings.KEY_MAX_AGE
        else:
            time_delta = settings.KEY_DEFAULT_AGE

        return time_delta

    def get_msg(self):
        msg = self.request.GET.get('msg', None)
        if not msg:
            raise ParseError(detail={'detail': 'No msg given'}, code=498)
        return msg

    def get_image_key_iid(self, image_not_note):
        msg = self.get_msg()

        # Try to decrypt the message
        try:
            decrypted_data = self.crypto.decrypt(msg)
            iid, key, secret_type = decrypted_data.rsplit(self.crypto.sep, 2)
            instance = SecretImage.objects.get(id=iid)
        except (InvalidToken, TypeError, ValueError, SecretImage.DoesNotExist) as e:
            return self.expired()

        crypto2 = PWSCrypto(key=key)
        if image_not_note:
            image = crypto2.plain_decrypt(instance.image.file.read())
            return image, instance
        else:
            note = crypto2.plain_decrypt(instance.note.encode())
            return note, instance

    def clean_images(self):
        # Deleting old entrys
        for obj in SecretImage.objects.filter(
                created_at__lte=datetime.datetime.now() - datetime.timedelta(seconds=settings.KEY_MAX_AGE)):
            obj.delete()


class AngularTemplateView(View):
    @staticmethod
    def process_request(request):
        """
        Prevent common bots from decrypt messages over the angular frontend.
        """
        for k in settings.BOT_KEYWORDS:
            if k in request.META['HTTP_USER_AGENT']:
                return render(request, 'bot.html')
        return render(request, 'home.html')

    def get(self, request, *args, **kwargs):
        return self.process_request(request)

    def post(self, request, *args, **kwargs):
        return self.process_request(request)


class SecretView(PwsViewMixin, APIView):
    cid = 'msgs'
    permission_classes = []

    def post(self, request, format=None):
        s_type = self.request.data.get('type', None)
        if not s_type:
            raise ParseError(detail={'type': 'This field is required.'}, code=400)
        elif s_type == 'note':
            form = NoteSecretSerializer(data=request.data)
        elif s_type == 'login':
            form = LogInSecretSerializer(data=request.data)
        else:
            raise ParseError(detail={'type': "Invalid type. Use: 'note', 'login'"}, code=400)

        # Build data chain
        if form.is_valid():
            if s_type == 'note':
                encrypt_data = form.data['note']
                encrypt_data += self.crypto.sep + 'n'
            elif s_type == 'login':
                password = form.data['password']
                username = form.data['username']
                encrypt_data = password + self.crypto.sep + username
                encrypt_data += self.crypto.sep + 'p'
            else:
                encrypt_data = ''

            time_delta = self.get_timedelta()
            kid = self.crypto.encrypt(encrypt_data, time_delta)
            return Response({'msg': kid}, status=200)
        else:
            raise ParseError(form.errors, code=400)

    def get(self, request, format=None):
        """
        Return messages from encrypted value.
        :param request: DjangoRequest
        :param format:
        :return: HTTPResponse {type:"note|login"; ?note; ?username; ?password}
        """
        msg = self.get_msg()

        # Try to decrypt the message
        try:
            decrypted_data = self.crypto.decrypt(msg)
            decrypted_data, secret_type = decrypted_data.rsplit(self.crypto.sep, 1)
        except (InvalidToken, TypeError, ValueError):
            return self.expired()

        # Main expiration validation #
        # The decrypted messages are saved temporary in the cache, but
        # only for message ages below the maximum age. (settings.KEY_MAX_AGE)
        #
        # Privacy Notices:
        #  - Only hashes of the encrypted messages are being used
        #  - The saved messages will be removed after the max age passed
        msg = msg.encode('ascii')
        msg_hash = hashlib.sha224(msg).hexdigest()
        c = json.load(open(settings.ID_LOG_FILE, 'r'))
        if not c:
            c = []
        else:
            for i in reversed(c):
                if i[1] < time.time() - settings.KEY_MAX_AGE:
                    c.remove(i)
                elif i[0] == msg_hash:
                    return self.expired()

        c.append([msg_hash, time.time()])
        with open(settings.ID_LOG_FILE, 'w') as id_file:
            json.dump(c, id_file)

        if secret_type == 'n':
            return Response({'type': 'note', 'note': decrypted_data}, status=200)
        elif secret_type == 'p':
            password, username = decrypted_data.rsplit(self.crypto.sep, 1)
            return Response({'type': 'login', 'username': username, 'password': password}, status=200)
        else:
            self.expired()


class SecretImageView(PwsViewMixin, APIView):
    parser_classes = [MultiPartParser]

    def post(self, request, format=None):
        """
        Generates key and id for a new SecretImage instance, than the key will be used to encrypt the note
        and the image file, than key and id will get encrypted and this resulting kid will be send back
        :param request: DjangoRequest Object
        :param format:
        :return: HttpResponse
        """
        form = ImageSecretSerializer(data={
            'image': request.data.get('image', None),
            'note': request.data.get('note', None)
        })
        if form.is_valid():
            key = Fernet.generate_key()
            iid = uuid.uuid4()
            time_delta = self.get_timedelta()

            msg_data = str(iid) + self.crypto.sep + str(key, 'ascii') + self.crypto.sep + 'i'
            kid = self.crypto.encrypt(msg_data, time_delta)

            crypto2 = PWSCrypto(key=key)
            data = form.validated_data
            encrypted_image = crypto2.plain_encrypt(data['image'].file.read())
            encrypted_note = crypto2.plain_encrypt(
                data['note'].encode('utf-8') if data['note'] else data['image'].name.encode())
            instance = SecretImage(id=iid,
                                   image=ContentFile(
                                       content=encrypted_image,
                                       name=str(crypto2.plain_encrypt(data['image'].name.encode()), 'ascii')
                                   ),
                                   note=str(encrypted_note, 'utf-8'))
            instance.save()
            del key
            return Response({'msg': kid}, status=200)
        else:
            raise ParseError(form.errors, code=400)

    def get(self, request, format=None):
        note, instance = self.get_image_key_iid(False)
        self.clean_images()

        return Response({'type': 'image', 'note': note}, status=200)


class SecretImageFileView(PwsViewMixin, View):
    def get(self, request, *args, **kwargs):
        self.clean_images()

        try:
            image, instance = self.get_image_key_iid(True)
            instance.delete()
        except ParseError:
            return HttpResponse(status=400)
        return HttpResponse(content=image, content_type='image/*')
