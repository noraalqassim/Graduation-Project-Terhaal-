from django.urls import include, path

urlpatterns = [
    path("", include("terhal_server.user.urls")),
    path("terhal/", include("terhal_server.terhal.urls")),
    path("recommendation/", include("terhal_server.recommendation.urls")),
]
