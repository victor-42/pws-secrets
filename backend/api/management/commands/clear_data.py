from datetime import datetime

from django.core.management import BaseCommand
from django.conf import settings


class Command(BaseCommand):
    help = 'Clears old secrets in SQlite database'

    def handle(self, *args, **options):
        from api.models import Secret
        objs = Secret.objects.filter(expiration__lte=datetime.utcnow() - settings.CLEAR_AFTER_EXPIRED_TIMEDELTA)
        print('Deleting {} expired secrets'.format(len(objs)))
        objs.delete()
