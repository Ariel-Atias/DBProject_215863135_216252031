#!/bin/bash

echo "=== SQL Backup Script ===" > backupSQL.log
echo "Started at: $(date)" >> backupSQL.log
echo "" >> backupSQL.log

# Start timing
start_time=$(date +%s.%N)

echo "Creating SQL backup with DROP/CREATE/INSERT statements..." | tee -a backupSQL.log

# Create SQL backup
pg_dump -h localhost -U postgres -d postgres \
    --verbose \
    --clean \
    --create \
    --if-exists \
    --format=plain \
    --file=backupSQL.sql 2>&1 | tee -a backupSQL.log

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "✅ SQL backup completed successfully!" | tee -a backupSQL.log
else
    echo "❌ SQL backup failed!" | tee -a backupSQL.log
    exit 1
fi

# End timing
end_time=$(date +%s.%N)
duration=$(echo "$end_time - $start_time" | bc)

echo "" >> backupSQL.log
echo "Backup completed at: $(date)" >> backupSQL.log
echo "Total duration: ${duration} seconds" >> backupSQL.log

# File info
file_size=$(ls -lh backupSQL.sql | awk '{print $5}')
echo "Backup file size: $file_size" >> backupSQL.log

echo "" >> backupSQL.log
echo "=== SQL Backup Process Completed ===" >> backupSQL.log

