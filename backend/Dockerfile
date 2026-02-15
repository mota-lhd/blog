# syntax=docker/dockerfile:1.4

FROM python:3.14 AS requirements

WORKDIR /tmp
RUN pip install uv
COPY uv.lock pyproject.toml /tmp/

# get dependencies (including dev for migrations)
RUN uv sync --frozen
RUN uv pip freeze > requirements.txt

FROM python:3.14-alpine AS prod

ARG USER=back
ARG GROUP=web
ARG UID=1001
ARG GID=1001

RUN addgroup -g ${GID} ${GROUP} && \
  adduser --disabled-password --ingroup ${GROUP} -u ${UID} ${USER}

WORKDIR /web
COPY --from=requirements /tmp/requirements.txt /web/requirements.txt
COPY --chown=${USER}:${GROUP} ./src/ /web/
COPY --chown=${USER}:${GROUP} ./alembic.ini /web/
COPY --chown=${USER}:${GROUP} ./alembic /web/alembic/
COPY --chown=${USER}:${GROUP} --chmod=754 ./entrypoint.sh /web/

RUN apk -U upgrade --no-cache && \
  apk add tini --no-cache && \
  pip install --upgrade pip && \
  pip install --no-cache-dir --upgrade -r /web/requirements.txt

# Prepare volume directory and set permissions
RUN mkdir -p /app/data && \
  chown -R ${USER}:${GROUP} /app

# create volume mount point for sqlite database
VOLUME ["/app/data"]

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost/docs')" || exit 1

USER ${USER}

ENTRYPOINT ["./entrypoint.sh"]
