# 使用 Ubuntu 24.04 作为基础镜像
FROM ubuntu:24.04 AS base

# 设置环境变量，避免交互式配置
ARG DEBIAN_FRONTEND=noninteractive

# 设置默认语言并将时区为亚洲/上海
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    TZ=Asia/Shanghai

# 安装APT依赖包并清理APT缓存
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    ca-certificates \
    curl \
    gnupg2 \
    lsb-release \
    tar \
    openssh-server \
    sqlite3 \
    tzdata \
    rsyslog \
    && apt-get upgrade -y \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list && \
    python3 -m pip install pyasynchat --break-system-packages && \
    apt-get remove python3-pip -y && \
    apt-get autoremove -y && \
    apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /default/root /default/etc/ssh && \
    cp -r /root/. /default/root/ && \
    cp -r /etc/ssh/. /default/etc/ssh/ && \
    echo "$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat" > /etc/rsyslog.d/00-time.conf

# 定义版本参数
ARG PANELVER=v2.0.5

# 设置环境变量
ENV PANELVER=$PANELVER

FROM base AS builder

# 设置工作目录
WORKDIR /app/1panel/

# 复制全局进程管理器 dumb-init
COPY --from=dph5199278/dumb-init:latest /usr/bin/dumb-init ./usr/bin/dumb-init

RUN mkdir -p ./usr/local/bin && \
    mkdir -p ./usr/bin

# 集成systemctl脚本
RUN curl -L "https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py" -o ./usr/local/bin/systemctl && \
    chmod +x ./usr/local/bin/systemctl

# 复制 docker systemctl 脚本
COPY docker.service ./usr/lib/systemd/system/

# 设置工作目录
WORKDIR /app/1panel/app/

# 复制安装文件并下载并安装 1Panel
# https://resource.fit2cloud.com/1panel/package/v2/${INSTALL_MODE}/latest
COPY ./install.override.sh .
RUN chmod +x install.override.sh ; \
    INSTALL_MODE="stable" && \
    ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "armhf" ]; then ARCH="armv7"; fi && \
    if [ "$ARCH" = "ppc64el" ]; then ARCH="ppc64le"; fi && \
    package_file_name="1panel-${PANELVER}-linux-${ARCH}.tar.gz" && \
    package_download_url="https://resource.fit2cloud.com/1panel/package/v2/${INSTALL_MODE}/${PANELVER}/release/${package_file_name}" && \
    echo "Downloading ${package_download_url}" && \
    curl -sSL -o ${package_file_name} "$package_download_url" && \
    tar zxvf ${package_file_name} --strip-components 1 && \
    rm install.sh && \
    mv -f install.override.sh install.sh && \
    bash install.sh && \
    rm -rf ./*

# 复制启动文件
COPY ./update_app_version.sh .
COPY ./run.sh .
RUN chmod +x update_app_version.sh run.sh

FROM base AS prod

# 复制必要的文件
COPY --from=builder /app/1panel/ /

# 安装所需的软件包并清理APT缓存
RUN ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose && \
    ln -s /usr/local/bin/systemctl /usr/bin/systemctl


# 设置工作目录为根目录
WORKDIR /

# 暴露端口 10086 22222
EXPOSE 10086 22222

# 启动
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/app/run.sh"]
