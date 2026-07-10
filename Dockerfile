ARG BASEIMAGE=public.ecr.aws/docker/library/python:3.14.6-slim-bookworm@sha256:4ff4b92a68355dbdb52584ab3391dff8d371a61d4e063468bfd0130e3189c6d9
# uvのバージョンは .github/workflows の setup-uv と renovate が同期する
ARG UVIMAGE=ghcr.io/astral-sh/uv:0.11.24@sha256:99ea34acedc870ba4ad11a1f540a1c04267c9f30aadc465a94406f52dfda2c36

FROM $UVIMAGE AS uv

#### Build Python deps

FROM $BASEIMAGE AS build

WORKDIR /usr/src/app

# Setup build environment
RUN apt-get update
RUN apt-get install -y --no-install-recommends curl make gcc g++ libc-dev \
    pkg-config libyaml-dev libffi-dev
# mysqlclient 使用時は以下をアンコメント \
# RUN apt-get install -y --no-install-recommends libmariadb-dev

# Setup uv
ENV UV_INSTALL_DIR=/opt/uv
COPY --from=uv /uv /uvx ${UV_INSTALL_DIR}/

# Use system python
ENV UV_PYTHON_DOWNLOADS=never

# Build venv
ENV PATH="$PATH:${UV_INSTALL_DIR}"
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project --no-dev


#### Setup runtime environment

FROM $BASEIMAGE AS runtime

# Install packages
RUN <<EOF
apt-get update
apt-get upgrade -y # base image ビルド後に公開されたセキュリティ修正
apt-get install -y --no-install-recommends libyaml-0-2 libffi8

# mysqlclient 使用時は以下をアンコメント \
# apt-get install -y --no-install-recommends libmariadb3

apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/* /var/tmp/* /root/.cache/*
EOF

# Setup account
RUN <<EOF
set -e
groupadd -g 999 appuser
useradd -r -u 999 -g appuser appuser
EOF

# Build directories
RUN <<EOF
set -e
mkdir -p /log
chown -R appuser:appuser /log
mkdir -p /opt/pythonenv/
chown -R appuser:appuser /opt/pythonenv/
EOF

COPY --from=build /usr/src/app/.venv /usr/src/app/.venv

# Copy source files
USER appuser

WORKDIR /usr/src/app
COPY --chown=appuser:appuser . /usr/src/app
EXPOSE 8000

# Setup environemnt variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PATH="/usr/src/app/.venv/bin:${PATH}"
ENV PYTHONPATH=/usr/src/app/reno_test_1

# Make static files
RUN python reno_test_1/manage.py collectstatic --noinput

CMD ["uwsgi", "uwsgi.ini"]
