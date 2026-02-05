#!/bin/bash

# AI Agent Repo Analyzer - Simple and Robust Version
# This script provides comprehensive analysis of AI Agent GitHub repositories

set -e  # Exit on any error

# Configuration
DATE=$(date +%Y-%m-%d)
REPORT_DIR="/tmp/ai-agent-analysis-$DATE"
REPO_OWNER="0xagentlabs"
REPO_NAME="openclaw-say"
WORKSPACE_DIR="/tmp/openclaw-say-task"

# Ensure required tools are available
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is required but not installed."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    exit 1
fi

# Create working directory
mkdir -p "$REPORT_DIR"
cd "$REPORT_DIR"

echo "Starting detailed AI Agent repository analysis for $DATE..."

# Step 1: Search for top AI Agent repositories on GitHub
echo "Searching for top AI Agent repositories..."
SEARCH_RESULTS=$(gh api \
  -H "Accept: application/vnd.github.v3+json" \
  "search/repositories?q=ai+agent+created:>$(date -d '30 days ago' +%Y-%m-%d)&sort=stars&order=desc&per_page=5")

# Step 2: Process the search results
TOP_REPOS=$(echo "$SEARCH_RESULTS" | jq -r '.items[0:5] | .[] | "\(.full_name)|\(.html_url)|\(.description)|\(.language)|\(.stargazers_count)|\(.updated_at)|\(.topics | join(", "))"')

echo "Found top repositories:"
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
    
    echo "Analyzing $full_name..."
    
    # Clone the repository
    local clone_dir="$REPORT_DIR/${repo}_analysis"
    if [ -d "$clone_dir" ]; then
        rm -rf "$clone_dir"
    fi
    
    git clone --depth 1 "$html_url" "$clone_dir" || {
        echo "Failed to clone $html_url, skipping..."
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
    
    # Determine application scope
    if [[ "$readme_content" =~ [Cc]hat|[Cc]onversational|[Cc]hatbot ]]; then
        app_scope="Conversational AI / Chatbots"
    elif [[ "$readme_content" =~ [Aa]gent|[Aa]utomation|[Tt]ask ]]; then
        app_scope="Autonomous Agents / Task Automation"
    elif [[ "$readme_content" =~ [Rr]easoning|[Rr]esearch|[Rr]etriev ]]; then
        app_scope="Research / RAG Systems"
    elif [[ "$readme_content" =~ [Tt]rading|[Cc]rypto|[Bb]lockchain ]]; then
        app_scope="Financial / Trading AI"
    elif [[ "$readme_content" =~ [Dd]evops|[Cc]ode|[Pp]rogramming ]]; then
        app_scope="Developer Tools / Code Assistance"
    else
        app_scope="General Purpose AI Agent"
    fi
    
    # Identify technology stack
    if [ -f "requirements.txt" ]; then
        dependencies=$(grep -E "(openai|anthropic|langchain|llama|transformers|pytorch|tensorflow|groq|ollama|crewai|autogen|agents)" requirements.txt | head -10 | tr '\n' ', ')
        tech_stack+=("Python")
        tech_stack+=("Dependencies: $(echo $dependencies | sed 's/,$//')")
    fi
    
    if [ -f "pyproject.toml" ]; then
        dependencies=$(grep -E "(openai|anthropic|langchain|llama|transformers|pytorch|tensorflow|groq|ollama|crewai|autogen|agents)" pyproject.toml | head -10 | tr '\n' ', ')
        tech_stack+=("Python (pyproject)")
        tech_stack+=("Dependencies: $(echo $dependencies | sed 's/,$//')")
    fi
    
    if [ -f "package.json" ]; then
        dependencies=$(grep -E "(openai|anthropic|langchain)" package.json | head -10 | tr '\n' ', ')
        tech_stack+=("JavaScript/Node.js")
        tech_stack+=("Dependencies: $(echo $dependencies | sed 's/,$//')")
    fi
    
    if [ -f "go.mod" ]; then
        tech_stack+=("Go")
    fi
    
    if [ -f "Cargo.toml" ]; then
        tech_stack+=("Rust")
    fi
    
    if [ -f "Dockerfile" ]; then
        tech_stack+=("Containerized")
    fi
    
    if [ -f "docker-compose.yml" ]; then
        tech_stack+=("Docker Compose")
    fi
    
    # Check for extension capabilities
    if [ -d "plugins" ] || [ -d "extensions" ] || [ -d "skills" ] || [ -d "tools" ]; then
        extension_capability="High - Has dedicated extension/plugin system"
    elif [ -f "docs/plugins.md" ] || [ -f "docs/extensions.md" ] || [ -f "PLUGINS.md" ]; then
        extension_capability="Medium - Plugin system documented"
    elif grep -r "plugin\|extension\|tool\|skill" . --include="*.md" --include="*.py" --include="*.js" --include="*.ts" | head -5; then
        extension_capability="Low to Medium - Extension capability detected in code"
    else
        extension_capability="Basic - Limited extension capability"
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
        strengths+=("High popularity ($stars ⭐)")
    elif [ "$stars" -gt 1000 ]; then
        strengths+=("Significant popularity ($stars ⭐)")
    elif [ "$stars" -gt 100 ]; then
        strengths+=("Growing popularity ($stars ⭐)")
    fi
    
    if [ "$forks" -gt 100 ]; then
        strengths+=("Active community (>$forks forks)")
    elif [ "$forks" -gt 10 ]; then
        strengths+=("Community interest ($forks forks)")
    fi
    
    if [ $has_docs -eq 1 ]; then
        strengths+=("Good documentation")
    fi
    
    if [ $has_examples -eq 1 ]; then
        strengths+=("Rich examples")
    fi
    
    if [ $has_tests -eq 1 ]; then
        strengths+=("Test coverage")
    fi
    
    if [ "$issues" -lt 50 ]; then
        strengths+=("Well maintained (low open issues: $issues)")
    elif [ $((issues * 100 / stars)) -lt 5 ]; then
        strengths+=("Relatively well maintained")
    fi
    
    if [ "$license" != "None" ] && [ "$license" != "null" ]; then
        strengths+=("Clear licensing ($license)")
    fi
    
    # Weaknesses
    if [ "$stars" -lt 50 ]; then
        weaknesses+=("Low popularity (<50 ⭐)")
    fi
    
    if [ $has_docs -eq 0 ]; then
        weaknesses+=("Limited documentation")
    fi
    
    if [ $has_examples -eq 0 ]; then
        weaknesses+=("Missing examples")
    fi
    
    if [ $has_tests -eq 0 ]; then
        weaknesses+=("No visible test suite")
    fi
    
    if [ "$issues" -gt 200 ]; then
        weaknesses+=("High number of open issues ($issues)")
    fi
    
    # Create detailed analysis report for this repository
    local report_file="$REPORT_DIR/${repo}_report.md"
    cat > "$report_file" << EOL
# Analysis Report: $full_name

## Repository Overview
- **URL**: $html_url
- **Description**: $description
- **Primary Language**: $language
- **Stars**: $stars
- **Forks**: $forks
- **Open Issues**: $issues
- **License**: $license
- **Last Updated**: $updated_at
- **Topics**: $topics

## Application Scope
$app_scope

## Technology Stack
EOL

    if [ ${#tech_stack[@]} -gt 0 ]; then
        for tech in "${tech_stack[@]}"; do
            echo "- $tech" >> "$report_file"
        done
    else
        echo "- Not clearly specified" >> "$report_file"
    fi

    cat >> "$report_file" << EOL

## Extension Capabilities
$extension_capability

## Repository Structure
\`\`\`text
$file_structure
\`\`\`

## Strengths
EOL

    if [ ${#strengths[@]} -gt 0 ]; then
        for strength in "${strengths[@]}"; do
            echo "- $strength" >> "$report_file"
        done
    else
        echo "- None identified" >> "$report_file"
    fi

    cat >> "$report_file" << EOL

## Potential Weaknesses
EOL

    if [ ${#weaknesses[@]} -gt 0 ]; then
        for weakness in "${weaknesses[@]}"; do
            echo "- $weakness" >> "$report_file"
        done
    else
        echo "- None identified" >> "$report_file"
    fi

    cat >> "$report_file" << EOL

## README Preview
\`\`\`markdown
$(echo "$readme_content" | head -50)
\`\`\`

## Additional Notes
- Documentation: $(if [ $has_docs -eq 1 ]; then echo "Present"; else echo "Missing or minimal"; fi)
- Tests: $(if [ $has_tests -eq 1 ]; then echo "Present"; else echo "Missing or minimal"; fi)
- Examples: $(if [ $has_examples -eq 1 ]; then echo "Present"; else echo "Missing or minimal"; fi)

---
*Analysis performed on $DATE*
EOL

    # Create a simple HTML version of the report (without complex replacements that cause issues)
    local html_report_file="$REPORT_DIR/${repo}_report.html"
    {
        echo "<!DOCTYPE html>"
        echo "<html lang=\"en\">"
        echo "<head>"
        echo "    <meta charset=\"UTF-8\">"
        echo "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
        echo "    <title>Analysis Report: $full_name</title>"
        echo "    <style>"
        echo "        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }"
        echo "        .container { background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }"
        echo "        h1 { color: #2c3e50; }"
        echo "        h2 { color: #3498db; border-bottom: 2px solid #3498db; }"
        echo "        .repo-link { display: inline-block; background: #3498db; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 10px 0; }"
        echo "        .repo-link:hover { background: #2980b9; }"
        echo "        .stats { display: flex; flex-wrap: wrap; gap: 15px; margin: 20px 0; }"
        echo "        .stat-box { background: #ecf0f1; padding: 10px 15px; border-radius: 5px; }"
        echo "        ul { margin: 10px 0; padding-left: 20px; }"
        echo "        li { margin-bottom: 5px; }"
        echo "        .section { margin: 25px 0; }"
        echo "        .strengths { background: #d4edda; padding: 15px; border-left: 4px solid #28a745; }"
        echo "        .weaknesses { background: #f8d7da; padding: 15px; border-left: 4px solid #dc3545; }"
        echo "    </style>"
        echo "</head>"
        echo "<body>"
        echo "    <div class=\"container\">"
        echo "        <h1>Repository Analysis Report</h1>"
        echo "        <h2>$full_name</h2>"
        echo "        <a href=\"$html_url\" class=\"repo-link\" target=\"_blank\">Visit Repository</a>"
        
        echo "        <div class=\"stats\">"
        echo "            <div class=\"stat-box\">⭐ Stars: $stars</div>"
        echo "            <div class=\"stat-box\">🔄 Forks: $forks</div>"
        echo "            <div class=\"stat-box\">📋 Issues: $issues</div>"
        echo "            <div class=\"stat-box\">🏷️ Language: $language</div>"
        echo "            <div class=\"stat-box\">📄 License: $license</div>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>Description</h3>"
        echo "            <p>$description</p>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>Application Scope</h3>"
        echo "            <p>$app_scope</p>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>Technology Stack</h3>"
        echo "            <ul>"
        if [ ${#tech_stack[@]} -gt 0 ]; then
            for tech in "${tech_stack[@]}"; do
                echo "                <li>$tech</li>"
            done
        else
            echo "                <li>Not clearly specified</li>"
        fi
        echo "            </ul>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>Extension Capabilities</h3>"
        echo "            <p>$extension_capability</p>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>Repository Structure</h3>"
        echo "            <pre>$file_structure</pre>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>Strengths</h3>"
        echo "            <div class=\"strengths\">"
        echo "                <ul>"
        if [ ${#strengths[@]} -gt 0 ]; then
            for strength in "${strengths[@]}"; do
                echo "                    <li>$strength</li>"
            done
        else
            echo "                    <li>None identified</li>"
        fi
        echo "                </ul>"
        echo "            </div>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>Potential Weaknesses</h3>"
        echo "            <div class=\"weaknesses\">"
        echo "                <ul>"
        if [ ${#weaknesses[@]} -gt 0 ]; then
            for weakness in "${weaknesses[@]}"; do
                echo "                    <li>$weakness</li>"
            done
        else
            echo "                    <li>None identified</li>"
        fi
        echo "                </ul>"
        echo "            </div>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>README Preview</h3>"
        echo "            <pre>$(echo "$readme_content" | head -50)</pre>"
        echo "        </div>"
        
        echo "        <div class=\"section\">"
        echo "            <h3>Additional Notes</h3>"
        echo "            <ul>"
        echo "                <li>Documentation: $(if [ $has_docs -eq 1 ]; then echo "Present"; else echo "Missing or minimal"; fi)</li>"
        echo "                <li>Tests: $(if [ $has_tests -eq 1 ]; then echo "Present"; else echo "Missing or minimal"; fi)</li>"
        echo "                <li>Examples: $(if [ $has_examples -eq 1 ]; then echo "Present"; else echo "Missing or minimal"; fi)</li>"
        echo "            </ul>"
        echo "        </div>"
        
        echo "        <p><em>Analysis performed on $DATE</em></p>"
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

# Step 4: Create a simple summary HTML report
SUMMARY_HTML_FILE="$REPORT_DIR/ai_agent_analysis_$DATE.html"
{
    echo "<!DOCTYPE html>"
    echo "<html lang=\"en\">"
    echo "<head>"
    echo "    <meta charset=\"UTF-8\">"
    echo "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
    echo "    <title>Daily AI Agent Repository Analysis - $DATE</title>"
    echo "    <style>"
    echo "        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }"
    echo "        .container { background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }"
    echo "        h1 { color: #2c3e50; text-align: center; }"
    echo "        h2 { color: #3498db; border-bottom: 2px solid #3498db; }"
    echo "        .repo-card { background: white; margin: 20px 0; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid #3498db; }"
    echo "        .repo-title { color: #2c3e50; margin: 0 0 10px 0; }"
    echo "        .repo-stats { display: flex; flex-wrap: wrap; gap: 15px; margin: 15px 0; }"
    echo "        .stat-item { background: #ecf0f1; padding: 5px 10px; border-radius: 5px; font-size: 0.9em; }"
    echo "        .repo-link { display: inline-block; background: #3498db; color: white; padding: 8px 16px; text-decoration: none; border-radius: 5px; margin-top: 10px; }"
    echo "        .repo-link:hover { background: #2980b9; }"
    echo "        .section-title { color: #3498db; border-bottom: 2px solid #3498db; padding-bottom: 5px; }"
    echo "        .report-list { margin-top: 20px; }"
    echo "        .report-item { margin: 10px 0; }"
    echo "        footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #7f8c8d; }"
    echo "    </style>"
    echo "</head>"
    echo "<body>"
    echo "    <div class=\"container\">"
    echo "        <h1>Daily AI Agent Repository Analysis</h1>"
    echo "        <h2>Top AI Agent Projects from GitHub - $DATE</h2>"
    
    # Generate repo cards for the summary
    while IFS='|' read -r full_name html_url description language stars updated_at topics; do
        repo_name=$(basename "$full_name" | cut -d'/' -f2)
        echo "        <div class=\"repo-card\">"
        echo "            <h3 class=\"repo-title\">$full_name</h3>"
        echo "            <p>$description</p>"
        echo "            <div class=\"repo-stats\">"
        echo "                <div class=\"stat-item\">⭐ $stars stars</div>"
        echo "                <div class=\"stat-item\">Lang: $language</div>"
        echo "                <div class=\"stat-item\">📅 Updated: $updated_at</div>"
        echo "            </div>"
        echo "            <a href=\"$html_url\" class=\"repo-link\" target=\"_blank\">View on GitHub</a>"
        echo "            <a href=\"./${repo_name}_report.html\" class=\"repo-link\" target=\"_blank\" style=\"background: #2ecc71; margin-left: 10px;\">View Detailed Report</a>"
        echo "        </div>"
    done <<< "$(echo "$TOP_REPOS")"
    
    echo "        <div class=\"report-list\">"
    echo "            <h3 class=\"section-title\">Individual Repository Reports</h3>"
    for report_html in "$REPORT_DIR"/*_report.html; do
        if [ -f "$report_html" ]; then
            repo_name=$(basename "$report_html" _report.html)
            title=$(head -10 "$REPORT_DIR/${repo_name}_report.md" | grep "# Analysis Report:" | sed 's/# Analysis Report: //')
            echo "            <div class=\"report-item\">"
            echo "                <a href=\"./${repo_name}_report.html\" class=\"repo-link\" target=\"_blank\" style=\"background: #9b59b6;\">$title</a>"
            echo "            </div>"
        fi
    done
    echo "        </div>"
    
    echo "        <footer>"
    echo "            <p>Automated AI Agent Repository Analysis</p>"
    echo "            <p>Generated by OpenClaw AI Assistant</p>"
    echo "            <p>Reports available at: https://0xagentlabs.github.io/openclaw-say/reports/daily-ai-agent-analysis/</p>"
    echo "        </footer>"
    echo "    </div>"
    echo "</body>"
    echo "</html>"
} > "$SUMMARY_HTML_FILE"

# Step 5: Update the openclaw-say repository with the new reports
echo "Updating openclaw-say repository with detailed analysis reports..."

# Clone the target repository if not already present
if [ ! -d "$WORKSPACE_DIR" ]; then
    git clone "https://github.com/$REPO_OWNER/$REPO_NAME.git" "$WORKSPACE_DIR"
fi

cd "$WORKSPACE_DIR"

# Create reports directory if it doesn't exist
mkdir -p reports/daily-ai-agent-analysis

# Copy all report files to the reports directory
cp "$SUMMARY_HTML_FILE" "reports/daily-ai-agent-analysis/analysis-$DATE.html"
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
git commit -m "Add detailed daily AI agent analysis reports for $DATE" || {
    echo "No changes to commit or commit failed"
}

# Push to the repository
git push origin main

echo "Detailed reports generated and uploaded successfully!"
echo "Summary report available at: https://0xagentlabs.github.io/openclaw-say/reports/daily-ai-agent-analysis/analysis-$DATE.html"

# Clean up
cd /
rm -rf "$REPORT_DIR"

echo "Task completed successfully!"