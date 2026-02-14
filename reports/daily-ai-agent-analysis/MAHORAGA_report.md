# 项目分析报告: ygwyg/MAHORAGA

## 项目概览
- **项目地址**: https://github.com/ygwyg/MAHORAGA
- **项目描述**: autonomous trading agent powered by social sentiment analysis and ai that learns, grows, and adapts
- **主要语言**: TypeScript
- **星标数**: 486
- **复刻数**: 141
- **开放问题**: 1
- **许可证**: NOASSERTION
- **最后更新**: 2026-02-13T19:25:00Z
- **主题标签**: 

## 一句话介绍
ygwyg/MAHORAGA 是一个具备自动化能力的 TypeScript 自主代理 / 任务自动化 项目，拥有 486 个星标。

## 核心亮点
自主学习能力

## 应用领域
自主代理 / 任务自动化

## 技术栈
- JavaScript/Node.js
- 依赖包: "@ai-sdk/anthropic": "^3.0.35",, "@ai-sdk/openai": "^3.0.25",, "openai": "^6.16.0",

## 核心特性
- 自主学习能力
- 检索增强生成(RAG)

## 扩展能力
低至中 - 代码中检测到扩展能力

## 执行流程解析
基于代码库分析，该项目的主要执行流程可能包括：
1. 初始化阶段：根据配置文件或命令行参数设置运行环境
2. 输入处理：接收用户输入或任务指令
3. 代理循环：执行AI推理、工具调用、行动规划等
4. 输出处理：生成响应或执行结果
5. 记忆/状态管理：更新内部状态或记忆系统

(具体执行流程需参考源代码实现)

## 仓库结构
```text
.
./src
./src/core
./src/durable-objects
./src/jobs
./src/lib
./src/mcp
./src/policy
./src/providers
./src/providers/alpaca
./src/providers/llm
./src/providers/news
./src/providers/social
./src/schemas
./src/storage
./src/storage/d1
./src/storage/kv
./src/storage/r2
./src/strategy
./src/strategy/default
```

## 优势分析
- 持续增长 (486 ⭐)
- 活跃社区 (>141 复刻)
- 良好文档
- 维护良好 (低开放问题数: 1)
- 许可证清晰 (NOASSERTION)

## 潜在不足
- 缺少示例
- 无可见测试套件

## README预览
```markdown
⚠️ **Warning:** This software is provided for educational and informational purposes only. Nothing in this repository constitutes financial, investment, legal, or tax advice.

# MAHORAGA

An autonomous, LLM-powered trading agent that runs 24/7 on Cloudflare Workers.

[![Discord](https://img.shields.io/discord/1467592472158015553?color=7289da&label=Discord&logo=discord&logoColor=white)](https://discord.gg/vMFnHe2YBh)

MAHORAGA monitors social sentiment from StockTwits and Reddit, uses AI (OpenAI, Anthropic, Google, xAI, DeepSeek via AI SDK) to analyze signals, and executes trades through Alpaca. It runs as a Cloudflare Durable Object with persistent state, automatic restarts, and 24/7 crypto trading support.

<img width="1278" height="957" alt="dashboard" src="https://github.com/user-attachments/assets/56473ab6-e2c6-45fc-9e32-cf85e69f1a2d" />

## Features

- **24/7 Operation** — Runs on Cloudflare Workers, no local machine required
- **Multi-Source Signals** — StockTwits, Reddit (4 subreddits), Twitter confirmation
- **Multi-Provider LLM** — OpenAI, Anthropic, Google, xAI, DeepSeek via AI SDK or Cloudflare AI Gateway
- **Crypto Trading** — Trade BTC, ETH, SOL around the clock
- **Options Support** — High-conviction options plays
- **Staleness Detection** — Auto-exit positions that lose momentum
- **Pre-Market Analysis** — Prepare trading plans before market open
- **Discord Notifications** — Get alerts on BUY signals
- **Fully Customizable** — Well-documented with `[TUNE]` and `[CUSTOMIZABLE]` markers

## Requirements

- Node.js 18+
- Cloudflare account (free tier works)
- Alpaca account (free, paper trading supported)
- LLM API key (OpenAI, Anthropic, Google, xAI, DeepSeek) or Cloudflare AI Gateway credentials

## Quick Start

### 1. Clone and install

```bash
git clone https://github.com/ygwyg/MAHORAGA.git
cd mahoraga
npm install
```

### 2. Create Cloudflare resources

```bash
# Create D1 database
npx wrangler d1 create mahoraga-db
# Copy the database_id to wrangler.jsonc

# Create KV namespace
npx wrangler kv namespace create CACHE
```

## 补充说明
- 文档完善度: 完整
- 测试覆盖度: 缺失或简单
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-14*
