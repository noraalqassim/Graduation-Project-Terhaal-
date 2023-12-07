from django.db import models
from django.utils.translation import gettext_lazy as _


class Category(models.Model):
    """Model definition for Category."""

    name = models.CharField(_("Name"), max_length=255)
    code = models.CharField(_("Code"), max_length=255)
    icon = models.FileField(_("Icon"), upload_to="category_icons/")

    class Meta:
        """Meta definition for Category."""

        verbose_name = _("Category")
        verbose_name_plural = _("Categories")

    def __str__(self):
        """Unicode representation of Category."""
        return self.name


class Image(models.Model):
    """Model definition for Image."""

    image = models.ImageField(upload_to="images/")

    def __str__(self):
        """Unicode representation of Image."""
        return self.image.name
