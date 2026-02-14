# 项目分析报告: rivet-dev/sandbox-agent

## 项目概览
- **项目地址**: https://github.com/rivet-dev/sandbox-agent
- **项目描述**: Run Coding Agents in Sandboxes. Control Them Over HTTP. Supports Claude Code, Codex, OpenCode, and Amp.
- **主要语言**: Rust
- **星标数**: 812
- **复刻数**: 54
- **开放问题**: 61
- **许可证**: Apache-2.0
- **最后更新**: 2026-02-14T05:43:57Z
- **主题标签**: agent, ai, amp, claude, claude-code, codex, daytona, e2b, opencode, sandbox

## 一句话介绍
rivet-dev/sandbox-agent 是一个具备自动化能力的 Rust 自主代理 / 任务自动化 项目，拥有 812 个星标。

## 核心亮点
检索增强生成(RAG)

## 应用领域
自主代理 / 任务自动化

## 技术栈
- JavaScript/Node.js
- 依赖包: 
- Rust

## 核心特性
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
./.agents
./.agents/skills
./.agents/skills/agent-browser
./examples
./examples/persist-postgres
./gigacode
./gigacode/src
./research
./research/acp
./research/acp/missing-features-spec
./research/agents
./research/opencode-compat
./research/opencode-compat/snapshots
./research/specs
```

## 优势分析
- 持续增长 (812 ⭐)
- 社区兴趣 (54 复刻)
- 良好文档
- 丰富示例
- 许可证清晰 (Apache-2.0)

## 潜在不足
- 无可见测试套件

## README预览
```markdown
<p align="center">
  <img src=".github/media/banner.png" alt="Sandbox Agent SDK" />
</p>

<h3 align="center">Run Coding Agents in Sandboxes. Control Them Over HTTP.</h3>

<p align="center">
  A server that runs inside your sandbox. Your app connects remotely to control Claude Code, Codex, OpenCode, Cursor, Amp, or Pi — streaming events, handling permissions, managing sessions.
</p>

<p align="center">
  <a href="https://sandboxagent.dev/docs">Documentation</a> — <a href="https://sandboxagent.dev/docs/api-reference">API Reference</a> — <a href="https://rivet.dev/discord">Discord</a>
</p>

<p align="center">
  <em><strong>Experimental:</strong> <a href="./gigacode/">Gigacode</a> — use OpenCode's TUI with any coding agent.</em>
</p>

## Why Sandbox Agent?

Running coding agents remotely is hard. Existing SDKs assume local execution, SSH breaks TTY handling and streaming, and every agent has a different API. Building from scratch means reimplementing everything for each coding agent.

Sandbox Agent solves three problems:

1. **Coding agents need sandboxes** — You can't let AI execute arbitrary code on your production servers. Coding agents need isolated environments, but existing SDKs assume local execution. Sandbox Agent is a server that runs inside the sandbox and exposes HTTP/SSE.

2. **Every coding agent is different** — Claude Code, Codex, OpenCode, Cursor, Amp, and Pi each have proprietary APIs, event formats, and behaviors. Swapping agents means rewriting your integration. Sandbox Agent provides one HTTP API — write your code once, swap agents with a config change.

3. **Sessions are ephemeral** — Agent transcripts live in the sandbox. When the process ends, you lose everything. Sandbox Agent streams events in a universal schema to your storage. Persist to Postgres, ClickHouse, or [Rivet](https://rivet.dev). Replay later, audit everything.

## Features

- **Universal Agent API**: Single interface to control Claude Code, Codex, OpenCode, Cursor, Amp, and Pi with full feature coverage
- **Universal Session Schema**: Standardized schema that normalizes all agent event formats for storage and replay
- **Runs Inside Any Sandbox**: Lightweight static Rust binary. One curl command to install inside E2B, Daytona, Vercel Sandboxes, or Docker
- **Server or SDK Mode**: Run as an HTTP server or embed with the TypeScript SDK
- **OpenAPI Spec**: [Well documented](https://sandboxagent.dev/docs/api-reference) and easy to integrate from any language
- **OpenCode SDK & UI Support** *(Experimental)*: [Connect OpenCode CLI, SDK, or web UI](https://sandboxagent.dev/docs/opencode-compatibility) to control agents through familiar OpenCode tooling

## Architecture

![Agent Architecture Diagram](./.github/media/agent-diagram.gif)

The Sandbox Agent acts as a universal adapter between your client application and various coding agents. Each agent has its own adapter that handles the translation between the universal API and the agent-specific interface.

- **Embedded Mode**: Runs agents locally as subprocesses
- **Server Mode**: Runs as HTTP server from any sandbox provider

[Architecture documentation](https://sandboxagent.dev/docs)
```

## 补充说明
- 文档完善度: 完整
- 测试覆盖度: 缺失或简单
- 示例丰富度: 完整

---
*分析时间: 2026-02-14*
