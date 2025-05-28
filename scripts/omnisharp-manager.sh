#!/bin/bash

# OmniSharp Performance Manager
# Helps monitor and control OmniSharp resource usage

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CPU_THRESHOLD=25
MEMORY_THRESHOLD=500000  # KB (500MB)
CHECK_INTERVAL=5

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        OmniSharp Performance Manager   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo
}

get_omnisharp_pids() {
    pgrep -f "OmniSharp" 2>/dev/null || echo ""
}

get_process_stats() {
    local pid=$1
    if ps -p "$pid" > /dev/null 2>&1; then
        ps -p "$pid" -o pid,pcpu,pmem,rss,etime,args --no-headers 2>/dev/null
    else
        echo ""
    fi
}

kill_omnisharp() {
    local force=${1:-false}
    
    echo -e "${YELLOW}🚨 Stopping OmniSharp processes...${NC}"
    
    if [ "$force" = "true" ]; then
        echo -e "${RED}Using SIGKILL (force)${NC}"
        pkill -9 -f "OmniSharp" 2>/dev/null || true
    else
        echo -e "${YELLOW}Using SIGTERM (graceful)${NC}"
        pkill -15 -f "OmniSharp" 2>/dev/null || true
        sleep 3
        
        # Check if any processes remain and force kill if needed
        local remaining_pids=$(get_omnisharp_pids)
        if [ -n "$remaining_pids" ]; then
            echo -e "${RED}Some processes didn't respond to SIGTERM, using SIGKILL${NC}"
            pkill -9 -f "OmniSharp" 2>/dev/null || true
        fi
    fi
    
    # Clean up any remaining dotnet processes that might be related
    pkill -f "dotnet.*OmniSharp" 2>/dev/null || true
    
    echo -e "${GREEN}✓ OmniSharp processes stopped${NC}"
}

monitor_processes() {
    local duration=${1:-60}  # Default 60 seconds
    local start_time=$(date +%s)
    
    echo -e "${BLUE}📊 Monitoring OmniSharp for ${duration} seconds...${NC}"
    echo -e "${BLUE}CPU threshold: ${CPU_THRESHOLD}% | Memory threshold: $((MEMORY_THRESHOLD/1024))MB${NC}"
    echo
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -ge $duration ]; then
            echo -e "\n${GREEN}✓ Monitoring completed${NC}"
            break
        fi
        
        local pids=$(get_omnisharp_pids)
        
        if [ -z "$pids" ]; then
            echo -e "${YELLOW}⚠️  No OmniSharp processes found${NC}"
            sleep $CHECK_INTERVAL
            continue
        fi
        
        local high_cpu_found=false
        local high_memory_found=false
        
        echo -e "${BLUE}[$(date +'%H:%M:%S')] Checking processes...${NC}"
        
        for pid in $pids; do
            local stats=$(get_process_stats "$pid")
            if [ -n "$stats" ]; then
                local cpu=$(echo "$stats" | awk '{print $2}' | cut -d. -f1)
                local memory=$(echo "$stats" | awk '{print $4}')
                local etime=$(echo "$stats" | awk '{print $5}')
                
                # Remove any non-numeric characters
                cpu=${cpu//[^0-9]/}
                memory=${memory//[^0-9]/}
                
                if [ -n "$cpu" ] && [ "$cpu" -gt $CPU_THRESHOLD ]; then
                    echo -e "${RED}  🔥 PID $pid: CPU ${cpu}% (HIGH!) | Memory ${memory}KB | Runtime $etime${NC}"
                    high_cpu_found=true
                elif [ -n "$memory" ] && [ "$memory" -gt $MEMORY_THRESHOLD ]; then
                    echo -e "${YELLOW}  💾 PID $pid: CPU ${cpu}% | Memory ${memory}KB (HIGH!) | Runtime $etime${NC}"
                    high_memory_found=true
                else
                    echo -e "${GREEN}  ✓ PID $pid: CPU ${cpu}% | Memory ${memory}KB | Runtime $etime${NC}"
                fi
            fi
        done
        
        if [ "$high_cpu_found" = true ] || [ "$high_memory_found" = true ]; then
            echo -e "${YELLOW}  ⚠️  High resource usage detected. Consider running: $0 kill${NC}"
        fi
        
        echo
        sleep $CHECK_INTERVAL
    done
}

status_check() {
    print_header
    
    local pids=$(get_omnisharp_pids)
    
    if [ -z "$pids" ]; then
        echo -e "${YELLOW}📊 Status: No OmniSharp processes running${NC}"
        echo -e "${GREEN}✓ System should be responsive${NC}"
        return 0
    fi
    
    echo -e "${BLUE}📊 Active OmniSharp processes:${NC}"
    echo
    printf "%-8s %-8s %-8s %-12s %-12s %s\n" "PID" "CPU%" "MEM%" "MEMORY(KB)" "RUNTIME" "COMMAND"
    echo "────────────────────────────────────────────────────────────────────────────"
    
    local total_cpu=0
    local total_memory=0
    local process_count=0
    
    for pid in $pids; do
        local stats=$(get_process_stats "$pid")
        if [ -n "$stats" ]; then
            local cpu=$(echo "$stats" | awk '{print $2}')
            local mem_percent=$(echo "$stats" | awk '{print $3}')
            local memory=$(echo "$stats" | awk '{print $4}')
            local etime=$(echo "$stats" | awk '{print $5}')
            local cmd=$(echo "$stats" | awk '{for(i=6;i<=NF;i++) printf "%s ", $i; print ""}' | cut -c1-50)
            
            printf "%-8s %-8s %-8s %-12s %-12s %s\n" "$pid" "$cpu" "$mem_percent" "$memory" "$etime" "$cmd"
            
            # Add to totals (remove decimals for calculation)
            cpu_int=${cpu//[^0-9]/}
            memory_int=${memory//[^0-9]/}
            if [ -n "$cpu_int" ]; then
                total_cpu=$((total_cpu + cpu_int))
            fi
            if [ -n "$memory_int" ]; then
                total_memory=$((total_memory + memory_int))
            fi
            process_count=$((process_count + 1))
        fi
    done
    
    echo
    echo -e "${BLUE}📈 Summary:${NC}"
    echo -e "  Processes: $process_count"
    echo -e "  Total CPU: ~${total_cpu}%"
    echo -e "  Total Memory: ~$((total_memory/1024))MB"
    
    if [ $total_cpu -gt $CPU_THRESHOLD ] || [ $total_memory -gt $MEMORY_THRESHOLD ]; then
        echo -e "${RED}  ⚠️  HIGH RESOURCE USAGE DETECTED!${NC}"
        echo -e "${YELLOW}  Consider running: $0 kill${NC}"
    else
        echo -e "${GREEN}  ✓ Resource usage looks normal${NC}"
    fi
}

usage() {
    echo "Usage: $0 {status|monitor|kill|force-kill|help}"
    echo
    echo "Commands:"
    echo "  status     - Show current OmniSharp processes and resource usage"
    echo "  monitor    - Monitor processes for 60 seconds (or specify duration)"
    echo "  kill       - Gracefully stop all OmniSharp processes"
    echo "  force-kill - Force stop all OmniSharp processes"
    echo "  help       - Show this help message"
    echo
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 monitor 120  # Monitor for 2 minutes"
    echo "  $0 kill"
}

case "${1:-}" in
    "status")
        status_check
        ;;
    "monitor")
        print_header
        monitor_processes "${2:-60}"
        ;;
    "kill")
        kill_omnisharp false
        ;;
    "force-kill")
        kill_omnisharp true
        ;;
    "help"|"--help"|"-h")
        print_header
        usage
        ;;
    "")
        status_check
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        echo
        usage
        exit 1
        ;;
esac 