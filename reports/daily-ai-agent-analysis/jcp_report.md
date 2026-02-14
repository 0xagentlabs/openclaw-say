# 项目分析报告: run-bigpig/jcp

## 项目概览
- **项目地址**: https://github.com/run-bigpig/jcp
- **项目描述**: 韭菜盘 (JCP AI) - AI 驱动的智能A股分析系统，基于 Wails + Go + React，支持多 Agent 协作分析
- **主要语言**: Go
- **星标数**: 690
- **复刻数**: 158
- **开放问题**: 1
- **许可证**: NOASSERTION
- **最后更新**: 2026-02-13T16:50:58Z
- **主题标签**: 

## 一句话介绍
run-bigpig/jcp 是一个具备自动化能力的 Go 自主代理 / 任务自动化 项目，拥有 690 个星标。

## 核心亮点
活跃的开发维护

## 应用领域
自主代理 / 任务自动化

## 技术栈
- Go

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
./frontend
./frontend/src
./frontend/src/assets
./frontend/src/components
./frontend/src/contexts
./frontend/src/hooks
./frontend/src/services
./frontend/wailsjs
./frontend/wailsjs/go
./frontend/wailsjs/runtime
./image
```

## 优势分析
- 持续增长 (690 ⭐)
- 活跃社区 (>158 复刻)
- 维护良好 (低开放问题数: 1)
- 许可证清晰 (NOASSERTION)

## 潜在不足
- 文档有限
- 缺少示例
- 无可见测试套件

## README预览
```markdown
# 韭菜盘 (JCP AI)

> AI 驱动的智能股票分析系统 - 多 Agent 协作，让投资决策更智能

[![Go Version](https://img.shields.io/badge/Go-1.24-blue.svg)](https://golang.org)
[![React](https://img.shields.io/badge/React-18-61dafb.svg)](https://reactjs.org)
[![Wails](https://img.shields.io/badge/Wails-v2-red.svg)](https://wails.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-0.2.0-orange.svg)](https://github.com/run-bigpig/jcp/releases)

## 项目简介

韭菜盘是一款基于 Wails 框架开发的跨平台桌面应用，集成了多个 AI 大模型（OpenAI、Google Gemini、DeepSeek、Kimi、GLM 等 OpenAI 兼容接口），通过多 Agent 协作讨论的方式，为用户提供专业的股票分析和投资建议。

### 核心特性

- **多 Agent 智库** - 多个 AI 专家角色协作讨论，提供多维度分析视角
- **策略管理系统** - 灵活的策略配置，支持多 Agent 组合与独立 AI 配置
- **智能记忆系统** - 按股票隔离的长期记忆，AI 能记住历史讨论和关键结论
- **提示词增强** - AI 驱动的提示词优化，提升 Agent 响应质量
- **实时行情** - 股票实时数据、K线图表、盘口深度一应俱全
- **热点舆情** - 聚合百度、抖音、B站、头条等平台热点趋势
- **研报服务** - 专业研究报告查询和智能分析
- **MCP 扩展** - 支持 Model Context Protocol，可扩展更多工具能力
- **布局持久化** - 自动保存窗口和面板布局，下次启动自动恢复

## 技术栈

| 层级 | 技术 |
|------|------|
| **框架** | Wails v2 (Go + Web 混合桌面应用) |
| **后端** | Go 1.24 |
| **前端** | React 18 + TypeScript + Vite |
| **UI** | TailwindCSS + Lucide Icons |
| **图表** | Recharts |
| **AI** | OpenAI / Gemini / DeepSeek / Kimi / GLM 等 |
| **分词** | GSE (纯 Go 实现，无 CGO 依赖) |

## 功能展示

### 主界面
- 左侧：自选股列表与市场指数
- 中间：K线图表（支持分时/日K/周K/月K）
- 右侧：AI 智库讨论室

![主界面展示](image/1.png)

![功能展示](image/2.png)

### 核心功能模块
```

## 补充说明
- 文档完善度: 缺失或简单
- 测试覆盖度: 缺失或简单
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-14*
