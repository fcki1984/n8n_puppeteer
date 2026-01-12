FROM node:20-alpine

# 安装系统依赖
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    font-noto-cjk \
    libx11 \
    libxcomposite \
    libxdamage \
    libxext \
    libxfixes \
    libxrandr \
    libxcb \
    libxkbcommon \
    pango \
    cairo \
    gtk+3.0 \
    alsa-lib \
    cups-libs \
    dbus-libs \
    eudev-libs \
    libdrm \
    mesa-gbm \
    mesa-gl \
    atk \
    at-spi2-core \
    at-spi2-atk \
    glib \
    # 额外工具
    git \
    openssh-client \
    tini

# 设置 Puppeteer 环境变量
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    N8N_COMMUNITY_PACKAGES_ENABLED=true \
    NODE_ENV=production

# 安装 n8n
RUN npm install -g n8n

# 创建 node 用户（如果不存在）
RUN id -u node &>/dev/null || adduser -D -u 1000 node

# 创建必要目录
RUN mkdir -p /home/node/.n8n/nodes/node_modules && \
    chown -R node:node /home/node/.n8n

# 切换到 node 用户
USER node
WORKDIR /home/node/.n8n/nodes/node_modules

# 安装 Puppeteer 社区节点
RUN npm init -y && \
    npm install n8n-nodes-puppeteer \
    puppeteer-extra-plugin-user-preferences \
    puppeteer-extra-plugin-stealth \
    --legacy-peer-deps

WORKDIR /home/node

# 暴露端口
EXPOSE 5678

# 使用 tini 作为 init 进程
ENTRYPOINT ["/sbin/tini", "--"]

# 启动 n8n
CMD ["n8n", "start"]

# 标签
LABEL org.opencontainers.image.source="https://github.com/OWNER/n8n-puppeteer"
LABEL org.opencontainers.image.description="n8n with Puppeteer and Chromium support"
LABEL org.opencontainers.image.licenses="MIT"
