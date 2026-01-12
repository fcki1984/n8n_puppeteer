FROM n8nio/n8n:latest

USER root

# 安装 Chromium 和所有必要的系统依赖库
RUN apk add --no-cache \
    # Chromium 浏览器
    chromium \
    # 字体支持
    font-noto-cjk \
    ttf-freefont \
    # 核心库
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    # X11 和图形相关
    libx11 \
    libxcomposite \
    libxdamage \
    libxext \
    libxfixes \
    libxrandr \
    libxcb \
    libxkbcommon \
    # GTK 和渲染
    pango \
    cairo \
    gtk+3.0 \
    # 音频和打印
    alsa-lib \
    cups-libs \
    # DBus 和系统服务
    dbus-libs \
    udev \
    # DRM 和 Mesa
    libdrm \
    mesa-gbm \
    # 无障碍支持
    atk \
    at-spi2-core \
    at-spi2-atk \
    # GLib
    glib

# 设置 Puppeteer 环境变量
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    # 允许 n8n 社区节点
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
