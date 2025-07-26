#!/bin/bash

PANEL_BASE_DIR=/opt
PANEL_PORT=10086
SSH_PORT=22222
PANEL_ENTRANCE="entrance"
PANEL_USERNAME="1panel"
PANEL_PASSWORD="1panel_password"

CURRENT_DIR=$(
    cd "$(dirname "$0")"
    pwd
)

FAKE_DIR=$(
    cd "${CURRENT_DIR}" && cd ..
    pwd
)
mkdir -p "$$FAKE_DIR/usr/local/bin"
mkdir -p "$$FAKE_DIR/usr/bin"
mkdir -p "$FAKE_DIR/etc/systemd/system"
mkdir -p "$FAKE_DIR/etc/ssh"
mkdir -p "$FAKE_DIR/default/etc/ssh"

LANG_DIR="$CURRENT_DIR/lang"
selected_lang="en"
LANGFILE="$LANG_DIR/$selected_lang.sh"
if [ -f "$LANGFILE" ]; then
    source "$LANGFILE"
else
    echo -e "$TXT_LANG_NOT_FOUND_MSG $LANGFILE"
    exit 1
fi
clear

function log() {
    message="[1Panel Log]: $1 "
    echo -e "${message}" 2>&1 | tee -a ${CURRENT_DIR}/install.log
}

echo
cat << EOF
 ██╗    ██████╗  █████╗ ███╗   ██╗███████╗██╗     
███║    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║     
╚██║    ██████╔╝███████║██╔██╗ ██║█████╗  ██║     
 ██║    ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║     
 ██║    ██║     ██║  ██║██║ ╚████║███████╗███████╗
 ╚═╝    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
EOF

log "$TXT_START_INSTALLATION"

USE_EXISTING=false

function Set_Ssh(){
    if which ssh >/dev/null 2>&1; then
        sed -i "s/^#Port.*/Port $SSH_PORT/" /etc/ssh/sshd_config
        cp /etc/ssh/sshd_config $FAKE_DIR/etc/ssh/
        cp /etc/ssh/sshd_config $FAKE_DIR/default/etc/ssh/
    fi
}

function Set_Firewall(){
    if which firewall-cmd >/dev/null 2>&1; then
        if systemctl status firewalld | grep -q "Active: active" >/dev/null 2>&1;then
            log "$TXT_FIREWALL_OPEN_PORT $PANEL_PORT/$SSH_PORT"
            firewall-cmd --zone=public --add-port="$PANEL_PORT"/tcp --permanent
            firewall-cmd --zone=public --add-port="$SSH_PORT"/tcp --permanent
            firewall-cmd --reload
        else
            log "$TXT_FIREWALL_NOT_ACTIVE_SKIP"
        fi
    fi

    if which ufw >/dev/null 2>&1; then
        if systemctl status ufw | grep -q "Active: active" >/dev/null 2>&1;then
            log "$TXT_FIREWALL_OPEN_PORT $PANEL_PORT/$SSH_PORT"
            ufw allow "$PANEL_PORT"/tcp
            ufw allow "$SSH_PORT"/tcp
            ufw reload
        else
            log "$TXT_FIREWALL_NOT_ACTIVE_IGNORE"
        fi
    fi
}

function Init_Panel(){
    log "$TXT_CONFIGURE_PANEL_SERVICE"

    RUN_BASE_DIR=$PANEL_BASE_DIR/1panel
    mkdir -p "$FAKE_DIR/$RUN_BASE_DIR"

    cd "${CURRENT_DIR}" || exit

    cp ./1panel-core $FAKE_DIR/usr/local/bin && chmod +x $FAKE_DIR/usr/local/bin/1panel-core
    ln -s /usr/local/bin/1panel-core $FAKE_DIR/usr/bin/1panel >/dev/null 2>&1
    ln -s /usr/local/bin/1panel-core $FAKE_DIR/usr/bin/1panel-core >/dev/null 2>&1

    cp ./1panel-agent $FAKE_DIR/usr/local/bin && chmod +x $FAKE_DIR/usr/local/bin/1panel-agent
    ln -s /usr/local/bin/1panel-agent $FAKE_DIR/usr/bin/1panel-agent >/dev/null 2>&1

    cp ./1pctl $FAKE_DIR/usr/local/bin && chmod +x $FAKE_DIR/usr/local/bin/1pctl
    sed -i -e "s#BASE_DIR=.*#BASE_DIR=${PANEL_BASE_DIR}#g" $FAKE_DIR/usr/local/bin/1pctl
    sed -i -e "s#ORIGINAL_PORT=.*#ORIGINAL_PORT=${PANEL_PORT}#g" $FAKE_DIR/usr/local/bin/1pctl
    sed -i -e "s#ORIGINAL_USERNAME=.*#ORIGINAL_USERNAME=${PANEL_USERNAME}#g" $FAKE_DIR/usr/local/bin/1pctl
    ESCAPED_PANEL_PASSWORD=$(echo "$PANEL_PASSWORD" | sed 's/[!@#$%*_,.?]/\\&/g')
    sed -i -e "s#ORIGINAL_PASSWORD=.*#ORIGINAL_PASSWORD=${ESCAPED_PANEL_PASSWORD}#g" $FAKE_DIR/usr/local/bin/1pctl
    sed -i -e "s#ORIGINAL_ENTRANCE=.*#ORIGINAL_ENTRANCE=${PANEL_ENTRANCE}#g" $FAKE_DIR/usr/local/bin/1pctl
    sed -i -e "s#LANGUAGE=.*#LANGUAGE=${selected_lang}#g" $FAKE_DIR/usr/local/bin/1pctl
    ln -s /usr/local/bin/1pctl $FAKE_DIR/usr/bin/1pctl >/dev/null 2>&1

    if [ -d "$FAKE_DIR/$RUN_BASE_DIR/geo" ]; then
        rm -rf "$FAKE_DIR/$RUN_BASE_DIR/geo"
    fi
    mkdir $FAKE_DIR/$RUN_BASE_DIR/geo
    cp -r ./GeoIP.mmdb $FAKE_DIR/$RUN_BASE_DIR/geo/

    cp -r ./lang $FAKE_DIR/usr/local/bin
    cp ./1panel-core.service $FAKE_DIR/etc/systemd/system
    cp ./1panel-agent.service $FAKE_DIR/etc/systemd/system
}

function main(){
    Set_Ssh
    Set_Firewall
    Init_Panel
}
main
