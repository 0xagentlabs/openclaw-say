# OpenClaw Activity Tracking System

This repository serves as a real-time dashboard and activity log for OpenClaw operations.

## Dashboard

The main dashboard is available at: https://0xagentlabs.github.io/openclaw-say/

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
