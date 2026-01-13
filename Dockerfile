# ============================================================
# n8n-runners-puppeteer
# 基于 n8nio/runners:2.4.0，预装 Chromium + puppeteer-core
# ============================================================

FROM n8nio/runners:2.4.0-amd64

# 切换到 root 安装系统依赖
USER root

# 设置环境变量
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    CHROME_BIN=/usr/bin/chromium \
    CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage"

# 安装 Chromium 及完整依赖（字体、GTK、X11 等）
# n8nio/runners:2.4.0-amd64 基于 Debian
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Chromium 浏览器
    chromium \
    # 基础字体
    fonts-liberation \
    fonts-noto-color-emoji \
    fonts-noto-cjk \
    fonts-freefont-ttf \
    # Chromium 运行时依赖
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxshmfence1 \
    libxss1 \
    libxtst6 \
    xdg-utils \
    # 其他可能需要的工具
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 验证 Chromium 安装
RUN chromium --version

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
