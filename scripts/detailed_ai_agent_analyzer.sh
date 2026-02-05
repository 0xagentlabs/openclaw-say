#!/bin/bash

# AI Agent Repo Analyzer - Detailed Analysis
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
TOP_REPOS=$(echo "$SEARCH_RESULTS" | jq -r '.items[0:5] | .[] | "\(.full_name)|\(.html_url)|\(.description)|\(.language)|\(.stargazers_count)|\(.updated_at)|\(.topics | join(\", \"))"')

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
    
    if [ "$updated_at" -lt "$(date -d '6 months ago' -Iseconds)" ]; then
        weaknesses+=("Potentially inactive development")
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

    # Create HTML version of the report
    local html_report_file="$REPORT_DIR/${repo}_report.html"
    cat > "$html_report_file" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Repository Analysis - FULL_NAME_PLACEHOLDER</title>
    <style>
        :root {
            --primary: #4f46e5;
            --secondary: #7c3aed;
            --light: #f9fafb;
            --dark: #1f2937;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: var(--dark);
            background: linear-gradient(135deg, #f0f9ff 0%, #fdf2f8 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        h1 {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }
        
        .repo-link {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 25px;
            text-decoration: none;
            margin-top: 1rem;
            transition: all 0.3s ease;
        }
        
        .repo-link:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        .summary-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
            padding: 1.5rem;
            background: var(--light);
        }
        
        .stat-card {
            background: white;
            padding: 1rem;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .stat-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--primary);
        }
        
        .section {
            padding: 1.5rem;
            margin: 1rem 0;
        }
        
        .section-title {
            color: var(--secondary);
            border-bottom: 2px solid var(--secondary);
            padding-bottom: 0.5rem;
            margin: 1rem 0 0.5rem 0;
            font-size: 1.5rem;
        }
        
        .strengths {
            background: #ecfdf5;
            border-left: 4px solid var(--success);
            padding: 1rem;
            margin: 1rem 0;
        }
        
        .weaknesses {
            background: #fef2f2;
            border-left: 4px solid var(--danger);
            padding: 1rem;
            margin: 1rem 0;
        }
        
        .readme-preview {
            background: #f8fafc;
            padding: 1rem;
            border-radius: 8px;
            font-family: monospace;
            white-space: pre-wrap;
            max-height: 300px;
            overflow-y: auto;
        }
        
        .repo-structure {
            background: #f8fafc;
            padding: 1rem;
            border-radius: 8px;
            font-family: monospace;
            white-space: pre;
            overflow-x: auto;
        }
        
        ul {
            padding-left: 1.5rem;
            margin: 0.5rem 0;
        }
        
        li {
            margin-bottom: 0.5rem;
        }
        
        footer {
            background: var(--dark);
            color: white;
            text-align: center;
            padding: 1.5rem;
            margin-top: 2rem;
        }
        
        @media (max-width: 768px) {
            .summary-stats {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Repository Analysis Report</h1>
            <h2>FULL_NAME_PLACEHOLDER</h2>
            <a href="HTML_URL_PLACEHOLDER" class="repo-link" target="_blank">Visit Repository</a>
        </header>

        <div class="summary-stats">
            <div class="stat-card">
                <div class="stat-value">STARS_PLACEHOLDER</div>
                <div>Stars</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">FORKS_PLACEHOLDER</div>
                <div>Forks</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">ISSUES_PLACEHOLDER</div>
                <div>Open Issues</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">LANGUAGE_PLACEHOLDER</div>
                <div>Primary Language</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">LICENSE_PLACEHOLDER</div>
                <div>License</div>
            </div>
        </div>

        <div class="section">
            <h3 class="section-title">Description</h3>
            <p>DESCRIPTION_PLACEHOLDER</p>
        </div>

        <div class="section">
            <h3 class="section-title">Application Scope</h3>
            <p>APP_SCOPE_PLACEHOLDER</p>
        </div>

        <div class="section">
            <h3 class="section-title">Technology Stack</h3>
            <ul>
                TECH_STACK_PLACEHOLDER
            </ul>
        </div>

        <div class="section">
            <h3 class="section-title">Extension Capabilities</h3>
            <p>EXTENSION_CAPABILITY_PLACEHOLDER</p>
        </div>

        <div class="section">
            <h3 class="section-title">Repository Structure</h3>
            <div class="repo-structure">
STRUCTURE_PLACEHOLDER
            </div>
        </div>

        <div class="section">
            <h3 class="section-title">Strengths</h3>
            <div class="strengths">
                <ul>
                    STRENGTHS_PLACEHOLDER
                </ul>
            </div>
        </div>

        <div class="section">
            <h3 class="section-title">Potential Weaknesses</h3>
            <div class="weaknesses">
                <ul>
                    WEAKNESSES_PLACEHOLDER
                </ul>
            </div>
        </div>

        <div class="section">
            <h3 class="section-title">README Preview</h3>
            <div class="readme-preview">
README_PREVIEW_PLACEHOLDER
            </div>
        </div>

        <footer>
            <p>Analysis performed on DATE_PLACEHOLDER</p>
            <p>Generated by OpenClaw AI Assistant</p>
        </footer>
    </div>
</body>
</html>
EOF

    # Replace placeholders in HTML template
    sed -i "s|FULL_NAME_PLACEHOLDER|$full_name|g" "$html_report_file"
    sed -i "s|HTML_URL_PLACEHOLDER|$html_url|g" "$html_report_file"
    sed -i "s|STARS_PLACEHOLDER|$stars|g" "$html_report_file"
    sed -i "s|FORKS_PLACEHOLDER|$forks|g" "$html_report_file"
    sed -i "s|ISSUES_PLACEHOLDER|$issues|g" "$html_report_file"
    sed -i "s|LANGUAGE_PLACEHOLDER|$language|g" "$html_report_file"
    sed -i "s|LICENSE_PLACEHOLDER|$license|g" "$html_report_file"
    sed -i "s|DESCRIPTION_PLACEHOLDER|$description|g" "$html_report_file"
    sed -i "s|APP_SCOPE_PLACEHOLDER|$app_scope|g" "$html_report_file"
    
    # Format tech stack for HTML
    local tech_html=""
    for tech in "${tech_stack[@]}"; do
        tech_html+="<li>$tech</li>"
    done
    if [ -z "$tech_html" ]; then
        tech_html="<li>Not clearly specified</li>"
    fi
    sed -i "s|TECH_STACK_PLACEHOLDER|$tech_html|g" "$html_report_file"
    
    sed -i "s|EXTENSION_CAPABILITY_PLACEHOLDER|$extension_capability|g" "$html_report_file"
    sed -i "s|STRUCTURE_PLACEHOLDER|$(echo "$file_structure" | sed 's/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g')|g" "$html_report_file"
    
    # Format strengths for HTML
    local strengths_html=""
    for strength in "${strengths[@]}"; do
        strengths_html+="<li>$strength</li>"
    done
    if [ -z "$strengths_html" ]; then
        strengths_html="<li>None identified</li>"
    fi
    sed -i "s|STRENGTHS_PLACEHOLDER|$strengths_html|g" "$html_report_file"
    
    # Format weaknesses for HTML
    local weaknesses_html=""
    for weakness in "${weaknesses[@]}"; do
        weaknesses_html+="<li>$weakness</li>"
    done
    if [ -z "$weaknesses_html" ]; then
        weaknesses_html="<li>None identified</li>"
    fi
    sed -i "s|WEAKNESSES_PLACEHOLDER|$weaknesses_html|g" "$html_report_file"
    
    sed -i "s|README_PREVIEW_PLACEHOLDER|$(echo "$readme_content" | head -50 | sed 's/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g')|g" "$html_report_file"
    sed -i "s|DATE_PLACEHOLDER|$DATE|g" "$html_report_file"

    # Return to main directory
    cd "$REPORT_DIR"
}

# Step 3: Analyze each repository
while IFS='|' read -r full_name html_url description language stars updated_at topics; do
    analyze_repo "$full_name" "$html_url" "$description" "$language" "$stars" "$updated_at" "$topics"
done <<< "$(echo "$TOP_REPOS")"

# Step 4: Create a summary HTML report
SUMMARY_HTML_FILE="$REPORT_DIR/ai_agent_analysis_$DATE.html"
cat > "$SUMMARY_HTML_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily AI Agent Repository Analysis - DATE_PLACEHOLDER</title>
    <style>
        :root {
            --primary: #4f46e5;
            --secondary: #7c3aed;
            --light: #f9fafb;
            --dark: #1f2937;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: var(--dark);
            background: linear-gradient(135deg, #f0f9ff 0%, #fdf2f8 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        h1 {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }
        
        .subtitle {
            font-size: 1.2rem;
            opacity: 0.9;
            margin-bottom: 1rem;
        }
        
        .repo-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.5rem;
            padding: 2rem;
        }
        
        .repo-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            border: 1px solid #e2e8f0;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .repo-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }
        
        .repo-title {
            color: var(--primary);
            margin: 0 0 0.5rem 0;
            font-size: 1.25rem;
        }
        
        .repo-description {
            color: var(--dark);
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }
        
        .repo-stats {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            margin: 1rem 0;
        }
        
        .stat-item {
            background: #eef2ff;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .repo-link {
            display: inline-block;
            background: var(--primary);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 25px;
            text-decoration: none;
            margin-top: 1rem;
            font-size: 0.9rem;
        }
        
        .repo-link:hover {
            background: var(--secondary);
        }
        
        .individual-reports {
            padding: 2rem;
            background: var(--light);
        }
        
        .section-title {
            color: var(--secondary);
            border-bottom: 2px solid var(--secondary);
            padding-bottom: 0.5rem;
            margin: 1rem 0 0.5rem 0;
            font-size: 1.5rem;
        }
        
        .report-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }
        
        .report-link {
            display: block;
            background: white;
            padding: 1rem;
            border-radius: 8px;
            text-decoration: none;
            color: var(--dark);
            border: 1px solid #e2e8f0;
            transition: all 0.3s ease;
        }
        
        .report-link:hover {
            background: #eef2ff;
            transform: translateX(5px);
        }
        
        footer {
            background: var(--dark);
            color: white;
            text-align: center;
            padding: 2rem;
        }
        
        @media (max-width: 768px) {
            .repo-grid {
                grid-template-columns: 1fr;
            }
            
            .report-list {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Daily AI Agent Repository Analysis</h1>
            <div class="subtitle">Top AI Agent Projects from GitHub - DATE_PLACEHOLDER</div>
        </header>

        <div class="repo-grid">
            REPO_CARDS_PLACEHOLDER
        </div>

        <div class="individual-reports">
            <h2 class="section-title">Individual Repository Reports</h2>
            <div class="report-list">
                INDIVIDUAL_REPORTS_PLACEHOLDER
            </div>
        </div>

        <footer>
            <p>Automated AI Agent Repository Analysis</p>
            <p>Generated by OpenClaw AI Assistant</p>
        </footer>
    </div>
</body>
</html>
EOF

# Generate repo cards for the summary
REPO_CARDS=""
INDIVIDUAL_REPORTS=""

# Find all generated report files
for report_html in "$REPORT_DIR"/*_report.html; do
    if [ -f "$report_html" ]; then
        # Extract repo name from file path
        repo_name=$(basename "$report_html" _report.html)
        
        # Read basic info from the markdown report to populate the summary
        md_report="$REPORT_DIR/${repo_name}_report.md"
        if [ -f "$md_report" ]; then
            title=$(head -5 "$md_report" | grep "# Analysis Report:" | sed 's/# Analysis Report: //')
            description=$(grep "^- **Description**:" "$md_report" | sed 's/- **Description**: //')
            stars=$(grep "^- **Stars**:" "$md_report" | sed 's/- **Stars**: //')
            language=$(grep "^- **Primary Language**:" "$md_report" | sed 's/- **Primary Language**: //')
            updated=$(grep "^- **Last Updated**:" "$md_report" | sed 's/- **Last Updated**: //')
            
            # Add to repo cards
            REPO_CARDS+="<div class=\"repo-card\">
                <h3 class=\"repo-title\">$title</h3>
                <p class=\"repo-description\">$description</p>
                <div class=\"repo-stats\">
                    <div class=\"stat-item\">⭐ $stars stars</div>
                    <div class=\"stat-item\">$LANGUAGE: $language</div>
                    <div class=\"stat-item\">📅 $updated</div>
                </div>
                <a href=\"./${repo_name}_report.html\" class=\"repo-link\" target=\"_blank\">View Detailed Report</a>
            </div>"
            
            # Add to individual reports list
            INDIVIDUAL_REPORTS+="<a href=\"./${repo_name}_report.html\" class=\"report-link\">$title</a>"
        fi
    fi
done

# Replace placeholders in summary HTML
sed -i "s|DATE_PLACEHOLDER|$DATE|g" "$SUMMARY_HTML_FILE"
sed -i "s|REPO_CARDS_PLACEHOLDER|$REPO_CARDS|g" "$SUMMARY_HTML_FILE"
sed -i "s|INDIVIDUAL_REPORTS_PLACEHOLDER|$INDIVIDUAL_REPORTS|g" "$SUMMARY_HTML_FILE"

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

# Also copy markdown reports if needed
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