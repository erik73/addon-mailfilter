ARG BUILD_FROM=ghcr.io/erik73/base/amd64:3.0.29

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
ARG S6_OVERLAY_VERSION="v3.2.0.2"

# Setup base

RUN apk add --no-cache \
    nginx=1.26.2-r3 \
    freshclam=1.2.2-r0 \
    clamav-scanner=1.2.2-r0 \
    clamav-daemon=1.2.2-r0 \
    clamav=1.2.2-r0 \
    clamav-libunrar=1.2.2-r0 \
    redis=7.2.5-r2 \
    rspamd=3.8.4-r0 \
    rspamd-openrc=3.8.4-r0 \
    && mkdir -p /run/systemd/journal \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/syslogd-overlay-noarch.tar.xz" \
        | tar -C / -Jxpf - 

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
