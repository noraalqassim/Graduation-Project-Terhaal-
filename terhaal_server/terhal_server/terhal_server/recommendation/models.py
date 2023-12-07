from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models
from django.utils.translation import gettext_lazy as _

from terhal_server.core.models import City, Country, State
from terhal_server.terhal.models import Category


class Recommendation(models.Model):
    """Model definition for Recommendation."""

    name = models.CharField(_("Name"), max_length=255)
    code = models.CharField(_("Code"), max_length=255)
    category = models.ForeignKey(Category, verbose_name=_("Category"), on_delete=models.CASCADE)
    country = models.ForeignKey(Country, verbose_name=_("Country"), on_delete=models.CASCADE)
    state = models.ForeignKey(State, verbose_name=_("State"), on_delete=models.CASCADE)
    city = models.ForeignKey(City, verbose_name=_("City"), on_delete=models.CASCADE)
    address = models.CharField(_("Address"), max_length=255)
    canonical = models.URLField(_("Canonical"), max_length=255, blank=True, null=True)
    reviews_num = models.IntegerField(_("Reviews Number"), default=0)
    reviews_rating = models.FloatField(
        _("Reviews Rating"), default=0, validators=[MinValueValidator(0), MaxValueValidator(10)]
    )
    top_feature = models.TextField(_("Top Feature"))
    images = models.JSONField(_("Images"), default=dict, blank=True, null=True)
    description = models.TextField(_("Description"))
    top_facilities = models.TextField(_("Top Facilities"))
    reviews = models.JSONField(_("Reviews"), default=dict, blank=True, null=True)
    latitude = models.FloatField(_("Latitude"), default=0)
    longitude = models.FloatField(_("Longitude"), default=0)
    trending = models.BooleanField(_("Trending"), default=False)
    babies = models.BooleanField(_("Babies"), default=False)
    children = models.BooleanField(_("Children"), default=False)
    adults = models.BooleanField(_("Adults"), default=False)
    heart = models.BooleanField(_("Heart"), default=False)
    asthma = models.BooleanField(_("Asthma"), default=False)
    no_condition = models.BooleanField(_("No Condition"), default=False)
    stroller = models.BooleanField(_("Stroller"), default=False)

    class Meta:
        """Meta definition for Recommendation."""

        verbose_name = _("Recommendation")
        verbose_name_plural = _("Recommendations")

    def __str__(self):
        """Unicode representation of Recommendation."""
        return self.name


class RecommendationImage(models.Model):
    """Model definition for RecommendationImage."""

    recommendation = models.ForeignKey(Recommendation, verbose_name=_("Recommendation"), on_delete=models.CASCADE)
    image = models.ImageField(_("Image"), upload_to="recommendations/images/")
    is_active = models.BooleanField(_("Active"), default=True)
    is_primary = models.BooleanField(_("Is Primary"), default=False)
    is_thumbnail = models.BooleanField(_("Is Thumbnail"), default=False)
    is_cover = models.BooleanField(_("Is Cover"), default=False)

    class Meta:
        """Meta definition for RecommendationImage."""

        verbose_name = _("Recommendation Image")
        verbose_name_plural = _("Recommendation Images")

    def __str__(self):
        """Unicode representation of RecommendationImage."""
        return self.recommendation.name
