# 项目分析报告: coollabsio/jean

## 项目概览
- **项目地址**: https://github.com/coollabsio/jean
- **项目描述**: Your AI dev team, parallelized.
- **主要语言**: TypeScript
- **星标数**: 369
- **复刻数**: 26
- **开放问题**: 45
- **许可证**: Apache-2.0
- **最后更新**: 2026-02-14T05:24:22Z
- **主题标签**: agent, ai, claude-code, git, parallel, worktree

## 一句话介绍
coollabsio/jean 是一个基于 TypeScript 的 对话式AI / 聊天机器人 项目，具有 369 个星标。

## 核心亮点
活跃的开发维护

## 应用领域
对话式AI / 聊天机器人

## 技术栈
- JavaScript/Node.js
- 依赖包: 

## 核心特性
- 未识别出核心特性

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
./src/assets
./src/components
./src/components/dashboard
./src/fonts
./src/fonts/fira-code
./src/fonts/geist
./src/fonts/inter
./src/fonts/jetbrains-mono
./src/fonts/lato
./src/fonts/roboto
./src/fonts/source-code-pro
./src/hooks
./src/lib
./src/lib/commands
./src/services
./src/store
./src/types
./.vscode
```

## 优势分析
- 持续增长 (369 ⭐)
- 社区兴趣 (26 复刻)
- 良好文档
- 维护良好 (低开放问题数: 45)
- 许可证清晰 (Apache-2.0)

## 潜在不足
- 缺少示例
- 无可见测试套件

## README预览
```markdown
<div align="center">

# Jean

A desktop AI assistant for managing multiple projects, worktrees, and chat sessions with Claude CLI.

Tauri v2 · React 19 · Rust · TypeScript · Tailwind CSS v4 · shadcn/ui v4 · Zustand v5 · TanStack Query · CodeMirror 6 · xterm.js

</div>

## About the Project

Jean is a native desktop app built with Tauri that gives you a powerful interface for working with Claude CLI across multiple projects. It manages git worktrees, chat sessions, terminals, and GitHub integrations — all in one place.

No vendor lock-in. Everything runs locally on your machine with your own Claude CLI installation.

For more information, take a look at [jean.build](https://jean.build).

## Screenshots

<table>
<tr>
<td><img src="screenshots/SCR-20260209-nigu.png" width="400" alt="Main Interface" /></td>
<td><img src="screenshots/SCR-20260209-ninl.png" width="400" alt="Development Mode" /></td>
</tr>
<tr>
<td><img src="screenshots/SCR-20260209-niug.png" width="400" alt="Diff View" /></td>
<td><img src="screenshots/SCR-20260209-njel.png" width="400" alt="Plan Mode" /></td>
</tr>
</table>

## Features

- **Project & Worktree Management** — Multi-project support, git worktree automation (create, archive, restore, delete), custom project avatars
- **Session Management** — Multiple sessions per worktree, execution modes (Plan, Build, Yolo), archiving, recovery, auto-naming, canvas views
- **AI Chat (Claude CLI)** — Model selection (Opus, Sonnet, Haiku), thinking/effort levels, MCP server support, file mentions, image support, custom system prompts
- **Magic Commands** — Investigate issues/PRs/workflows, code review with finding tracking, AI commit messages, PR content generation, merge conflict resolution, release notes
- **GitHub Integration** — Issue & PR investigation, checkout PRs as worktrees, auto-archive on PR merge, workflow investigation
- **Developer Tools** — Integrated terminal, open in editor (VS Code, Cursor, Xcode), git status, diff viewer (unified & side-by-side), file tree with preview
- **Remote Access** — Built-in HTTP server with WebSocket support, token-based auth, web browser access
- **Customization** — Themes (light/dark/system), custom fonts, customizable AI prompts, configurable keybindings

## Installation

Download the latest version from the [GitHub Releases](https://github.com/coollabsio/jean/releases) page or visit [jean.build](https://jean.build).

### Building from Source

Prerequisites:
- [Node.js](https://nodejs.org/)
```

## 补充说明
- 文档完善度: 完整
- 测试覆盖度: 缺失或简单
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-14*
