# n8n-runners-puppeteer

基于 `n8nio/runners:2.4.0` 的自定义镜像，预装 Chromium + puppeteer-core，用于在 n8n Code 节点中运行 Puppeteer 任务。

## 特性

- 基于官方 `n8nio/runners:2.4.0-amd64`
- 预装 Chromium 浏览器及完整依赖（字体、GTK、X11 等）
- 预装 `puppeteer-core` npm 包
- 预配置 allowlist（`n8n-task-runners.json`）
- 支持中文字体渲染

## 快速开始

### 1. 使用预构建镜像

```bash
docker pull ghcr.io/fcki1984/n8n-runners-puppeteer:2.4.0
