[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/dph5199278/1panel/latest?color=%2348BB78&logo=docker&label=version)](https://hub.docker.com/r/dph5199278/1panel)
[![Docker Pulls](https://img.shields.io/docker/pulls/dph5199278/1panel?color=%2348BB78&logo=docker&label=pulls)](https://hub.docker.com/r/dph5199278/1panel)
[![Docker Stars](https://img.shields.io/docker/stars/dph5199278/1panel?color=%2348BB78&logo=docker&label=stars)](https://hub.docker.com/r/dph5199278/1panel)
[![GitHub Repo stars](https://img.shields.io/github/stars/dph5199278/docker-1panel)](https://star-history.com/#dph5199278/docker-1panel&Date)

- [简介](#简介)
- [1. 注意事项](#1-注意事项)
  - [1.1 镜像默认配置](#11-镜像默认配置)
  - [1.2 DinD参数](#12-dind参数)
  - [1.3 DooD参数](#13-dood参数)
- [2. 关于镜像](#2-关于镜像)
  - [2.1 架构平台](#21-架构平台)
  - [2.2 DinD](#22-dind)
  - [2.3 DooD](#23-dood)
- [3. 镜像编译](#3-镜像编译)
  - [3.1 DinD](#31-dind)
  - [3.2 DooD](#32-dood)

***

## 简介

感谢[**tangger2000/1panel-dood**](https://github.com/tangger2000/1panel-dood)与[**okxlin/docker-1panel**](https://github.com/okxlin/docker-1panel)项目提供的思路。

基于以上项目，对`1panel`进行了优化，以此来适配1panel V2版本。

1. 分为DinD与DooD架构
   - DinD：Docker in Docker，适合需要容器化部署的场景。
     - 适合需要容器化部署的场景。
     - 适合需要隔离Docker环境的场景。
     - 适合需要在容器内运行Docker命令的场景。
   - DooD：Docker out of Docker，适合需要直接使用宿主机Docker的场景。
     - 适合需要直接使用宿主机Docker的场景。
     - 适合需要与宿主机Docker共享资源的场景。
     - 适合需要在宿主机Docker环境中运行的场景。
2. 优化了镜像体积
3. 添加了伪`systemd`支持（并没有完整支持）
4. 多进程信号支持（可在容器内升级`1panel`，但还是重新pull下镜像）
5. DinD容器内预留了`/app/accelerator.sh`，这是配置`1panel`的镜像加速地址，运行后可在`容器->配置->全部配置`中找到。

## 1. 注意事项

- 由于容器限制，部分功能目前尚不完整。
  - 如：DooD`1Panel`的`Docker`仓库与配置功能可设置但无效。
- 镜像latest是dind-latest
- DinD容器内预留了`/app/accelerator.sh`，这是`1panel`官方的国内镜像加速源配置，运行后可在`容器->配置->全部配置`中找到。


### 1.1 镜像默认配置
***
- 默认端口：`10086`
- 默认SSH端口：`22222`
- 默认账户：`1panel`
- 默认密码：`1panel_password`
- 默认入口：`entrance`

### 1.2 DinD参数
***
- 不可调整参数
  - 无
 ***
- 可调整参数
  - `/docker/1panel/opt/1panel:/opt/1panel`           `1Panel`文件存储映射
  - `TZ=Asia/Shanghai`                                时区设置
  - `1panel`                                          容器名
  - `/docker/1panel/root:/root`                       Root目录映射
  - `/docker/1panel/etc/ssh:/etc/ssh`                 SSH配置映射
  - `/docker/1panel/var/lib/docker:/var/lib/docker`   Docker存储映射
  - `/docker/1panel/etc/docker:/etc/docker`           Docker配置映射

### 1.3 DooD参数
***
- 不可调整参数
  - `/var/run/docker.sock`的相关映射
 ***
- 可调整参数
  - `/opt/1panel:/opt/1panel`                         `1Panel`文件存储映射(推荐/opt，不然应用可能异常)
  - `TZ=Asia/Shanghai`                                时区设置
  - `1panel`                                          容器名
  - `/var/lib/docker/volumes:/var/lib/docker/volumes` Docker存储卷映射
  - `/root:/root`                                     Root目录
  - `/docker/1panel/ssh:/etc/ssh`                     SSH配置映射

## 2. 关于镜像
### 2.1 架构平台
- amd64
- arm64
- ppc64le
- s390x

### 2.2 DinD

DooD：Docker out of Docker，适合需要直接使用宿主机Docker的场景。
- 适合需要直接使用宿主机Docker的场景。
- 适合需要与宿主机Docker共享资源的场景。
- 适合需要在宿主机Docker环境中运行的场景。

***
docker
```bash
# pull
docker pull dph5199278/1panel:dind-latest
# run
docker run -d \
    --name 1panel \
    --restart always \
    --network host \
    -e TZ=Asia/Shanghai \
    -v /docker/1panel/opt/1panel:/opt/1panel \
    -v /docker/1panel/var/lib/docker:/var/lib/docker \
    -v /docker/1panel/etc/docker:/etc/docker \
    -v /docker/1panel/root:/root \
    -v /docker/1panel/ssh:/etc/ssh \
    --cap-add=NET_ADMIN \
    dph5199278/1panel:dind-latest
```
***
docker-compose

创建一个`docker-compose.yml`文件，内容类似如下
```yml
version: '3'
services:
  1panel:
    # 容器名
    container_name: 1panel
    restart: always
    network_mode: "host"
    volumes:
      # 1Panel文件存储映射
      - /docker/1panel/opt/1panel:/opt/1panel
      # Docker存储映射
      - /docker/1panel/var/lib/docker:/var/lib/docker
      # Docker配置映射
      - /docker/1panel/etc/docker:/etc/docker
      # Root目录映射
      - /docker/1panel/root:/root
      # SSH配置映射
      - /docker/1panel/ssh:/etc/ssh
    cap_add:
      - NET_ADMIN
    environment:
      # 时区设置
      - TZ=Asia/Shanghai
    image: dph5199278/1panel:dind-latest
    labels:  
      createdBy: "Apps"
```
然后`docker-compose up -d`运行

### 2.3 DooD

DinD：Docker in Docker，适合需要容器化部署的场景。
- 适合需要容器化部署的场景。
- 适合需要隔离Docker环境的场景。
- 适合需要在容器内运行Docker命令的场景。

***
docker
```bash
# pull
docker pull dph5199278/1panel:dood-latest
# run
docker run -d \
    --name 1panel \
    --restart always \
    --network host \
    -e TZ=Asia/Shanghai \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /opt/1panel:/opt/1panel \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    -v /root:/root \
    -v /docker/1panel/ssh:/etc/ssh \
    dph5199278/1panel:dood-latest
```
***
docker-compose

创建一个`docker-compose.yml`文件，内容类似如下
```yml
version: '3'
services:
  1panel:
    # 容器名
    container_name: 1panel
    restart: always
    network_mode: "host"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      # 1Panel文件存储映射
      - /opt/1panel:/opt/1panel
      # Docker存储卷映射
      - /var/lib/docker/volumes:/var/lib/docker/volumes
      # Root目录映射
      - /root:/root
      # SSH配置映射
      - /docker/1panel/ssh:/etc/ssh
    environment:
      # 时区设置
      - TZ=Asia/Shanghai
    image: dph5199278/1panel:dood-latest
    labels:  
      createdBy: "Apps"
```
然后`docker-compose up -d`运行

## 3. 镜像编译

### 3.1 DinD
```bash
cd dind
docker build --build-arg PANELVER=your_desired_version -t your_image_name:tag .

```

- 编译当前平台：
```bash
cd dind && \
docker build --build-arg PANELVER=v2.0.5 -t 1panel:v2.0.5 .
```

- 编译多平台并推送：
```bash
cd dind && \
docker buildx build --platform linux/amd64,linux/arm64,linux/ppc64le,linux/s390x --build-arg PANELVER=v2.0.5 -t dph5199278/1panel:v2.0.5 --push .
```

### 3.2 DooD
```bash
cd dood && \
docker build --build-arg PANELVER=your_desired_version -t your_image_name:tag .

```

- 编译当前平台：
```bash
cd dood && \
docker build --build-arg PANELVER=v2.0.5 -t 1panel:v2.0.5 .
```

- 编译多平台并推送：
```bash
cd dood && \
docker buildx build --platform linux/amd64,linux/arm64,linux/ppc64le,linux/s390x --build-arg PANELVER=v2.0.5 -t dph5199278/1panel:v2.0.5 --push .
```
