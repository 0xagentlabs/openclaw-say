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

# Step 1: Search for top AI Agent repositories on GitHub
echo "搜索顶级AI Agent项目..."
SEARCH_RESULTS=$(gh api \
  -H "Accept: application/vnd.github.v3+json" \
  "search/repositories?q=ai+agent+created:>$(date -d '30 days ago' +%Y-%m-%d)&sort=stars&order=desc&per_page=8")

# Step 2: Process the search results
TOP_REPOS=$(echo "$SEARCH_RESULTS" | jq -r '.items[0:8] | .[] | "\(.full_name)|\(.html_url)|\(.description)|\(.language)|\(.stargazers_count)|\(.updated_at)|\(.topics | join(", "))"')

echo "找到顶级项目："
echo "$TOP_REPOS"

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
    
    if [[ "$readme_content" =~ [Aa]utonomous|[Ss]elf-[Ll]earning|[Aa]dap[t]*ive ]]; then
        core_features+=("自主学习能力")
    fi
    
    if [[ "$readme_content" =~ [Tt]ool.*[Cc]alling|[Ff]unction.*[Cc]alling|[Aa]ction.*[Pp]lanning ]]; then
        core_features+=("工具调用和行动规划")
    fi
    
    if [[ "$readme_content" =~ [Mm]emor[y]*|[Ll]ong.*[Tt]erm.*[Mm]emor[y]* ]]; then
        core_features+=("长期记忆管理")
    fi
    
    if [[ "$readme_content" =~ [Rr][Aa][Gg]|[Rr]etriev[a-z]*[ -][Ee]nhanc[a-z]*[ -][Gg]eneration ]]; then
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

# Step 4: Create an index HTML page for the aggregator
INDEX_HTML_FILE="$REPORT_DIR/index.html"
{
    echo "<!DOCTYPE html>"
    echo "<html lang=\"zh-CN\">"
    echo "<head>"
    echo "    <meta charset=\"UTF-8\">"
    echo "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
    echo "    <title>OpenClaw AI Agent 项目聚合器 - $DATE</title>"
    echo "    <style>"
    echo "        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }"
    echo "        .container { max-width: 1200px; margin: 0 auto; }"
    echo "        .header { text-align: center; color: white; margin-bottom: 30px; }"
    echo "        h1 { margin: 0; font-size: 2.5em; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }"
    echo "        .subtitle { font-size: 1.2em; opacity: 0.9; margin-top: 10px; }"
    echo "        .projects-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 25px; }"
    echo "        .project-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 10px 20px rgba(0,0,0,0.1); transition: transform 0.3s ease; }"
    echo "        .project-card:hover { transform: translateY(-5px); }"
    echo "        .project-title { color: #2c3e50; margin: 0 0 10px 0; font-size: 1.3em; }"
    echo "        .project-description { color: #7f8c8d; margin: 10px 0; font-size: 0.95em; }"
    echo "        .project-stats { display: flex; flex-wrap: wrap; gap: 12px; margin: 15px 0; }"
    echo "        .stat-item { background: #f8f9fa; padding: 6px 12px; border-radius: 20px; font-size: 0.85em; }"
    echo "        .highlight-feature { background: #ffeaa7; padding: 12px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #fdcb6e; }"
    echo "        .view-details { display: inline-block; background: #74b9ff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin-top: 10px; }"
    echo "        .view-details:hover { background: #0984e3; }"
    echo "        .github-link { display: inline-block; background: #2d3436; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin-top: 10px; margin-left: 10px; }"
    echo "        .github-link:hover { background: #000; }"
    echo "        .last-updated { text-align: center; color: white; margin-top: 30px; font-size: 0.9em; opacity: 0.8; }"
    echo "        .intro { background: rgba(255,255,255,0.2); padding: 20px; border-radius: 10px; color: white; margin-bottom: 30px; text-align: center; }"
    echo "    </style>"
    echo "</head>"
    echo "<body>"
    echo "    <div class=\"container\">"
    echo "        <div class=\"header\">"
    echo "            <h1>🦞 OpenClaw AI Agent 项目聚合器</h1>"
    echo "            <div class=\"subtitle\">每日聚合 GitHub 上最受欢迎的 AI Agent 项目</div>"
    echo "        </div>"
    
    echo "        <div class=\"intro\">"
    echo "            <p>本聚合器每日自动分析 GitHub 上排名最靠前的 AI Agent 项目，提供一句话介绍、核心亮点和详细技术报告。</p>"
    echo "            <p>所有分析均为自动化生成，旨在帮助用户快速了解最新的 AI Agent 技术趋势。</p>"
    echo "        </div>"
    
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
        echo "            <h3 class=\"project-title\">$full_name</h3>"
        echo "            <div class=\"project-stats\">"
        echo "                <div class=\"stat-item\">⭐ $stars 星标</div>"
        echo "                <div class=\"stat-item\">$LANGUAGE</div>"
        echo "                <div class=\"stat-item\">🔄 $updated_at</div>"
        echo "            </div>"
        echo "            <p class=\"project-description\">$description</p>"
        echo "            <div class=\"highlight-feature\">"
        echo "                <strong>核心亮点:</strong> $highlight_feature"
        echo "            </div>"
        echo "            <p><strong>一句话介绍:</strong> $one_sentence_summary</p>"
        echo "            <a href=\"./${repo_name}_report.html\" class=\"view-details\" target=\"_blank\">查看详情报告</a>"
        echo "            <a href=\"$html_url\" class=\"github-link\" target=\"_blank\">访问GitHub</a>"
        echo "        </div>"
    done <<< "$(echo "$TOP_REPOS")"
    
    echo "        <div class=\"last-updated\">"
    echo "            <p>最后更新: $DATE | 数据来源: GitHub API</p>"
    echo "            <p>下一个更新周期: 北京时间明日14:00</p>"
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
git commit -m "添加每日AI Agent项目聚合分析报告 $DATE" || {
    echo "无变更提交或提交失败"
}

# Push to the repository
git push origin main

echo "详细报告已生成并成功上传！"
echo "项目聚合器首页: https://0xagentlabs.github.io/openclaw-say/reports/daily-ai-agent-analysis/index.html"
echo "今日报告: https://0xagentlabs.github.io/openclaw-say/reports/daily-ai-agent-analysis/analysis-$DATE.html"

# Clean up
cd /
rm -rf "$REPORT_DIR"

echo "任务完成！"