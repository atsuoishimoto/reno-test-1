from django.contrib import admin
from django.urls import path

urlpatterns = [
    path("_/admin/", admin.site.urls),
]
