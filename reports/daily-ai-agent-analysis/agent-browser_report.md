# Analysis Report: vercel-labs/agent-browser

## Repository Overview
- **URL**: https://github.com/vercel-labs/agent-browser
- **Description**: Browser automation CLI for AI agents
- **Primary Language**: TypeScript
- **Stars**: 12656
- **Forks**: 718
- **Open Issues**: 158
- **License**: Apache-2.0
- **Last Updated**: 2026-02-05T05:51:21Z
- **Topics**: 

## Application Scope
Autonomous Agents / Task Automation

## Technology Stack
- JavaScript/Node.js
- Dependencies: 

## Extension Capabilities
High - Has dedicated extension/plugin system

## Repository Structure
```text
.
./bin
./cli
./cli/src
./docker
./docs
./docs/src
./docs/src/app
./docs/src/components
./scripts
./skills
./skills/agent-browser
./skills/agent-browser/references
./skills/agent-browser/templates
./skills/skill-creator
./skills/skill-creator/references
./skills/skill-creator/scripts
./src
```

## Strengths
- High popularity (12656 ⭐)
- Active community (>718 forks)
- Good documentation
- Test coverage
- Relatively well maintained
- Clear licensing (Apache-2.0)

## Potential Weaknesses
- Missing examples

## README Preview
```markdown
# agent-browser

Headless browser automation CLI for AI agents. Fast Rust CLI with Node.js fallback.

## Installation

### npm (recommended)

```bash
npm install -g agent-browser
agent-browser install  # Download Chromium
```

### From Source

```bash
git clone https://github.com/vercel-labs/agent-browser
cd agent-browser
pnpm install
pnpm build
pnpm build:native   # Requires Rust (https://rustup.rs)
pnpm link --global  # Makes agent-browser available globally
agent-browser install
```

### Linux Dependencies

On Linux, install system dependencies:

```bash
agent-browser install --with-deps
# or manually: npx playwright install-deps chromium
```

## Quick Start

```bash
agent-browser open example.com
agent-browser snapshot                    # Get accessibility tree with refs
agent-browser click @e2                   # Click by ref from snapshot
agent-browser fill @e3 "test@example.com" # Fill by ref
agent-browser get text @e1                # Get text by ref
agent-browser screenshot page.png
agent-browser close
```

### Traditional Selectors (also supported)

```bash
agent-browser click "#submit"
```

## Additional Notes
- Documentation: Present
- Tests: Present
- Examples: Missing or minimal

---
*Analysis performed on 2026-02-05*
