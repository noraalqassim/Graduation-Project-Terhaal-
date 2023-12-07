from rest_framework import serializers

from terhal_server.recommendation.models import Recommendation, RecommendationImage
from terhal_server.user.models import UserRating


class RecommendationImageSerializer(serializers.ModelSerializer):
    """Serializer for RecommendationImage model."""

    primary = serializers.IntegerField(source="is_primary", read_only=True)

    class Meta:
        """Meta class for RecommendationImageSerializer."""

        model = RecommendationImage
        fields = ["image", "primary"]


class RecommendationSerializer(serializers.ModelSerializer):
    """Serializer for Recommendation model."""

    ratings_and_reviews = serializers.SerializerMethodField()
    ratings_and_reviews_count = serializers.SerializerMethodField()
    reviews_rating = serializers.SerializerMethodField()
    category = serializers.SerializerMethodField()
    images = serializers.SerializerMethodField()
    full_address = serializers.SerializerMethodField()

    class Meta:
        """Meta class for RecommendationSerializer."""

        model = Recommendation
        fields = [
            "id",
            "name",
            "code",
            "description",
            "reviews_rating",
            "latitude",
            "longitude",
            "full_address",
            "category",
            "images",
            "trending",
            "ratings_and_reviews_count",
            "ratings_and_reviews",
        ]

    def get_ratings_and_reviews(self, obj):
        """
        Returns the distribution of ratings among different star categories for the given recommendation object.

        Args:
            obj: The recommendation object for which to retrieve the ratings distribution.

        Returns:
            The distribution of ratings among different star categories.
        """
        # Get all UserRating objects
        user_ratings = UserRating.objects.all()

        # Initialize counts for each star category
        one_star_count = two_star_count = three_star_count = four_star_count = five_star_count = 0

        # Filter ratings for the current recommendation object
        ratings_for_recommendation = [
            rating["rating"]
            for user_rating in user_ratings
            for rating in user_rating.ratings
            if rating.get("place") == obj.id
        ]

        # Calculate the counts for each star category
        for rating_value in ratings_for_recommendation:
            if 1 <= rating_value < 1.5:
                one_star_count += 1
            elif 1.5 <= rating_value < 2.5:
                two_star_count += 1
            elif 2.5 <= rating_value < 3.5:
                three_star_count += 1
            elif 3.5 <= rating_value < 4.5:
                four_star_count += 1
            elif 4.5 <= rating_value <= 5:
                five_star_count += 1

        return {
            "oneStar": one_star_count,
            "twoStar": two_star_count,
            "threeStar": three_star_count,
            "fourStar": four_star_count,
            "fiveStar": five_star_count,
        }

    def get_ratings_and_reviews_count(self, obj):
        """
        Returns the number of ratings and reviews for the given recommendation object.

        Args:
            obj: The recommendation object for which to retrieve the number of ratings and reviews.

        Returns:
            The number of ratings and reviews for the recommendation object.
        """
        # Get all UserRating objects
        user_ratings = UserRating.objects.all()

        # Filter ratings for the current recommendation object
        ratings_for_recommendation = [
            rating["rating"]
            for user_rating in user_ratings
            for rating in user_rating.ratings
            if rating.get("place") == obj.id
        ]

        return len(ratings_for_recommendation)

    def get_reviews_rating(self, obj):
        """
        Returns the average rating for the given recommendation object.

        Args:
            obj: The recommendation object for which to retrieve the average rating.

        Returns:
            The average rating for the recommendation object.
        """
        # Get all UserRating objects
        user_ratings = UserRating.objects.all()

        # Filter ratings for the current recommendation object
        ratings_for_recommendation = [
            rating["rating"]
            for user_rating in user_ratings
            for rating in user_rating.ratings
            if rating.get("place") == obj.id
        ]

        # Calculate the average rating
        total_ratings = len(ratings_for_recommendation)
        if total_ratings > 0:
            average_rating = sum(ratings_for_recommendation) / total_ratings
            rounded_rating = round(average_rating * 2) / 2  # Round to the nearest 0.5
            # Cap the rating between 1 and 5
            capped_rating = max(1, min(5, rounded_rating))
            return float(capped_rating)
        else:
            return float(max(1, min(5, obj.reviews_rating)))

    def get_images(self, obj):
        """
        Returns a list of recommendation images for the given recommendation object.

        Args:
            obj: The recommendation object for which to retrieve images.

        Returns:
            A list of dictionaries, each containing information about a recommendation image.
            Each dictionary contains the following keys:
                - image: The URL of the recommendation image.
                - primary: An integer indicating whether the image is the primary image for the recommendation.
            The list contains both the images associated with the recommendation object and any additional images
            that were passed in as part of the object.
        """
        request = self.context.get("request")
        images = []
        for image in obj.recommendationimage_set.all():
            images.append({"image": request.build_absolute_uri(image.image.url), "primary": image.is_primary})
        obj_images = [{"image": image["image"], "primary": image["primary"] == 1} for image in obj.images]
        return images + obj_images

    def get_full_address(self, obj):
        """
        Returns the full address of the given object.

        Args:
            obj: The object to retrieve the address from.

        Returns:
            A string representing the full address of the object in the format "city, state, country".
        """
        return f"{obj.city}, {obj.state}, {obj.country}"

    def get_category(self, obj):
        """
        Returns a dictionary containing the category ID, name, code, and icon for the given object.

        Args:
            obj: The object to retrieve the category information from.

        Returns:
            A dictionary containing the category ID, name, code, and icon.
        """
        return {
            "id": obj.category.id,
            "name": obj.category.name,
            "code": obj.category.code,
            "icon": obj.category.icon.url,
        }
