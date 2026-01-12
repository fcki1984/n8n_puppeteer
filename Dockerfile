FROM node:20-alpine

# 安装 Chromium 和依赖 - 使用 Alpine 官方支持的包名
RUN apk update && apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    # 中文字体
    font-noto-cjk \
    # 其他工具
    git \
    tini

# 设置 Puppeteer 环境变量
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    N8N_COMMUNITY_PACKAGES_ENABLED=true \
    NODE_ENV=production

# 安装 n8n
RUN npm install -g n8n

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

LABEL org.opencontainers.image.source="https://github.com/OWNER/n8n-puppeteer"
LABEL org.opencontainers.image.description="n8n with Puppeteer and Chromium support"
