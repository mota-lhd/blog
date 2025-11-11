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
ARG VOLUME_PATH=/app/data

RUN addgroup ${GROUP}
RUN adduser --disabled-password --ingroup ${GROUP} ${USER}

WORKDIR /web
COPY --from=requirements /tmp/requirements.txt /web/requirements.txt
COPY --chown=${USER}:${GROUP} ./src/ /web/
COPY --chown=${USER}:${GROUP} ./alembic.ini /web/
COPY --chown=${USER}:${GROUP} ./alembic /web/alembic/
COPY --chown=${USER}:${GROUP} --chmod=754 ./entrypoint.sh /web/

RUN apk -U upgrade
RUN pip install --upgrade pip
RUN pip install --no-cache-dir --upgrade -r /web/requirements.txt

# Prepare volume directory and set permissions
RUN mkdir -p ${VOLUME_PATH} && \
    chown ${USER}:${GROUP} ${VOLUME_PATH}

USER ${USER}

# create volume mount point for sqlite database
VOLUME ["${VOLUME_PATH}"]

ENTRYPOINT ["/web/entrypoint.sh"]
