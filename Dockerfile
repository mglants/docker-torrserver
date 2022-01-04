FROM golang:1.17.5-alpine3.15 as base

ENV REFRESHED_AT="2021-04-01" \
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
RUN apk add --no-cache libstdc++ libgcc ffmpeg && \
    addgroup -S torrserver 2>/dev/null && \
    adduser -S -D -H -h /var/empty -s /bin/false -G torrserver -g torrserver torrserver 2>/dev/null

LABEL \
  MAINTAINER="Mark Glants <mark@glants.xyz>" \
  CONTRIBUTORS="YouROK"
ENV GODEBUG="madvdontneed=1"
EXPOSE 8090/tcp
ENTRYPOINT ["/bin/torrserver"]
