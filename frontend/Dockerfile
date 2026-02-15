FROM node:gallium-alpine AS build

ENV HUGO_VERSION="0.155.3"
ENV HUGO_CHECKSUM="6c280fb8aae09b0dea9a83dbb6c3429bf7fd683839b454bd00c4e21f60440c45"

RUN apk add --no-cache curl

RUN curl -sSL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -o /tmp/hugo.tar.gz
RUN echo "${HUGO_CHECKSUM}  /tmp/hugo.tar.gz" | sha256sum -c
RUN tar xf /tmp/hugo.tar.gz hugo -C /tmp/
RUN cp /tmp/hugo /usr/bin
RUN chmod 700 /usr/bin/hugo

WORKDIR /web
COPY ./src/ /web/

RUN npm install
RUN npm run css
RUN hugo --minify --gc --destination public --source .

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
