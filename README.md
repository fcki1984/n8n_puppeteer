# n8n with Puppeteer

n8n Docker 镜像，预装 Puppeteer 节点和 Chromium 浏览器。

## 功能

- ✅ 基于官方 n8n 镜像
- ✅ 预装 Chromium 浏览器
- ✅ 预装 n8n-nodes-puppeteer 节点
- ✅ 支持 Stealth 模式
- ✅ 支持中文字体

## 使用方法

### Docker Compose

```yaml
version: '3.8'

services:
  n8n:
    # 替换 OWNER 为你的 GitHub 用户名
    image: ghcr.io/fcki1984/n8n-puppeteer:latest
    container_name: n8n-puppeteer
    restart: always
    ports:
      - "5678:5678"
    environment:
      # 时区设置
      - GENERIC_TIMEZONE=Asia/Shanghai
      - TZ=Asia/Shanghai
      # Puppeteer 设置
      - PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
      - PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
      # n8n 设置
      - N8N_COMMUNITY_PACKAGES_ENABLED=true
      - N8N_REINSTALL_MISSING_PACKAGES=true
    volumes:
      - n8n_data:/home/node/.n8n
    # 给 Chromium 分配共享内存
    shm_size: '2gb'
    security_opt:
      - no-new-privileges:true

volumes:
  n8n_data:
    driver: local
