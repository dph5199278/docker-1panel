#!/bin/bash

# 解决挂载目录为空时，无法启动的问题
# 如果挂载目录为空，则复制默认配置文件到挂载目录
[ -z "$(ls -A /root)" ] && cp -r /default/root/. /root/
[ -z "$(ls -A /etc/ssh)" ] && cp -r /default/etc/ssh/. /etc/ssh/

# 开启日志
systemctl start rsyslog

# 1Panel数据初始化
systemctl start 1panel-core
sleep 3
systemctl stop 1panel-core

# 启动 containerd
echo "Start Containerd"
systemctl start containerd
# 启动 docker
echo "Start Docker"
systemctl start docker
# 启动 ssh
echo "Start SSH"
systemctl start ssh
# 更新数据库版本
/app/update_app_version.sh
# 启动 1Panel
echo "Start 1Panel Core"
systemctl start 1panel-core
# Wait for 1Panel Core to start
sleep 3
echo "Start 1Panel Agent"
systemctl start 1panel-agent

# 监听日志
systemctl log 1panel-core -f
