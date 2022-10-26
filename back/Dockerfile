FROM python:3.10 as requirements-step

WORKDIR /tmp

RUN pip install --no-cache-dir poetry
COPY poetry.lock pyproject.toml /tmp/

RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

FROM python:3.10-alpine as prod

LABEL org.opencontainers.image.authors="elmouatassim.louhaidia@pm.me"

HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f http://localhost/ || exit 1

RUN addgroup web
RUN adduser --disabled-password --ingroup web back

WORKDIR /web
COPY --from=requirements-step /tmp/requirements.txt /web/requirements.txt
COPY --chown=back:web ./src/ /web/

RUN apk -U upgrade
RUN pip install --no-cache-dir --upgrade -r /web/requirements.txt

EXPOSE 80

USER back

ENTRYPOINT [ "uvicorn" ]
CMD ["main:app", "--host", "0.0.0.0", "--port", "80"]
