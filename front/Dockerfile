FROM alpine:3.16 as build

ENV HUGO_VERSION="0.105.0"
ENV HUGO_CHECKSUM="f5d76d69c4dbe56dae506ebadf03acca414f8b2905bce089a1de298515324daa"

RUN apk add --no-cache curl

RUN curl -sSL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -o /tmp/hugo.tar.gz
RUN echo "${HUGO_CHECKSUM}  /tmp/hugo.tar.gz" | sha256sum -c
RUN tar xf /tmp/hugo.tar.gz hugo -C /tmp/ && cp /tmp/hugo /usr/bin

WORKDIR /web
COPY ./src/ /web/
RUN hugo --minify --gc --destination public --source .

FROM nginx:stable-alpine as prod

LABEL org.opencontainers.image.authors="elmouatassim.louhaidia@pm.me"

HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f http://localhost/ || exit 1

RUN apk -U upgrade

WORKDIR /web
COPY --from=build /web/public/ /web
COPY ./nginx.conf /etc/nginx/nginx.conf

RUN addgroup web
RUN adduser --disabled-password --no-create-home --ingroup web front

USER front
