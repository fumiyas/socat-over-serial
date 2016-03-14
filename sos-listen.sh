#!/bin/sh
##
## socat over serial: Listener
## Copyright (c) 2016 SATOH Fumiyasu @ OSS Technology Corp., Japan
##
## License: GNU General Public License version 3
##

set -u

socat_opts="-d -d"
listen_ip="127.0.0.1"
serial_speed="115200"

if [ $# -ne 2 ]; then
  echo "Usage: ${0##*/} <LISTEN_PORT> <SERIAL_PATH>"
  exit 1
fi

listen_port="$1"; shift
serial_path="$1"; shift

socat_kick_getty_sh='
  [ -n "${BASH_VERSION+set}" ] && shopt -s lastpipe 2>/dev/null
  { echo; exec cat; } |exec socat $socat_opts - "$serial_path$serial_opts" |{ read x; exec cat; }
'

if [ -z "${serial_path##/dev/tty*}" ]; then
  serial_opts=",b$serial_speed,cfmakeraw"
else
  serial_opts=""
fi

export socat_opts serial_path serial_opts

while :; do
  socat \
    $socat_opts \
    TCP-LISTEN:"$listen_port",bind="$listen_ip",reuseaddr \
    SYSTEM:"$socat_kick_getty_sh" \
  ;
  [ $? -ne 0 ] && exit 1
done

