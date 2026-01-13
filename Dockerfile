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

# 第一步：检测 Alpine 版本并恢复 apk-tools
# 动态获取版本，避免硬编码导致 404
RUN ALPINE_VERSION=$(cat /etc/alpine-release | cut -d'.' -f1,2) && \
    echo "Detected Alpine version: ${ALPINE_VERSION}" && \
    # 获取 apk-tools-static 包列表页面，提取最新版本
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="x86_64"; fi && \
    APK_TOOLS_URL="https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main/${ARCH}/" && \
    echo "Fetching apk-tools-static from: ${APK_TOOLS_URL}" && \
    # 下载 apk-tools-static
    APK_STATIC_PKG=$(wget -qO- "${APK_TOOLS_URL}" | grep -o 'apk-tools-static-[^"]*\.apk' | head -1) && \
    echo "Found package: ${APK_STATIC_PKG}" && \
    wget -q "${APK_TOOLS_URL}${APK_STATIC_PKG}" -O /tmp/apk-tools-static.apk && \
    # 解压并安装
    tar -xzf /tmp/apk-tools-static.apk -C /tmp && \
    /tmp/sbin/apk.static add --no-cache --allow-untrusted apk-tools && \
    rm -rf /tmp/apk-tools-static.apk /tmp/sbin /tmp/usr

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
