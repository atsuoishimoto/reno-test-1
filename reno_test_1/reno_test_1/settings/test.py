# ruff: NOQA: F403,F405
from reno_test_1.settings import *

DATABASES = {"default": {"ENGINE": "django.db.backends.sqlite3", "NAME": ":memory:"}}
