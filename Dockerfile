# ============================================================
# n8n-runners-puppeteer
# 基于 n8nio/runners:2.4.0，预装 Chromium + puppeteer-core
# ============================================================

FROM n8nio/runners:2.4.0-amd64

USER root

# 设置环境变量
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    CHROME_BIN=/usr/bin/chromium-browser \
    CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage"

# 第一步：恢复 apk-tools（n8n 2.x 镜像中被移除了）
# 注意：Alpine 版本和 apk-tools 版本需要匹配基础镜像
RUN wget -q https://dl-cdn.alpinelinux.org/alpine/v3.21/main/x86_64/apk-tools-static-2.14.6-r2.apk -O /tmp/apk-tools.apk && \
    tar -xzf /tmp/apk-tools.apk -C /tmp && \
    /tmp/sbin/apk.static add --no-cache apk-tools && \
    rm -rf /tmp/apk-tools.apk /tmp/sbin

# 第二步：安装 Chromium 及完整依赖
RUN apk update && apk add --no-cache \
    chromium \
    font-noto-cjk \
    font-noto-emoji \
    fontconfig \
    freetype \
    ttf-freefont \
    harfbuzz \
    nss \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# 验证 Chromium 安装
RUN chromium-browser --version

# 安装 puppeteer-core 到 JS task runner 环境
WORKDIR /opt/runners/task-runner-javascript
RUN pnpm add puppeteer-core

# 复制 allowlist 配置文件
COPY n8n-task-runners.json /etc/n8n-task-runners.json
RUN chmod 644 /etc/n8n-task-runners.json

# 切换回非 root 用户
USER runner

WORKDIR /opt/runners
