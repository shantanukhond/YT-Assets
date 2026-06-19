from django.conf import settings
from django.db import models
from pgvector.django import VectorField


class Document(models.Model):
    id = models.AutoField(primary_key=True)
    title = models.TextField(blank=True, null=True)
    source_url = models.TextField(unique=True)
    content = models.TextField()
    embedding = VectorField(dimensions=settings.EMBEDDING_DIMENSIONS)
    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "documents"

    def __str__(self):
        return self.title or self.source_url
