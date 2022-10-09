FROM python:3.10.6-alpine as build

RUN apk add --no-cache \
        curl gcc libressl-dev build-base musl-dev libffi-dev

RUN /usr/local/bin/python -m pip install --upgrade pip
RUN /usr/local/bin/python -m pip install --no-cache-dir poetry==1.2.1

WORKDIR /
COPY poetry.lock pyproject.toml /
RUN poetry config virtualenvs.create false
RUN poetry install --no-root --without dev
RUN /usr/local/bin/python -m pip uninstall --yes poetry

FROM python:3.10.6-alpine as prod

RUN addgroup web
RUN adduser --disabled-password --ingroup web back

RUN apk -U upgrade
RUN apk add --no-cache jq git

EXPOSE 80

WORKDIR /web
COPY --from=build /usr/local /usr/local
COPY --chown=back:web ./src/ /web/

USER back

ENTRYPOINT [ "uvicorn" ]
CMD ["main:app", "--host", "0.0.0.0", "--port", "80"]
