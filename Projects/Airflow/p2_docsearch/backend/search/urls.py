from django.urls import path

from . import views

urlpatterns = [
    path("", views.index, name="index"),
    path("api/suggest/", views.suggest, name="suggest"),
    path("documents/<int:pk>/", views.document_detail, name="document-detail"),
]
