# 项目分析报告: qufei1993/skills-hub

## 项目概览
- **项目地址**: https://github.com/qufei1993/skills-hub
- **项目描述**: A cross-platform desktop app to manage Agent Skills in one place and sync them to multiple AI coding tools’ global skills directories — “Install once, sync everywhere”.
- **主要语言**: Rust
- **星标数**: 389
- **复刻数**: 45
- **开放问题**: 11
- **许可证**: MIT
- **最后更新**: 2026-02-14T02:48:24Z
- **主题标签**: 

## 一句话介绍
qufei1993/skills-hub 是一个具备自动化能力的 Rust 自主代理 / 任务自动化 项目，拥有 389 个星标。

## 核心亮点
活跃的开发维护

## 应用领域
自主代理 / 任务自动化

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
./docs
./docs/assets
./scripts
./src
./src/assets
./src/components
./src/components/skills
./src/i18n
./src/pages
```

## 优势分析
- 持续增长 (389 ⭐)
- 社区兴趣 (45 复刻)
- 良好文档
- 维护良好 (低开放问题数: 11)
- 许可证清晰 (MIT)

## 潜在不足
- 缺少示例
- 无可见测试套件

## README预览
```markdown
# Skills Hub (Tauri Desktop)

A cross-platform desktop app (Tauri + React) to manage Agent Skills in one place and sync them to multiple AI coding tools’ global skills directories (prefer symlink/junction, fallback to copy) — “Install once, sync everywhere”.

## Documentation

- English (default): `README.md` (this file)
- 中文：[`docs/README.zh.md`](docs/README.zh.md)

Design docs:

- System design (EN): [`docs/system-design.md`](docs/system-design.md)
- 系统设计（中文）：[`docs/system-design.zh.md`](docs/system-design.zh.md)

## Key Features

- Unified view: managed skills and per-tool activation status
- Onboarding migration: scan existing skills in installed tools, import into the Central Repo, and sync
- Import sources: local folder / Git URL (including multi-skill repo selection)
- Update: refresh from source; propagate updates to copy-mode targets
- New tool detection: detect newly installed tools and prompt to sync managed skills

![Skills Hub](docs/assets/home-example.png)

## Supported AI Coding Tools

| tool key | Display name | skills dir (relative to `~`) | detect dir (relative to `~`) |
| --- | --- | --- | --- |
| `cursor` | Cursor | `.cursor/skills` | `.cursor` |
| `claude_code` | Claude Code | `.claude/skills` | `.claude` |
| `codex` | Codex | `.codex/skills` | `.codex` |
| `opencode` | OpenCode | `.config/opencode/skills` | `.config/opencode` |
| `antigravity` | Antigravity | `.gemini/antigravity/global_skills` | `.gemini/antigravity` |
| `amp` | Amp | `.config/agents/skills` | `.config/agents` |
| `kimi_cli` | Kimi Code CLI | `.config/agents/skills` | `.config/agents` |
| `augment` | Augment | `.augment/rules` | `.augment` |
| `openclaw` | OpenClaw | `.moltbot/skills` | `.moltbot` |
| `cline` | Cline | `.cline/skills` | `.cline` |
| `codebuddy` | CodeBuddy | `.codebuddy/skills` | `.codebuddy` |
| `command_code` | Command Code | `.commandcode/skills` | `.commandcode` |
| `continue` | Continue | `.continue/skills` | `.continue` |
| `crush` | Crush | `.config/crush/skills` | `.config/crush` |
| `junie` | Junie | `.junie/skills` | `.junie` |
| `iflow_cli` | iFlow CLI | `.iflow/skills` | `.iflow` |
| `kiro_cli` | Kiro CLI | `.kiro/skills` | `.kiro` |
| `kode` | Kode | `.kode/skills` | `.kode` |
| `mcpjam` | MCPJam | `.mcpjam/skills` | `.mcpjam` |
| `mistral_vibe` | Mistral Vibe | `.vibe/skills` | `.vibe` |
| `mux` | Mux | `.mux/skills` | `.mux` |
| `openclaude` | OpenClaude IDE | `.openclaude/skills` | `.openclaude` |
```

## 补充说明
- 文档完善度: 完整
- 测试覆盖度: 缺失或简单
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-14*
