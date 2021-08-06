from django.conf import settings
from django.conf.urls import url
from django.conf.urls.static import static

from api.views import SecretView, AngularTemplateView, SecretImageView, SecretImageFileView

urlpatterns = [
    url(r'^api/secret/$', SecretView.as_view(), name='secret'),
    url(r'^api/secret-image/$', SecretImageView.as_view(), name='secret-image'),
    url(r'^api/secret-image.img$', SecretImageFileView.as_view(), name='secret-image-file'),
    url(r'^.*', AngularTemplateView.as_view(), name="home")
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
