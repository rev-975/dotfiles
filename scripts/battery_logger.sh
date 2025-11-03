#!/bin/bash

# Battery Logger - Logs battery status every 30 minutes
# Usage: ./battery_logger.sh

LOG_FILE="${HOME}/battery_log.txt"
INTERVAL=1800  # 30 minutes in seconds

# Function to log battery info
log_battery() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Get battery info using upower
    local battery_info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null)

    if [ -z "$battery_info" ]; then
        echo "[$timestamp] ERROR: Could not read battery information" >> "$LOG_FILE"
        return
    fi

    # Extract relevant information
    local percentage=$(echo "$battery_info" | grep -E "percentage" | awk '{print $2}')
    local state=$(echo "$battery_info" | grep -E "state:" | awk '{print $2}')
    local time_to=$(echo "$battery_info" | grep -E "time to" | sed 's/^[[:space:]]*//')
    local energy=$(echo "$battery_info" | grep -E "energy:" | awk '{print $2, $3}')
    local energy_rate=$(echo "$battery_info" | grep -E "energy-rate:" | awk '{print $2, $3}')

    # Write to log file
    echo "[$timestamp] Battery: $percentage | State: $state | Energy: $energy | Rate: $energy_rate | $time_to" >> "$LOG_FILE"
}

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo "Battery Log - Started $(date '+%Y-%m-%d %H:%M:%S')" > "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
fi

echo "Battery logging started. Log file: $LOG_FILE"
echo "Logging interval: 30 minutes"
echo "Press Ctrl+C to stop"

# Main loop
while true; do
    log_battery
    sleep $INTERVAL
done
