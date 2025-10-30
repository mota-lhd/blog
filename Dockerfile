FROM python:3.14 AS requirements

WORKDIR /tmp
RUN pip install uv
COPY uv.lock pyproject.toml /tmp/
RUN uv sync
RUN uv pip freeze > requirements.txt

FROM python:3.14-alpine AS prod

ARG USER=back
ARG GROUP=web

RUN addgroup ${GROUP}
RUN adduser --disabled-password --ingroup ${GROUP} ${USER}

WORKDIR /web
COPY --from=requirements /tmp/requirements.txt /web/requirements.txt
COPY --chown=${USER}:${GROUP} ./src/ /web/

RUN apk -U upgrade
RUN pip install --upgrade pip
RUN pip install --no-cache-dir --upgrade -r /web/requirements.txt

USER ${USER}

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
