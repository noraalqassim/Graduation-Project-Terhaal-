import ast
from collections import defaultdict

import pandas as pd
from django.conf import settings
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel

from terhal_server.core.models import City, Country, GlobalSetting, State
from terhal_server.recommendation.models import Recommendation
from terhal_server.terhal.models import Category
from terhal_server.user.models import User, UserFavorite, UserRating, UserSearchHistory


def read_data(as_dict=False):
    """
    Reads the recommendation data from a CSV file and returns it as a pandas DataFrame or a list of dictionaries.

    Args:
        as_dict (bool): If True, returns the data as a list of dictionaries. If False, returns the data as a pandas
        DataFrame.

    Returns:
        pandas.DataFrame or list: The recommendation data.
    """
    global_setting = GlobalSetting.get_solo()
    df = pd.read_csv(f"{settings.BASE_DIR}{global_setting.csv_file.url}")
    return df.to_dict(orient="records") if as_dict else df


def get_recommendation_data(query_params):
    """
    Returns a list of Recommendation objects based on the given query parameters.

    Args:
        query_params (dict): A dictionary containing the query parameters to filter the Recommendation objects.

    Returns:
        list: A list of Recommendation objects.
    """
    csv_data = read_data(as_dict=True)

    for data in csv_data:
        data["category"] = Category.objects.get(id=data["category"])
        data["country"] = Country.objects.get(id=data["country"])
        data["state"] = State.objects.get(id=data["state"])
        data["city"] = City.objects.get(id=data["city"])
        data["images"] = ast.literal_eval(data["images"])

    queryset = [Recommendation(**data) for data in csv_data]
    if query_params:
        queryset = get_filtered_queryset(queryset, query_params)
    if int(query_params.get("similar", 0)) and query_params.get("id"):
        queryset = get_similar_places(queryset, query_params)

    return queryset


def get_similar_places(queryset, query_params):
    place_id = int(query_params.get("id"))

    current_place = next((place for place in queryset if place.id == place_id), None)
    if not current_place:
        return []
    return get_similar_places_from_current_place(queryset, current_place)


def get_similar_places_from_current_place(queryset, current_place):
    features = ["heart", "asthma", "no_condition", "stroller", "children"]
    similar_places = []
    for place in queryset:
        if place.id != current_place.id:
            if current_place.category.id == place.category.id and current_place.trending == place.trending:
                if any(getattr(current_place, feature) == getattr(place, feature) for feature in features):
                    similar_places.append(place)

    return similar_places


def get_filtered_queryset(queryset, query_params):
    """
    Filters a queryset based on the given query parameters.

    Args:
        queryset (QuerySet): The queryset to filter.
        query_params (dict): A dictionary containing the query parameters.

    Returns:
        QuerySet: The filtered queryset.
    """
    if query_params:
        if bool(int(query_params.get("trending", 0))):
            queryset = [recommendation for recommendation in queryset if recommendation.trending]

        if query_params.get("q"):
            q = query_params.get("q").lower()
            queryset = [
                recommendation
                for recommendation in queryset
                if any(
                    q in value.lower() if isinstance(value, str) else False
                    for value in [
                        recommendation.name,
                        recommendation.code,
                        recommendation.category.name,
                        recommendation.country.name,
                        recommendation.state.name,
                        recommendation.city.name,
                        recommendation.address,
                    ]
                )
            ]

        if query_params.get("category") and int(query_params.get("category")) != 0:
            queryset = [
                recommendation
                for recommendation in queryset
                if recommendation.category.id == int(query_params.get("category"))
            ]

        if query_params.get("uid") and int(query_params.get("favorites", 0)):
            if User.objects.filter(uid=query_params.get("uid")).exists():
                user = User.objects.get(uid=query_params.get("uid")).pk
                favorites = UserFavorite.objects.get(user=user).favorites
                queryset = [recommendation for recommendation in queryset if recommendation.id in favorites]
            else:
                queryset = []

        if query_params.get("uid") and int(query_params.get("recommended", 0)):
            queryset = get_contextual_recommendations(queryset, query_params)

        if query_params.get("uid") and int(query_params.get("interests", 0)):
            queryset = get_collaborative_recommendations(queryset, query_params)

    return queryset


def check_health_condition(row, health_condition):
    return row["adults"] == 1 and row[health_condition] == 1


# Helper function to check stroller requirement
def check_stroller_condition(row, user_need_stroller):
    return not user_need_stroller or row["stroller"] == 1


def get_contextual_recommendations(queryset, query_params):
    """
    Get contextual-based recommendations for a user.

    Args:
        queryset (QuerySet): The original queryset.
        query_params (dict): A dictionary containing user-specific parameters.

    Returns:
        QuerySet: The contextual-based filtered queryset.
    """
    global_setting = GlobalSetting.get_solo()
    place_data = pd.read_csv(f"{settings.BASE_DIR}{global_setting.csv_file.url}")
    if User.objects.filter(uid=query_params.get("uid")).exists():
        user = User.objects.get(uid=query_params.get("uid"))

        # Extract user preferences
        user_travel_companion = user.travel_companion
        user_health_condition = user.health_condition
        user_need_stroller = user.need_stroller

        # Combine description and top_facilities into a single string for each place
        place_data["combined_contextual"] = (
            place_data["description"].fillna("") + " " + place_data["top_facilities"].fillna("")
        )

        # Combine user information into a single string
        user_info = f"""Travel Companion: {user_travel_companion},
        Health Condition: {user_health_condition}, Need Stroller: {user_need_stroller}"""

        # Combine user information with place contextual
        place_data["combined_contextual"] += " " + user_info

        # Create a TF-IDF matrix
        tfidf_vectorizer = TfidfVectorizer(stop_words="english")
        tfidf_matrix = tfidf_vectorizer.fit_transform(place_data["combined_contextual"])

        # Calculate similarity scores using linear kernel
        cosine_similarities = linear_kernel(tfidf_matrix, tfidf_matrix)

        # Filter places based on user preferences
        filtered_indices = []

        for i, _ in enumerate(cosine_similarities):
            # Check if user_travel_companion is "Solo"
            if user_travel_companion == "Solo":
                # Check health conditions and stroller requirement
                if (
                    (user_health_condition == "Heart" and check_health_condition(place_data.iloc[i], "heart"))
                    or (user_health_condition == "Asthma" and check_health_condition(place_data.iloc[i], "asthma"))
                    or (
                        user_health_condition == "No Condition"
                        and check_health_condition(place_data.iloc[i], "no_condition")
                    )
                ) and check_stroller_condition(place_data.iloc[i], user_need_stroller):
                    filtered_indices.append(i)

            # Check if user_travel_companion is "Family"
            elif user_travel_companion == "Family":
                # Check health conditions and stroller requirement
                if (
                    (
                        (user_health_condition == "Heart" and check_health_condition(place_data.iloc[i], "heart"))
                        or (user_health_condition == "Asthma" and check_health_condition(place_data.iloc[i], "asthma"))
                        or (
                            user_health_condition == "No Condition"
                            and check_health_condition(place_data.iloc[i], "no_condition")
                        )
                    )
                    and check_stroller_condition(place_data.iloc[i], user_need_stroller)
                    and (place_data.iloc[i]["children"] == 1 or place_data.iloc[i]["adults"] == 0)
                ):
                    filtered_indices.append(i)

        # Get unique filtered indices
        filtered_indices = list(set(filtered_indices))

        # If user has ratings, sort recommendations based on ratings
        user_ratings, _ = UserRating.objects.get_or_create(user=user)
        highest_ratings = {}
        if user_ratings:
            for rating in user_ratings.ratings:
                place_id = rating["place"]
                rating_value = rating["rating"]
                if rating_value > highest_ratings.get(place_id, 0):
                    highest_ratings[place_id] = rating_value

        # Apply content-based filtering and sorting based on highest ratings list
        context_filtered_queryset = sorted(
            [
                recommendation
                for recommendation in queryset
                if recommendation.id in place_data.iloc[filtered_indices]["id"].values
            ],
            key=lambda x: highest_ratings.get(x.id, 0),
            reverse=True,
        )

        return context_filtered_queryset

    return []


def get_collaborative_recommendations(queryset, query_params):
    """
    Generate collaborative recommendations for a user based on their search history, ratings, and favorites.

    Args:
        queryset (list): A list of Recommendation objects to generate recommendations from.
        query_params (dict): A dictionary containing user-specific parameters.

    Returns:
        list: A list of Recommendation objects representing collaborative recommendations for the user.
    """
    # Get user-related data
    user_search_history = get_user_search_history(query_params)
    user_ratings = get_user_ratings(query_params)
    user_favorites = get_user_favorites(query_params)

    # Initialize user-aggregated preferences
    user_aggregated_preferences = defaultdict(lambda: defaultdict(float))

    # Iterate through recommendations and user search history
    for recommendation in queryset:
        for user, history in user_search_history.items():
            # Find matching queries with at least 5 characters in the name
            matching_queries = [
                query.lower()
                for item in history
                for query in item.get("query", "").lower().split()
                if len(query) >= 4 and recommendation.name.lower().find(query) != -1
            ]

            # Update user preferences based on the interests or user search history
            user_aggregated_preferences[user]["interests"] += 1 if matching_queries else 0

        # Update user preferences based on ratings, favorites
        user = query_params.get("uid")
        user_aggregated_preferences[user]["ratings"] += (
            1 if recommendation.id in user_ratings[user] and user_ratings[user][recommendation.id] >= 3 else 0
        )
        user_aggregated_preferences[user]["favorites"] += 1 if recommendation.id in user_favorites[user] else 0

    # Sort users based on aggregated preferences
    sorted_users = sorted(
        user_aggregated_preferences.keys(),
        key=lambda user: (
            user_aggregated_preferences[user]["ratings"],
            user_aggregated_preferences[user]["favorites"],
            user_aggregated_preferences[user]["interests"],
        ),
        reverse=True,
    )

    # Initialize collaborative recommendations list
    collaborative_recommendations = []

    # Iterate through sorted users or use the default user if no users are present
    for user in sorted_users if sorted_users else [query_params.get("uid")]:
        user_favorites_set = set(user_favorites[user])
        user_interests_set = set()

        # Add items with 5 characters in the name to user interests
        for user, history in user_search_history.items():
            for recommendation in queryset:
                matching_queries = [
                    query.lower()
                    for item in history
                    for query in item.get("query", "").lower().split()
                    if len(query) >= 4 and query in recommendation.name.lower()
                ]
                if matching_queries:
                    user_interests_set.add(recommendation.id)

        # Combine all user-related sets into one
        # get the user ratings place id and add it to the user_combined_set if the value is 3 or more
        user_ratings_set = {place_id for place_id, rating in user_ratings[user].items() if rating >= 3}
        user_combined_set = user_favorites_set.union(user_ratings_set, user_interests_set)

        # Use a set intersection to get recommendations that match any of the user-related sets
        recommendations = [recommendation for recommendation in queryset if recommendation.id in user_combined_set]

        # Sort recommendations based on aggregated preferences
        recommendations.sort(
            key=lambda recommendation, user=user: (
                user_aggregated_preferences[user]["ratings"] * user_ratings[user].get(recommendation.id, 0),
                user_aggregated_preferences[user]["favorites"],
            ),
            reverse=True,
        )

        # Extend collaborative recommendations with sorted recommendations
        collaborative_recommendations.extend(recommendations)

    return collaborative_recommendations


def get_user_search_history(query_params):
    if not UserSearchHistory.objects.filter(user__uid=query_params.get("uid")).exists():
        UserSearchHistory.objects.get_or_create(user=User.objects.get(uid=query_params.get("uid")))

    user_search_history = UserSearchHistory.objects.filter(user__uid=query_params.get("uid")).values(
        "user__uid", "history"
    )
    return {item["user__uid"]: item["history"] for item in user_search_history}


def get_user_ratings(query_params):
    if not UserRating.objects.filter(user__uid=query_params.get("uid")).exists():
        UserRating.objects.get_or_create(user=User.objects.get(uid=query_params.get("uid")))

    user_ratings = UserRating.objects.filter(user__uid=query_params.get("uid")).values("user__uid", "ratings")
    return {
        item["user__uid"]: {rating["place"]: rating["rating"] for rating in item["ratings"]} for item in user_ratings
    }


def get_user_favorites(query_params):
    if not UserFavorite.objects.filter(user__uid=query_params.get("uid")).exists():
        UserFavorite.objects.get_or_create(user=User.objects.get(uid=query_params.get("uid")))

    user_favorites = UserFavorite.objects.filter(user__uid=query_params.get("uid")).values("user__uid", "favorites")
    return {item["user__uid"]: set(item["favorites"]) for item in user_favorites}
