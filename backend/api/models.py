import os
from django.conf import settings
from django.core import validators

from django.core.files.storage import FileSystemStorage
from django.db import models
import uuid

fs = FileSystemStorage(location=os.path.join(settings.MEDIA_ROOT, 'images'))


class SecretImage(models.Model):
    uuid = models.UUIDField(default=uuid.uuid4, blank=False, unique=True, primary_key=True)
    image = models.FileField(blank=False, null=False)
    filename = models.CharField(max_length=1024, null=False, blank=False, default='')
    note = models.CharField(max_length=20000, null=False, blank=False, default='')

    def delete(self, *args, **kwargs):
        try:
            self.image.delete()
        except (FileNotFoundError, FileExistsError):
            pass
        super(SecretImage, self).delete(args, kwargs)


class Secret(models.Model):
    uuid = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True)
    type = models.CharField(max_length=1, null=False, blank=False, default='n')
    view_time = models.IntegerField(null=True, blank=True, default=None, help_text='in seconds',
                                    validators=[validators.MinValueValidator(0), validators.MaxValueValidator(300)])
    expiration = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    opened_at = models.DateTimeField(null=True, blank=True, default=None)
