# 项目分析报告: callstackincubator/agent-device

## 项目概览
- **项目地址**: https://github.com/callstackincubator/agent-device
- **项目描述**: CLI to control iOS and Android devices for AI agents
- **主要语言**: TypeScript
- **星标数**: 589
- **复刻数**: 39
- **开放问题**: 2
- **许可证**: MIT
- **最后更新**: 2026-02-14T04:21:57Z
- **主题标签**: agentic-ai, agents, automation, mobile, testing

## 一句话介绍
callstackincubator/agent-device 是一个具备自动化能力的 TypeScript 自主代理 / 任务自动化 项目，拥有 589 个星标。

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
./bin
./skills
./src
./src/core
./src/core/__tests__
./src/daemon
./src/daemon/handlers
./src/daemon/__tests__
./src/platforms
./src/platforms/android
./src/platforms/ios
./src/platforms/__tests__
./src/utils
./src/utils/__tests__
```

## 优势分析
- 持续增长 (589 ⭐)
- 社区兴趣 (39 复刻)
- 测试覆盖
- 维护良好 (低开放问题数: 2)
- 许可证清晰 (MIT)

## 潜在不足
- 文档有限
- 缺少示例

## README预览
```markdown
<a href="https://www.callstack.com/open-source?utm_campaign=generic&utm_source=github&utm_medium=referral&utm_content=agent-device" align="center">
  <picture>
    <img alt="agent-device" src="website/docs/public/agent-device-banner.jpg">
  </picture>
</a>

---

# agent-device

CLI to control iOS and Android devices for AI agents influenced by Vercel’s [agent-browser](https://github.com/vercel-labs/agent-browser). 

The project is in early development and considered experimental. Pull requests are welcome!

## Features
- Platforms: iOS (simulator + limited device support) and Android (emulator + device).
- Core commands: `open`, `back`, `home`, `app-switcher`, `press`, `long-press`, `focus`, `type`, `fill`, `scroll`, `scrollintoview`, `wait`, `alert`, `screenshot`, `close`, `reinstall`.
- Inspection commands: `snapshot` (accessibility tree).
- Device tooling: `adb` (Android), `simctl`/`devicectl` (iOS via Xcode).
- Minimal dependencies; TypeScript executed directly on Node 22+ (no build step).

## Install

```bash
npm install -g agent-device
```

Or use it without installing:

```bash
npx agent-device open SampleApp
```

## Quick Start

Use refs for agent-driven exploration and normal automation flows.

```bash
agent-device open Contacts --platform ios # creates session on iOS Simulator
agent-device snapshot
agent-device click @e5
agent-device fill @e6 "John"
agent-device fill @e7 "Doe"
agent-device click @e3
agent-device close
```

## CLI Usage

```bash
```

## 补充说明
- 文档完善度: 缺失或简单
- 测试覆盖度: 完整
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-14*
