# 项目分析报告: coreyhaines31/marketingskills

## 项目概览
- **项目地址**: https://github.com/coreyhaines31/marketingskills
- **项目描述**: Marketing skills for Claude Code and AI agents. CRO, copywriting, SEO, analytics, and growth engineering.
- **主要语言**: null
- **星标数**: 7268
- **复刻数**: 838
- **开放问题**: 12
- **许可证**: MIT
- **最后更新**: 2026-02-11T08:44:49Z
- **主题标签**: claude, codex, marketing

## 一句话介绍
coreyhaines31/marketingskills 是一个具备自动化能力的 null 自主代理 / 任务自动化 项目，拥有 7268 个星标。

## 核心亮点
超高人气与社区认可度

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
./skills/competitor-alternatives
./skills/competitor-alternatives/references
./skills/content-strategy
./skills/free-tool-strategy
./skills/free-tool-strategy/references
./skills/paid-ads
./skills/paid-ads/references
./skills/paywall-upgrade-cro
./skills/paywall-upgrade-cro/references
./skills/product-marketing-context
./skills/social-content
./tools
./tools/integrations
```

## 优势分析
- 极高人气 (7268 ⭐)
- 活跃社区 (>838 复刻)
- 维护良好 (低开放问题数: 12)
- 许可证清晰 (MIT)

## 潜在不足
- 文档有限
- 缺少示例
- 无可见测试套件

## README预览
```markdown
# Marketing Skills for Claude Code

A collection of AI agent skills focused on marketing tasks. Built for technical marketers and founders who want Claude Code (or similar AI coding assistants) to help with conversion optimization, copywriting, SEO, analytics, and growth engineering.

Built by [Corey Haines](https://corey.co?ref=marketingskills). Need hands-on help? Check out [Conversion Factory](https://conversionfactory.co?ref=marketingskills) — Corey's agency for conversion optimization, landing pages, and growth strategy. Want to learn more about marketing? Subscribe to [Swipe Files](https://swipefiles.com?ref=marketingskills).

New to the terminal and coding agents? Check out the companion guide [Coding for Marketers](https://codingformarketers.com?ref=marketingskills).

**Contributions welcome!** Found a way to improve a skill or have a new one to add? [Open a PR](#contributing).

## What are Skills?

Skills are markdown files that give AI agents specialized knowledge and workflows for specific tasks. When you add these to your project, Claude Code can recognize when you're working on a marketing task and apply the right frameworks and best practices.

## Available Skills

<!-- SKILLS:START -->
| Skill | Description |
|-------|-------------|
| [ab-test-setup](skills/ab-test-setup/) | When the user wants to plan, design, or implement an A/B test or experiment. Also use when the user mentions "A/B... |
| [analytics-tracking](skills/analytics-tracking/) | When the user wants to set up, improve, or audit analytics tracking and measurement. Also use when the user mentions... |
| [competitor-alternatives](skills/competitor-alternatives/) | When the user wants to create competitor comparison or alternative pages for SEO and sales enablement. Also use when... |
| [content-strategy](skills/content-strategy/) | When the user wants to plan a content strategy, decide what content to create, or figure out what topics to cover. Also... |
| [copy-editing](skills/copy-editing/) | When the user wants to edit, review, or improve existing marketing copy. Also use when the user mentions 'edit this... |
| [copywriting](skills/copywriting/) | When the user wants to write, rewrite, or improve marketing copy for any page — including homepage, landing pages,... |
| [email-sequence](skills/email-sequence/) | When the user wants to create or optimize an email sequence, drip campaign, automated email flow, or lifecycle email... |
| [form-cro](skills/form-cro/) | When the user wants to optimize any form that is NOT signup/registration — including lead capture forms, contact forms,... |
| [free-tool-strategy](skills/free-tool-strategy/) | When the user wants to plan, evaluate, or build a free tool for marketing purposes — lead generation, SEO value, or... |
| [launch-strategy](skills/launch-strategy/) | When the user wants to plan a product launch, feature announcement, or release strategy. Also use when the user... |
| [marketing-ideas](skills/marketing-ideas/) | When the user needs marketing ideas, inspiration, or strategies for their SaaS or software product. Also use when the... |
| [marketing-psychology](skills/marketing-psychology/) | When the user wants to apply psychological principles, mental models, or behavioral science to marketing. Also use when... |
| [onboarding-cro](skills/onboarding-cro/) | When the user wants to optimize post-signup onboarding, user activation, first-run experience, or time-to-value. Also... |
| [page-cro](skills/page-cro/) | When the user wants to optimize, improve, or increase conversions on any marketing page — including homepage, landing... |
| [paid-ads](skills/paid-ads/) | When the user wants help with paid advertising campaigns on Google Ads, Meta (Facebook/Instagram), LinkedIn, Twitter/X,... |
| [paywall-upgrade-cro](skills/paywall-upgrade-cro/) | When the user wants to create or optimize in-app paywalls, upgrade screens, upsell modals, or feature gates. Also use... |
| [popup-cro](skills/popup-cro/) | When the user wants to create or optimize popups, modals, overlays, slide-ins, or banners for conversion purposes. Also... |
| [pricing-strategy](skills/pricing-strategy/) | When the user wants help with pricing decisions, packaging, or monetization strategy. Also use when the user mentions... |
| [product-marketing-context](skills/product-marketing-context/) | When the user wants to create or update their product marketing context document. Also use when the user mentions... |
| [programmatic-seo](skills/programmatic-seo/) | When the user wants to create SEO-driven pages at scale using templates and data. Also use when the user mentions... |
| [referral-program](skills/referral-program/) | When the user wants to create, optimize, or analyze a referral program, affiliate program, or word-of-mouth strategy.... |
| [schema-markup](skills/schema-markup/) | When the user wants to add, fix, or optimize schema markup and structured data on their site. Also use when the user... |
| [seo-audit](skills/seo-audit/) | When the user wants to audit, review, or diagnose SEO issues on their site. Also use when the user mentions "SEO... |
| [signup-flow-cro](skills/signup-flow-cro/) | When the user wants to optimize signup, registration, account creation, or trial activation flows. Also use when the... |
| [social-content](skills/social-content/) | When the user wants help creating, scheduling, or optimizing social media content for LinkedIn, Twitter/X, Instagram,... |
<!-- SKILLS:END -->

## Installation

### Option 1: CLI Install (Recommended)
```

## 补充说明
- 文档完善度: 缺失或简单
- 测试覆盖度: 缺失或简单
- 示例丰富度: 缺失或简单

---
*分析时间: 2026-02-11*
