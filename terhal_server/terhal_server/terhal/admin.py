from django.contrib import admin

from terhal_server.terhal.models import Category, Image


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    """Admin definition for Category."""

    list_display = ["name", "code", "icon"]
    search_fields = ["name", "code"]


admin.register(Image, admin.ModelAdmin)


admin.site.site_header = "Terhal Admin"
