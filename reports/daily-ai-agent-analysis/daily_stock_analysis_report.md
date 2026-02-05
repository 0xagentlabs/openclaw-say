# Analysis Report: ZhuLinsen/daily_stock_analysis

## Repository Overview
- **URL**: https://github.com/ZhuLinsen/daily_stock_analysis
- **Description**: LLM驱动的 A/H/美股智能分析器，多数据源行情 + 实时新闻 + Gemini 决策仪表盘 + 多渠道推送，零成本，纯白嫖，定时运行
- **Primary Language**: Python
- **Stars**: 9441
- **Forks**: 9894
- **Open Issues**: 24
- **License**: MIT
- **Last Updated**: 2026-02-05T06:03:27Z
- **Topics**: agent, ai, aigc, gemini, llm, quant, quantitative-trading, rag, stock

## Application Scope
Conversational AI / Chatbots

## Technology Stack
- Python
- Dependencies: openai>=1.0.0 # OpenAI 兼容 API（可选，支持 DeepSeek/通义千问等）
- Python (pyproject)
- Dependencies: 

## Extension Capabilities
Low to Medium - Extension capability detected in code

## Repository Structure
```text
.
./bot
./bot/commands
./bot/platforms
./data_provider
./docker
./docs
./docs/bot
./docs/docker
./sources
./src
./src/core
```

## Strengths
- High popularity (9441 ⭐)
- Active community (>9894 forks)
- Good documentation
- Test coverage
- Well maintained (low open issues: 24)
- Clear licensing (MIT)

## Potential Weaknesses
- Missing examples

## README Preview
```markdown
<div align="center">

# 📈 股票智能分析系统

[![GitHub stars](https://img.shields.io/github/stars/ZhuLinsen/daily_stock_analysis?style=social)](https://github.com/ZhuLinsen/daily_stock_analysis/stargazers)
[![CI](https://github.com/ZhuLinsen/daily_stock_analysis/actions/workflows/ci.yml/badge.svg)](https://github.com/ZhuLinsen/daily_stock_analysis/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-Ready-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/)

> 🤖 基于 AI 大模型的 A股/港股/美股自选股智能分析系统，每日自动分析并推送「决策仪表盘」到企业微信/飞书/Telegram/邮箱

[**功能特性**](#-功能特性) · [**快速开始**](#-快速开始) · [**推送效果**](#-推送效果) · [**完整指南**](docs/full-guide.md) · [**常见问题**](docs/FAQ.md) · [**更新日志**](docs/CHANGELOG.md)

简体中文 | [English](docs/README_EN.md) | [繁體中文](docs/README_CHT.md)

</div>

## 💖 赞助商 (Sponsors)
<div align="center">
  <a href="https://serpapi.com/baidu-search-api?utm_source=github_daily_stock_analysis" target="_blank">
    <img src="./sources/serpapi_banner_zh.png" alt="轻松抓取搜索引擎上的实时金融新闻数据 - SerpApi" height="160">
  </a>
</div>
<br>


## ✨ 功能特性

| 模块 | 功能 | 说明 |
|------|------|------|
| AI | 决策仪表盘 | 一句话核心结论 + 精确买卖点位 + 操作检查清单 |
| 分析 | 多维度分析 | 技术面 + 筹码分布 + 舆情情报 + 实时行情 |
| 市场 | 全球市场 | 支持 A股、港股、美股 |
| 复盘 | 大盘复盘 | 每日市场概览、板块涨跌、北向资金 |
| 推送 | 多渠道通知 | 企业微信、飞书、Telegram、钉钉、邮件、Pushover |
| 自动化 | 定时运行 | GitHub Actions 定时执行，无需服务器 |

### 技术栈与数据来源

| 类型 | 支持 |
|------|------|
| AI 模型 | Gemini（免费）、OpenAI 兼容、DeepSeek、通义千问、Claude、Ollama |
| 行情数据 | AkShare、Tushare、Pytdx、Baostock、YFinance |
| 新闻搜索 | Tavily、SerpAPI、Bocha |

### 内置交易纪律

| 规则 | 说明 |
```

## Additional Notes
- Documentation: Present
- Tests: Present
- Examples: Missing or minimal

---
*Analysis performed on 2026-02-05*
