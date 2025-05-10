#!/bin/bash

# Enable logging to both syslog and a file
exec 1> >(tee -a /tmp/lid-handler.log) 2>&1

# Log start time and script execution
echo "=== Lid handler script executed at $(date) ==="

# Function to check if lid is closed
check_lid() {
    local state=$(cat /proc/acpi/button/lid/LID/state)
    echo "Current lid state: $state"
    echo "$state" | grep -q "state:.*closed"
    return $?
}

# Function to move all workspaces to external monitor
move_workspaces_to_external() {
    echo "Moving workspaces to external monitor DP-1..."
    # Get list of active workspaces
    local workspaces=$(hyprctl workspaces | grep "workspace ID" | cut -d" " -f3)
    
    for workspace in $workspaces; do
        echo "Moving workspace $workspace to DP-1"
        hyprctl dispatch moveworkspacetomonitor "$workspace" DP-1
    done
}

# Main logic
if check_lid; then
    echo "Lid is closed, moving workspaces"
    move_workspaces_to_external
else
    echo "Lid is open, no action needed"
fi 