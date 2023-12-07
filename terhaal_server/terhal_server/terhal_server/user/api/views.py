import random
import string
from datetime import datetime

from rest_framework import generics, status, viewsets
from rest_framework.exceptions import ValidationError
from rest_framework.pagination import LimitOffsetPagination
from rest_framework.response import Response
from rest_framework.views import APIView

from terhal_server.user.api.serializers import UserFavoriteSerializer, UserRatingSerializer, UserSerializer
from terhal_server.user.models import User, UserFavorite, UserRating


class UserViewSet(viewsets.ModelViewSet):
    """API endpoint that allows user to be viewed or created."""

    serializer_class = UserSerializer
    queryset = User.objects.all()
    http_method_names = ["get", "post"]


class UserUpdateView(generics.UpdateAPIView):
    """API endpoint that allows user to be viewed or edited."""

    serializer_class = UserSerializer
    queryset = User.objects.all()
    lookup_field = "uid"

    def get_object(self):
        """
        Retrieve the user object with the given uid.

        Returns:
            User: The user object with the given uid.
        """
        uid = self.kwargs.get("uid")
        try:
            return User.objects.get(uid=uid)
        except User.DoesNotExist:
            return None

    def generate_unique_username(self, base_username):
        """
        Generate a unique username by appending 5 random characters and numbers.

        Args:
            base_username (str): The base username.

        Returns:
            str: The unique username.
        """
        suffix = "".join(random.choices(string.ascii_letters + string.digits, k=5))
        return f"{base_username}_{suffix}"

    def update(self, request, *args, **kwargs):
        instance = self.get_object()

        if instance is None:
            data = request.data.copy()
            base_username = f"{data.get('first_name', '')}_{data.get('last_name', '')}"
            data["uid"] = kwargs.get("uid")

            if not data.get("username"):
                data["username"] = base_username

            serializer = self.get_serializer(data=data)
            try:
                serializer.is_valid(raise_exception=True)
            except ValidationError as e:
                if "username" in e.detail:
                    # If validation fails for username, modify the username
                    while User.objects.filter(username=data["username"]).exists():
                        data["username"] = self.generate_unique_username(base_username)
                else:
                    raise

            serializer = self.get_serializer(data=data)
        else:
            serializer = self.get_serializer(instance, data=request.data, partial=True)

        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)

        return Response(serializer.data, status=status.HTTP_201_CREATED if instance is None else status.HTTP_200_OK)


class UserDeleteView(generics.DestroyAPIView):
    """API endpoint that allows user to be viewed or deleted."""

    serializer_class = UserSerializer
    queryset = User.objects.all()
    lookup_field = "uid"

    def get_object(self):
        """
        Retrieve the user object with the given uid.

        Returns:
            User: The user object with the given uid.
        """
        uid = self.kwargs.get("uid")
        try:
            return User.objects.get(uid=uid)
        except User.DoesNotExist:
            return None

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()

        if instance is None:
            return Response({"error": "User does not exist"}, status=status.HTTP_404_NOT_FOUND)

        self.perform_destroy(instance)
        return Response(status=status.HTTP_204_NO_CONTENT)


class UserFavoriteViewSet(generics.ListCreateAPIView):
    """API endpoint that allows user to be viewed or created."""

    pagination_class = None
    serializer_class = UserFavoriteSerializer
    queryset = UserFavorite.objects.all()
    http_method_names = ["get", "post", "put"]

    def get_queryset(self):
        query_params = self.kwargs
        queryset = self.queryset

        if query_params and query_params.get("uid"):
            uid = query_params.get("uid")

            # Check if the user exists
            if User.objects.filter(uid=uid).exists():
                user = User.objects.get(uid=uid)

                # Check if UserFavorite exists for the user
                UserFavorite.objects.get_or_create(user=user, defaults={"favorites": []})

                # Return the queryset with the user's favorites
                queryset = UserFavorite.objects.filter(user=user)
            else:
                # If the user doesn't exist, return an empty queryset
                queryset = self.queryset.none()
        else:
            # If uid is not provided or invalid, return an empty queryset
            queryset = self.queryset.none()

        return queryset

    def create(self, request, *args, **kwargs):
        """
        Creates a new UserFavorite object or updates an existing one with the provided favorite_id.

        Args:
            request (Request): The HTTP request object.
            uid (str): The user ID.
            favorite_id (int): The ID of the favorite object.

        Returns:
            Response: The HTTP response object containing the serialized UserFavorite object.
        """
        uid = request.data.get("uid")
        favorite_id = request.data.get("favorite_id")

        if not uid or not User.objects.filter(uid=uid).exists():
            return Response({"error": "Invalid or missing 'uid' parameter"}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.get(uid=uid).pk

        # Ensure that favorite_id is an integer
        try:
            favorite_id = int(favorite_id)
        except ValueError:
            return Response({"error": "Invalid 'favorite_id', must be an integer"}, status=status.HTTP_400_BAD_REQUEST)

        # Check if the favorite object exists for the user
        try:
            favorite = UserFavorite.objects.get(user=user)
            # If it exists, update the favorites field
            favorites = favorite.favorites
            if favorite_id in favorites:
                favorites.remove(favorite_id)
            else:
                favorites.append(favorite_id)
            favorite.favorites = favorites
            serializer = self.get_serializer(favorite, data={"user": user, "favorites": favorites})
        except UserFavorite.DoesNotExist:
            # If it doesn't exist, create a new object with the provided favorite_id
            serializer = self.get_serializer(data={"user": user, "favorites": [favorite_id]})

        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)

        # If there's only one item in the queryset, return it as a single object
        if len(serializer.data) == 1:
            return Response(serializer.data[0])

        return Response(serializer.data)


class UserRatingViewSet(generics.ListCreateAPIView):
    """API endpoint that allows user to be viewed or created."""

    pagination_class = None
    serializer_class = UserRatingSerializer
    queryset = UserRating.objects.all()
    http_method_names = ["get", "post", "put"]

    def get_queryset(self):
        query_params = self.kwargs
        queryset = self.queryset

        if query_params and query_params.get("uid"):
            uid = query_params.get("uid")

            # Check if the user exists
            if User.objects.filter(uid=uid).exists():
                user = User.objects.get(uid=uid)

                # Check if UserRating exists for the user
                UserRating.objects.get_or_create(user=user, defaults={"ratings": []})

                # Return the queryset with the user's ratings
                queryset = UserRating.objects.filter(user=user)
            else:
                # If the user doesn't exist, return an empty queryset
                queryset = self.queryset.none()
        else:
            # If uid is not provided or invalid, return an empty queryset
            queryset = self.queryset.none()

        return queryset

    def create(self, request, *args, **kwargs):
        uid = request.data.get("uid")

        if not uid or not User.objects.filter(uid=uid).exists():
            return Response({"error": "Invalid or missing 'uid' parameter"}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.get(uid=uid)
        user_rating, _ = UserRating.objects.get_or_create(user=user, defaults={"ratings": []})

        rating_data = request.data.get("rating")

        if not rating_data:
            return Response({"error": "Missing 'rating' parameter"}, status=status.HTTP_400_BAD_REQUEST)

        # Ensure that rating_data is a dictionary
        if not isinstance(rating_data, dict):
            return Response(
                {"error": "Invalid 'rating' parameter, must be a dictionary"}, status=status.HTTP_400_BAD_REQUEST
            )

        # Ensure that rating_data contains the required keys
        required_keys = ["place", "rating"]
        if not all(key in rating_data for key in required_keys):
            return Response(
                {"error": "Invalid 'rating' parameter, missing required keys"}, status=status.HTTP_400_BAD_REQUEST
            )

        place_id = rating_data.get("place")
        new_rating = {
            "place": place_id,
            "rating": rating_data.get("rating"),
            "review": rating_data.get("review"),
            "date": rating_data.get("date") or datetime.now().strftime("%m/%d/%y"),
        }

        # Update or add the new rating to the list
        ratings_list = user_rating.ratings
        existing_rating = next((rating for rating in ratings_list if rating.get("place") == place_id), None)

        if existing_rating:
            # Update the existing rating
            existing_rating.update(new_rating)
        else:
            # Add the new rating to the list
            ratings_list.append(new_rating)

        # Save the updated ratings list to the UserRating instance
        user_rating.ratings = ratings_list
        user_rating.save()

        serializer = self.get_serializer(user_rating)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)

        # If there's only one item in the queryset, return it as a single object
        if len(serializer.data) == 1:
            return Response(serializer.data[0])

        return Response(serializer.data)


class PlaceRatingPagination(LimitOffsetPagination):
    default_limit = 10
    max_limit = 100


class PlaceRatingViewSet(APIView):
    """API endpoint that allows user to be viewed or created."""

    def get(self, request, *args, **kwargs):
        query_params = self.kwargs
        if query_params and query_params.get("place_id"):
            uid = request.query_params.get("uid")
            if not uid or not User.objects.filter(uid=uid).exists():
                return Response({"error": "Invalid or missing 'uid' parameter"}, status=status.HTTP_400_BAD_REQUEST)
            user = User.objects.get(uid=uid)
            user_ratings = UserRating.objects.all()
            place_id = int(query_params.get("place_id"))
            place_ratings = [
                {
                    "user": f"{user_rating.user.first_name} {user_rating.user.last_name}",
                    **rating,
                    "rating": float(rating.get("rating")),
                    "current": user_rating.user == user,
                }
                for user_rating in user_ratings
                for rating in user_rating.ratings
                if rating.get("place") == place_id
            ]
            # Paginate the result using LimitOffsetPagination
            paginator = PlaceRatingPagination()
            result_page = paginator.paginate_queryset(place_ratings, request)
            return paginator.get_paginated_response(result_page)
        return Response({"error": "Invalid or missing 'place_id' parameter"}, status=status.HTTP_400_BAD_REQUEST)
