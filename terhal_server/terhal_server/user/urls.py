from django.conf import settings
from django.urls import include, path
from rest_framework.routers import DefaultRouter, SimpleRouter

from terhal_server.user.api.views import (
    PlaceRatingViewSet,
    UserDeleteView,
    UserFavoriteViewSet,
    UserRatingViewSet,
    UserUpdateView,
    UserViewSet,
)

router = DefaultRouter() if settings.DEBUG else SimpleRouter()

router.register("user", UserViewSet, basename="user")

urlpatterns = [
    path("", include(router.urls)),
    path("user/favorite/<str:uid>/", UserFavoriteViewSet.as_view(), name="user-favorite"),
    path("user/rating/<str:uid>/", UserRatingViewSet.as_view(), name="user-rating"),
    path("place/ratings/<str:place_id>/", PlaceRatingViewSet.as_view(), name="place-ratings"),
    path("user/update/<str:uid>/", UserUpdateView.as_view(), name="user-update"),
    path("user/delete/<str:uid>/", UserDeleteView.as_view(), name="user-delete"),
]
