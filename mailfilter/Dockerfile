ARG BUILD_FROM=ghcr.io/erik73/base/amd64:2.0.7

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
ARG RSPAMD_VERSION="3.4"

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
    libsodium=1.0.18-r2 \
    sqlite-libs=3.40.1-r0 \
    glib=2.74.6-r0 \
    icu-libs=72.1-r1 \
    lua5.3=5.3.6-r4 \
&& apk add --no-cache --virtual .build-dependencies \
    build-base=0.5-r3 \
    cmake=3.24.4-r0 \
    curl-dev=7.88.1-r1 \
    file-dev=5.43-r0 \
    gd-dev=2.3.3-r3 \
    glib-dev=2.74.6-r0 \
    icu-dev=72.1-r1 \
    libsodium-dev=1.0.18-r2 \
    openssl-dev=3.0.8-r3 \
    pcre2-dev=10.42-r0 \
    perl=5.36.0-r0 \
    ragel=6.10-r1 \
    sqlite-dev=3.40.1-r0 \
    lua5.3-dev=5.3.6-r4 \
    git=2.38.4-r1 \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone -b "${RSPAMD_VERSION}" --recursive https://github.com/rspamd/rspamd \
    && cd rspamd \
    && export CFLAGS=-U_FORTIFY_SOURCE \
    && export CXXFLAGS=-U_FORTIFY_SOURCE \
    && cmake -DCMAKE_INSTALL_PREFIX= . -DENABLE_JEMALLOC=ON -DENABLE_LUAJIT=OFF \
    && make install \
    && apk del .build-dependencies \
    && cd / \
    && rm -f -r \
        /tmp/* \
        /usr/src/rspamd \
    && mkdir -p /run/systemd/journal \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/syslogd-overlay-noarch.tar.xz" \
        | tar -C / -Jxpf - 

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
