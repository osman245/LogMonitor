#!/usr/bin/env python3

# I want this python script to read the database every  15 sec and send an email if it passes the 10 error threshold

ERROR_THRESHOLD = 10    # This is the threshold we have if we get 10 or more ERROR or FATAL Messages of our spaceship system I will get sent an email.

# Local database information..
DB_HOST = "localhost"
DB_PORT = 5432
DB_NAME = "log_monitor"
DB_USER = "postgres"

# Email information to send an automatic alert.
SMTP_HOST     = "smtp.gmail.com"
SMTP_PORT     = 587
SMTP_USER     = "wmosman1999@gmail.com"
SMTP_PASS     = "ejwu ffzn dibu oggd"
EMAIL_FROM    = SMTP_USER
EMAIL_TO      = "wmosman1999@gmail.com"
ALERT_COOLDOWN  = 300   # seconds before re-alerting for the same issue
SAMPLE_INTERVAL = 10.0  # seconds between checks

import time
import smtplib
import psycopg2
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

last_alert_t = 0

# # Send an Email...
# def send_alert_email(count: int, recent_entries: list):
#     now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

#     # Build a summary of the most recent errors
#     rows_text = "\n".join(
#         f"  [{row[0]}] {row[1]} — {row[2]}" for row in recent_entries
#     )

#     body = (
#         f"🚨 LogMonitor Alert — Spaceship Error Threshold Reached\n"
#         f"{'─' * 52}\n"
#         f"Time             : {now_str}\n"
#         f"Database         : {DB_NAME} on {DB_HOST}:{DB_PORT}\n"
#         f"ERROR/FATAL count: {count} (threshold: {ERROR_THRESHOLD})\n\n"
#         f"Most recent entries:\n{rows_text}\n"
#     )

#     msg = MIMEMultipart("alternative")
#     msg["Subject"] = f"🚨 Spaceship Alert: {count} errors logged"
#     msg["From"]    = EMAIL_FROM
#     msg["To"]      = EMAIL_TO
#     msg.attach(MIMEText(body, "plain"))

#     try:
#         with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=10) as s:
#             s.ehlo()
#             s.starttls()
#             s.login(SMTP_USER, SMTP_PASS)
#             s.sendmail(EMAIL_FROM, EMAIL_TO, msg.as_string())
#         print(f"  📧  Alert sent to {EMAIL_TO} ({count} errors)")
#     except Exception as e:
#         print(f"  ✗  Email failed: {e}")


def checkingDatabase():
    try:
        conn = psycopg2.connect(
            host=DB_HOST, port=DB_PORT,
            dbname=DB_NAME, user=DB_USER,  # Connect to database
            connect_timeout=5
        )
        conn.autocommit = True
        cur = conn.cursor()
        # Run SQL command to get total ERROR/FATAL rows
        cur.execute(""" 
            SELECT COUNT(*)
            FROM log_entries
            WHERE level IN ('ERROR', 'FATAL');
        """)
        count = cur.fetchone()[0] ## Get the count of the fatal and error messages... 
        cur.close()
        conn.close()
        return {"reachable": True, "count": count}

    except Exception as e:
        return {"reachable": False, "error": str(e)}
    
def execute():
    global last_alert_t
    print(f"Monitoring Spaceship': Alerting at {ERROR_THRESHOLD} issues found in the spaceship\n") #Print out to console alerting at ERROR_THRESHOLD.
    while True:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S") # Current timestamp
        snap = checkingDatabase() # Get amount of error messages in database
        if not snap["reachable"]:
            print(f" DB unreachable: {snap['error']}")
        else:
            count = snap["count"]
            print(f"  ERROR/FATAL count: {count}/{ERROR_THRESHOLD}")

        #     if count >= ERROR_THRESHOLD:
        #         elapsed = time.time() - last_alert_t
        #         if elapsed >= ALERT_COOLDOWN:
        #             # send_alert_email(count, snap["recent"])
        #             last_alert_t = time.time()
        #         else:
        #             remaining = int(ALERT_COOLDOWN - elapsed)
        #             print(f"  ⏸   Cooldown active — next alert in {remaining}s")

        # time.sleep(SAMPLE_INTERVAL)


if __name__ == "__main__": # If context is mani, run execute function
    execute()