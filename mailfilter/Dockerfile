ARG BUILD_FROM=ghcr.io/erik73/base/amd64:2.0.8

# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION
ARG S6_OVERLAY_VERSION="v3.1.4.1"
ARG RSPAMD_VERSION="3.5"

# Setup base

RUN apk add --no-cache \
    nginx=1.22.1-r0 \ 
    clamav-libs=0.105.2-r0 \
    freshclam=0.105.2-r0 \
    clamav-scanner=0.105.2-r0 \
    clamav-daemon=0.105.2-r0 \
    clamav=0.105.2-r0 \
    clamav-libunrar=0.105.2-r0 \
    redis=7.0.10-r0 \
    rspamd=3.5-r1

ENV LD_PRELOAD="/usr/local/lib/libjemalloc.so.2"

# Copy data for add-on
COPY rootfs /

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Erik Hilton <erikhilton73@gmail.com>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Erik73 Hassio-Addons" \
    org.opencontainers.image.authors="Erik Hilton <erikhilton73@gmail.com>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/erik73/hassio-addons" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
