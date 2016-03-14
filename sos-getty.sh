#!/bin/sh
##
## socat over serial: getty
## Copyright (c) 2016 SATOH Fumiyasu @ OSS Technology Corp., Japan
##
## License: GNU General Public License version 3
##

set -u

run() {
  echo "$(date '+%Y/%m/%d %H:%M:%S') $*" 1>&2
  "$@"
}

serial_speed="115200"
connect_ip="127.0.0.1"

if [ $# -ne 2 ]; then
  echo "Usage: ${0##*/} <SERIAL_PATH> <CONNECT_PORT>"
  exit 1
fi

serial_path="$1"; shift
connect_port="$1"; shift

while :; do
  run /sbin/agetty \
    --wait-cr \
    --skip-login \
    --login-program /usr/bin/socat \
    --login-options "-,cfmakeraw TCP:$connect_ip:$connect_port" \
    "$serial_path" \
    "$serial_speed" \
  ;
  [ $? -ne 0 ] && exit 1
done

