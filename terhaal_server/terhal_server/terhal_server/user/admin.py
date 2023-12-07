from django.contrib import admin
from django.contrib.auth import admin as auth_admin
from django.contrib.auth import get_user_model
from django.db import models
from django.utils.translation import gettext_lazy as _

from terhal_server.core.widgets import JSONEditorWidget
from terhal_server.user.models import UserFavorite, UserRating, UserSearchHistory

User = get_user_model()


@admin.register(User)
class UserAdmin(auth_admin.UserAdmin):
    """Define admin model for custom User model with no email field."""

    fieldsets = (
        (
            _("Personal info"),
            {"fields": (("uid", "is_active"), ("first_name", "last_name"), ("username", "email"))},
        ),
        (
            _("Details"),
            {
                "fields": (
                    ("date_of_birth", "gender"),
                    ("travel_companion", "health_condition", "need_stroller"),
                ),
            },
        ),
    )
    list_display = ["username", "first_name", "last_name", "is_active"]
    search_fields = ["first_name", "last_name", "username"]
    list_display_links = ["username", "first_name", "last_name", "is_active"]


@admin.register(UserFavorite)
class UserFavoriteAdmin(admin.ModelAdmin):
    """Admin class for UserFavorite."""

    list_display = ["user"]
    search_fields = ["user"]
    list_display_links = ["user"]
    formfield_overrides = {models.JSONField: {"widget": JSONEditorWidget}}


@admin.register(UserRating)
class UserRatingAdmin(admin.ModelAdmin):
    """Admin class for UserRating."""

    list_display = ["user"]
    search_fields = ["user"]
    list_display_links = ["user"]
    formfield_overrides = {models.JSONField: {"widget": JSONEditorWidget}}


@admin.register(UserSearchHistory)
class UserSearchHistoryAdmin(admin.ModelAdmin):
    """Admin class for UserSearchHistory."""

    list_display = ["user"]
    search_fields = ["user"]
    list_display_links = ["user"]
    formfield_overrides = {models.JSONField: {"widget": JSONEditorWidget}}
