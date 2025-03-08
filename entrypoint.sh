#!/bin/sh

if [ -n "$RUN_DHCPCD" ]; then
	if [ -n "$DUID" ]; then
		echo "$DUID" > /var/lib/dhcpcd/duid
	fi
	dhcpcd
fi


downloadsPath="/downloads"
profilePath="/config"
qbtConfigFile="$profilePath/qBittorrent/config/qBittorrent.conf"

if [ -n "$PUID" ] && [ "$PUID" != "$(id -u qbtUser)" ]; then
    sed -i "s|^qbtUser:x:[0-9]*:|qbtUser:x:$PUID:|g" /etc/passwd
fi

if [ -n "$PGID" ] && [ "$PGID" != "$(id -g qbtUser)" ]; then
    sed -i "s|^\(qbtUser:x:[0-9]*\):[0-9]*:|\1:$PGID:|g" /etc/passwd
    sed -i "s|^qbtUser:x:[0-9]*:|qbtUser:x:$PGID:|g" /etc/group
fi


if [ ! -f "$qbtConfigFile" ]; then
    mkdir -p "$(dirname $qbtConfigFile)"
    cat << EOF > "$qbtConfigFile"
[BitTorrent]
Session\DefaultSavePath=$downloadsPath
Session\Port=6881
Session\TempPath=$downloadsPath/temp
EOF
fi

confirmLegalNotice="--confirm-legal-notice"

if [ -z "$QBT_WEBUI_PORT" ]; then
    QBT_WEBUI_PORT=8080
fi

# those are owned by root by default
# don't change existing files owner in `$downloadsPath`

# set umask just before starting qbt
if [ -n "$UMASK" ]; then
    umask "$UMASK"
fi

exec \
    doas -u qbtUser \
        qbittorrent-nox \
            --profile="$profilePath" \
            --webui-port="$QBT_WEBUI_PORT" \
            "$@"
