#!/bin/bash

# Configuration
THRESHOLD_CPU=90
THRESHOLD_MEM=85
THRESHOLD_DISK=10
EMAIL="sylvia@example.com"
LOG_FILE="logs/system_health.log"
REPORT_FILE="reports/system_report.html"

# Collect system metrics
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
DISK_USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')

# Log metrics
echo "$(date) - CPU: $CPU_USAGE%, Memory: $MEM_USAGE%, Disk: $DISK_USAGE%" >> $LOG_FILE

# Check thresholds and send alerts
if (( $(echo "$CPU_USAGE > $THRESHOLD_CPU" | bc -l) )); then
    echo "High CPU usage detected: $CPU_USAGE%" | mail -s "System Alert: High CPU Usage" $EMAIL
fi

if (( $(echo "$MEM_USAGE > $THRESHOLD_MEM" | bc -l) )); then
    echo "High memory usage detected: $MEM_USAGE%" | mail -s "System Alert: High Memory Usage" $EMAIL
fi

if (( $(echo "$DISK_USAGE > $THRESHOLD_DISK" | bc -l) )); then
    echo "Low disk space detected: $DISK_USAGE%" | mail -s "System Alert: Low Disk Space" $EMAIL
fi

# Generate HTML report
echo "<html><body><h1>System Health Report</h1>" > $REPORT_FILE
echo "<p>Date: $(date)</p>" >> $REPORT_FILE
echo "<p>CPU Usage: $CPU_USAGE%</p>" >> $REPORT_FILE
echo "<p>Memory Usage: $MEM_USAGE%</p>" >> $REPORT_FILE
echo "<p>Disk Usage: $DISK_USAGE%</p>" >> $REPORT_FILE
echo "</body></html>" >> $REPORT_FILE

