#!/bin/bash

# Information to sign into local database
LOG_FILE="spaceship.txt" #
DB_NAME="log_monitor"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

 # First we need to make sure the file exists..
if [[ ! -f "$LOGFILE" ]]; then
    log "Log file $LOGFILE not found. Exiting."
    exit 1
fi
 

while IFS= read -r NEW_LINES; do # While new lines are generated do
    if echo "$NEW_LINES" | grep -qE "(ERROR|FATAL)"; then ## If this line has "ERROR" or "Fatal" in its string run below if block

        TS=$(echo "$NEW_LINES"      | awk '{print $1}') # Get the first part of the string(Timestamp)
        LEVEL=$(echo "$NEW_LINES"   | awk '{print $2}') # Get the second part of the string(Level of error)
        MESSAGE=$(echo "$NEW_LINES" | cut -d' ' -f3-) # Get the last part of the string the message..

        MESSAGE_ESCAPED="${MESSAGE//\'/\'\'}"  # Escape single quotes for SQL safety

        SQL="INSERT INTO log_entries (log_time, level, message) 
             VALUES ('$TS', '$LEVEL', '$MESSAGE_ESCAPED');"

        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
             -c "$SQL" >> "$SCRIPT_LOG" 2>&1 ## Sign into psql and do the $SQL command.

    fi
done < <(tail -F "$LOG_FILE")

 
