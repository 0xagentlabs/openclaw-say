# 项目分析报告: yohey-w/multi-agent-shogun

## 项目概览
- **项目地址**: https://github.com/yohey-w/multi-agent-shogun
- **项目描述**: Samurai-inspired multi-agent system for Claude Code. Orchestrate parallel AI tasks via tmux with shogun → karo → ashigaru hierarchy.
- **主要语言**: Shell
- **星标数**: 819
- **复刻数**: 185
- **开放问题**: 0
- **许可证**: MIT
- **最后更新**: 2026-02-11T07:48:02Z
- **主题标签**: ai-agent, anthropic, automation, claude-code, llm, multi-agent, parallel-processing, samurai, shogun, tmux

## 一句话介绍
yohey-w/multi-agent-shogun 是一个具备自动化能力的 Shell 自主代理 / 任务自动化 项目，拥有 819 个星标。

## 核心亮点
长期记忆管理

## 应用领域
自主代理 / 任务自动化

## 技术栈
- 技术栈未明确指定

## 核心特性
- 长期记忆管理

## 扩展能力
高 - 具备专门的插件/扩展系统

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
./agents
./agents/default
./.claude
./config
./context
./docs
./images
./images/screenshots
./images/screenshots/hero
./images/screenshots/masked
./lib
./saytask
./scripts
./skills
./skills/skill-creator
./templates
```

## 优势分析
- 持续增长 (819 ⭐)
- 活跃社区 (>185 复刻)
- 良好文档
- 测试覆盖
- 维护良好 (低开放问题数: 0)
- 许可证清晰 (MIT)

## 潜在不足
- 缺少示例

## README预览
```markdown
<div align="center">

# multi-agent-shogun

**Command your AI army like a feudal warlord.**

Run 10 AI coding agents in parallel — **Claude Code, OpenAI Codex, GitHub Copilot, Kimi Code** — orchestrated through a samurai-inspired hierarchy with zero coordination overhead.

**Talk Coding, not Vibe Coding. Speak to your phone, AI executes.**

[![GitHub Stars](https://img.shields.io/github/stars/yohey-w/multi-agent-shogun?style=social)](https://github.com/yohey-w/multi-agent-shogun)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![v3.0 Multi-CLI](https://img.shields.io/badge/v3.0-Multi--CLI_Support-ff6600?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiI+PHRleHQgeD0iMCIgeT0iMTIiIGZvbnQtc2l6ZT0iMTIiPuKalTwvdGV4dD48L3N2Zz4=)](https://github.com/yohey-w/multi-agent-shogun)
[![Shell](https://img.shields.io/badge/Shell%2FBash-100%25-green)]()

[English](README.md) | [日本語](README_ja.md)

</div>

<p align="center">
  <img src="images/screenshots/hero/latest-translucent-20260210-190453.png" alt="Latest translucent command session in the Shogun pane" width="940">
</p>

<p align="center">
  <img src="images/screenshots/hero/latest-translucent-20260208-084602.png" alt="Quick natural-language command in the Shogun pane" width="420">
  <img src="images/company-creed-all-panes.png" alt="Karo and Ashigaru panes reacting in parallel" width="520">
</p>

<p align="center"><i>One Karo (manager) coordinating 8 Ashigaru (workers) — real session, no mock data.</i></p>

---

## What is this?

**multi-agent-shogun** is a system that runs multiple AI coding CLI instances simultaneously, orchestrating them like a feudal Japanese army. Supports **Claude Code**, **OpenAI Codex**, **GitHub Copilot**, and **Kimi Code**.

**Why use it?**
- One command spawns 8 AI workers executing in parallel
- Zero wait time — give your next order while tasks run in the background
- AI remembers your preferences across sessions (Memory MCP)
- Real-time progress on a dashboard

```
        You (上様 / The Lord)
             │
             ▼  Give orders
      ┌─────────────┐
      │   SHOGUN    │  ← Receives your command, delegates instantly
      └──────┬──────┘
             │  YAML + tmux
```

## 补充说明
- 文档完善度: 完整
- 测试覆盖度: 完整
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-11*
