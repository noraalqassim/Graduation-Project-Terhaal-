from rest_framework import serializers

from terhal_server.terhal.models import Category


class CategorySerializer(serializers.ModelSerializer):
    """Serializer for Category model."""

    class Meta:
        """Meta class for CategorySerializer."""

        model = Category
        fields = ["id", "name", "code", "icon"]
