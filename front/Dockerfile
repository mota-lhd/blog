FROM node:gallium-alpine AS build

ENV HUGO_VERSION="0.122.0"
ENV HUGO_CHECKSUM="356a4948e8be7c538220210f03f6374b5d2379d9ca440182efec534cfd45ca9c"

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

HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f http://localhost/ || exit 1

RUN apk -U upgrade

WORKDIR /web
COPY --from=build /web/public/ /web
COPY ./nginx.conf /etc/nginx/nginx.conf

RUN addgroup ${GROUP}
RUN adduser --disabled-password --no-create-home --ingroup ${GROUP} ${USER}

USER ${USER}
