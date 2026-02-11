# 项目分析报告: callstackincubator/agent-skills

## 项目概览
- **项目地址**: https://github.com/callstackincubator/agent-skills
- **项目描述**: A collection of agent-optimized React Native skills for AI coding assistants.
- **主要语言**: null
- **星标数**: 824
- **复刻数**: 42
- **开放问题**: 3
- **许可证**: MIT
- **最后更新**: 2026-02-11T00:25:44Z
- **主题标签**: 

## 一句话介绍
callstackincubator/agent-skills 是一个基于 null 的 对话式AI / 聊天机器人 项目，具有 824 个星标。

## 核心亮点
长期记忆管理

## 应用领域
对话式AI / 聊天机器人

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
./.claude
./.claude/skills
./.claude/skills/validate-skills
./docs
./skills
./skills/react-native-best-practices
./skills/react-native-best-practices/agents
./skills/react-native-best-practices/references
./skills/upgrading-react-native
./skills/upgrading-react-native/agents
./skills/upgrading-react-native/references
```

## 优势分析
- 持续增长 (824 ⭐)
- 社区兴趣 (42 复刻)
- 良好文档
- 维护良好 (低开放问题数: 3)
- 许可证清晰 (MIT)

## 潜在不足
- 缺少示例
- 无可见测试套件

## README预览
```markdown
# Agent Skills

A collection of agent-optimized skills for AI coding assistants. Skills provide structured, actionable instructions for domain-specific tasks.

## Available Skills

| Skill                                                                | Description                                             |
| -------------------------------------------------------------------- | ------------------------------------------------------- |
| [react-native-best-practices](./skills/react-native-best-practices/) | React Native optimization best practices from Callstack |
| [github](./skills/github/)                                           | GitHub workflow patterns for PRs, code review, branching |
| [upgrading-react-native](./skills/upgrading-react-native/)           | React Native upgrade workflow: templates, dependencies, and common pitfalls |

## React Native Best Practices

Performance optimization skills based on [**The Ultimate Guide to React Native Optimization**](https://www.callstack.com/ebooks/the-ultimate-guide-to-react-native-optimization) by [Callstack](https://www.callstack.com/).

Covers:

- **JavaScript/React**: Profiling, FPS, re-renders, lists, state management, animations
- **Native**: iOS/Android profiling, TTI, memory management, Turbo Modules
- **Bundling**: Bundle analysis, tree shaking, R8, app size optimization

### Quick Start

#### Install as Claude Code Plugin

**1. Add the marketplace:**
```bash
/plugin marketplace add callstackincubator/agent-skills
```

**2. Install the skill:**
```bash
/plugin install react-native-best-practices@callstack-agent-skills
```

Or use the interactive menu:
```bash
/plugin menu
```

**For local development:**
```bash
claude --plugin-dir ./path/to/agent-skills
```

Once installed, Claude will automatically use the React Native best practices skill when working on React Native projects.

#### Use with Other AI Assistants
```

## 补充说明
- 文档完善度: 完整
- 测试覆盖度: 缺失或简单
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-11*
