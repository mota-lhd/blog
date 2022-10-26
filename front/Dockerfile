FROM alpine:3.16 as build

ENV HUGO_VERSION="0.104.3"
ENV HUGO_CHECKSUM="da45809872c2c3a318c277adcacd80d00f4e0cd4527640f67055beac3b642333"

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
