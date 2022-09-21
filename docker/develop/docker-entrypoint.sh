#!/bin/bash

# ----- Ensure correct ownership of /diaspora -----
dia_home=/home/diaspora

HOST_UID=$(stat -c %u /diaspora)
HOST_GID=$(stat -c %g /diaspora)

if ! getent group $HOST_GID >/dev/null; then
  groupmod --gid $HOST_GID diaspora
fi

if ! getent passwd $HOST_UID >/dev/null; then
  usermod --uid $HOST_UID --gid $HOST_GID diaspora
fi

chown -R $HOST_UID:$HOST_GID /home/diaspora
mkdir -p /diaspora/tmp/pids
chown $HOST_UID:$HOST_GID /diaspora/tmp /diaspora/tmp/pids /diaspora/vendor/bundle

function wait_for_port() {
  local host=$1
  local port=$2

  local c=0
  trap '{ exit 1; }' INT
  while ! (< /dev/tcp/${host}/${port}) 2>/dev/null; do
    printf "\rWaiting for $host:$port to become ready ... ${c}s"
    sleep 1
    ((c++))
  done
  trap - INT
  if [ ! -z $c ]; then
    printf "\rWaiting for $host:$port to become ready ... done (${c}s)\n"
  fi
}

if [ -z $DIA_NODB ] || [ ! $DIA_NODB -eq 1 ]; then
  # ----- Wait for DB -----
  if grep -qFx "  <<: *postgresql" /diaspora/config/database.yml; then
    wait_for_port postgresql 5432
  else
    wait_for_port mysql 3306
  fi

  # ----- Wait for Redis -----
  wait_for_port redis 6379
fi

cd /diaspora

gosu $HOST_UID:$HOST_GID "$@"
