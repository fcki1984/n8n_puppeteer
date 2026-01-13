# ============================================================
# n8n-runners-puppeteer
# 基于 n8nio/runners:2.4.0，预装 Chromium + puppeteer-core
# ============================================================

FROM n8nio/runners:2.4.0-amd64

# 切换到 root 安装系统依赖
USER root

# 设置环境变量
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    CHROME_BIN=/usr/bin/chromium-browser \
    CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage"

# 安装 Chromium 及完整依赖（Alpine 使用 apk）
RUN apk update && apk add --no-cache \
    # Chromium 浏览器
    chromium \
    # 字体
    font-noto-cjk \
    font-noto-emoji \
    fontconfig \
    freetype \
    ttf-freefont \
    # Chromium 运行时依赖
    harfbuzz \
    nss \
    # 其他工具
    ca-certificates \
    wget \
    && rm -rf /var/cache/apk/*

# 验证 Chromium 安装
RUN chromium-browser --version

# 安装 puppeteer-core 到 JS task runner 环境
WORKDIR /opt/runners/task-runner-javascript
RUN pnpm add puppeteer-core

# 复制 allowlist 配置文件
COPY n8n-task-runners.json /etc/n8n-task-runners.json

# 确保配置文件权限正确
RUN chmod 644 /etc/n8n-task-runners.json

# 切换回非 root 用户运行
USER runner

# 默认工作目录
WORKDIR /opt/runners
