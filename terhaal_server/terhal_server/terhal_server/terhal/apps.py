from django.apps import AppConfig
from django.utils.translation import gettext_lazy as _


class TerhalConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "terhal_server.terhal"
    verbose_name = _("Terhal")
