ARG BUILD_FROM=ghcr.io/erik73/base/amd64:6.0.6

# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV S6_STAGE2_HOOK=/etc/s6-s2-hook/disable-services.sh

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION
ARG S6_OVERLAY_VERSION="v3.2.2.0"

# Setup base

RUN apk add --no-cache \
    nginx=1.28.2-r0 \
    freshclam=1.4.3-r2 \
    clamav-scanner=1.4.3-r2 \
    clamav-daemon=1.4.3-r2 \
    clamav=1.4.3-r2 \
    clamav-libunrar=1.4.3-r2 \
    redis=8.4.1-r0 \
    rspamd=3.14.0-r0 \
    rspamd-openrc=3.14.0-r0 \
    && mkdir -p /run/systemd/journal \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/syslogd-overlay-noarch.tar.xz" \
        | tar -C / -Jxpf - \
    && sed -i 's#^ + .*$# + -^auth\\\\. -^authpriv\\\\. -user\\\\. -local\\\\. -mail\\\\. $T ${dir}/everything#' /etc/s6-overlay/s6-rc.d/syslogd-log/run \
    && sed -i '22 s# .*$# - +^[[:alnum:]]*\\\\.info: +^[[:alnum:]]*\\\\.notice: +^[[:alnum:]]*\\\\.warn: -^auth\\\\. -^authpriv\\\\. -^cron\\\\. -daemon\\\\. -local\\\. -user\\\\. -mail\\\\.  $T ${dir}/messages#' /etc/s6-overlay/s6-rc.d/syslogd-log/run \
    && sed -i 's#^backtick .*$#backtick -D "n20 s1000000 T 1" line { printcontenv S6_LOGGING_SCRIPT }#' /etc/s6-overlay/s6-rc.d/syslogd-log/run \
    && sed -i 's#^s6-socklog .*$#s6-socklog -d3 -U -t3000 -x /run/systemd/journal/dev-log#' /etc/s6-overlay/s6-rc.d/syslogd/run

# Copy data for app
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
