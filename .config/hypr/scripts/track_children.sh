
#!/usr/bin/env bash

# Function to get the workspace of a PID
get_workspace_by_pid() {
    local pid=$1
    hyprctl clients -j | jq -r ".[] | select(.pid == $pid) | .workspace.id"
}

# Function to find the parent PID of a window
get_parent_pid() {
    local pid=$1
    # Get the parent PID using ps
    ps -o ppid= -p "$pid" | tr -d ' '
}

handle() {
    local line=$1
    # Listen for the openwindow event
    if [[ "$line" =~ ^openwindow\>\>([^,]+),([^,]+),([^,]+),(.+)$ ]]; then
        local win_address="0x${BASH_REMATCH[1]}"
        local workspace_name="${BASH_REMATCH[2]}"
        local win_class="${BASH_REMATCH[3]}"
        
        # Get the PID of the newly opened window
        local client_info=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$win_address\")")
        local pid=$(echo "$client_info" | jq -r '.pid')
        
        if [ -n "$pid" ] && [ "$pid" != "null" ]; then
            local p_pid=$(get_parent_pid "$pid")
            
            # Keep climbing the process tree if the immediate parent isn't a window
            while [ -n "$p_pid" ] && [ "$p_pid" != "1" ]; do
                local parent_ws=$(get_workspace_by_pid "$p_pid")
                
                # If we find a parent running on a workspace, move the child there
                if [ -n "$parent_ws" ] && [ "$parent_ws" != "null" ]; then
                    if [ "$workspace_name" != "$parent_ws" ]; then
                        hyprctl dispatch movetoworkspace "$parent_ws,address:$win_address"
                    fi
                    break
                fi
                p_pid=$(get_parent_pid "$p_pid")
            done
        fi
    fi
}

# Listen to Hyprland events
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    handle "$line"
done
