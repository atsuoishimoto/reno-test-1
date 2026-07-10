import logging

from django.http import HttpResponse

try:
    import uwsgi
    import uwsgidecorators  # noqa: F401 Ensure uwsgi is missing

    in_uwsgi = True
except (ImportError, AttributeError):
    in_uwsgi = False


logger = logging.getLogger(__name__)

HEALTHCHECK_PATH = "/healthcheck"


class HealthCheckMiddleware:
    """ALB/ELBからのヘルスチェックに応答するミドルウェア.

    SecurityMiddleware より前に配置することで、ALLOWED_HOSTS チェックや
    HTTPS リダイレクトをスキップして 200 OK を返す。
    ALB のヘルスチェックは正しい Host ヘッダを送らないため、
    通常の Django リクエスト処理を通すと DisallowedHost エラーになる。
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.path == HEALTHCHECK_PATH:
            return HttpResponse()
        return self.get_response(request)


class UwsgiLogMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        if not in_uwsgi:
            return response

        # Extract & settings log
        try:
            # resolver path
            if request.resolver_match:
                uwsgi.set_logvar("re_path", request.resolver_match.route)
        except Exception:
            logger.exception("uwsgi logging error")

        return response
