#!/bin/bash

##############################################
# Log Rotation Script
# Requirements:
# - Rotate logs > 100MB
# - Rotate logs older than 7 days
# - Compress using gzip
# - Delete logs older than 30 days
# - Generate execution logs
##############################################

LOG_PATH="/var/log/myapp"
ROTATION_LOG="/var/log/log-rotation.log"
MAX_SIZE_MB=100
MAX_DAYS_ROTATE=7
MAX_DAYS_DELETE=30

timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

echo "[$(timestamp)] --- Starting log rotation ---" >> $ROTATION_LOG

# 1. Rotate logs larger than 100MB
for file in $LOG_PATH/*.log; do
  if [ -f "$file" ]; then
    size_mb=$(du -m "$file" | cut -f1)

    if [ $size_mb -gt $MAX_SIZE_MB ]; then
      echo "[$(timestamp)] Rotating $file (size ${size_mb}MB)" >> $ROTATION_LOG
      mv "$file" "$file.$(date +%Y%m%d%H%M%S)"
    fi
  fi
done

# 2. Rotate logs older than 7 days
find $LOG_PATH -name "*.log" -type f -mtime +$MAX_DAYS_ROTATE | while read file; do
  echo "[$(timestamp)] Rotating old file: $file" >> $ROTATION_LOG
  mv "$file" "$file.$(date +%Y%m%d%H%M%S)"
done

# 3. Compress rotated logs
find $LOG_PATH -name "*.log.*" -type f ! -name "*.gz" | while read file; do
  echo "[$(timestamp)] Compressing $file" >> $ROTATION_LOG
  gzip "$file"
done

# 4. Delete logs older than 30 days
find $LOG_PATH -type f -mtime +$MAX_DAYS_DELETE | while read file; do
  echo "[$(timestamp)] Deleting old file: $file" >> $ROTATION_LOG
  rm -f "$file"
done

echo "[$(timestamp)] --- Log rotation finished ---" >> $ROTATION_LOG
exit 0
