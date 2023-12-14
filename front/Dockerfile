FROM node:gallium-alpine as build

ENV HUGO_VERSION="0.121.1"
ENV HUGO_CHECKSUM="348997284f405abee2a84634525a4e1298b710bbf5bdf5dea30bfc0b1c9aeba5"

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

FROM nginx:stable-alpine as prod

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
