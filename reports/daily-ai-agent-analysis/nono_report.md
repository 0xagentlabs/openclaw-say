# 项目分析报告: always-further/nono

## 项目概览
- **项目地址**: https://github.com/always-further/nono
- **项目描述**: Secure, kernel-enforced sandbox for AI agents, MCP and LLM workloads. Capability-based isolation with secure key management and blocking of destructive actions in a zero-trust environment.
- **主要语言**: Rust
- **星标数**: 347
- **复刻数**: 20
- **开放问题**: 25
- **许可证**: Apache-2.0
- **最后更新**: 2026-02-14T06:22:42Z
- **主题标签**: agent, agentic-ai, ai-agent-security, ai-agents, ai-security, code-execution, cybersecurity, isolation, linux-security, llm, mcp, open-source, prompt-injection, runtime-security, sandbox, security, sigstore, supply-chain-security, zero-trust

## 一句话介绍
always-further/nono 是一个基于 Rust 的 对话式AI / 聊天机器人 项目，具有 347 个星标。

## 核心亮点
检索增强生成(RAG)

## 应用领域
对话式AI / 聊天机器人

## 技术栈
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
./assets
./docs
./docs/assets
./docs/clients
./docs/development
./docs/getting_started
./docs/security
./docs/usage
./scripts
./src
./src/config
./src/profile
./src/sandbox
```

## 优势分析
- 持续增长 (347 ⭐)
- 社区兴趣 (20 复刻)
- 良好文档
- 测试覆盖
- 维护良好 (低开放问题数: 25)
- 许可证清晰 (Apache-2.0)

## 潜在不足
- 缺少示例

## README预览
```markdown
<div align="center">

<img src="assets/nono-logo.png" alt="nono logo" width="600"/>

**The Swiss Army knife of agent security**

<a href="https://discord.gg/pPcjYzGvbS">
  <img src="https://img.shields.io/badge/Chat-Join%20Discord-7289da?style=for-the-badge&logo=discord&logoColor=white" alt="Join Discord"/>
</a>

<p>
  <a href="https://opensource.org/licenses/Apache-2.0">
    <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License"/>
  </a>
  <a href="https://github.com/always-further/nono/actions/workflows/ci.yml">
    <img src="https://github.com/always-further/nono/actions/workflows/ci.yml/badge.svg" alt="CI Status"/>
  </a>
  <a href="https://discord.gg/pPcjYzGvbS">
    <img src="https://img.shields.io/discord/1384081906773131274?color=7289da&label=Discord&logo=discord&logoColor=white" alt="Discord"/>
  </a>
  <a href="https://docs.nono.sh">
    <img src="https://img.shields.io/badge/Docs-docs.nono.sh-green.svg" alt="Documentation"/>
  </a>
</p>

</div>

> [!WARNING]
> This is an early alpha release that has not undergone comprehensive security audit
> We are also in the process of porting the core to its own library. We still welcome PR's, but note a bit of cat herding maybe involved if the change touches a lot of files.

**nono** is a secure, kernel-enforced capability shell for running AI agents and any POSIX style process. Unlike policy-based sandboxes that intercept and filter operations, nono leverages OS security primitives (Landlock on Linux, Seatbelt on macOS) to create an environment where unauthorized operations are structurally impossible.

**nono** also provides protections against destructive commands (rm -rf ..) and provides a way to securely store API keys, tokens, secrets that are injected securely into the process at run time.

> [!NOTE]
> NEWS! Work is underway to seperate the core functionality into a library with C bindings, which will allow other projects to integrate nono's security primitives directly without shelling out to the CLI. This will also allow us to expand support to other platforms like Windows. Initial languages will be Python, Typescript, and of course Rust. Following up with Go, Java, and C# bindings.

Many more features are planned, see the Roadmap below. 

## Quick Start

### MacOS

```bash
brew tap always-further/nono 
brew install nono
```
> [!NOTE]
> The package is not in homebrew official yet, [give us a star](https://github.com/always-further/nono) to help raise our profile for when request approval
```

## 补充说明
- 文档完善度: 完整
- 测试覆盖度: 完整
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-14*
