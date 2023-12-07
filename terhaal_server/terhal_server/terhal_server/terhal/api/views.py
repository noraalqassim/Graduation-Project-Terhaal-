from rest_framework import viewsets

from terhal_server.terhal.models import Category

from .serializers import CategorySerializer


class CategoryViewSet(viewsets.ModelViewSet):
    """API endpoint that allows categories to be viewed or edited."""

    serializer_class = CategorySerializer
    queryset = Category.objects.all()
    http_method_names = ["get", "head"]
