# 项目分析报告: six2dez/burp-ai-agent

## 项目概览
- **项目地址**: https://github.com/six2dez/burp-ai-agent
- **项目描述**: Burp Suite extension that adds built-in MCP tooling, AI-assisted analysis, privacy controls, passive and active scanning and more
- **主要语言**: Kotlin
- **星标数**: 610
- **复刻数**: 99
- **开放问题**: 0
- **许可证**: MIT
- **最后更新**: 2026-02-13T13:50:22Z
- **主题标签**: ai, appsec, bugbounty, burp, burp-extensions, burp-plugin, burp-suite, hacking, kotlin, llm, mcp, pentesting, security, web-security

## 一句话介绍
six2dez/burp-ai-agent 是一个基于 Kotlin 的 对话式AI / 聊天机器人 项目，具有 610 个星标。

## 核心亮点
自主学习能力

## 应用领域
对话式AI / 聊天机器人

## 技术栈
- 技术栈未明确指定

## 核心特性
- 自主学习能力

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
./gradle
./gradle/wrapper
./screenshots
./src
./src/main
./src/main/kotlin
./src/main/resources
./src/test
./src/test/kotlin
```

## 优势分析
- 持续增长 (610 ⭐)
- 社区兴趣 (99 复刻)
- 良好文档
- 维护良好 (低开放问题数: 0)
- 许可证清晰 (MIT)

## 潜在不足
- 缺少示例
- 无可见测试套件

## README预览
```markdown
# Burp AI Agent

**The bridge between Burp Suite and modern AI.**

<!-- screenshot: main extension tab with chat and settings visible -->
![Burp AI Agent Screenshot](screenshots/main-tab.png)

Burp AI Agent is an extension for Burp Suite that integrates AI into your security workflow. Use local models or cloud providers, connect external AI agents via MCP, and let passive/active scanners find vulnerabilities while you focus on manual testing.

## Highlights

- **7 AI Backends** — Ollama, LM Studio, Generic OpenAI-compatible, Gemini CLI, Claude CLI, Codex CLI, OpenCode CLI.
- **53+ MCP Tools** — Let Claude Desktop (or any MCP client) drive Burp autonomously.
- **62 Vulnerability Classes** — Passive and Active AI scanners across injection, auth, crypto, and more.
- **3 Privacy Modes** — STRICT / BALANCED / OFF. Redact sensitive data before it leaves Burp.
- **Audit Logging** — JSONL with SHA-256 integrity hashing for compliance.

## Quick Start

### 1. Install

Download the latest JAR from [Releases](https://github.com/six2dez/burp-ai-agent/releases), or build from source (Java 21):

```bash
git clone https://github.com/six2dez/burp-ai-agent.git
cd burp-ai-agent
JAVA_HOME=/path/to/jdk-21 ./gradlew clean shadowJar
# Output: build/libs/Burp-AI-Agent-<version>.jar
```

### 2. Load into Burp

1. Open Burp Suite (Community or Professional).
2. Go to **Extensions > Installed > Add**.
3. Select **Java** as extension type and choose the `.jar` file.

<!-- screenshot: Burp Extensions > Add dialog with the JAR loaded -->
![Load Extension](screenshots/burp-extensions-add.png)

### 3. Agent Profiles

The extension auto-installs the bundled profiles into `~/.burp-ai-agent/AGENTS/` on first run.
Drop additional `*.md` files in that directory to add custom profiles.

### 4. Configure a Backend

Open the **AI Agent** tab and go to **Settings**. Pick a backend:

| Backend | Type | Setup |
| :--- | :--- | :--- |
```

## 补充说明
- 文档完善度: 完整
- 测试覆盖度: 缺失或简单
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-14*
