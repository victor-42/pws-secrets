import json
import os

from django.conf import settings


class CacheMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Create ID File if not exist
        if not os.path.isfile(settings.ID_LOG_FILE):
            with open(settings.ID_LOG_FILE, 'w') as id_log_file:
                json.dump([], id_log_file)

        response = self.get_response(request)
        return response
