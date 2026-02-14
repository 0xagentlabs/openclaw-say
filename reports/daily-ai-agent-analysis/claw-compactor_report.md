# 项目分析报告: aeromomo/claw-compactor

## 项目概览
- **项目地址**: https://github.com/aeromomo/claw-compactor
- **项目描述**: 🦞 Claw Compactor — The 98% Crusher. Cut your AI agent token spend in half with 5 layered compression techniques.
- **主要语言**: Python
- **星标数**: 387
- **复刻数**: 34
- **开放问题**: 0
- **许可证**: MIT
- **最后更新**: 2026-02-14T07:23:49Z
- **主题标签**: 

## 一句话介绍
aeromomo/claw-compactor 是一个具备自动化能力的 Python 自主代理 / 任务自动化 项目，拥有 387 个星标。

## 核心亮点
长期记忆管理

## 应用领域
自主代理 / 任务自动化

## 技术栈
- Python (pyproject)
- 依赖包: 

## 核心特性
- 长期记忆管理

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
./references
./scripts
./scripts/lib
./tests
```

## 优势分析
- 持续增长 (387 ⭐)
- 社区兴趣 (34 复刻)
- 测试覆盖
- 维护良好 (低开放问题数: 0)
- 许可证清晰 (MIT)

## 潜在不足
- 文档有限
- 缺少示例

## README预览
```markdown
# Claw Compactor
![Claw Compactor Banner](assets/banner.png)

[![Build](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/aeromomo/claw-compactor) [![Release](https://img.shields.io/github/v/release/aeromomo/claw-compactor?color=blue)](https://github.com/aeromomo/claw-compactor/releases) [![Tests](https://img.shields.io/badge/tests-800%20passed-brightgreen)](https://github.com/aeromomo/claw-compactor) [![Python](https://img.shields.io/badge/python-3.9%2B-blue)](https://python.org) [![License](https://img.shields.io/badge/license-MIT-purple)](LICENSE) [![OpenClaw](https://img.shields.io/badge/OpenClaw-skill-orange)](https://openclaw.ai)

*"Cut your tokens. Keep your facts."*

**Cut your AI agent's token spend in half.** One command compresses your entire workspace — memory files, session transcripts, sub-agent context — using 5 layered compression techniques. Deterministic. Mostly lossless. No LLM required.

## Features
- **5 compression layers** working in sequence for maximum savings
- **Zero LLM cost** — all compression is rule-based and deterministic
- **Lossless roundtrip** for dictionary, RLE, and rule-based compression
- **~97% savings** on session transcripts via observation extraction
- **Tiered summaries** (L0/L1/L2) for progressive context loading
- **CJK-aware** — full Chinese/Japanese/Korean support
- **One command** (`full`) runs everything in optimal order

## 5 Compression Layers
| 1 | Rule engine | Dedup lines, strip markdown filler, merge sections | 4-8% | |
| 2 | Dictionary encoding | Auto-learned codebook, `$XX` substitution | 4-5% | |
| 3 | Observation compression | Session JSONL → structured summaries | ~97% | * |
| 4 | RLE patterns | Path shorthand (`$WS`), IP prefix, enum compaction | 1-2% | |
| 5 | Compressed Context Protocol | ultra/medium/light abbreviation | 20-60% | * |

\*Lossy techniques preserve all facts and decisions; only verbose formatting is removed.

## Quick Start
```bash
git clone https://github.com/aeromomo/claw-compactor.git
cd claw-compactor

# See how much you'd save (non-destructive)
python3 scripts/mem_compress.py /path/to/workspace benchmark

# Compress everything
python3 scripts/mem_compress.py /path/to/workspace full
```

**Requirements:** Python 3.9+. Optional: `pip install tiktoken` for exact token counts (falls back to heuristic).

## Architecture
┌─────────────────────────────────────────────────────────────┐
│ mem_compress.py │
│ (unified entry point) │
└──────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬────┘
 │ │ │ │ │ │ │ │
 ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼
 estimate compress dict dedup observe tiers audit optimize
 └──────┴──────┴──┬───┴──────┴──────┴──────┴──────┘
```

## 补充说明
- 文档完善度: 缺失或简单
- 测试覆盖度: 完整
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-14*
