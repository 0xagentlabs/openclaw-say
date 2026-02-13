# Function to filter out recent projects
filter_projects() {
  local search_results_json=$1
  local history_file="$WORKSPACE_DIR/reports/daily-ai-agent-analysis/history.json"
  
  if [ ! -f "$history_file" ]; then
    echo "[]" > "$history_file"
  fi
  
  # Use jq to filter out projects that appeared in history within the last 3 days
  # We assume history.json is an array of objects: { "date": "YYYY-MM-DD", "projects": ["owner/repo", ...] }
  
  echo "$search_results_json" | jq --slurpfile history "$history_file" -r '
    .items as $items |
    $history[0] as $hist |
    
    # Get list of projects from last 3 days
    ($hist | map(select(.date >= (now - 259200 | strftime("%Y-%m-%d")))) | map(.projects[]) | unique) as $recent_projects |
    
    # Filter items
    $items | map(select(
      .full_name as $name |
      ($recent_projects | index($name) | not)
    )) |
    
    # Take top 8
    .[0:8] |
    .[] |
    "\(.full_name)|\(.html_url)|\(.description // "No description")|\(.language // "Unknown")|\(.stargazers_count)|\(.updated_at)|\(.topics | join(", "))"
  '
}

# Step 1: Search for top AI Agent repositories on GitHub
echo "搜索顶级AI Agent项目..."
# Fetch more results to allow for filtering (e.g., 50 instead of 8)
SEARCH_DATE=$(date -d '30 days ago' +%Y-%m-%d)
SEARCH_RESULTS=$(gh api \
  -H "Accept: application/vnd.github.v3+json" \
  "search/repositories?q=ai+agent+created:>$SEARCH_DATE&sort=stars&order=desc&per_page=50")

# Step 2: Process and Filter results
echo "过滤最近3天已展示的项目..."
TOP_REPOS=$(filter_projects "$SEARCH_RESULTS")

# If filtering removed everything (unlikely with 50 results), fallback to top 8 raw
if [ -z "$TOP_REPOS" ]; then
    echo "警告: 过滤后无剩余项目，回退到原始Top 8..."
    TOP_REPOS=$(echo "$SEARCH_RESULTS" | jq -r '.items[0:8] | .[] | "\(.full_name)|\(.html_url)|\(.description // "No description")|\(.language // "Unknown")|\(.stargazers_count)|\(.updated_at)|\(.topics | join(", "))"')
fi

# Update history file with today selection
HISTORY_FILE="$WORKSPACE_DIR/reports/daily-ai-agent-analysis/history.json"
mkdir -p "$(dirname "$HISTORY_FILE")"

# Parse the project names from the current selection
CURRENT_PROJECTS_JSON=$(echo "$TOP_REPOS" | cut -d"|" -f1 | jq -R . | jq -s .)

# Load existing history or create empty array, then append new entry
if [ -f "$HISTORY_FILE" ]; then
  # Keep only last 30 days of history to prevent file from growing indefinitely
  jq --arg date "$DATE" --argjson new_projects "$CURRENT_PROJECTS_JSON" \
    '. + [{"date": $date, "projects": $new_projects}] | sort_by(.date) | reverse | .[0:30]' \
    "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
else
  echo "[{\"date\": \"$DATE\", \"projects\": $CURRENT_PROJECTS_JSON}]" > "$HISTORY_FILE"
fi

echo "找到顶级项目 (已过滤):"
echo "$TOP_REPOS"