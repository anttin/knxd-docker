#!/bin/sh
set -xe

UID=${USER_ID:-9000}
GID=${GROUP_ID:-9000}

exec /usr/sbin/gosu $UID:$GID "$@"
