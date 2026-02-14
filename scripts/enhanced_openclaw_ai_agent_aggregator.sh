#!/bin/bash

# OpenClaw Say - 日报系统主控制脚本
# 功能：运行所有采集脚本、合并数据、提交到 GitHub

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
DATE=$(date +%Y-%m-%d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_DIR="$REPO_ROOT/data"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           OpenClaw Say - AI 日报系统                        ║"
echo "║           每日自动采集与发布                                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}📅 日期: $DATE${NC}"
echo -e "${BLUE}📁 工作目录: $REPO_ROOT${NC}"
echo ""

# 检查必要的命令
command -v node >/dev/null 2>&1 || { echo -e "${RED}❌ 需要安装 Node.js${NC}"; exit 1; }
command -v git >/dev/null 2>&1 || { echo -e "${RED}❌ 需要安装 Git${NC}"; exit 1; }

# 确保目录结构存在
echo -e "${YELLOW}📂 检查目录结构...${NC}"
mkdir -p "$DATA_DIR"/{github,youtube,producthunt,combined}
mkdir -p "$SCRIPT_DIR/collectors"

# 检查采集脚本是否存在
COLLECTORS=("collect_github.js" "collect_youtube.js" "collect_producthunt.js" "merge_data.js")
for script in "${COLLECTORS[@]}"; do
    if [ ! -f "$SCRIPT_DIR/collectors/$script" ]; then
        echo -e "${RED}❌ 采集脚本不存在: $script${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✅ 所有采集脚本已就绪${NC}"
echo ""

# 记录失败的任务
FAILED_TASKS=()

# 运行采集脚本
run_collector() {
    local name=$1
    local script=$2
    
    echo -e "${YELLOW}🚀 开始采集: $name${NC}"
    cd "$SCRIPT_DIR/collectors"
    
    if node "$script"; then
        echo -e "${GREEN}✅ $name 采集完成${NC}"
        return 0
    else
        echo -e "${RED}❌ $name 采集失败${NC}"
        FAILED_TASKS+=("$name")
        return 1
    fi
}

# 1. 采集 GitHub 数据
echo "═══════════════════════════════════════════════════════════"
run_collector "GitHub" "collect_github.js"
echo ""

# 2. 采集 YouTube 数据
echo "═══════════════════════════════════════════════════════════"
run_collector "YouTube" "collect_youtube.js"
echo ""

# 3. 采集 Product Hunt 数据
echo "═══════════════════════════════════════════════════════════"
run_collector "Product Hunt" "collect_producthunt.js"
echo ""

# 4. 合并数据
echo "═══════════════════════════════════════════════════════════"
echo -e "${YELLOW}🔄 开始合并数据...${NC}"
cd "$SCRIPT_DIR/collectors"

if node merge_data.js "$DATE"; then
    echo -e "${GREEN}✅ 数据合并完成${NC}"
else
    echo -e "${RED}❌ 数据合并失败${NC}"
    FAILED_TASKS+=("数据合并")
fi
echo ""

# 5. 检查数据文件
echo "═══════════════════════════════════════════════════════════"
echo -e "${YELLOW}📊 检查生成的数据文件...${NC}"

DATA_FILES=(
    "data/github/$DATE.json"
    "data/youtube/$DATE.json"
    "data/producthunt/$DATE.json"
    "data/combined/$DATE.json"
    "data/combined/latest.json"
)

for file in "${DATA_FILES[@]}"; do
    filepath="$REPO_ROOT/$file"
    if [ -f "$filepath" ]; then
        size=$(du -h "$filepath" | cut -f1)
        echo -e "${GREEN}✅${NC} $file (${size})"
    else
        echo -e "${RED}❌${NC} $file (不存在)"
    fi
done
echo ""

# 6. 提交到 GitHub
echo "═══════════════════════════════════════════════════════════"
echo -e "${YELLOW}📤 准备提交到 GitHub...${NC}"

cd "$REPO_ROOT"

# 检查是否有变更
if git diff --quiet && git diff --cached --quiet; then
    echo -e "${YELLOW}⚠️ 没有变更需要提交${NC}"
else
    # 配置 git（如果是 CI 环境）
    if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
        git config user.email "bot@openclaw.ai" || true
        git config user.name "OpenClaw Bot" || true
    fi
    
    # 添加所有变更
    git add -A
    
    # 创建提交
    COMMIT_MSG="📰 Daily Report: $DATE

自动生成的 AI 日报数据
- GitHub 热门项目
- YouTube 精选视频  
- Product Hunt 最新产品

生成时间: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    
    if git commit -m "$COMMIT_MSG"; then
        echo -e "${GREEN}✅ 已创建提交${NC}"
        
        # 推送到 GitHub
        echo -e "${YELLOW}🚀 推送到 GitHub...${NC}"
        if git push origin main; then
            echo -e "${GREEN}✅ 推送成功${NC}"
        else
            echo -e "${RED}❌ 推送失败${NC}"
            FAILED_TASKS+=("GitHub 推送")
        fi
    else
        echo -e "${RED}❌ 提交失败${NC}"
        FAILED_TASKS+=("Git 提交")
    fi
fi
echo ""

# 7. 生成报告摘要
echo "═══════════════════════════════════════════════════════════"
echo -e "${BLUE}📋 日报生成摘要${NC}"
echo "═══════════════════════════════════════════════════════════"

if [ ${#FAILED_TASKS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ 所有任务成功完成！${NC}"
else
    echo -e "${YELLOW}⚠️ 以下任务失败:${NC}"
    for task in "${FAILED_TASKS[@]}"; do
        echo -e "  ${RED}❌${NC} $task"
    done
fi

# 显示数据统计
echo ""
echo -e "${BLUE}📊 数据统计:${NC}"

# 读取合并后的数据统计
COMBINED_FILE="$DATA_DIR/combined/$DATE.json"
if [ -f "$COMBINED_FILE" ]; then
    TOTAL=$(cat "$COMBINED_FILE" | grep -o '"total":[0-9]*' | grep -o '[0-9]*' || echo "0")
    GITHUB=$(cat "$COMBINED_FILE" | grep -o '"github":[0-9]*' | grep -o '[0-9]*' || echo "0")
    YOUTUBE=$(cat "$COMBINED_FILE" | grep -o '"youtube":[0-9]*' | grep -o '[0-9]*' || echo "0")
    PRODUCTHUNT=$(cat "$COMBINED_FILE" | grep -o '"producthunt":[0-9]*' | grep -o '[0-9]*' || echo "0")
    
    echo -e "  总计: ${GREEN}$TOTAL${NC} 条数据"
    echo -e "  - GitHub: $GITHUB"
    echo -e "  - YouTube: $YOUTUBE"
    echo -e "  - Product Hunt: $PRODUCTHUNT"
else
    echo -e "  ${YELLOW}无法读取统计数据${NC}"
fi

echo ""
echo -e "${BLUE}🔗 访问地址:${NC}"
echo -e "  https://0xagentlabs.github.io/openclaw-say/"
echo ""
echo -e "${GREEN}✨ 日报系统执行完成！${NC}"
echo "═══════════════════════════════════════════════════════════"

# 如果有失败任务，返回非零退出码
if [ ${#FAILED_TASKS[@]} -gt 0 ]; then
    exit 1
fi

exit 0
