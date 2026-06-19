from django.contrib import admin

from .models import Document


@admin.register(Document)
class DocumentAdmin(admin.ModelAdmin):
    list_display = ("id", "title", "source_url", "created_at")
    search_fields = ("title", "source_url", "content")
    readonly_fields = ("title", "source_url", "content", "created_at")
