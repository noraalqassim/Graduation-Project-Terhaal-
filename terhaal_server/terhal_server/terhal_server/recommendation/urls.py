from django.conf import settings
from django.urls import include, path
from rest_framework.routers import DefaultRouter, SimpleRouter

from terhal_server.recommendation.api.views import RecommendationViewSet

router = DefaultRouter() if settings.DEBUG else SimpleRouter()

router.register("recommendations", RecommendationViewSet, basename="recommendation")

urlpatterns = [path("", include(router.urls))]
