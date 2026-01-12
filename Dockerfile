FROM n8nio/n8n:latest

USER root

# 使用完整路径运行 apk，并分步安装以便调试
RUN /sbin/apk update && \
    /sbin/apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    font-noto-cjk

RUN /sbin/apk add --no-cache \
    libx11 \
    libxcomposite \
    libxdamage \
    libxext \
    libxfixes \
    libxrandr \
    libxcb \
    libxkbcommon

RUN /sbin/apk add --no-cache \
    pango \
    cairo \
    gtk+3.0 \
    alsa-lib \
    cups-libs

RUN /sbin/apk add --no-cache \
    dbus-libs \
    eudev-libs \
    libdrm \
    mesa-gbm \
    mesa-gl

RUN /sbin/apk add --no-cache \
    atk \
    at-spi2-core \
    at-spi2-atk \
    glib

# 设置 Puppeteer 环境变量
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    N8N_COMMUNITY_PACKAGES_ENABLED=true

# 创建节点目录并设置权限
RUN mkdir -p /home/node/.n8n/nodes/node_modules && \
    chown -R node:node /home/node/.n8n

# 切换到 node 用户安装节点
USER node

# 安装 n8n-nodes-puppeteer 和所有依赖
WORKDIR /home/node/.n8n/nodes/node_modules

RUN npm init -y && \
    npm install n8n-nodes-puppeteer \
    puppeteer-extra-plugin-user-preferences \
    puppeteer-extra-plugin-stealth \
    --legacy-peer-deps

# 返回默认工作目录
WORKDIR /home/node

# 添加标签
LABEL org.opencontainers.image.source="https://github.com/OWNER/n8n-puppeteer"
LABEL org.opencontainers.image.description="n8n with Puppeteer support"
LABEL org.opencontainers.image.licenses="MIT"
