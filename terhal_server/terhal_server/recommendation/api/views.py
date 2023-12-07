import re
from math import sqrt

from django.db.models import Q
from django.db.models.query import QuerySet
from django.utils import timezone
from rest_framework import viewsets

from terhal_server.recommendation.api.serializers import RecommendationSerializer
from terhal_server.recommendation.models import Recommendation
from terhal_server.recommendation.utils.recommendation import get_recommendation_data
from terhal_server.user.models import User, UserFavorite, UserSearchHistory

FEATURES = [
    "reviews_num",
    "reviews_rating",
    "category",
    "trending",
    "babies",
    "children",
    "adults",
    "heart",
    "asthma",
    "no_condition",
    "stroller",
]

MAX_HISTORY_SIZE = 200
CLEAR_THRESHOLD = 100


def word_is_valid(word):
    pattern = re.compile(r"^[a-zA-Z\s]{5,14}$")
    return bool(pattern.match(word))


class RecommendationViewSet(viewsets.ModelViewSet):
    """API endpoint that allows recommendations to be viewed or edited."""

    serializer_class = RecommendationSerializer
    queryset = Recommendation.objects.all()
    http_method_names = ["get", "head", "post", "put"]

    def get_queryset(self):
        """
        Returns a queryset of recommendations based on the query parameters.

        The queryset is filtered based on the following query parameters:
        - trending: if set to 1, only trending recommendations are returned
        - q: a search query that is matched against the name, code, category, country, state, city, address, and
        description fields
        - category: the ID of the category to filter by

        The queryset is sorted by reviews_rating in descending order.

        Returns:
        queryset: a list of Recommendation objects
        """
        query_params = self.request.query_params
        criterions = Q()
        if query_params:
            if bool(int(query_params.get("trending", 0))):
                criterions &= Q(trending=True)

            if query_params.get("q"):
                q = query_params.get("q")
                if query_params.get("uid") and not int(query_params.get("interests", 0)):
                    self.update_user_search_history(query_params, q)

                criterions = self.create_criterions(q)

            if query_params.get("category"):
                criterions &= Q(category__id=query_params.get("category"))

            if query_params.get("uid") and not int(query_params.get("recommended", 0)):
                if User.objects.filter(uid=query_params.get("uid")).exists():
                    user = User.objects.get(uid=query_params.get("uid"))
                    user_favorite, _ = UserFavorite.objects.get_or_create(user=user, defaults={"favorites": []})
                    criterions &= Q(id__in=user_favorite.favorites)

            if query_params.get("uid") and int(query_params.get("recommended", 0)):
                self.queryset = self.get_context_recommendations(self.queryset, query_params, criterions)

            if int(query_params.get("similar", 0)) and query_params.get("id"):
                self.queryset = self.get_similar_places(self.queryset, query_params)

        recommendations = self.get_recommendations()
        recommendations.extend(list(self.queryset.filter(criterions)))

        if query_params.get("uid") and int(query_params.get("recommended", 0)):
            queryset = recommendations
        else:
            queryset = sorted(recommendations, key=lambda x: x.reviews_rating, reverse=True)

        return queryset

    def create_criterions(self, q):
        """
        Create criteria for filtering based on the search query.

        Args:
        - q: Search query

        Returns:
        - criterions: Combined Q objects for filtering
        """
        return (
            Q(name__icontains=q)
            | Q(code__icontains=q)
            | Q(category__name__icontains=q)
            | Q(country__name__icontains=q)
            | Q(state__name__icontains=q)
            | Q(city__name__icontains=q)
            | Q(address__icontains=q)
        )

    def update_user_search_history(self, query_params, q):
        """
        Update user search history with the given search query.

        Args:
        - query_params: Dictionary containing query parameters
        - q: Search query to be added to the user search history
        """
        if User.objects.filter(uid=query_params.get("uid")).exists():
            user = User.objects.get(uid=query_params.get("uid"))
            user_search_history, _ = UserSearchHistory.objects.get_or_create(user=user, defaults={"history": []})
            if word_is_valid(q):
                timestamp = timezone.now().isoformat()
                query_object = {"query": q, "timestamp": timestamp}
                if query_object not in user_search_history.history:
                    user_search_history.history.append(query_object)
                    if len(user_search_history.history) > MAX_HISTORY_SIZE:
                        user_search_history.history = user_search_history.history[CLEAR_THRESHOLD:]
                    user_search_history.save()

    def get_context_recommendations(self, queryset: QuerySet, query_params: dict, criterions: Q) -> QuerySet:
        """
        Get context-based recommendations for a user.

        Args:
            queryset (QuerySet): The original queryset.
            query_params (dict): A dictionary containing user-specific parameters.
            criterions (Q): The existing criterions Q object.

        Returns:
            QuerySet: The context-based filtered queryset.
        """
        if User.objects.filter(uid=query_params.get("uid")).exists():
            user = User.objects.get(uid=query_params.get("uid"))

            # Extract user preferences
            user_travel_companion = user.travel_companion
            user_health_condition = user.health_condition
            user_need_stroller = user.need_stroller

            # Apply content-based filtering
            context_filtered_queryset = self.content_based_filtering(
                queryset, user_travel_companion, user_health_condition, user_need_stroller, criterions
            )

            return context_filtered_queryset

        return queryset.none()

    def get_similar_places(self, queryset, query_params):
        place_id = query_params.get("id")

        if not queryset.filter(id=place_id).exists():
            return queryset.none()

        current_place = queryset.get(id=place_id)
        current_features = get_features(current_place)

        similar_places = []
        for place in queryset.exclude(id=place_id):
            features = get_features(place)
            distance = euclidean_distance(current_features, features)
            similar_places.append({"place": place, "distance": distance})

        similar_places = sorted(similar_places, key=lambda x: x["distance"])
        result_ids = [place["place"].id for place in similar_places]
        return queryset.filter(id__in=result_ids)

    def content_based_filtering(
        self, queryset, user_travel_companion, user_health_condition, user_need_stroller, criterions
    ):
        """
        Apply content-based filtering to the queryset based on user preferences.

        Args:
            queryset (QuerySet): The queryset to filter.
            user_travel_companion (str): User's travel companion preference ("Solo" or "Family").
            user_health_condition (str): User's health condition preference ("Heart", "Asthma", "No Condition").
            user_need_stroller (bool): User's stroller requirement.
            criterions (Q): The existing criterions Q object.

        Returns:
            QuerySet: The filtered queryset.
        """
        for recommendation in queryset:
            # Filter based on travel companion preference
            if user_travel_companion == "Solo":
                criterions &= Q(children=False)
            elif user_travel_companion == "Family":
                criterions &= Q(children=True)

            # Filter based on health condition preference
            if user_health_condition == "Heart":
                criterions &= Q(heart=True)
            elif user_health_condition == "Asthma":
                criterions &= Q(asthma=True)
            elif user_health_condition == "No Condition":
                criterions &= Q(no_condition=True)

            # Filter based on stroller requirement
            if user_need_stroller and recommendation.stroller:
                criterions &= Q(stroller=True)

        return queryset.filter(criterions)

    def get_recommendations(self):
        """
        Returns a list of recommended items based on the query parameters passed in the request.

        Returns:
            list: A list of recommended items.
        """
        return get_recommendation_data(self.request.query_params)


def get_features(place):
    return [getattr(place, feature) for feature in FEATURES]


def euclidean_distance(features1, features2):
    return sqrt(sum((x - y) ** 2 for x, y in zip(features1, features2)))
