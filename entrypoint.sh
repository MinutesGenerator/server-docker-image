#!/usr/bin/env bash
set -euo pipefail

mkdir -p /var/run/sshd /root/.ssh
chmod 700 /root/.ssh

if [ -n "${PUBLIC_KEY:-}" ]; then
  touch /root/.ssh/authorized_keys
  if ! grep -qxF "${PUBLIC_KEY}" /root/.ssh/authorized_keys; then
    echo "${PUBLIC_KEY}" >> /root/.ssh/authorized_keys
  fi
  chmod 600 /root/.ssh/authorized_keys
fi

service ssh start

exec "$@"
