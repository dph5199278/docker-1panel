#!/bin/bash

CURRENT_DIR=$(
    cd "$(dirname "$0")" || exit
    pwd
)

ACCELERATOR_URL="https://docker.1panel.live"
ACCELERATOR_TENCENT_URL="https://mirror.ccs.tencentyun.com"
DAEMON_JSON="/etc/docker/daemon.json"

function configure_accelerator() {
    mkdir -p /etc/docker
    echo '{
        "registry-mirrors": [
          "'"$ACCELERATOR_URL"'",
          "'"$ACCELERATOR_TENCENT_URL"'"
        ]
    }' | tee "$DAEMON_JSON" > /dev/null
}

configure_accelerator
