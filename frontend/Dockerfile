FROM alpine:3 AS installer

ENV HUGO_VERSION="0.161.1"
ENV HUGO_CHECKSUM="fae28bf7909c1a42d1365b89d2e9e3d4194fbe5968ae0dd5504f562381018a1d"

RUN apk add --no-cache curl

RUN curl -sSL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -o /tmp/hugo.tar.gz
RUN echo "${HUGO_CHECKSUM}  /tmp/hugo.tar.gz" | sha256sum -c
RUN tar xf /tmp/hugo.tar.gz hugo -C /tmp/

FROM oven/bun:1 AS build

COPY --from=installer /tmp/hugo /usr/bin
RUN chmod 700 /usr/bin/hugo

WORKDIR /web
COPY ./src/ /web/

RUN bun install --frozen-lockfile && \
  bun run build:css && \
  bun run build:generate

FROM nginx:stable-alpine AS prod

ARG USER=front
ARG GROUP=web

RUN apk -U upgrade --no-cache

WORKDIR /web
COPY --from=build /web/public/ /web
COPY ./nginx.conf /etc/nginx/nginx.conf

RUN addgroup ${GROUP}
RUN adduser --disabled-password --no-create-home --ingroup ${GROUP} ${USER}

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD sh -c 'ps -ef | grep -q "[n]ginx"' || exit 1

USER ${USER}
