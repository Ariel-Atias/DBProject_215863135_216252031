#!/bin/bash

# PostgreSQL Database Dump Script
# This script creates a backup of your PostgreSQL database schema and data

echo "=== PostgreSQL Database Dump Script ==="
echo "This script will create a backup of your database"
echo ""

# Default configuration - modify these values for your setup
DB_NAME="postgres"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

# You can override defaults by passing arguments
if [ ! -z "$1" ]; then
    DB_NAME="$1"
fi

if [ ! -z "$2" ]; then
    DB_USER="$2"
fi

# Create timestamp for unique filename
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DUMP_FILE="payment_clearing_dump_${TIMESTAMP}.sql"

echo "Database Configuration:"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo ""
echo "Output file: $DUMP_FILE"
echo ""

# Check if pg_dump is available
if ! command -v pg_dump &> /dev/null; then
    echo "❌ ERROR: pg_dump command not found!"
    echo "Please install PostgreSQL client tools."
    exit 1
fi

echo "🔄 Starting database dump..."

# Create the dump
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
        --verbose \
        --clean \
        --no-owner \
        --no-privileges \
        --format=plain \
        --file="$DUMP_FILE"

# Check if dump was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Database dump completed successfully!"
    echo "📁 File created: $DUMP_FILE"
    
    # Show file size
    FILE_SIZE=$(ls -lh "$DUMP_FILE" | awk '{print $5}')
    echo "📊 File size: $FILE_SIZE"
    
    # Show first few lines to verify content
    echo ""
    echo "📋 Dump file preview (first 10 lines):"
    echo "----------------------------------------"
    head -10 "$DUMP_FILE"
    echo "----------------------------------------"
    
    echo ""
    echo "🎯 To restore this dump on another computer:"
    echo "   psql -h localhost -U $DB_USER -d $DB_NAME -f $DUMP_FILE"
    
else
    echo ""
    echo "❌ Database dump failed!"
    echo "Please check your database connection and credentials."
    exit 1
fi

echo ""
echo "=== Dump process completed ==="
