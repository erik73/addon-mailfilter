#!/command/with-contenv bashio
# shellcheck disable=SC2086,SC2016,SC2027
if bashio::config.false "enable_antivirus"; then
    bashio::log.info "Disabling antivirus services"
    rm -fr /etc/s6-overlay/s6-rc.d/user/contents.d/freshclam
    rm -fr /etc/s6-overlay/s6-rc.d/user/contents.d/clamav
    rm -rf /data/lib/clamav
fi