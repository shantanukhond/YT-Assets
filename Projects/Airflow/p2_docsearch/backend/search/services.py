import ollama
from django.conf import settings
from pgvector.django import CosineDistance

from .models import Document


def embed_query(text: str):
    client = ollama.Client(host=settings.OLLAMA_HOST)
    response = client.embed(model=settings.OLLAMA_EMBED_MODEL, input=text)
    return response["embeddings"][0]


def search_documents(query: str, limit: int = 10):
    embedding = embed_query(query)
    return list(
        Document.objects.annotate(distance=CosineDistance("embedding", embedding))
        .order_by("distance")[:limit]
    )


def document_to_dict(document):
    distance = getattr(document, "distance", None)
    return {
        "id": document.id,
        "title": document.title or document.source_url,
        "source_url": document.source_url,
        "distance": float(distance) if distance is not None else None,
    }
