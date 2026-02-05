# Analysis Report: snarktank/ralph

## Repository Overview
- **URL**: https://github.com/snarktank/ralph
- **Description**: Ralph is an autonomous AI agent loop that runs repeatedly until all PRD items are complete. 
- **Primary Language**: TypeScript
- **Stars**: 9428
- **Forks**: 1105
- **Open Issues**: 32
- **License**: MIT
- **Last Updated**: 2026-02-05T05:53:37Z
- **Topics**: 

## Application Scope
Autonomous Agents / Task Automation

## Technology Stack
- Not clearly specified

## Extension Capabilities
High - Has dedicated extension/plugin system

## Repository Structure
```text
.
./flowchart
./skills
./skills/prd
./skills/ralph
```

## Strengths
- High popularity (9428 ⭐)
- Active community (>1105 forks)
- Well maintained (low open issues: 32)
- Clear licensing (MIT)

## Potential Weaknesses
- Limited documentation
- Missing examples
- No visible test suite

## README Preview
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

## Additional Notes
- Documentation: Missing or minimal
- Tests: Missing or minimal
- Examples: Missing or minimal

---
*Analysis performed on 2026-02-05*
