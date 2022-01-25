FROM golang:1.17.5-alpine3.15 as base

ENV REFRESHED_AT="2022-25-01" \
    BUILD_DEPS="npm yarn curl bash build-base" \
    TORRSERVER_VERSION="111" \
    RUN_DEPS="ibstdc++ libgcc"

FROM base AS build
ARG TARGETOS
ARG TARGETARCH
RUN apk --update add $BUILD_DEPS
RUN curl -sSL https://github.com/YouROK/TorrServer/archive/refs/tags/MatriX.$TORRSERVER_VERSION.tar.gz | tar xz -C /tmp/
ADD build.sh /tmp/TorrServer-MatriX.$TORRSERVER_VERSION/build.sh
WORKDIR /tmp/TorrServer-MatriX.$TORRSERVER_VERSION
RUN chmod +x /tmp/TorrServer-MatriX.$TORRSERVER_VERSION/build.sh
RUN ["/bin/bash", "-c", "/tmp/TorrServer-MatriX.$TORRSERVER_VERSION/build.sh"]


FROM alpine:latest
COPY --from=build /tmp/torrserver /bin/
RUN apk add --no-cache libstdc++ libgcc ffmpeg

LABEL \
  MAINTAINER="Mark Glants <mark@glants.xyz>" \
  CONTRIBUTORS="YouROK"
ENV GODEBUG="madvdontneed=1"
ENV TS_CONF_PATH="/data"
ENV TS_TORR_DIR="/data/torrents"
EXPOSE 8090/tcp
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN mkdir /data
ENTRYPOINT ["docker-entrypoint.sh"]