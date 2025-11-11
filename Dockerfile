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

RUN addgroup ${GROUP}
RUN adduser --disabled-password --ingroup ${GROUP} ${USER}

WORKDIR /web
COPY --from=requirements /tmp/requirements.txt /web/requirements.txt
COPY --chown=${USER}:${GROUP} ./src/ /web/
COPY --chown=${USER}:${GROUP} alembic.ini .
COPY --chown=${USER}:${GROUP} alembic ./alembic/

RUN apk -U upgrade
RUN pip install --upgrade pip
RUN pip install --no-cache-dir --upgrade -r /web/requirements.txt

USER ${USER}

# create volume mount point for sqlite database
VOLUME ["/app/data"]

CMD alembic upgrade head && uvicorn main:app --proxy-headers --host 0.0.0.0 --port 80
