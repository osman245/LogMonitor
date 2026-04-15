#!/bin/bash

## Read the Logfile, extract all FATAL and ERROR messages and insert it into the local psql database 
# ---------- Configuration ----------
# Use ; colon when running sql statements..
#
LOGFILE="spaceship.txt" #
DB_NAME="log_monitor"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

 # First we need to make sure the file exists..
if [[ ! -f "$LOGFILE" ]]; then
    log "Log file $LOGFILE not found. Exiting."
    exit 1
fi
 
# ---------- Read only new lines ----------

while IFS= read -r NEW_LINES; do # While  new lines are generated do
    if echo "$NEW_LINES" | grep -qE "(ERROR|FATAL)"; then

        # Parse fields from the log line (adjust to your log format)
        TS=$(echo "$NEW_LINES"      | awk '{print $1}') # Get the first part of the string(Timestamp)
        LEVEL=$(echo "$NEW_LINES"   | awk '{print $2}') # Get the second part of the string(Level of error)
        MESSAGE=$(echo "$NEW_LINES" | cut -d' ' -f3-) # Get the last part of the string the message..

        MESSAGE_ESCAPED="${MESSAGE//\'/\'\'}"  # Escape single quotes for SQL safety

        SQL="INSERT INTO log_entries (log_time, level, message) 
             VALUES ('$TS', '$LEVEL', '$MESSAGE_ESCAPED');"

        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
             -c "$SQL" >> "$SCRIPT_LOG" 2>&1 ## Sign into psql and do the $SQL command.

        if [[ $? -eq 0 ]]; then
            ((INSERTED++))
            log "Inserted [$LEVEL] at $TS"
        else
            log "ERROR: Failed to insert line: $NEW_LINES"
        fi
    fi
done < <(tail -F "$LOG_FILE")

 
# ---------- Save new position ----------
echo "$CURRENT_SIZE" > "$STATE_FILE"
 
log "Done. Inserted $INSERTED new entries. New position: $CURRENT_SIZE"