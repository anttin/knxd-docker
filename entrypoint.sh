#!/bin/sh
set -xe

UID=${USER_ID:-9000}
GID=${GROUP_ID:-9000}

/usr/bin/knxd --version
exec /usr/sbin/gosu $UID:$GID "$@"
