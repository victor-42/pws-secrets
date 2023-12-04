from django.conf import settings
from django.urls import path, include

from django.conf.urls.static import static

from api.views import SecretView, AngularTemplateView, SecretImageView, SecretImageFileView

urlpatterns = [
    path(r'^api/secret/$', SecretView.as_view(), name='secret'),
    path(r'^api/secret-image/$', SecretImageView.as_view(), name='secret-image'),
    path(r'^api/secret-image.img$', SecretImageFileView.as_view(), name='secret-image-file'),
    path(r'^.*', AngularTemplateView.as_view(), name="home")
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
