#!/bin/bash

# OpenClaw AI Agent Project Aggregator
# Daily analysis of top AI Agent projects from GitHub

set -e  # Exit on any error

# Configuration
DATE=$(date +%Y-%m-%d)
REPORT_DIR="/tmp/ai-agent-aggregator-$DATE"
REPO_OWNER="0xagentlabs"
REPO_NAME="openclaw-say"
WORKSPACE_DIR="/tmp/openclaw-say-task"

# Ensure required tools are available
if ! command -v gh &> /dev/null; then
    echo "错误：需要安装GitHub CLI (gh)。"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "错误：需要安装jq。"
    exit 1
fi

# Create working directory
mkdir -p "$REPORT_DIR"
cd "$REPORT_DIR"

echo "开始分析 $DATE 的顶级AI Agent项目..."

# Clone the target repository FIRST so we have the history file
if [ ! -d "$WORKSPACE_DIR" ]; then
    git clone "https://github.com/$REPO_OWNER/$REPO_NAME.git" "$WORKSPACE_DIR"
else
    # Update existing repo
    (cd "$WORKSPACE_DIR" && git pull origin main)
fi

# Step 0.5: Fetch Product Updates (New Integration)
echo "正在获取产品动态..."
PRODUCT_UPDATES_HTML=""
if [ -f "$WORKSPACE_DIR/scripts/fetch_product_updates.js" ]; then
    # Run the fetch script
    # It writes to ../product_updates.html relative to script, so $WORKSPACE_DIR/product_updates.html
    echo "Running fetch_product_updates.js..."
    (cd "$WORKSPACE_DIR/scripts" && node fetch_product_updates.js)
    
    if [ -f "$WORKSPACE_DIR/product_updates.html" ]; then
        PRODUCT_UPDATES_HTML=$(cat "$WORKSPACE_DIR/product_updates.html")
        echo "产品动态获取成功。"
    else
         echo "Warning: product_updates.html extraction failed."
    fi
else
    echo "Warning: fetch_product_updates.js script not found in $WORKSPACE_DIR/scripts."
fi

# Function to filter out recent projects
filter_projects() {
  local search_results_json=$1
  local history_file="$WORKSPACE_DIR/reports/daily-ai-agent-analysis/history.json"
  
  # Ensure directory exists for history file
  mkdir -p "$(dirname "$history_file")"

  if [ ! -f "$history_file" ]; then
    echo "[]" > "$history_file"
  fi
  
  # Calculate date 3 days ago
  local date_threshold=$(date -d '3 days ago' +%s)
  
  # Extract items from search results
  local items=$(echo "$search_results_json" | jq -r '.items')
  
  # Filter using jq
  echo "$items" | jq --arg threshold "$date_threshold" --slurpfile history "$history_file" '
    # Flatten history projects from the last 3 days
    ($history[0] | map(select((.date | strptime("%Y-%m-%d") | mktime) >= ($threshold | tonumber))) | map(.projects[]) | unique) as $recent_projects |
    
    # Filter current items
    map(select(
      .full_name as $name |
      ($recent_projects | index($name) | not)
    )) |
    
    # Take top 8
    .[0:8] |
    .[] |
    "\(.full_name)|\(.html_url)|\(.description // "No description")|\(.language // "Unknown")|\(.stargazers_count)|\(.updated_at)|\(.topics | join(", "))"
  ' | sed 's/"//g' # Clean up extra quotes if any remain from jq output
}

# Step 1: Search for top AI Agent repositories on GitHub
echo "搜索顶级AI Agent项目..."

# Calculate the start date for the search (e.g., created in the last 30 days)
SEARCH_DATE=$(date -d '30 days ago' +%Y-%m-%d)

# Fetch current search results (increased to 50 to allow for filtering)
SEARCH_RESULTS=$(gh api \
  -H "Accept: application/vnd.github.v3+json" \
  "search/repositories?q=ai+agent+created:>$SEARCH_DATE&sort=stars&order=desc&per_page=50")

# Validation: Check if search results are valid JSON and contain items
if ! echo "$SEARCH_RESULTS" | jq -e '.items' > /dev/null; then
    echo "Error: GitHub API returned invalid response or no items."
    echo "Response: $SEARCH_RESULTS"
    # Fallback to a mock/empty list or exit, but for now let's try to continue with empty to show at least the Product Updates
    SEARCH_RESULTS='{"items":[]}'
fi

# Step 2: Process and Filter results
echo "过滤最近3天已展示的项目..."


# Ensure WORKSPACE_DIR exists (it should, from the git clone above)
TOP_REPOS=$(filter_projects "$SEARCH_RESULTS")

# If filtering removed everything (unlikely with 50 results), fallback to top 8 raw
if [ -z "$TOP_REPOS" ]; then
    echo "警告: 过滤后无剩余项目，回退到原始Top 8..."
    TOP_REPOS=$(echo "$SEARCH_RESULTS" | jq -r '.items[0:8] | .[] | "\(.full_name)|\(.html_url)|\(.description // "No description")|\(.language // "Unknown")|\(.stargazers_count)|\(.updated_at)|\(.topics | join(", "))"')
fi

echo "找到顶级项目 (已过滤):"
echo "$TOP_REPOS"

# Update history file with today's selection
HISTORY_FILE="$WORKSPACE_DIR/reports/daily-ai-agent-analysis/history.json"
# Parse the project names from the current selection
CURRENT_PROJECTS_JSON=$(echo "$TOP_REPOS" | cut -d"|" -f1 | jq -R . | jq -s .)

# Load existing history or create empty array, then append new entry
if [ -f "$HISTORY_FILE" ]; then
  # Read existing, add new, sort by date desc, keep top 30
  jq --arg date "$DATE" --argjson new_projects "$CURRENT_PROJECTS_JSON" \
    '. + [{"date": $date, "projects": $new_projects}] | sort_by(.date) | reverse | .[0:30]' \
    "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
else
  echo "[{\"date\": \"$DATE\", \"projects\": $CURRENT_PROJECTS_JSON}]" > "$HISTORY_FILE"
fi

# Function to analyze a single repository
analyze_repo() {
    local full_name=$1
    local html_url=$2
    local description=$3
    local language=$4
    local stars=$5
    local updated_at=$6
    local topics=$7
    
    # Extract owner and repo name
    local owner=$(echo "$full_name" | cut -d'/' -f1)
    local repo=$(echo "$full_name" | cut -d'/' -f2)
    
    echo "分析 $full_name..."
    
    # Clone the repository
    local clone_dir="$REPORT_DIR/${repo}_analysis"
    if [ -d "$clone_dir" ]; then
        rm -rf "$clone_dir"
    fi
    
    git clone --depth 1 "$html_url" "$clone_dir" || {
        echo "克隆 $html_url 失败，跳过..."
        return 1
    }
    
    cd "$clone_dir"
    
    # Gather repository information
    local repo_info=$(gh api repos/$full_name)
    local forks=$(echo "$repo_info" | jq -r '.forks_count')
    local issues=$(echo "$repo_info" | jq -r '.open_issues_count')
    local license=$(echo "$repo_info" | jq -r '.license.spdx_id // "None"')
    
    # Get README content
    local readme_content=""
    if [ -f "README.md" ]; then
        readme_content=$(head -100 "README.md")
    elif [ -f "readme.md" ]; then
        readme_content=$(head -100 "readme.md")
    elif [ -f "Readme.md" ]; then
        readme_content=$(head -100 "Readme.md")
    fi
    
    # Analyze file structure
    local file_structure=$(find . -maxdepth 3 -type d | head -20 | grep -v ".git" | sort)
    
    # Identify technology stack based on files
    local tech_stack=()
    local dependencies=""
    local app_scope=""
    local extension_capability=""
    local core_features=()
    
    # Determine application scope
    if [[ "$readme_content" =~ [Cc]hat|[Cc]onversational|[Cc]hatbot ]]; then
        app_scope="对话式AI / 聊天机器人"
    elif [[ "$readme_content" =~ [Aa]gent|[Aa]utomation|[Tt]ask ]]; then
        app_scope="自主代理 / 任务自动化"
    elif [[ "$readme_content" =~ [Rr]easoning|[Rr]esearch|[Rr]etriev ]]; then
        app_scope="研究 / RAG系统"
    elif [[ "$readme_content" =~ [Tt]rading|[Cc]rypto|[Bb]lockchain ]]; then
        app_scope="金融 / 交易AI"
    elif [[ "$readme_content" =~ [Dd]evops|[Cc]ode|[Pp]rogramming ]]; then
        app_scope="开发者工具 / 代码辅助"
    else
        app_scope="通用AI代理"
    fi
    
    # Identify technology stack
    if [ -f "requirements.txt" ]; then
        dependencies=$(grep -E "(openai|anthropic|langchain|llama|transformers|pytorch|tensorflow|groq|ollama|crewai|autogen|agents)" requirements.txt | head -10 | tr '\n' ', ')
        tech_stack+=("Python")
        tech_stack+=("依赖包: $(echo $dependencies | sed 's/,$//')")
    fi
    
    if [ -f "pyproject.toml" ]; then
        dependencies=$(grep -E "(openai|anthropic|langchain|llama|transformers|pytorch|tensorflow|groq|ollama|crewai|autogen|agents)" pyproject.toml | head -10 | tr '\n' ', ')
        tech_stack+=("Python (pyproject)")
        tech_stack+=("依赖包: $(echo $dependencies | sed 's/,$//')")
    fi
    
    if [ -f "package.json" ]; then
        dependencies=$(grep -E "(openai|anthropic|langchain)" package.json | head -10 | tr '\n' ', ')
        tech_stack+=("JavaScript/Node.js")
        tech_stack+=("依赖包: $(echo $dependencies | sed 's/,$//')")
    fi
    
    if [ -f "go.mod" ]; then
        tech_stack+=("Go")
    fi
    
    if [ -f "Cargo.toml" ]; then
        tech_stack+=("Rust")
    fi
    
    if [ -f "Dockerfile" ]; then
        tech_stack+=("容器化")
    fi
    
    if [ -f "docker-compose.yml" ]; then
        tech_stack+=("Docker Compose")
    fi
    
    # Identify core features
    if [[ "$readme_content" =~ [Mm]ulti-[Mm]odal|[Ii]mage.*[Pp]rocessing|[Vv]ision ]]; then
        core_features+=("多模态处理")
    fi
    
    if [[ "$readme_content" =~ [Aa]utonomous|[Ss]elf-[Ll]earning|[Aa]daptive ]]; then
        core_features+=("自主学习能力")
    fi
    
    if [[ "$readme_content" =~ [Tt]ool.*[Cc]alling|[Ff]unction.*[Cc]alling|[Aa]ction.*[Pp]lanning ]]; then
        core_features+=("工具调用和行动规划")
    fi
    
    if [[ "$readme_content" =~ [Mm]emory|[Ll]ong.*[Tt]erm.*[Mm]emory ]]; then
        core_features+=("长期记忆管理")
    fi
    
    if [[ "$readme_content" =~ [Rr][Aa][Gg]|[Rr]etrieval.*[Ee]nhancement.*[Gg]eneration ]]; then
        core_features+=("检索增强生成(RAG)")
    fi
    
    # Check for extension capabilities
    if [ -d "plugins" ] || [ -d "extensions" ] || [ -d "skills" ] || [ -d "tools" ]; then
        extension_capability="高 - 具备专门的插件/扩展系统"
    elif [ -f "docs/plugins.md" ] || [ -f "docs/extensions.md" ] || [ -f "PLUGINS.md" ]; then
        extension_capability="中 - 插件系统有文档说明"
    elif grep -r "plugin\|extension\|tool\|skill" . --include="*.md" --include="*.py" --include="*.js" --include="*.ts" | head -5; then
        extension_capability="低至中 - 代码中检测到扩展能力"
    else
        extension_capability="基本 - 扩展能力有限"
    fi
    
    # Check for documentation
    local has_docs=0
    if [ -d "docs" ] || [ -d "documentation" ] || [ -f "DOCUMENTATION.md" ] || [ -f "docs.md" ]; then
        has_docs=1
    fi
    
    # Check for tests
    local has_tests=0
    if [ -d "tests" ] || [ -d "test" ] || [ -f "jest.config.js" ] || [ -f "pytest.ini" ]; then
        has_tests=1
    fi
    
    # Check for examples
    local has_examples=0
    if [ -d "examples" ] || [ -d "example" ] || [ -d "sample" ]; then
        has_examples=1
    fi
    
    # Generate strengths and weaknesses
    local strengths=()
    local weaknesses=()
    
    # Strengths
    if [ "$stars" -gt 5000 ]; then
        strengths+=("极高人气 ($stars ⭐)")
    elif [ "$stars" -gt 1000 ]; then
        strengths+=("显著人气 ($stars ⭐)")
    elif [ "$stars" -gt 100 ]; then
        strengths+=("持续增长 ($stars ⭐)")
    fi
    
    if [ "$forks" -gt 100 ]; then
        strengths+=("活跃社区 (>$forks 复刻)")
    elif [ "$forks" -gt 10 ]; then
        strengths+=("社区兴趣 ($forks 复刻)")
    fi
    
    if [ $has_docs -eq 1 ]; then
        strengths+=("良好文档")
    fi
    
    if [ $has_examples -eq 1 ]; then
        strengths+=("丰富示例")
    fi
    
    if [ $has_tests -eq 1 ]; then
        strengths+=("测试覆盖")
    fi
    
    if [ "$issues" -lt 50 ]; then
        strengths+=("维护良好 (低开放问题数: $issues)")
    elif [ $((issues * 100 / stars)) -lt 5 ]; then
        strengths+=("相对维护良好")
    fi
    
    if [ "$license" != "None" ] && [ "$license" != "null" ]; then
        strengths+=("许可证清晰 ($license)")
    fi
    
    # Weaknesses
    if [ "$stars" -lt 50 ]; then
        weaknesses+=("人气较低 (<50 ⭐)")
    fi
    
    if [ $has_docs -eq 0 ]; then
        weaknesses+=("文档有限")
    fi
    
    if [ $has_examples -eq 0 ]; then
        weaknesses+=("缺少示例")
    fi
    
    if [ $has_tests -eq 0 ]; then
        weaknesses+=("无可见测试套件")
    fi
    
    if [ "$issues" -gt 200 ]; then
        weaknesses+=("开放问题数量较多 ($issues)")
    fi
    
    # Determine one-sentence summary and highlight
    local one_sentence_summary=""
    local highlight_feature=""
    
    # Generate one sentence summary
    if [ "$app_scope" = "对话式AI / 聊天机器人" ]; then
        one_sentence_summary="$full_name 是一个基于 $language 的 $app_scope 项目，具有 $stars 个星标。"
    elif [ "$app_scope" = "自主代理 / 任务自动化" ]; then
        one_sentence_summary="$full_name 是一个具备自动化能力的 $language $app_scope 项目，拥有 $stars 个星标。"
    elif [ "$app_scope" = "研究 / RAG系统" ]; then
        one_sentence_summary="$full_name 是一个基于 $language 的 $app_scope 项目，专注于知识检索与生成，拥有 $stars 个星标。"
    elif [ "$app_scope" = "金融 / 交易AI" ]; then
        one_sentence_summary="$full_name 是一个基于 $language 的 $app_scope 项目，利用AI进行智能决策，拥有 $stars 个星标。"
    elif [ "$app_scope" = "开发者工具 / 代码辅助" ]; then
        one_sentence_summary="$full_name 是一个基于 $language 的 $app_scope 项目，提升开发效率，拥有 $stars 个星标。"
    else
        one_sentence_summary="$full_name 是一个基于 $language 的 $app_scope 项目，拥有 $stars 个星标。"
    fi
    
    # Determine highlight feature
    if [ ${#core_features[@]} -gt 0 ]; then
        highlight_feature="${core_features[0]}"
    elif [ "$stars" -gt 5000 ]; then
        highlight_feature="超高人气与社区认可度"
    elif [ $has_docs -eq 1 ] && [ $has_examples -eq 1 ]; then
        highlight_feature="完善的文档和示例"
    elif [ "$extension_capability" = "高 - 具备专门的插件/扩展系统" ]; then
        highlight_feature="强大的扩展性"
    else
        highlight_feature="活跃的开发维护"
    fi
    
    # Create detailed analysis report for this repository
    local report_file="$REPORT_DIR/${repo}_report.md"
    cat > "$report_file" << EOL
# 项目分析报告: $full_name

## 项目概览
- **项目地址**: $html_url
- **项目描述**: $description
- **主要语言**: $language
- **星标数**: $stars
- **复刻数**: $forks
- **开放问题**: $issues
- **许可证**: $license
- **最后更新**: $updated_at
- **主题标签**: $topics

## 一句话介绍
$one_sentence_summary

## 核心亮点
$highlight_feature

## 应用领域
$app_scope

## 技术栈
EOL

    if [ ${#tech_stack[@]} -gt 0 ]; then
        for tech in "${tech_stack[@]}"; do
            echo "- $tech" >> "$report_file"
        done
    else
        echo "- 技术栈未明确指定" >> "$report_file"
    fi

    cat >> "$report_file" << EOL

## 核心特性
EOL

    if [ ${#core_features[@]} -gt 0 ]; then
        for feature in "${core_features[@]}"; do
            echo "- $feature" >> "$report_file"
        done
    else
        echo "- 未识别出核心特性" >> "$report_file"
    fi

    cat >> "$report_file" << EOL

## 扩展能力
$extension_capability

## 执行流程解析
基于代码库分析，该项目的主要执行流程可能包括：
1. 初始化阶段：根据配置文件或命令行参数设置运行环境
2. 输入处理：接收用户输入或任务指令
3. 代理循环：执行AI推理、工具调用、行动规划等
4. 输出处理：生成响应或执行结果
5. 记忆/状态管理：更新内部状态或记忆系统

(具体执行流程需参考源代码实现)

## 仓库结构
\`\`\`text
$file_structure
\`\`\`

## 优势分析
EOL

    if [ ${#strengths[@]} -gt 0 ]; then
        for strength in "${strengths[@]}"; do
            echo "- $strength" >> "$report_file"
        done
    else
        echo "- 未识别出明显优势" >> "$report_file"
    fi

    cat >> "$report_file" << EOL

## 潜在不足
EOL

    if [ ${#weaknesses[@]} -gt 0 ]; then
        for weakness in "${weaknesses[@]}"; do
            echo "- $weakness" >> "$report_file"
        done
    else
        echo "- 未识别出明显不足" >> "$report_file"
    fi

    cat >> "$report_file" << EOL

## README预览
\`\`\`markdown
$(echo "$readme_content" | head -50)
\`\`\`

## 补充说明
- 文档完善度: $(if [ $has_docs -eq 1 ]; then echo "完整"; else echo "缺失或简单"; fi)
- 测试覆盖度: $(if [ $has_tests -eq 1 ]; then echo "完整"; else echo "缺失或简单"; fi)
- 示例丰富度: $(if [ $has_examples -eq 1 ]; then echo "完整"; else echo "缺失或简单"; fi)

---
*分析时间: $DATE*
EOL

    # Create HTML version of the report
    local html_report_file="$REPORT_DIR/${repo}_report.html"
    {
        echo "<!DOCTYPE html>"
        echo "<html lang=\"zh-CN\">"
        echo "<head>"
        echo "    <meta charset=\"UTF-8\">"
        echo "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
        echo "    <title>项目分析报告: $full_name</title>"
        echo "    <style>"
        echo "        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f8f9fa; }"
        echo "        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }"
        echo "        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }"
        echo "        h2 { color: #3498db; margin-top: 30px; }"
        echo "        h3 { color: #2980b9; }"
        echo "        .summary-box { background: linear-gradient(135deg, #74b9ff, #0984e3); color: white; padding: 20px; border-radius: 10px; margin: 20px 0; }"
        echo "        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0; }"
        echo "        .stat-card { background: #f1f2f6; padding: 15px; border-radius: 8px; text-align: center; }"
        echo "        .highlight { background: #fdcb6e; padding: 15px; border-left: 5px solid #e17055; margin: 15px 0; }"
        echo "        .strengths { background: #a29bfe; padding: 15px; border-left: 5px solid #6c5ce7; margin: 15px 0; }"
        echo "        .weaknesses { background: #fab1a0; padding: 15px; border-left: 5px solid #d63031; margin: 15px 0; }"
        echo "        .features { background: #74b9ff; color: white; padding: 15px; border-radius: 8px; margin: 15px 0; }"
        echo "        .repo-link { display: inline-block; background: #00b894; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 10px 5px; }"
        echo "        .repo-link:hover { background: #00a085; }"
        echo "        pre { background: #2d3436; color: #fff; padding: 15px; border-radius: 5px; overflow-x: auto; }"
        echo "        ul { margin: 10px 0; padding-left: 20px; }"
        echo "        li { margin-bottom: 8px; }"
        echo "        .section { margin: 25px 0; padding: 15px; border-radius: 5px; }"
        echo "        .tech-stack { background: #ffeaa7; }"
        echo "        .execution-flow { background: #e17055; color: white; }"
        echo "    </style>"
        echo "</head>"
        echo "<body>"
        echo "    <div class=\"container\">"
        echo "        <h1>项目分析报告</h1>"
        echo "        <h2>$full_name</h2>"
        echo "        <a href=\"$html_url\" class=\"repo-link\" target=\"_blank\">访问项目主页</a>"
        echo "        <a href=\"../index.html\" class=\"repo-link\" style=\"background:#636e72;\" target=\"_blank\">返回项目聚合器首页</a>"
        
        echo "        <div class=\"summary-box\">"
        echo "            <h3>项目摘要</h3>"
        echo "            <p><strong>一句话介绍:</strong> $one_sentence_summary</p>"
        echo "            <p><strong>核心亮点:</strong> $highlight_feature</p>"
        echo "        </div>"
        
        echo "        <div class=\"stats\">"
        echo "            <div class=\"stat-card\">⭐ <strong>星标</strong><br>$stars</div>"
        echo "            <div class=\"stat-card\">🔄 <strong>复刻</strong><br>$forks</div>"
        echo "            <div class=\"stat-card\">📋 <strong>问题</strong><br>$issues</div>"
        echo "            <div class=\"stat-card\">🏷️ <strong>语言</strong><br>$language</div>"
        echo "            <div class=\"stat-card\">📄 <strong>许可</strong><br>$license</div>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>项目描述</h3>"
        echo "            <p>$description</p>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>应用领域</h3>"
        echo "            <p>$app_scope</p>"
        echo "        </div>"
        
        echo "        <div class=\"section tech-stack\">"
        echo "            <h3>技术栈</h3>"
        echo "            <ul>"
        if [ ${#tech_stack[@]} -gt 0 ]; then
            for tech in "${tech_stack[@]}"; do
                echo "                <li>$tech</li>"
            done
        else
            echo "                <li>技术栈未明确指定</li>"
        fi
        echo "            </ul>"
        echo "        </div>"
        
        echo "        <div class=\"features\">"
        echo "            <h3 style=\"color:white;\">核心特性</h3>"
        echo "            <ul style=\"color:white;\">"
        if [ ${#core_features[@]} -gt 0 ]; then
            for feature in "${core_features[@]}"; do
                echo "                <li>$feature</li>"
            done
        else
            echo "                <li>未识别出核心特性</li>"
        fi
        echo "            </ul>"
        echo "        </div>"
        
        echo "        <div class=\"execution-flow\">"
        echo "            <h3>执行流程解析</h3>"
        echo "            <p>基于代码库分析，该项目的主要执行流程可能包括：</p>"
        echo "            <ol>"
        echo "                <li>初始化阶段：根据配置文件或命令行参数设置运行环境</li>"
        echo "                <li>输入处理：接收用户输入或任务指令</li>"
        echo "                <li>代理循环：执行AI推理、工具调用、行动规划等</li>"
        echo "                <li>输出处理：生成响应或执行结果</li>"
        echo "                <li>记忆/状态管理：更新内部状态或记忆系统</li>"
        echo "            </ol>"
        echo "            <p>(具体执行流程需参考源代码实现)</p>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>扩展能力</h3>"
        echo "            <p>$extension_capability</p>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>仓库结构</h3>"
        echo "            <pre>$file_structure</pre>"
        echo "        </div>"
        
        echo "        <div class=\"strengths\">"
        echo "            <h3 style=\"color:white;\">优势分析</h3>"
        echo "            <ul style=\"color:white;\">"
        if [ ${#strengths[@]} -gt 0 ]; then
            for strength in "${strengths[@]}"; do
                echo "                <li>$strength</li>"
            done
        else
            echo "                <li>未识别出明显优势</li>"
        fi
        echo "            </ul>"
        echo "        </div>"
        
        echo "        <div class=\"weaknesses\">"
        echo "            <h3 style=\"color:white;\">潜在不足</h3>"
        echo "            <ul style=\"color:white;\">"
        if [ ${#weaknesses[@]} -gt 0 ]; then
            for weakness in "${weaknesses[@]}"; do
                echo "                <li>$weakness</li>"
            done
        else
            echo "                <li>未识别出明显不足</li>"
        fi
        echo "            </ul>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>README预览</h3>"
        echo "            <pre>$(echo "$readme_content" | head -50)</pre>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>补充说明</h3>"
        echo "            <ul>"
        echo "                <li>文档完善度: $(if [ $has_docs -eq 1 ]; then echo "完整"; else echo "缺失或简单"; fi)</li>"
        echo "                <li>测试覆盖度: $(if [ $has_tests -eq 1 ]; then echo "完整"; else echo "缺失或简单"; fi)</li>"
        echo "                <li>示例丰富度: $(if [ $has_examples -eq 1 ]; then echo "完整"; else echo "缺失或简单"; fi)</li>"
        echo "            </ul>"
        echo "        </div>"
        
        echo "        <p><em>分析时间: $DATE</em></p>"
        echo "    </div>"
        echo "</body>"
        echo "</html>"
    } > "$html_report_file"

    # Return to main directory
    cd "$REPORT_DIR"
}

# Step 3: Analyze each repository
while IFS='|' read -r full_name html_url description language stars updated_at topics; do
    analyze_repo "$full_name" "$html_url" "$description" "$language" "$stars" "$updated_at" "$topics"
done <<< "$(echo "$TOP_REPOS")"

# Step 4: Create an enhanced index HTML page for the aggregator with beautiful styling
INDEX_HTML_FILE="$REPORT_DIR/index.html"
{
    echo "<!DOCTYPE html>"
    echo "<html lang=\"zh-CN\">"
    echo "<head>"
    echo "    <meta charset=\"UTF-8\">"
    echo "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
    echo "    <title>🦞 OpenClaw AI Agent 项目聚合器 - $DATE</title>"
    echo "    <link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css\">"
    echo "    <style>"
    echo "        :root {"
    echo "            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);"
    echo "            --card-bg: rgba(255, 255, 255, 0.95);"
    echo "            --hover-gradient: linear-gradient(135deg, #764ba2 0%, #667eea 100%);"
    echo "            --accent-color: #74b9ff;"
    echo "            --positive-color: #00b894;"
    echo "            --negative-color: #d63031;"
    echo "        }"
    echo ""
    echo "        * {"
    echo "            margin: 0;"
    echo "            padding: 0;"
    echo "            box-sizing: border-box;"
    echo "        }"
    echo ""
    echo "        body {"
    echo "            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;"
    echo "            background: var(--primary-gradient);"
    echo "            min-height: 100vh;"
    echo "            padding: 20px;"
    echo "            position: relative;"
    echo "            overflow-x: hidden;"
    echo "        }"
    echo ""
    echo "        body::before {"
    echo "            content: '';"
    echo "            position: absolute;"
    echo "            top: 0;"
    echo "            left: 0;"
    echo "            right: 0;"
    echo "            bottom: 0;"
    echo "            background: url('data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\"><defs><pattern id=\"grain\" width=\"100\" height=\"100\" patternUnits=\"userSpaceOnUse\"><circle cx=\"25\" cy=\"25\" r=\"1\" fill=\"white\" opacity=\"0.1\"/><circle cx=\"75\" cy=\"75\" r=\"1\" fill=\"white\" opacity=\"0.1\"/><circle cx=\"50\" cy=\"10\" r=\"0.5\" fill=\"white\" opacity=\"0.1\"/><circle cx=\"10\" cy=\"90\" r=\"0.5\" fill=\"white\" opacity=\"0.1\"/></pattern></defs><rect width=\"100\" height=\"100\" fill=\"url(%23grain)\"/></svg>');"
    echo "            opacity: 0.3;"
    echo "            pointer-events: none;"
    echo "        }"
    echo ""
    echo "        .container {"
    echo "            max-width: 1400px;"
    echo "            margin: 0 auto;"
    echo "            position: relative;"
    echo "            z-index: 1;"
    echo "        }"
    echo ""
    echo "        .header {"
    echo "            text-align: center;"
    echo "            color: white;"
    echo "            margin-bottom: 40px;"
    echo "            animation: fadeInUp 1s ease-out;"
    echo "        }"
    echo ""
    echo "        .header h1 {"
    echo "            font-size: 3.5rem;"
    echo "            margin: 0 0 15px 0;"
    echo "            text-shadow: 3px 3px 6px rgba(0,0,0,0.3);"
    echo "            background: linear-gradient(to right, #ffffff, #f1f3f4);"
    echo "            -webkit-background-clip: text;"
    echo "            -webkit-text-fill-color: transparent;"
    echo "        }"
    echo ""
    echo "        .header .subtitle {"
    echo "            font-size: 1.4rem;"
    echo "            opacity: 0.9;"
    echo "            margin-bottom: 25px;"
    echo "            font-weight: 300;"
    echo "        }"
    echo ""
    echo "        .stats-bar {"
    echo "            background: rgba(255,255,255,0.15);"
    echo "            backdrop-filter: blur(10px);"
    echo "            border-radius: 15px;"
    echo "            padding: 20px;"
    echo "            margin: 20px auto;"
    echo "            max-width: 800px;"
    echo "            display: flex;"
    echo "            justify-content: space-around;"
    echo "            align-items: center;"
    echo "            color: white;"
    echo "            font-size: 1.1rem;"
    echo "        }"
    echo ""
    echo "        .intro {"
    echo "            background: var(--card-bg);"
    echo "            border-radius: 20px;"
    echo "            padding: 30px;"
    echo "            margin: 30px auto;"
    echo "            max-width: 800px;"
    echo "            text-align: center;"
    echo "            box-shadow: 0 10px 30px rgba(0,0,0,0.1);"
    echo "            border: 1px solid rgba(255,255,255,0.2);"
    echo "            animation: fadeIn 1.5s ease-out;"
    echo "        }"
    echo ""
    echo "        .intro h2 {"
    echo "            color: #2d3436;"
    echo "            margin-bottom: 15px;"
    echo "            font-size: 1.8rem;"
    echo "        }"
    echo ""
    echo "        .intro p {"
    echo "            color: #636e72;"
    echo "            line-height: 1.6;"
    echo "            margin: 10px 0;"
    echo "            font-size: 1.1rem;"
    echo "        }"
    echo ""
    echo "        .projects-grid {"
    echo "            display: grid;"
    echo "            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));"
    echo "            gap: 30px;"
    echo "            margin: 40px 0;"
    echo "        }"
    echo ""
    echo "        .project-card {"
    echo "            background: var(--card-bg);"
    echo "            border-radius: 20px;"
    echo "            padding: 30px;"
    echo "            box-shadow: 0 15px 35px rgba(0,0,0,0.1);"
    echo "            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);"
    echo "            border: 1px solid rgba(255,255,255,0.2);"
    echo "            position: relative;"
    echo "            overflow: hidden;"
    echo "            animation: slideIn 0.6s ease-out;"
    echo "        }"
    echo ""
    echo "        .project-card::before {"
    echo "            content: '';"
    echo "            position: absolute;"
    echo "            top: 0;"
    echo "            left: -100%;"
    echo "            width: 100%;"
    echo "            height: 100%;"
    echo "            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);"
    echo "            transition: left 0.5s;"
    echo "        }"
    echo ""
    echo "        .project-card:hover {"
    echo "            transform: translateY(-10px) scale(1.02);"
    echo "            box-shadow: 0 25px 50px rgba(0,0,0,0.15);"
    echo "        }"
    echo ""
    echo "        .project-card:hover::before {"
    echo "            left: 100%;"
    echo "        }"
    echo ""
    echo "        .project-title {"
    echo "            color: #2d3436;"
    echo "            margin: 0 0 15px 0;"
    echo "            font-size: 1.5rem;"
    echo "            font-weight: 600;"
    echo "            display: flex;"
    echo "            align-items: center;"
    echo "            gap: 10px;"
    echo "        }"
    echo ""
    echo "        .project-title i {"
    echo "            color: var(--accent-color);"
    echo "        }"
    echo ""
    echo "        .project-description {"
    echo "            color: #636e72;"
    echo "            margin: 15px 0;"
            echo "            line-height: 1.6;"
    echo "            font-size: 1rem;"
    echo "        }"
    echo ""
    echo "        .project-stats {"
    echo "            display: flex;"
    echo "            flex-wrap: wrap;"
    echo "            gap: 15px;"
    echo "            margin: 20px 0;"
    echo "        }"
    echo ""
    echo "        .stat-item {"
    echo "            background: linear-gradient(135deg, #f8f9fa, #e9ecef);"
    echo "            padding: 10px 18px;"
    echo "            border-radius: 25px;"
    echo "            font-size: 0.9rem;"
    echo "            display: flex;"
    echo "            align-items: center;"
    echo "            gap: 8px;"
    echo "            box-shadow: 0 2px 10px rgba(0,0,0,0.05);"
    echo "        }"
    echo ""
    echo "        .highlight-feature {"
    echo "            background: linear-gradient(135deg, #ffeaa7, #fdcb6e);"
    echo "            padding: 18px;"
    echo "            border-radius: 15px;"
    echo "            margin: 20px 0;"
    echo "            border-left: 5px solid #e17055;"
    echo "            position: relative;"
    echo "        }"
    echo ""
    echo "        .highlight-feature::before {"
    echo "            content: '✨';"
    echo "            position: absolute;"
    echo "            top: 10px;"
    echo "            right: 15px;"
    echo "            font-size: 1.2rem;"
    echo "        }"
    echo ""
    echo "        .highlight-feature strong {"
    echo "            color: #2d3436;"
    echo "            font-size: 1.1rem;"
    echo "        }"
    echo ""
    echo "        .summary-section {"
    echo "            background: linear-gradient(135deg, #a29bfe, #6c5ce7);"
    echo "            color: white;"
    echo "            padding: 20px;"
    echo "            border-radius: 15px;"
    echo "            margin: 15px 0;"
    echo "            font-size: 1.1rem;"
    echo "        }"
    echo ""
    echo "        .button-group {"
    echo "            display: flex;"
    echo "            gap: 15px;"
    echo "            margin-top: 20px;"
    echo "            flex-wrap: wrap;"
    echo "        }"
    echo ""
    echo "        .view-details, .github-link, .daily-report-link {"
    echo "            display: inline-flex;"
    echo "            align-items: center;"
    echo "            gap: 8px;"
    echo "            padding: 12px 24px;"
    echo "            text-decoration: none;"
    echo "            border-radius: 25px;"
    echo "            font-weight: 500;"
    echo "            transition: all 0.3s ease;"
    echo "            box-shadow: 0 4px 15px rgba(0,0,0,0.1);"
    echo "        }"
    echo ""
    echo "        .view-details {"
    echo "            background: linear-gradient(135deg, #74b9ff, #0984e3);"
    echo "            color: white;"
    echo "        }"
    echo ""
    echo "        .github-link {"
    echo "            background: linear-gradient(135deg, #2d3436, #636e72);"
    echo "            color: white;"
    echo "        }"
    echo ""
    echo "        .daily-report-link {"
    echo "            background: linear-gradient(135deg, #00b894, #00cec9);"
    echo "            color: white;"
    echo "        }"
    echo ""
    echo "        .view-details:hover, .github-link:hover, .daily-report-link:hover {"
    echo "            transform: translateY(-2px);"
    echo "            box-shadow: 0 6px 20px rgba(0,0,0,0.15);"
    echo "        }"
    echo ""
    echo "        .last-updated {"
    echo "            text-align: center;"
    echo "            color: rgba(255,255,255,0.8);"
    echo "            margin-top: 40px;"
    echo "            font-size: 1rem;"
            echo "            padding: 20px;"
    echo "        }"
    echo ""
    echo "        @keyframes fadeInUp {"
    echo "            from { opacity: 0; transform: translateY(30px); }"
    echo "            to { opacity: 1; transform: translateY(0); }"
    echo "        }"
    echo ""
    echo "        @keyframes fadeIn {"
    echo "            from { opacity: 0; }"
    echo "            to { opacity: 1; }"
    echo "        }"
    echo ""
    echo "        @keyframes slideIn {"
    echo "            from { opacity: 0; transform: translateX(-20px); }"
    echo "            to { opacity: 1; transform: translateX(0); }"
    echo "        }"
    echo ""
    echo "        @media (max-width: 768px) {"
    echo "            .header h1 { font-size: 2.5rem; }"
    echo "            .header .subtitle { font-size: 1.1rem; }"
    echo "            .projects-grid { grid-template-columns: 1fr; }"
    echo "            .stats-bar { flex-direction: column; gap: 10px; }"
    echo "            .button-group { flex-direction: column; }"
    echo "        }"
    echo ""
    echo "        .floating-element {"
    echo "            position: fixed;"
    echo "            font-size: 2rem;"
    echo "            opacity: 0.1;"
    echo "            z-index: 0;"
    echo "            animation: float 6s ease-in-out infinite;"
    echo "        }"
    echo ""
    echo "        @keyframes float {"
    echo "            0%, 100% { transform: translateY(0px) rotate(0deg); }"
    echo "            50% { transform: translateY(-20px) rotate(10deg); }"
    echo "        }"
    echo "    </style>"
    echo "</head>"
    echo "<body>"
    echo "    <div class=\"floating-element\" style=\"top: 10%; left: 5%; animation-delay: 0s;\">🤖</div>"
    echo "    <div class=\"floating-element\" style=\"top: 20%; right: 10%; animation-delay: 1s;\">🧠</div>"
    echo "    <div class=\"floating-element\" style=\"bottom: 15%; left: 15%; animation-delay: 2s;\">💡</div>"
    echo "    <div class=\"floating-element\" style=\"bottom: 25%; right: 20%; animation-delay: 3s;\">🔗</div>"
    echo ""
    echo "    <div class=\"container\">"
    echo "        <div class=\"header\">"
    echo "            <h1><i class=\"fas fa-robot\"></i> OpenClaw AI Agent 项目聚合器</h1>"
    echo "            <div class=\"subtitle\">每日聚合 GitHub 上最受欢迎的 AI Agent 项目</div>"
    echo "            <div class=\"stats-bar\">"
    echo "                <div><i class=\"fas fa-calendar-day\"></i> 更新日期: $DATE</div>"
    echo "                <div><i class=\"fas fa-sync-alt\"></i> 自动更新: 每日14:25</div>"
    echo "                <div><i class=\"fas fa-globe\"></i> 数据源: GitHub API</div>"
    echo "            </div>"
    echo "        </div>"
    echo ""
    echo "        <div class=\"intro\">"
    echo "            <h2><i class=\"fas fa-star\"></i> 项目特色</h2>"
    echo "            <p>本聚合器每日自动分析 GitHub 上排名最靠前的 AI Agent 项目</p>"
    echo "            <p>提供一句话介绍、核心亮点和详细技术报告</p>"
    echo "            <p>所有分析均为自动化生成，帮助您快速了解最新的 AI Agent 技术趋势</p>"
    echo "            <div class=\"button-group\" style=\"justify-content: center; margin-top: 20px;\">"
    echo "                <a href=\"#daily-report\" class=\"daily-report-link\">"
    echo "                    <i class=\"fas fa-file-alt\"></i> 查看今日报告"
    echo "                </a>"
    echo "            </div>"
    echo "        </div>"
    echo ""
    echo "        <h2 style=\"text-align: center; color: white; margin: 40px 0 30px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3);\">"
    echo "            <i class=\"fas fa-fire\"></i> 今日热门 AI Agent 项目"
    echo "        </h2>"
    
    # Inject Product Updates
    if [ ! -z "$PRODUCT_UPDATES_HTML" ]; then
        echo "$PRODUCT_UPDATES_HTML"
    fi
    
    # Generate project cards for the index
    while IFS='|' read -r full_name html_url description language stars updated_at topics; do
        repo_name=$(basename "$full_name" | cut -d'/' -f2)
        
        # Extract one sentence summary and highlight from the markdown report
        if [ -f "$REPORT_DIR/${repo_name}_report.md" ]; then
            one_sentence_summary=$(grep "^## 一句话介绍" "$REPORT_DIR/${repo_name}_report.md" -A 1 | tail -1 | sed 's/^.*: //')
            highlight_feature=$(grep "^## 核心亮点" "$REPORT_DIR/${repo_name}_report.md" -A 1 | tail -1)
        else
            one_sentence_summary="项目一句话介绍待生成"
            highlight_feature="项目亮点待分析"
        fi
        
        echo "        <div class=\"project-card\">"
        echo "            <h3 class=\"project-title\">"
        echo "                <i class=\"fab fa-github\"></i> $full_name"
        echo "            </h3>"
        echo "            <div class=\"project-stats\">"
        echo "                <div class=\"stat-item\">"
        echo "                    <i class=\"fas fa-star\"></i> $stars 星标"
        echo "                </div>"
        echo "                <div class=\"stat-item\">"
        echo "                    <i class=\"fas fa-code\"></i> $LANGUAGE"
        echo "                </div>"
        echo "                <div class=\"stat-item\">"
        echo "                    <i class=\"fas fa-clock\"></i> $updated_at"
        echo "                </div>"
        echo "            </div>"
        echo "            <p class=\"project-description\">$description</p>"
        echo "            <div class=\"highlight-feature\">"
        echo "                <strong>核心亮点:</strong> $highlight_feature"
        echo "            </div>"
        echo "            <div class=\"summary-section\">"
        echo "                <strong>一句话介绍:</strong> $one_sentence_summary"
        echo "            </div>"
        echo "            <div class=\"button-group\">"
        echo "                <a href=\"./${repo_name}_report.html\" class=\"view-details\" target=\"_blank\">"
        echo "                    <i class=\"fas fa-external-link-alt\"></i> 详情报告"
        echo "                </a>"
        echo "                <a href=\"$html_url\" class=\"github-link\" target=\"_blank\">"
        echo "                    <i class=\"fab fa-github\"></i> GitHub"
        echo "                </a>"
        echo "            </div>"
        echo "        </div>"
    done <<< "$(echo "$TOP_REPOS")"
    
    echo "        <div id=\"daily-report\" class=\"intro\" style=\"margin-top: 50px; background: linear-gradient(135deg, #74b9ff, #0984e3); color: white;\">"
    echo "            <h2 style=\"color: white;\"><i class=\"fas fa-chart-line\"></i> 今日综合报告</h2>"
    echo "            <p>查看今天的完整AI Agent项目分析报告</p>"
    echo "            <div class=\"button-group\" style=\"justify-content: center; margin-top: 20px;\">"
    echo "                <a href=\"./analysis-$DATE.html\" class=\"daily-report-link\" target=\"_blank\">"
    echo "                    <i class=\"fas fa-file-contract\"></i> 今日详细报告"
    echo "                </a>"
    echo "            </div>"
    echo "        </div>"
    
    echo "        <div class=\"last-updated\">"
    echo "            <p><i class=\"fas fa-history\"></i> 最后更新: $DATE</p>"
    echo "            <p><i class=\"fas fa-bolt\"></i> 下一个更新周期: 北京时间明日14:25</p>"
    echo "            <p><i class=\"fas fa-rocket\"></i> powered by OpenClaw AI Assistant</p>"
    echo "        </div>"
    echo "    </div>"
    echo "</body>"
    echo "</html>"
} > "$INDEX_HTML_FILE"

# Step 5: Update the openclaw-say repository with the new reports
echo "正在更新 openclaw-say 仓库..."

# Clone the target repository if not already present
if [ ! -d "$WORKSPACE_DIR" ]; then
    git clone "https://github.com/$REPO_OWNER/$REPO_NAME.git" "$WORKSPACE_DIR"
fi

cd "$WORKSPACE_DIR"

# Create reports directory if it doesn't exist
mkdir -p reports/daily-ai-agent-analysis

# Copy all report files to the reports directory
cp "$INDEX_HTML_FILE" "reports/daily-ai-agent-analysis/index.html"
cp "$INDEX_HTML_FILE" "reports/daily-ai-agent-analysis/analysis-$DATE.html"
for report_html in "$REPORT_DIR"/*_report.html; do
    if [ -f "$report_html" ]; then
        cp "$report_html" "reports/daily-ai-agent-analysis/"
    fi
done

# Also copy markdown reports
for report_md in "$REPORT_DIR"/*_report.md; do
    if [ -f "$report_md" ]; then
        cp "$report_md" "reports/daily-ai-agent-analysis/"
    fi
done

# Add and commit the reports
git add reports/daily-ai-agent-analysis/
git config --local user.email "openclaw@example.com"
git config --local user.name "OpenClaw"
git commit -m "添加每日AI Agent项目聚合分析报告 $DATE - 增强版UI" || {
    echo "无变更提交或提交失败"
}

# Push to the repository
git push origin main

# Step 6: Deploy to Root (Fix for Issue #9)
# Copy the aggregator index to the root index.html to make it the landing page
# We need to adjust the relative links to point to the reports directory
ROOT_INDEX="$WORKSPACE_DIR/index.html"
sed 's|href="./|href="reports/daily-ai-agent-analysis/|g' "$WORKSPACE_DIR/reports/daily-ai-agent-analysis/index.html" > "$ROOT_INDEX"

# Also need to fix the analysis link which might not have ./ prefix in some contexts, but our script used ./
# Check if there are other links needing fix.
# The script uses: href="./${repo_name}_report.html" and href="./analysis-$DATE.html"
# The sed above handles these.

# Commit the root index change
cd "$WORKSPACE_DIR"
git add index.html
git commit -m "Deploy: Update root index.html with latest aggregator content" || echo "Root index already up to date"
git push origin main

echo "详细报告已生成并成功上传！"
echo "项目聚合器首页: https://0xagentlabs.github.io/openclaw-say/reports/daily-ai-agent-analysis/index.html"
echo "今日报告: https://0xagentlabs.github.io/openclaw-say/reports/daily-ai-agent-analysis/analysis-$DATE.html"

# Clean up
cd /
rm -rf "$REPORT_DIR"

echo "任务完成！"