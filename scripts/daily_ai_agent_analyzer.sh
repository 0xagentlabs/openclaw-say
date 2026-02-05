#!/bin/bash

# AI Agent Repo Analyzer - Daily Task
# This script runs daily at 14:00 to find, analyze, and report on top AI Agent GitHub repositories

set -e  # Exit on any error

# Configuration
DATE=$(date +%Y-%m-%d)
REPORT_DIR="/tmp/ai-agent-analysis-$DATE"
GITHUB_TOKEN="$GITHUB_TOKEN"  # Should be set in environment
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

echo "Starting AI Agent repository analysis for $DATE..."

# Step 1: Search for top AI Agent repositories on GitHub
echo "Searching for top AI Agent repositories..."
SEARCH_RESULTS=$(gh api \
  -H "Accept: application/vnd.github.v3+json" \
  "search/repositories?q=ai+agent+created:>$(date -d '7 days ago' +%Y-%m-%d)&sort=stars&order=desc&per_page=5")

# Step 2: Process the search results and select top 3
TOP_REPOS=$(echo "$SEARCH_RESULTS" | jq -r '.items[0:3] | .[] | "\(.full_name)|\(.html_url)|\(.description)|\(.language)|\(.stargazers_count)|\(.updated_at)"')

echo "Found top repositories:"
echo "$TOP_REPOS"

# Step 3: Clone, analyze and create reports for each repository
REPORT_CONTENT="# Daily AI Agent Repository Analysis Report - $DATE\n\n"
REPORT_CONTENT+="This report analyzes the top AI Agent repositories from GitHub.\n\n"

while IFS='|' read -r full_name html_url description language stars updated_at; do
    echo "Analyzing $full_name..."
    
    # Extract owner and repo name
    owner=$(echo "$full_name" | cut -d'/' -f1)
    repo=$(echo "$full_name" | cut -d'/' -f2)
    
    # Clone the repository
    clone_dir="$REPORT_DIR/${repo}_analysis"
    if [ -d "$clone_dir" ]; then
        rm -rf "$clone_dir"
    fi
    
    git clone --depth 1 "$html_url" "$clone_dir" || {
        echo "Failed to clone $html_url, skipping..."
        continue
    }
    
    cd "$clone_dir"
    
    # Analyze the repository
    echo "Creating analysis for $full_name..."
    
    # Get repository statistics
    readme_content=""
    if [ -f "README.md" ]; then
        readme_content=$(head -50 "README.md" | sed 's/$$/\\n/' | tr -d '\n')
    elif [ -f "readme.md" ]; then
        readme_content=$(head -50 "readme.md" | sed 's/$$/\\n/' | tr -d '\n')
    elif [ -f "Readme.md" ]; then
        readme_content=$(head -50 "Readme.md" | sed 's/$$/\\n/' | tr -d '\n')
    fi
    
    # Count important files
    has_requirements=$(find . -name "requirements.txt" -o -name "pyproject.toml" -o -name "package.json" | wc -l)
    has_docs=$(find . -name "docs" -type d | wc -l)
    has_tests=$(find . -name "*test*" -type d | wc -l)
    has_examples=$(find . -name "examples" -o -name "example" -type d | wc -l)
    
    # Detect main technologies
    tech_stack=""
    if [ -f "requirements.txt" ]; then
        tech_stack+="Python packages: "; tech_stack+=$(grep -E "(openai|anthropic|langchain|llama|transformers|pytorch|tensorflow)" requirements.txt | head -5 | tr '\n' ',' | sed 's/,$//'); tech_stack+=" | "
    fi
    
    if [ -f "pyproject.toml" ]; then
        tech_stack+="Python project: "; tech_stack+=$(grep -E "(openai|anthropic|langchain|llama|transformers|pytorch|tensorflow)" pyproject.toml | head -5 | tr '\n' ',' | sed 's/,$//'); tech_stack+=" | "
    fi
    
    if [ -f "package.json" ]; then
        tech_stack+="Node.js packages: "; tech_stack+=$(grep -E "(openai|anthropic|langchain)" package.json | head -5 | tr '\n' ',' | sed 's/,$//'); tech_stack+=" | "
    fi
    
    # Add to report
    REPORT_CONTENT+="## [$full_name]($html_url)\n"
    REPORT_CONTENT+="- **Stars**: $stars\n"
    REPORT_CONTENT+="- **Language**: $language\n"
    REPORT_CONTENT+="- **Description**: $description\n"
    REPORT_CONTENT+="- **Last Updated**: $updated_at\n\n"
    
    if [ -n "$readme_content" ]; then
        REPORT_CONTENT+="### README Preview\n\`\`\`markdown\n$(echo "$readme_content" | sed 's/\\n/\n/g' | head -15)\n\`\`\`\n\n"
    fi
    
    REPORT_CONTENT+="### Technical Analysis\n"
    REPORT_CONTENT+="- **Requirements/Dependencies**: $(if [ "$has_requirements" -gt 0 ]; then echo "Yes"; else echo "No"; fi)\n"
    REPORT_CONTENT+="- **Documentation**: $(if [ "$has_docs" -gt 0 ]; then echo "Yes"; else echo "No"; fi)\n"
    REPORT_CONTENT+="- **Tests**: $(if [ "$has_tests" -gt 0 ]; then echo "Yes"; else echo "No"; fi)\n"
    REPORT_CONTENT+="- **Examples**: $(if [ "$has_examples" -gt 0 ]; then echo "Yes"; else echo "No"; fi)\n"
    
    if [ -n "$tech_stack" ]; then
        REPORT_CONTENT+="- **Tech Stack**: ${tech_stack% | }\n"
    fi
    
    # Determine strengths and weaknesses
    REPORT_CONTENT+="\n### Strengths and Weaknesses\n"
    strengths=()
    weaknesses=()
    
    # Strength indicators
    if [ "$stars" -gt 1000 ]; then strengths+=("High popularity"); fi
    if [ "$has_docs" -gt 0 ]; then strengths+=("Good documentation"); fi
    if [ "$has_examples" -gt 0 ]; then strengths+=("Good examples"); fi
    if [ "$has_tests" -gt 0 ]; then strengths+=("Test coverage"); fi
    
    # Weakness indicators
    if [ "$has_docs" -eq 0 ]; then weaknesses+=("Limited documentation"); fi
    if [ "$has_examples" -eq 0 ]; then weaknesses+=("Missing examples"); fi
    if [ "$has_requirements" -eq 0 ]; then weaknesses+=("Unclear dependencies"); fi
    
    if [ ${#strengths[@]} -gt 0 ]; then
        REPORT_CONTENT+="- **Strengths**: $(IFS=', '; echo "${strengths[*]}")\n"
    fi
    
    if [ ${#weaknesses[@]} -gt 0 ]; then
        REPORT_CONTENT+="- **Weaknesses**: $(IFS=', '; echo "${weaknesses[*]}")\n"
    fi
    
    REPORT_CONTENT+="---\n\n"
    
    cd "$REPORT_DIR"
done <<< "$(echo "$TOP_REPOS")"

# Step 4: Create a comprehensive HTML report
HTML_REPORT_FILE="$REPORT_DIR/ai_agent_analysis_$DATE.html"
cat > "$HTML_REPORT_FILE" << 'EOF'
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
        
        .summary-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
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
            font-size: 2rem;
            font-weight: bold;
            color: var(--primary);
        }
        
        .repo-list {
            padding: 2rem;
        }
        
        .repo-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            border-left: 4px solid var(--primary);
        }
        
        .repo-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }
        
        .repo-title {
            color: var(--primary);
            margin: 0;
        }
        
        .repo-meta {
            display: flex;
            gap: 1rem;
            margin: 0.5rem 0;
            flex-wrap: wrap;
        }
        
        .meta-item {
            background: #eef2ff;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.875rem;
        }
        
        .section {
            margin: 1.5rem 0;
        }
        
        .section-title {
            color: var(--secondary);
            border-bottom: 2px solid var(--secondary);
            padding-bottom: 0.5rem;
            margin: 1rem 0 0.5rem 0;
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
            max-height: 200px;
            overflow-y: auto;
        }
        
        footer {
            background: var(--dark);
            color: white;
            text-align: center;
            padding: 2rem;
        }
        
        @media (max-width: 768px) {
            .repo-header {
                flex-direction: column;
                gap: 0.5rem;
            }
            
            .repo-meta {
                flex-direction: column;
                gap: 0.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Daily AI Agent Repository Analysis</h1>
            <div class="subtitle">Top AI Agent Repositories from GitHub - DATE_PLACEHOLDER</div>
        </header>

        <div class="summary-stats">
            <div class="stat-card">
                <div class="stat-value">COUNT_PLACEHOLDER</div>
                <div>Repositories Analyzed</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">STARS_PLACEHOLDER</div>
                <div>Total Stars</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">LANGS_PLACEHOLDER</div>
                <div>Technologies</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">DATE_PLACEHOLDER</div>
                <div>Analysis Date</div>
            </div>
        </div>

        <div class="repo-list">
            <!-- Repository analysis will be inserted here -->
            REPO_ANALYSIS_PLACEHOLDER
        </div>

        <footer>
            <p>Automated AI Agent Repository Analysis</p>
            <p>Generated by OpenClaw AI Assistant</p>
        </footer>
    </div>
</body>
</html>
EOF

# Calculate summary stats for the HTML report
total_stars=0
languages=()
repo_count=0

while IFS='|' read -r full_name html_url description language stars updated_at; do
    total_stars=$((total_stars + stars))
    languages+=("$language")
    repo_count=$((repo_count + 1))
done <<< "$(echo "$TOP_REPOS")"

# Remove duplicates from languages
unique_languages=$(printf '%s\n' "${languages[@]}" | sort -u | wc -l)

# Process the markdown report into HTML format for the repo analysis section
MARKDOWN_REPORT_FILE="$REPORT_DIR/temp_markdown_report.md"
echo -e "$REPORT_CONTENT" > "$MARKDOWN_REPORT_FILE"

# Create individual repo cards for HTML
REPO_CARDS=""
while IFS='|' read -r full_name html_url description language stars updated_at; do
    # Get repo-specific analysis from the markdown report
    repo_start_marker="## [$full_name]($html_url)"
    repo_end_marker="---"
    
    # Extract this repo's section from the full report
    repo_section=$(sed -n "/$(echo "$repo_start_marker" | sed 's/[[\.*^$()+?{|]/\\&/g')/,/$(echo "$repo_end_marker" | sed 's/[[\.*^$()+?{|]/\\&/g')/p" "$MARKDOWN_REPORT_FILE" | head -n -1)
    
    # Basic conversion of markdown to HTML for this section (avoid problematic sed operations)
    # Just use the raw text for now to avoid sed issues
    repo_html="<div class='repo-details'><p><strong>Description:</strong> $description</p>"
    
    # Determine strengths and weaknesses for this repo
    repo_stars=$stars
    repo_language=$language
    
    # Simple heuristic for strengths/weaknesses based on metrics
    repo_strengths=()
    repo_weaknesses=()
    
    if [ "$repo_stars" -gt 1000 ]; then
        repo_strengths+=("High popularity ($repo_stars ⭐)")
    elif [ "$repo_stars" -gt 100 ]; then
        repo_strengths+=("Moderate popularity ($repo_stars ⭐)")
    fi
    
    repo_strengths+=("Language: $repo_language")
    
    # Add to the cards
    repo_card="<div class=\"repo-card\">
        <div class=\"repo-header\">
            <h2 class=\"repo-title\"><a href=\"$html_url\" target=\"_blank\">$full_name</a></h2>
        </div>
        <div class=\"repo-meta\">
            <div class=\"meta-item\">⭐ $stars stars</div>
            <div class=\"meta-item\">Language: $language</div>
            <div class=\"meta-item\">🔄 Updated: $updated_at</div>
        </div>
        <p>$description</p>
        
        <div class=\"section\">
            <h3 class=\"section-title\">Strengths</h3>
            <ul>"
            
    for strength in "${repo_strengths[@]}"; do
        repo_card+="<li>$strength</li>"
    done
    
    repo_card+="</ul>
        </div>"
        
    if [ ${#repo_weaknesses[@]} -gt 0 ]; then
        repo_card+="<div class=\"section\">
            <h3 class=\"section-title\">Potential Areas for Improvement</h3>
            <ul>"
        for weakness in "${repo_weaknesses[@]}"; do
            repo_card+="<li>$weakness</li>"
        done
        repo_card+="</ul>
        </div>"
    fi
    
    repo_card+="</div>"
    
    REPO_CARDS+="$repo_card"
done <<< "$(echo "$TOP_REPOS")"

# Replace placeholders in HTML template using a safer method
TEMP_HTML_FILE="${HTML_REPORT_FILE}.tmp"
{
    sed "s|DATE_PLACEHOLDER|$DATE|g" "$HTML_REPORT_FILE"
} > "$TEMP_HTML_FILE" && mv "$TEMP_HTML_FILE" "$HTML_REPORT_FILE"

{
    sed "s|COUNT_PLACEHOLDER|$repo_count|g" "$HTML_REPORT_FILE"
} > "$TEMP_HTML_FILE" && mv "$TEMP_HTML_FILE" "$HTML_REPORT_FILE"

{
    sed "s|STARS_PLACEHOLDER|$total_stars|g" "$HTML_REPORT_FILE"
} > "$TEMP_HTML_FILE" && mv "$TEMP_HTML_FILE" "$HTML_REPORT_FILE"

{
    sed "s|LANGS_PLACEHOLDER|$unique_languages|g" "$HTML_REPORT_FILE"
} > "$TEMP_HTML_FILE" && mv "$TEMP_HTML_FILE" "$HTML_REPORT_FILE"

# Replace the repo analysis section
{
    awk -v content="$REPO_CARDS" '/REPO_ANALYSIS_PLACEHOLDER/{print content; next} {print}' "$HTML_REPORT_FILE"
} > "$TEMP_HTML_FILE" && mv "$TEMP_HTML_FILE" "$HTML_REPORT_FILE"

# Step 5: Update the openclaw-say repository with the new report
echo "Updating openclaw-say repository with analysis report..."

# Clone the target repository if not already present
if [ ! -d "$WORKSPACE_DIR" ]; then
    git clone "https://github.com/$REPO_OWNER/$REPO_NAME.git" "$WORKSPACE_DIR"
fi

cd "$WORKSPACE_DIR"

# Create reports directory if it doesn't exist
mkdir -p reports/daily-ai-agent-analysis

# Copy the HTML report to the reports directory
cp "$HTML_REPORT_FILE" "reports/daily-ai-agent-analysis/analysis-$DATE.html"

# Add and commit the report
git add "reports/daily-ai-agent-analysis/analysis-$DATE.html"
git config --local user.email "openclaw@example.com"
git config --local user.name "OpenClaw"
git commit -m "Add daily AI agent analysis report for $DATE" || {
    echo "No changes to commit or commit failed"
}

# Push to the repository
git push origin main

echo "Report generated and uploaded successfully!"
echo "Access the report at: https://0xagentlabs.github.io/openclaw-say/reports/daily-ai-agent-analysis/analysis-$DATE.html"

# Clean up
cd /
rm -rf "$REPORT_DIR"

echo "Task completed successfully!"