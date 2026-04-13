#!/bin/bash

# Path to the log file where log entries will be written, giving us the messages coming from the spaceship
LOGFILE="/home/admin/logs/spaceship.log"

# Infinite loop to continuously generate logs
while true; do
    # Get the current timestamp in the format 'YYYY-MM-DD HH:MM:SS'
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Randomly select a log level from INFO, WARNING, ERROR, and FATAL
    LEVEL=$(shuf -n 1 -e INFO WARNING ERROR FATAL)

    # Generate a variety of realistic log messages based on log levels
    case $LEVEL in
        INFO)
            MESSAGE=$(shuf -n 1 -e \
            "Commander Zara successfully docked at Space Station Omega-7." \
            "Crew manifest updated: 12 personnel aboard the ISV Horizon." \
            "Daily systems diagnostic completed. All systems nominal." \
            "Scheduled warp jump 'Route Alpha-9' executed at $TIMESTAMP." \
            "Life support check passed; all modules operating within parameters.")
            ;; ## Double semi-colon here indicates the end of a case statement in Bash
        WARNING)
            MESSAGE=$(shuf -n 1 -e \
            "Fuel cell reserves at 15% on thruster bank 3." \
            "Navigation response time for vessel NCC-7741 exceeded safe thresholds." \
            "Shield power usage high: 78% of available energy diverted." \
            "Unusually high signal traffic detected from sector 192.7.Gamma." \
            "Asteroid proximity scan took longer than expected (3.4 seconds).")
            ;;
        ERROR)
            MESSAGE=$(shuf -n 1 -e \
            "Subspace link lost while transmitting mission log TX-98765." \
            "Failed to load nav charts: /etc/spaceship/starcharts.yml." \
            "Crew ID 67890 failed biometric scan. Access denied to engine bay." \
            "Unable to establish comms: Deep space relay not responding." \
            "Hyperdrive sequence timeout for jump ID 87654.")
            ;;
        FATAL)
            MESSAGE=$(shuf -n 1 -e \
            "Hull breach detected in sector 0x004FA1. Emergency bulkheads engaged." \
            "Critical failure: Reactor core meltdown imminent. All hands abandon ship." \
            "Ship AI terminated unexpectedly: Memory core corrupted." \
            "Engine failure detected on thruster pod /dev/sdb. Immediate EVA required." \
            "Service 'life-support-backend' offline: Oxygen recycler dependency missing.")
            ;;
    esac

    # Write the timestamp, log level, and message to the log file
    echo "$TIMESTAMP [$LEVEL] $MESSAGE" >> $LOGFILE
    
    # Wait for a random time between 1 and 5 seconds before generating the next log entry
    sleep $(shuf -i 1-5 -n 1)
done