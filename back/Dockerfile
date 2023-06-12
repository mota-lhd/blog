FROM python:3.10 as requirements-step

WORKDIR /tmp

RUN pip install --no-cache-dir poetry
COPY poetry.lock pyproject.toml /tmp/

RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

FROM python:3.10-alpine as prod

ARG USER=back
ARG GROUP=web
LABEL org.opencontainers.image.authors="elmouatassim.louhaidia@pm.me"

HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f http://localhost/ || exit 1

RUN addgroup ${GROUP}
RUN adduser --disabled-password --ingroup ${GROUP} ${USER}

WORKDIR /web
COPY --from=requirements-step /tmp/requirements.txt /web/requirements.txt
COPY --chown=${USER}:${GROUP} ./src/ /web/

RUN apk -U upgrade
RUN apk add --no-cache dumb-init
RUN pip install --no-cache-dir --upgrade -r /web/requirements.txt

EXPOSE 80

USER ${USER}

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
