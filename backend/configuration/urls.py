from django.conf import settings
from django.urls import path

from django.conf.urls.static import static
from api.views import SecretView, KeyRotateView, SecretsView

urlpatterns = [
    path(r'api/secrets/', SecretsView.as_view(), name='secrets'),
    path(r'api/key-rotation/', KeyRotateView.as_view(), name='key-rotation'),
    path(r'api/sc/<str:cryptic>/', SecretView.as_view(), name='secet_cryptic'),
    path(r'api/not-secret/', SecretView.as_view(), name='secret'),
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
