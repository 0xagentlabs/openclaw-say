# 项目分析报告: snarktank/ralph

## 项目概览
- **项目地址**: https://github.com/snarktank/ralph
- **项目描述**: Ralph is an autonomous AI agent loop that runs repeatedly until all PRD items are complete. 
- **主要语言**: TypeScript
- **星标数**: 9430
- **复刻数**: 1105
- **开放问题**: 32
- **许可证**: MIT
- **最后更新**: 2026-02-05T06:15:25Z
- **主题标签**: 

## 一句话介绍
snarktank/ralph 是一个具备自动化能力的 TypeScript 自主代理 / 任务自动化 项目，拥有 9430 个星标。

## 核心亮点
自主学习能力

## 应用领域
自主代理 / 任务自动化

## 技术栈
- 技术栈未明确指定

## 核心特性
- 自主学习能力
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
./flowchart
./skills
./skills/prd
./skills/ralph
```

## 优势分析
- 极高人气 (9430 ⭐)
- 活跃社区 (>1105 复刻)
- 维护良好 (低开放问题数: 32)
- 许可证清晰 (MIT)

## 潜在不足
- 文档有限
- 缺少示例
- 无可见测试套件

## README预览
```markdown
# Ralph

![Ralph](ralph.webp)

Ralph is an autonomous AI agent loop that runs AI coding tools ([Amp](https://ampcode.com) or [Claude Code](https://docs.anthropic.com/en/docs/claude-code)) repeatedly until all PRD items are complete. Each iteration is a fresh instance with clean context. Memory persists via git history, `progress.txt`, and `prd.json`.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).

[Read my in-depth article on how I use Ralph](https://x.com/ryancarson/status/2008548371712135632)

## Prerequisites

- One of the following AI coding tools installed and authenticated:
  - [Amp CLI](https://ampcode.com) (default)
  - [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
- `jq` installed (`brew install jq` on macOS)
- A git repository for your project

## Setup

### Option 1: Copy to your project

Copy the ralph files into your project:

```bash
# From your project root
mkdir -p scripts/ralph
cp /path/to/ralph/ralph.sh scripts/ralph/

# Copy the prompt template for your AI tool of choice:
cp /path/to/ralph/prompt.md scripts/ralph/prompt.md    # For Amp
# OR
cp /path/to/ralph/CLAUDE.md scripts/ralph/CLAUDE.md    # For Claude Code

chmod +x scripts/ralph/ralph.sh
```

### Option 2: Install skills globally (Amp)

Copy the skills to your Amp or Claude config for use across all projects:

For AMP
```bash
cp -r skills/prd ~/.config/amp/skills/
cp -r skills/ralph ~/.config/amp/skills/
```

For Claude Code (manual)
```bash
cp -r skills/prd ~/.claude/skills/
```

## 补充说明
- 文档完善度: 缺失或简单
- 测试覆盖度: 缺失或简单
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-05*
