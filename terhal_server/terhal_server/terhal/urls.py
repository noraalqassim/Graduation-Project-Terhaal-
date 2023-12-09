from django.conf import settings
from django.urls import include, path
from rest_framework.routers import DefaultRouter, SimpleRouter

from terhal_server.terhal.api.views import CategoryViewSet

router = DefaultRouter() if settings.DEBUG else SimpleRouter()

router.register("categories", CategoryViewSet, basename="category")

urlpatterns = [path("", include(router.urls))]
