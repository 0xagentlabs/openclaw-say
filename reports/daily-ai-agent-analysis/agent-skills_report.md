# 项目分析报告: supabase/agent-skills

## 项目概览
- **项目地址**: https://github.com/supabase/agent-skills
- **项目描述**: Agent Skills to help developers using AI agents with Supabase
- **主要语言**: TypeScript
- **星标数**: 1140
- **复刻数**: 66
- **开放问题**: 13
- **许可证**: None
- **最后更新**: 2026-02-08T08:53:30Z
- **主题标签**: ai, ai-agents, skills, supabase

## 一句话介绍
supabase/agent-skills 是一个具备自动化能力的 TypeScript 自主代理 / 任务自动化 项目，拥有 1140 个星标。

## 核心亮点
强大的扩展性

## 应用领域
自主代理 / 任务自动化

## 技术栈
- JavaScript/Node.js
- 依赖包: 

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
./assets
./packages
./packages/skills-build
./packages/skills-build/src
./skills
./skills/supabase-postgres-best-practices
./skills/supabase-postgres-best-practices/references
```

## 优势分析
- 显著人气 (1140 ⭐)
- 社区兴趣 (66 复刻)
- 测试覆盖
- 维护良好 (低开放问题数: 13)

## 潜在不足
- 文档有限
- 缺少示例

## README预览
```markdown
![Supabase Agent Skills](assets/og.png)

# Supabase Agent Skills


Agent Skills to help developers using AI agents with Supabase. Agent Skills are
folders of instructions, scripts, and resources that agents like Claude Code,
Cursor, Github Copilot, etc... can discover and use to do things more accurately
and efficiently.

The skills in this repo follow the [Agent Skills](https://agentskills.io/)
format.

## Installation

```bash
npx skills add supabase/agent-skills
```

### Claude Code Plugin

You can also install the skills in this repo as Claude Code plugins

```bash
/plugin marketplace add supabase/agent-skills
/plugin install postgres-best-practices@supabase-agent-skills
```

## Available Skills

<details>
<summary><strong>supabase-postgres-best-practices</strong></summary>

Postgres performance optimization guidelines from Supabase. Contains references
across 8 categories, prioritized by impact.

**Use when:**

- Writing SQL queries or designing schemas
- Implementing indexes or query optimization
- Reviewing database performance issues
- Configuring connection pooling or scaling
- Working with Row-Level Security (RLS)

**Categories covered:**

- Query Performance (Critical)
- Connection Management (Critical)
- Schema Design (High)
- Concurrency & Locking (Medium-High)
```

## 补充说明
- 文档完善度: 缺失或简单
- 测试覆盖度: 完整
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-08*
