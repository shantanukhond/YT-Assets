from django.http import JsonResponse
from django.shortcuts import get_object_or_404, render
from django.views.decorators.http import require_GET

from .models import Document
from .services import document_to_dict, search_documents

MIN_QUERY_LENGTH = 2


@require_GET
def index(request):
    query = request.GET.get("q", "").strip()
    return render(request, "search/index.html", {"query": query})


@require_GET
def suggest(request):
    query = request.GET.get("q", "").strip()
    if len(query) < MIN_QUERY_LENGTH:
        return JsonResponse({"query": query, "results": []})

    results = [document_to_dict(doc) for doc in search_documents(query)]
    return JsonResponse({"query": query, "results": results})


@require_GET
def document_detail(request, pk: int):
    document = get_object_or_404(Document, pk=pk)
    return render(
        request,
        "search/document.html",
        {
            "document": document,
        },
    )
