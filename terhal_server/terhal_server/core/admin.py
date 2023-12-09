from django.contrib import admin
from solo.admin import SingletonModelAdmin

from terhal_server.core.models import City, Country, GlobalSetting, State


@admin.register(Country)
class CountryAdmin(admin.ModelAdmin):
    list_display = ["name", "code"]
    search_fields = ["name"]


@admin.register(State)
class StateAdmin(admin.ModelAdmin):
    list_display = ["name", "code", "country"]
    search_fields = ["name", "country__name"]


@admin.register(City)
class CityAdmin(admin.ModelAdmin):
    list_display = ["name", "code", "state"]
    search_fields = ["name", "state__name"]


admin.site.register(GlobalSetting, SingletonModelAdmin)
