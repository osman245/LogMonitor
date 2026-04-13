#!/bin/bash

## Read the Logfile, extract all FATAL and ERROR messages and insert it into the local psql database 
# ---------- Configuration ----------
LOGFILE="/home/admin/logs/spaceship.log" #
 
 
DB_NAME="log_monitor"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

 # First we need to make sure the file exists..
if [[ ! -f "$LOGFILE" ]]; then
    log "Log file $LOGFILE not found. Exiting."
    exit 1
fi
 
 

fi
 
# ---------- Read only new lines ----------

    
 do NEW_LINES= tail -n 1 $LOGFILE
    while read -r $NEW_LINES
    if [[ grep (ERROR|FATAL)]; then
        # Escape single quotes for SQL safety
        MESSAGE_ESCAPED="${MESSAGE//\'/\'\'}"
 
        SQL="INSERT INTO log_entries (log_time, level, message)
             VALUES ('$TS', '$LEVEL', '$MESSAGE_ESCAPED');"
 
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
             -c "$SQL" >> "$SCRIPT_LOG" 2>&1
 
        if [[ $? -eq 0 ]]; then
            ((INSERTED++))
            log "Inserted [$LEVEL] at $TS"
        else
            log "ERROR: Failed to insert line: $line"
        fi
    fi
done <<< "$NEW_LINES"
 
# ---------- Save new position ----------
echo "$CURRENT_SIZE" > "$STATE_FILE"
 
log "Done. Inserted $INSERTED new entries. New position: $CURRENT_SIZE"