from django.contrib import admin
from django.db import models

from terhal_server.core.widgets import JSONEditorWidget
from terhal_server.recommendation.models import Recommendation, RecommendationImage


class RecommendationImageInline(admin.TabularInline):
    model = RecommendationImage
    extra = 0


@admin.register(Recommendation)
class RecommendationAdmin(admin.ModelAdmin):
    list_display = ["name"]
    search_fields = ["name"]
    autocomplete_fields = ["category", "country", "state", "city"]
    inlines = [RecommendationImageInline]
    fieldsets = (
        (
            None,
            {
                "fields": (
                    ("name", "code"),
                    ("country", "state"),
                    ("city", "address", "canonical"),
                    ("category", "latitude", "longitude"),
                    "description",
                    ("trending", "babies", "children", "adults", "heart", "asthma", "no_condition", "stroller"),
                )
            },
        ),
        (
            "Recommendation Information",
            {
                "fields": (
                    "top_feature",
                    "top_facilities",
                    "images",
                ),
            },
        ),
        (
            "Recommendation Reviews",
            {
                "fields": (
                    ("reviews_num", "reviews_rating"),
                    "reviews",
                ),
            },
        ),
    )
    formfield_overrides = {models.JSONField: {"widget": JSONEditorWidget}}
