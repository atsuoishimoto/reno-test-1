import pytest
from django.test import RequestFactory, override_settings

from core.middlewares import HealthCheckMiddleware


@pytest.fixture
def rf():
    return RequestFactory()


@pytest.fixture
def middleware():
    return HealthCheckMiddleware(lambda req: None)


def test_healthcheck_returns_200(rf, middleware):
    request = rf.get("/healthcheck")
    response = middleware(request)
    assert response.status_code == 200


@override_settings(ALLOWED_HOSTS=["example.com"])
def test_healthcheck_skips_allowed_hosts_check(rf, middleware):
    request = rf.get("/healthcheck", HTTP_HOST="invalid-host")
    response = middleware(request)
    assert response.status_code == 200


def test_non_healthcheck_passes_through(rf):
    sentinel = object()
    mw = HealthCheckMiddleware(lambda req: sentinel)
    request = rf.get("/other-path")
    response = mw(request)
    assert response is sentinel
