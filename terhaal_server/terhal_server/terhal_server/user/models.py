from django.contrib.auth.models import AbstractUser
from django.db import models
from django.urls import reverse
from django.utils.translation import gettext_lazy as _


class User(AbstractUser):
    """Default user for terhal_server."""

    password = models.CharField(_("Password"), max_length=128, blank=True, null=True)
    uid = models.CharField(_("UID"), max_length=255, blank=True, null=True)
    first_name = models.CharField(_("First Name"), blank=True, max_length=255)
    last_name = models.CharField(_("Last Name"), blank=True, max_length=255)
    date_of_birth = models.DateField(_("Date of Birth"), blank=True, null=True)
    GENDER_OPTIONS = [("Male", "Male"), ("Female", "Female")]
    gender = models.CharField(_("Gender"), max_length=6, choices=GENDER_OPTIONS, blank=True, null=True)
    TRAVEL_COMPANION_OPTIONS = [("Family", "Family"), ("Solo", "Solo")]
    travel_companion = models.CharField(
        _("Travel Companion"), max_length=6, choices=TRAVEL_COMPANION_OPTIONS, blank=True, null=True
    )
    HEALTH_CONDITION_OPTIONS = [("Heart", "Heart"), ("Asthma", "Asthma"), ("No Condition", "No Condition")]
    health_condition = models.CharField(
        _("Health Condition"), max_length=255, choices=HEALTH_CONDITION_OPTIONS, blank=True, null=True
    )
    need_stroller = models.BooleanField(_("Need Stroller"), default=False)

    def get_absolute_url(self) -> str:
        """Return absolute url for User."""
        return reverse("users:detail", kwargs={"username": self.username})

    def __str__(self):
        """Unicode representation of User."""
        return f"{self.username}"


class UserFavorite(models.Model):
    """Model definition for UserFavorite."""

    user = models.OneToOneField(User, verbose_name=_("User"), on_delete=models.CASCADE)
    favorites = models.JSONField(_("Favorites"), default=list, blank=True, null=True)

    class Meta:
        """Meta definition for UserFavorite."""

        verbose_name = _("User Favorite")
        verbose_name_plural = _("User Favorites")

    def __str__(self):
        """Unicode representation of UserFavorite."""
        return f"{self.user}"


class UserRating(models.Model):
    """Model definition for UserRating."""

    user = models.ForeignKey(User, verbose_name=_("User"), on_delete=models.CASCADE)
    ratings = models.JSONField(_("User Rating"), default=list, blank=True, null=True)

    class Meta:
        """Meta definition for UserRating."""

        verbose_name = _("User Rating")
        verbose_name_plural = _("User Ratings")

    def __str__(self):
        """Unicode representation of UserRating."""
        return f"{self.user}"


class UserSearchHistory(models.Model):
    """Model definition for UserSearchHistory."""

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    history = models.JSONField(_("History"), default=list, blank=True, null=True)

    def __str__(self):
        """Unicode representation of UserSearchHistory."""
        return f"{self.user}"
