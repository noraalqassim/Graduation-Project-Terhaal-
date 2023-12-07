from rest_framework import serializers

from terhal_server.user.models import User, UserFavorite, UserRating


class UserSerializer(serializers.ModelSerializer):
    """Serializer for User model."""

    class Meta:
        """Meta class for UserSerializer."""

        model = User
        fields = [
            "uid",
            "username",
            "email",
            "first_name",
            "last_name",
            "date_of_birth",
            "gender",
            "travel_companion",
            "health_condition",
            "need_stroller",
        ]


class UserFavoriteSerializer(serializers.ModelSerializer):
    """Serializer for UserFavorite model."""

    email = serializers.EmailField(source="user.email", read_only=True)
    uid = serializers.UUIDField(source="user.uid", read_only=True)

    class Meta:
        """Meta class for UserFavoriteSerializer."""

        model = UserFavorite
        fields = ["user", "email", "uid", "favorites"]


class UserRatingSerializer(serializers.ModelSerializer):
    """Serializer for UserRating model."""

    email = serializers.EmailField(source="user.email", read_only=True)
    uid = serializers.UUIDField(source="user.uid", read_only=True)

    class Meta:
        """Meta class for UserRatingSerializer."""

        model = UserRating
        fields = ["user", "email", "uid", "ratings"]
