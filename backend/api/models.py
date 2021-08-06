import os
from django.conf import settings

from django.core.files.storage import FileSystemStorage
from django.db import models
import uuid

fs = FileSystemStorage(location=os.path.join(settings.MEDIA_ROOT, 'images'))


class SecretImage(models.Model):
    id = models.CharField(max_length=36, null=False, blank=False, unique=True, primary_key=True)
    image = models.ImageField(blank=False, null=False,
                              storage=fs)
    note = models.CharField(max_length=20000, null=False, blank=False, default='')
    created_at = models.DateTimeField(auto_now_add=True)

    def delete(self, *args, **kwargs):
        try:
            self.image.delete()
        except (FileNotFoundError, FileExistsError):
            pass
        super(SecretImage, self).delete(args, kwargs)
