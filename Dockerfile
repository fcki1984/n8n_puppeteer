FROM node:20-alpine

# 安装 Chromium 和依赖
RUN apk update && apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    font-noto-cjk \
    git \
    tini

# 设置 Puppeteer 环境变量
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    # 添加默认启动参数
    CHROMIUM_FLAGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu --disable-software-rasterizer --disable-extensions" \
    N8N_COMMUNITY_PACKAGES_ENABLED=true \
    NODE_ENV=production

# 安装 n8n
RUN npm install -g n8n

# 创建必要目录结构
RUN mkdir -p /home/node/.n8n/nodes && \
    chown -R node:node /home/node/.n8n

# 切换到 node 用户
USER node

# 在 nodes 目录下创建 package.json 并安装节点
WORKDIR /home/node/.n8n/nodes
RUN echo '{"name": "n8n-custom-nodes", "version": "1.0.0"}' > package.json && \
    npm install n8n-nodes-puppeteer \
    puppeteer-extra-plugin-user-preferences \
    puppeteer-extra-plugin-stealth \
    --legacy-peer-deps

WORKDIR /home/node

EXPOSE 5678

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]

LABEL org.opencontainers.image.source="https://github.com/OWNER/n8n-puppeteer"
LABEL org.opencontainers.image.description="n8n with Puppeteer and Chromium support"
