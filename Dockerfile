FROM python:3.13 AS requirements

WORKDIR /tmp
RUN pip install --no-cache-dir poetry poetry-plugin-export
COPY poetry.lock pyproject.toml /tmp/
RUN poetry export --format=requirements.txt \
  --output=requirements.txt \
  --without-hashes

FROM python:3.13-alpine AS prod

ARG USER=back
ARG GROUP=web
LABEL org.opencontainers.image.authors="elmouatassim.louhaidia@pm.me"

HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f http://localhost/docs || exit 1

RUN addgroup ${GROUP}
RUN adduser --disabled-password --ingroup ${GROUP} ${USER}

WORKDIR /web
COPY --from=requirements /tmp/requirements.txt /web/requirements.txt
COPY --chown=${USER}:${GROUP} ./src/ /web/

RUN apk -U upgrade
RUN pip install --upgrade pip
RUN pip install --no-cache-dir --upgrade -r /web/requirements.txt

USER ${USER}

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
