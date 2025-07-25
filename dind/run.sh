#!/bin/bash

# 只启动必要服务

# 1Panel数据初始化
systemctl start 1panel-core
sleep 3
systemctl stop 1panel-core

# 更新数据库版本
/app/update_app_version.sh
# 启动 ssh
echo "Start SSH"
systemctl start ssh
# 启动 containerd
echo "Start Containerd"
systemctl start containerd
# 启动 docker
echo "Start Docker"
systemctl start docker
# 启动 1Panel
echo "Start 1Panel Core"
systemctl start 1panel-core
echo "Start 1Panel Agent"
systemctl start 1panel-agent

# 监听日志
systemctl log 1panel-core -f
