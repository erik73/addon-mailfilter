#!/command/with-contenv bashio
# shellcheck disable=SC2086,SC2016,SC2027

    addgroup -S rspamd
    adduser -S -D -H -G rspamd rspamd
    mkdir -p /data/lib/rspamd
    mkdir -p /data/lib/redis
    mkdir -p /data/lib/clamav
    rm -fr /var/lib/rspamd
    rm -fr /var/lib/redis
    rm -fr /var/lib/clamav
    ln -s /data/lib/rspamd /var/lib/rspamd
    ln -s /data/lib/redis /var/lib/redis
    chown -R rspamd:rspamd /var/lib/rspamd/
    chown -R redis:redis /var/lib/redis/
    mkdir /run/clamav
    chown -R clamav:clamav /run/clamav
    ln -s /data/lib/clamav /var/lib/clamav
    chown -R clamav:clamav /var/lib/clamav/
    mkdir /run/rspamd
    
    # Disable DKIM Signing
    # mkdir -p /var/lib/rspamd/dkim/
    # chown rspamd:rspamd /var/lib/rspamd/dkim
    # rspamadm dkim_keygen -b 2048 -s mail -k /var/lib/rspamd/dkim/mail.key | tee -a  /var/lib/rspamd/dkim/mail.pub
    # chown -R rspamd:rspamd /var/lib/rspamd/dkim

# Add symbolic link to make logging work in older supervisor
if ! readlink /dev/log >/dev/null 2>&1
then
ln -s /run/systemd/journal/dev-log /dev/log
fi

# Modify config files for S6-logging
sed -i 's#^ + .*$# + -^auth\\\\. -^authpriv\\\\. -user\\\\. -local\\\\. -mail\\\\. $T ${dir}/everything#' /etc/s6-overlay/s6-rc.d/syslogd-log/run
sed -i 's#^ + .*$# + -^auth\\\\. -^authpriv\\\\. -user\\\\. -local\\\\. -mail\\\\. $T ${dir}/everything#' /run/service/syslogd-log/run.user
sed -i '22 s# .*$# - +^[[:alnum:]]*\\\\.info: +^[[:alnum:]]*\\\\.notice: +^[[:alnum:]]*\\\\.warn: -^auth\\\\. -^authpriv\\\\. -^cron\\\\. -daemon\\\\. -local\\\. -user\\\\. -mail\\\\.  $T ${dir}/messages#' /run/service/syslogd-log/run.user
sed -i '22 s# .*$# - +^[[:alnum:]]*\\\\.info: +^[[:alnum:]]*\\\\.notice: +^[[:alnum:]]*\\\\.warn: -^auth\\\\. -^authpriv\\\\. -^cron\\\\. -daemon\\\\. -local\\\. -user\\\\. -mail\\\\.  $T ${dir}/messages#' /etc/s6-overlay/s6-rc.d/syslogd-log/run
sed -i 's#^backtick .*$#backtick -D "n20 s1000000 T 1" line { printcontenv S6_LOGGING_SCRIPT }#' /etc/s6-overlay/s6-rc.d/syslogd-log/run
sed -i 's#^backtick .*$#backtick -D "n20 s1000000 T 1" line { printcontenv S6_LOGGING_SCRIPT }#' /run/service/syslogd-log/run.user
sed -i 's#^s6-socklog .*$#s6-socklog -d3 -U -t3000 -x /run/systemd/journal/dev-log#' /etc/s6-overlay/s6-rc.d/syslogd/run
sed -i 's#^s6-socklog .*$#s6-socklog -d3 -U -t3000 -x /run/systemd/journal/dev-log#' /run/service/syslogd/run.user

#Create rspamd encrypted password and set listening IP
rspamdpw="$(date | md5sum)"
encryptedpw="$(rspamadm pw --encrypt -p ${rspamdpw})"
encryptedenpw="$(rspamadm pw --encrypt -p ${rspamdpw})"
myip="$(ip route get 1 | awk '{print $NF;exit}')"
sed -i "4 s/password = /password = "${encryptedpw}";/g" /etc/rspamd/local.d/worker-controller.inc
sed -i "5 s/enable_password = /enable_password = "${encryptedenpw}";/g" /etc/rspamd/local.d/worker-controller.inc
sed -i '2 s/^bind.*$/bind_socket = "'${myip}:11332'";/g' /etc/rspamd/local.d/worker-proxy.inc

#Remove antivirus service files if disabled
if bashio::config.false "enable_antivirus"; then
    rm -fr /etc/services.d/clamav
    rm -fr /etc/services.d/freshclam
    rm -rf /data/lib/clamav
fi

if bashio::config.true "enable_antivirus"; then
    sed -i '1d' /etc/rspamd/local.d/antivirus.conf
    bashio::log.info "Updating antivirus patterns"
    freshclam
fi

if bashio::config.false "enable_dkim_signing"; then
    mv /etc/rspamd/local.d/dkim_signing.disabled /etc/rspamd/local.d/dkim_signing.conf
fi

if bashio::config.false "enable_dkim_signing" && bashio::fs.directory_exists "/ssl/dkim"; then
    bashio::log.info "DKIM signing is disabled, but old key files found. The will be removed"
    rm -rf /ssl/dkim
fi

if bashio::config.true "enable_dkim_signing"; then
    mv /etc/rspamd/local.d/dkim_signing.enabled /etc/rspamd/local.d/dkim_signing.conf
    bashio::log.info "DKIM signing is enabled"
fi

if bashio::config.true "enable_dkim_signing" && ! bashio::fs.directory_exists "/ssl/dkim"; then
    bashio::log.info "DKIM signing is enabled, but there are no keys available. Generating keys..."
    mkdir /ssl/dkim
    rspamadm dkim_keygen -b 2048 -s mail -k /ssl/dkim/mail.key | tee -a /ssl/dkim/mail.pub
    chown -R rspamd:rspamd /ssl/dkim
    bashio::log.info "DKIM keys (mail.key and mail.pub) saved to /ssl/dkim"
    bashio::log.info "Refer to the documentation on how to setup your DNS records"
fi
