# ruff: NOQA: F403,F405
from aaa_2.settings import *

DATABASES = {"default": {"ENGINE": "django.db.backends.sqlite3", "NAME": ":memory:"}}
