from django.test import TestCase
import uuid
from rest_framework.test import APIRequestFactory
from datetime import datetime, timedelta


class SecretsTests(TestCase):

    def setUp(self) -> None:
        self.factory = APIRequestFactory()

    def test_login_data_process(self):
        data = {
            'username': f'username4you dfa-fs-faf-ad-fsfsfadfdf-d-asdsfsdfs {uuid.uuid4()}',
            'password': f'{uuid.uuid4()}password4you',
            'expiration_date': (datetime.utcnow() + timedelta(minutes=120)).strftime('%Y-%m-%d %H:%M:%S'),
            'type': 'p',
            'uuid': str(uuid.uuid4())
        }
        response = self.factory.post('/api/secrets/', data=data)
        print(response)



    def tearDown(self) -> None:
        self.factory = None
