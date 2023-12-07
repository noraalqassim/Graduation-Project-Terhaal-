from django.core.validators import FileExtensionValidator
from django.db import models
from django.utils.translation import gettext_lazy as _
from solo.models import SingletonModel


class Country(models.Model):
    """Model definition for Country."""

    name = models.CharField(_("Name"), max_length=255)
    code = models.CharField(_("Code"), max_length=2)

    class Meta:
        """Meta definition for Country."""

        verbose_name = _("Country")
        verbose_name_plural = _("Countries")

    def __str__(self):
        """Unicode representation of Country."""
        return self.name


class State(models.Model):
    """Model definition for State."""

    name = models.CharField(_("Name"), max_length=255)
    code = models.CharField(_("Code"), max_length=255)
    country = models.ForeignKey(Country, verbose_name=_("Country"), on_delete=models.CASCADE)

    class Meta:
        """Meta definition for State."""

        verbose_name = _("State")
        verbose_name_plural = _("States")

    def __str__(self):
        """Unicode representation of State."""
        return self.name


class City(models.Model):
    """Model definition for City."""

    name = models.CharField(_("Name"), max_length=255)
    code = models.CharField(_("Code"), max_length=255)
    state = models.ForeignKey(State, verbose_name=_("State"), on_delete=models.CASCADE)

    class Meta:
        """Meta definition for City."""

        verbose_name = _("City")
        verbose_name_plural = _("Cities")

    def __str__(self):
        """Unicode representation of City."""
        return self.name


class GlobalSetting(SingletonModel):
    """Model definition for GlobalSetting."""

    csv_file = models.FileField(
        upload_to="recommendation/data/",
        validators=[FileExtensionValidator(allowed_extensions=["csv"])],
    )

    def __str__(self):
        """Unicode representation of GlobalSetting."""
        return self.csv_file.name
