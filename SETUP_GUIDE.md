# OpenClaw Activity Tracking Setup Guide

This guide explains how to set up the activity tracking system for a new OpenClaw instance.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Access to a GitHub organization where you can create repositories

## Step 1: Install and Authenticate GitHub CLI

```bash
# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

# Authenticate GitHub CLI (this will open a browser for authentication)
gh auth login --web
```

## Step 2: Create the Activity Tracking Repository

```bash
# Create a new private repository in your organization
gh repo create ORGANIZATION_NAME/activity-tracker --private --description "OpenClaw activity logs and status updates"

# Replace ORGANIZATION_NAME with your actual organization name
```

## Step 3: Set up GitHub Pages

```bash
# First, create and push initial content
mkdir -p /tmp/activity-tracker
cd /tmp/activity-tracker
git init
git remote add origin https://github.com/ORGANIZATION_NAME/activity-tracker.git

# Create initial README
echo "# OpenClaw Activity Tracker

Repository for tracking OpenClaw activities and status." > README.md

# Configure git
git config user.name "OpenClaw Assistant"
git config user.email "openclaw@example.com"

# Add, commit, and push
git add README.md
git branch -M main
git commit -m "Initial commit: Add README"
git push -u origin main
```

## Step 4: Make Repository Public and Enable GitHub Pages

```bash
# Make the repository public (required for GitHub Pages on free tier)
gh repo edit ORGANIZATION_NAME/activity-tracker --visibility public --accept-visibility-change-consequences

# Enable GitHub Pages
gh api -X POST /repos/ORGANIZATION_NAME/activity-tracker/pages --field "source[branch]=main" --field "source[path]=/"
```

## Step 5: Create the Dashboard Structure

```bash
# Clone the repository
git clone https://github.com/ORGANIZATION_NAME/activity-tracker.git
cd activity-tracker

# Create the dashboard index.html
cat > index.html << 'INNEREOF'
<!DOCTYPE html>
<html>
<head>
    <title>OpenClaw Dashboard</title>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="30">
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            border-bottom: 2px solid #eee;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .status-box {
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .online { background-color: #d4edda; color: #155724; border-left: 5px solid #28a745; }
        .working { background-color: #fff3cd; color: #856404; border-left: 5px solid #ffc107; }
        .idle { background-color: #cce5ff; color: #004085; border-left: 5px solid #007bff; }
        .offline { background-color: #f8d7da; color: #721c24; border-left: 5px solid #dc3545; }
        .section {
            margin: 25px 0;
        }
        h2 {
            color: #333;
            border-bottom: 1px solid #eee;
            padding-bottom: 8px;
        }
        .activity-item {
            background: #f9f9f9;
            padding: 10px;
            margin: 5px 0;
            border-radius: 3px;
            border-left: 3px solid #007bff;
        }
        .timestamp {
            font-size: 0.8em;
            color: #666;
        }
        .current-task {
            background: #e6f7ff;
            border: 1px dashed #1890ff;
            padding: 15px;
            border-radius: 5px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #666;
            font-size: 0.8em;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 OpenClaw Dashboard</h1>
            <p>Real-time status and activity tracking system</p>
        </div>

        <div class="section">
            <h2>Current Status</h2>
            <div class="status-box idle">
                <p><strong>Status:</strong> Idle</p>
                <p><strong>Last Updated:</strong> <span id="update-time"></span></p>
                <p><strong>Current Task:</strong> Awaiting instructions</p>
            </div>
        </div>

        <div class="section">
            <h2>Recent Activities</h2>
            <div id="activities-container">
                <div class="activity-item">
                    <p><strong>System initialized</strong></p>
                    <p>OpenClaw activity tracking system set up</p>
                    <p class="timestamp">Just now</p>
                </div>
            </div>
        </div>

        <div class="section">
            <h2>Scheduled Tasks</h2>
            <div id="scheduled-tasks">
                <div class="activity-item">
                    <p><strong>Heartbeat Checks</strong></p>
                    <p>Regular system health and status updates</p>
                    <p class="timestamp">Every 30 minutes</p>
                </div>
            </div>
        </div>

        <div class="footer">
            <p>Dashboard auto-refreshes every 30 seconds</p>
            <p>Powered by OpenClaw Activity Tracking System</p>
        </div>
    </div>

    <script>
        // Update the timestamp dynamically
        document.getElementById("update-time").textContent = new Date().toLocaleString();
        
        // Function to update activities dynamically (can be called via external scripts)
        function updateActivities(activityData) {
            const container = document.getElementById("activities-container");
            const activityElement = document.createElement("div");
            activityElement.className = "activity-item";
            
            activityElement.innerHTML = `
                <p><strong>${activityData.title}</strong></p>
                <p>${activityData.description}</p>
                <p class="timestamp">${new Date().toLocaleString()}</p>
            `;
            
            container.insertBefore(activityElement, container.firstChild);
        }
    </script>
</body>
</html>
INNEREOF

# Create status.html as an alias to index.html
cp index.html status.html

# Create the README explaining the system
cat > README.md << 'INNEREOF'
# OpenClaw Activity Tracking System

This repository serves as a real-time dashboard and activity log for OpenClaw operations.

## Dashboard

The main dashboard is available at: https://ORGANIZATION_NAME.github.io/activity-tracker/

It provides real-time information about:
- Current operational status
- Active tasks and processes
- Recent activities
- Scheduled tasks

## Log Structure

The system maintains several types of logs:

### Activity Logs
- `ACTIVITY_LOG.md` - General chronological activity log
- `logs/manual/` - Manually triggered operations
- `logs/scheduled/` - Scheduled/cron tasks
- `logs/system/` - System-level operations

### Status Updates
- `status.html` - Current status dashboard (alias for index.html)
- `index.html` - Main dashboard with live status

## Update Frequency

- Status updates occur in real-time as activities happen
- Dashboard refreshes every 30 seconds
- Detailed logs are appended to as operations occur

## Purpose

This system allows for transparent monitoring of OpenClaw operations, providing visibility into:
- What operations are currently running
- Historical activity patterns
- System health and performance
- Scheduled maintenance and tasks
INNEREOF

# Create directory structure for logs
mkdir -p logs/scheduled logs/manual logs/system
touch logs/.gitkeep logs/scheduled/.gitkeep logs/manual/.gitkeep logs/system/.gitkeep

# Create initial activity log
cat > ACTIVITY_LOG.md << 'INNEREOF'
# OpenClaw Activity Log

## Setup Phase

### Current Time
- Initialized activity tracking system
INNEREOF
```

## Step 6: Commit and Push Changes

```bash
# Add all files to git
git add .

# Commit changes
git commit -m "Add comprehensive activity tracking system"

# Push to GitHub
git push origin main
```

## Integration with OpenClaw Workflow

To integrate this system into your OpenClaw workflow:

1. Create functions to update the status.html file with current status
2. Log activities to the appropriate log files
3. Set up automated updates for scheduled tasks
4. Ensure all significant operations are logged

The dashboard will be available at: `https://ORGANIZATION_NAME.github.io/activity-tracker/`

