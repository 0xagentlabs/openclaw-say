# 项目分析报告: BankrBot/openclaw-skills

## 项目概览
- **项目地址**: https://github.com/BankrBot/openclaw-skills
- **项目描述**: Moltbot skill library for AI agents. Including polymarket, crypto trading, DeFi operations,  automation, and more. Open a PR to add skills. 
- **主要语言**: Shell
- **星标数**: 641
- **复刻数**: 190
- **开放问题**: 108
- **许可证**: None
- **最后更新**: 2026-02-13T22:11:04Z
- **主题标签**: 

## 一句话介绍
BankrBot/openclaw-skills 是一个具备自动化能力的 Shell 自主代理 / 任务自动化 项目，拥有 641 个星标。

## 核心亮点
自主学习能力

## 应用领域
自主代理 / 任务自动化

## 技术栈
- 技术栈未明确指定

## 核心特性
- 自主学习能力
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
./bankr
./bankr/references
./endaoment
./endaoment/references
./endaoment/scripts
./ens-primary-name
./ens-primary-name/scripts
./erc-8004
./erc-8004/references
./erc-8004/scripts
./onchainkit
./onchainkit/assets
./onchainkit/assets/templates
./onchainkit/references
./onchainkit/scripts
```

## 优势分析
- 持续增长 (641 ⭐)
- 活跃社区 (>190 复刻)

## 潜在不足
- 文档有限
- 缺少示例
- 无可见测试套件

## README预览
```markdown
# OpenClaw Skills Library

Pre-built capabilities for ai agents to interact with crypto infrastructure. Skills enable autonomous DeFi operations, token launches, onchain messaging, and protocol integrations through natural language interfaces.

Public repository of skills for [OpenClaw](https://github.com/BankrBot/openclaw-skills) (formerly Clawdbot) — including [Bankr](https://bankr.bot) skills and community-contributed skills from other providers.

## Quick Start
```bash
# Add this repo URL to OpenClaw to browse and install skills:
https://github.com/BankrBot/openclaw-skills
```

Skills are drop-in modules. No additional configuration required for basic usage.


## Available Skills

| Provider                   | Skill           | Description                                                                                               |
| -------------------------- | --------------- | --------------------------------------------------------------------------------------------------------- |
| [bankr](https://bankr.bot) | [bankr](bankr/) | Financial infrastructure for autonomous agents. Token launches, payment processing, trading, yield automation. Agents earn and spend independently. |
| [8004.org](https://8004.org) | [erc-8004](erc-8004/) | Ethereum agent registry using ERC-8004 standard. Mint agent NFTs, establish onchain identity, build reputation. |
| botchan                    | [botchan](botchan/) | Onchain messaging protocol on Base. Agent feeds, DMs, permanent data storage. |
| [Clanker](https://clanker.world) | [clanker](clanker/) | Deploy ERC20 tokens on Base and other EVM chains via Clanker SDK. |
| [Coinbase](https://onchainkit.xyz) | [onchainkit](onchainkit/) | Build onchain apps with React components from Coinbase's OnchainKit. |
| [Endaoment](https://endaoment.org) | [endaoment](endaoment/) | Donate to charities onchain via Endaoment. Supports Base, Ethereum, Optimism. |
| [ENS](https://ens.domains) | [ens-primary-name](ens-primary-name/) | Set your primary ENS name on Base and other L2s. |
| [qrcoin](https://qrcoin.fun) | [qrcoin](qrcoin/) | QR code auction platform on Base. Programmatic bidding for URL display. |
| [Veil Cash](https://veil.cash) | [veil](veil/) | Privacy and shielded transactions on Base via ZK proofs. |
| yoink                      | [yoink](yoink/) | Onchain capture-the-flag on Base. |
| base                       | —               | Planned                                                                                               |
| neynar                     | —               | Planned                                                                                               |
| zapper                     | —               | Planned                                                                                               |

## Structure

Each top-level directory is a provider. Each subdirectory within a provider is an installable skill containing a `SKILL.md` and other skill related files.

```
openclaw-skills/
├── bankr/
│   ├── SKILL.md
│   ├── references/
│   │   ├── token-trading.md
│   │   ├── leverage-trading.md
│   │   ├── polymarket.md
│   │   ├── automation.md
│   │   ├── token-deployment.md
│   │   └── ...
│   └── scripts/
│       └── bankr.sh
```

## 补充说明
- 文档完善度: 缺失或简单
- 测试覆盖度: 缺失或简单
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-14*
