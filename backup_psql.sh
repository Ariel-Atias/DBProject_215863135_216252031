#!/bin/bash

echo "=== PSQL Backup & Restore Script ===" > backupPSQL.log
echo "Started at: $(date)" >> backupPSQL.log
echo "" >> backupPSQL.log

# Database configuration
DB_NAME="postgres"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

# Step 1: Create PSQL backup
echo "Step 1: Creating PSQL backup..." | tee -a backupPSQL.log
start_backup=$(date +%s.%N)

pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME \
    --verbose \
    --format=custom \
    --compress=9 \
    --file=backupPSQL.sql 2>&1 | tee -a backupPSQL.log

end_backup=$(date +%s.%N)
backup_duration=$(echo "$end_backup - $start_backup" | bc)

if [ $? -eq 0 ]; then
    echo "✅ PSQL backup completed in ${backup_duration} seconds" | tee -a backupPSQL.log
else
    echo "❌ PSQL backup failed!" | tee -a backupPSQL.log
    exit 1
fi

# Step 2: Drop and recreate database
echo "" >> backupPSQL.log
echo "Step 2: Clearing database..." | tee -a backupPSQL.log
start_drop=$(date +%s.%N)

# Drop all tables (safer than dropping entire database)
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "
DROP TABLE IF EXISTS Transaction CASCADE;
DROP TABLE IF EXISTS PaymentMethod CASCADE;
DROP TABLE IF EXISTS Account CASCADE;
DROP TABLE IF EXISTS ClearingHouse CASCADE;
DROP TABLE IF EXISTS Merchant CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
" 2>&1 | tee -a backupPSQL.log

end_drop=$(date +%s.%N)
drop_duration=$(echo "$end_drop - $start_drop" | bc)

echo "Database cleared in ${drop_duration} seconds" | tee -a backupPSQL.log

# Step 3: Restore from backup
echo "" >> backupPSQL.log
echo "Step 3: Restoring from backup..." | tee -a backupPSQL.log
start_restore=$(date +%s.%N)

pg_restore -h $DB_HOST -U $DB_USER -d $DB_NAME \
    --verbose \
    --clean \
    --if-exists \
    backupPSQL.sql 2>&1 | tee -a backupPSQL.log

end_restore=$(date +%s.%N)
restore_duration=$(echo "$end_restore - $start_restore" | bc)

if [ $? -eq 0 ]; then
    echo "✅ Database restored in ${restore_duration} seconds" | tee -a backupPSQL.log
else
    echo "❌ Database restore failed!" | tee -a backupPSQL.log
    exit 1
fi

# Summary
total_duration=$(echo "$backup_duration + $drop_duration + $restore_duration" | bc)

echo "" >> backupPSQL.log
echo "=== TIMING SUMMARY ===" >> backupPSQL.log
echo "Backup duration:  ${backup_duration} seconds" >> backupPSQL.log
echo "Drop duration:    ${drop_duration} seconds" >> backupPSQL.log
echo "Restore duration: ${restore_duration} seconds" >> backupPSQL.log
echo "Total duration:   ${total_duration} seconds" >> backupPSQL.log

# File info
file_size=$(ls -lh backupPSQL.sql | awk '{print $5}')
echo "Backup file size: $file_size" >> backupPSQL.log

echo "" >> backupPSQL.log
echo "Completed at: $(date)" >> backupPSQL.log
echo "=== PSQL Backup & Restore Process Completed ===" >> backupPSQL.log

