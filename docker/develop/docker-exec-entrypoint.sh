#!/bin/bash

HOST_UID=$(stat -c %u /diaspora)
HOST_GID=$(stat -c %g /diaspora)

cd /diaspora
gosu $HOST_UID:$HOST_GID "$@"
