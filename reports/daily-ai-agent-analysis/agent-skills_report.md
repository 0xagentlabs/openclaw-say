# 项目分析报告: WordPress/agent-skills

## 项目概览
- **项目地址**: https://github.com/WordPress/agent-skills
- **项目描述**: Expert-level WordPress knowledge for AI coding assistants - blocks, themes, plugins, and best practices
- **主要语言**: JavaScript
- **星标数**: 601
- **复刻数**: 82
- **开放问题**: 13
- **许可证**: NOASSERTION
- **最后更新**: 2026-02-14T00:19:14Z
- **主题标签**: 

## 一句话介绍
WordPress/agent-skills 是一个具备自动化能力的 JavaScript 自主代理 / 任务自动化 项目，拥有 601 个星标。

## 核心亮点
强大的扩展性

## 应用领域
自主代理 / 任务自动化

## 技术栈
- 技术栈未明确指定

## 核心特性
- 未识别出核心特性

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
./skills
./skills/wordpress-router
./skills/wordpress-router/references
./skills/wp-block-development
./skills/wp-block-development/references
./skills/wp-block-development/scripts
./skills/wp-interactivity-api
./skills/wp-performance
./skills/wp-performance/references
./skills/wp-performance/scripts
./skills/wp-phpstan
./skills/wp-phpstan/references
./skills/wp-phpstan/scripts
./skills/wp-wpcli-and-ops
./skills/wp-wpcli-and-ops/references
./skills/wp-wpcli-and-ops/scripts
```

## 优势分析
- 持续增长 (601 ⭐)
- 社区兴趣 (82 复刻)
- 良好文档
- 维护良好 (低开放问题数: 13)
- 许可证清晰 (NOASSERTION)

## 潜在不足
- 缺少示例
- 无可见测试套件

## README预览
```markdown
# Agent Skills for WordPress

**Teach AI coding assistants how to build WordPress the right way.**

Agent Skills are portable bundles of instructions, checklists, and scripts that help AI assistants (Claude, Copilot, Codex, Cursor, etc.) understand WordPress development patterns, avoid common mistakes, and follow best practices.

> **AI Authorship Disclosure:** These skills were generated using GPT-5.2 Codex (High Reasoning) from official Gutenberg and WordPress documentation, then reviewed and edited by WordPress contributors. We tested skills with AI assistants and iterated based on results. This is v1, and skills will improve as the community uses them and contributes fixes. See [docs/ai-authorship.md](docs/ai-authorship.md) for details. ([WordPress AI Guidelines](https://make.wordpress.org/ai/handbook/ai-guidelines/))

## Why Agent Skills?

AI coding assistants are powerful, but they often:
- Generate outdated WordPress patterns (pre-Gutenberg, pre-block themes)
- Miss critical security considerations in plugin development
- Skip proper block deprecations, causing "Invalid block" errors
- Ignore existing tooling in your repo

Agent Skills solve this by giving AI assistants **expert-level WordPress knowledge** in a format they can actually use.

## Available Skills

| Skill | What it teaches |
|-------|-----------------|
| **wordpress-router** | Classifies WordPress repos and routes to the right workflow |
| **wp-project-triage** | Detects project type, tooling, and versions automatically |
| **wp-block-development** | Gutenberg blocks: `block.json`, attributes, rendering, deprecations |
| **wp-block-themes** | Block themes: `theme.json`, templates, patterns, style variations |
| **wp-plugin-development** | Plugin architecture, hooks, settings API, security |
| **wp-rest-api** | REST API routes/endpoints, schema, auth, and response shaping |
| **wp-interactivity-api** | Frontend interactivity with `data-wp-*` directives and stores |
| **wp-abilities-api** | Capability-based permissions and REST API authentication |
| **wp-wpcli-and-ops** | WP-CLI commands, automation, multisite, search-replace |
| **wp-performance** | Profiling, caching, database optimization, Server-Timing |
| **wp-phpstan** | PHPStan static analysis for WordPress projects (config, baselines, WP-specific typing) |
| **wp-playground** | WordPress Playground for instant local environments |
| **wpds** | WordPress Design System |

## Quick Start

### Install globally for Claude Code

```bash
# Clone agent-skills
git clone https://github.com/WordPress/agent-skills.git
cd agent-skills

# Build the distribution
node shared/scripts/skillpack-build.mjs --clean

# Install all skills globally (available across all projects)
node shared/scripts/skillpack-install.mjs --global
```

## 补充说明
- 文档完善度: 完整
- 测试覆盖度: 缺失或简单
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-14*
