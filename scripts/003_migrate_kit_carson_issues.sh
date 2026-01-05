#!/bin/bash
# ============================================================================
# A3S PLATFORM - MIGRATE KIT CARSON ISSUES
# ============================================================================
# 
# This script migrates accessibility issues and test URLs from the NEW database
# to the OLD/PRODUCTION database for the Kit Carson County Website project.
#
# Project: Kit Carson County Website
# Project ID: e58fbdec-5d3b-4686-9743-d283d2e1ef0f
#
# What this does:
#   1. Exports test_urls and accessibility_issues from SOURCE
#   2. Deletes existing data from TARGET
#   3. Imports data into TARGET (preserving created_at/updated_at)
#
# Usage: ./scripts/003_migrate_kit_carson_issues.sh
# ============================================================================

set -e

SOURCE_DB="postgresql://postgres.kwxnfskctsfccvysokxo:azsxdcfv321gbhnjm@aws-1-us-east-1.pooler.supabase.com:6543/postgres"
TARGET_DB="postgresql://postgres.nsaovodiykewfluipkam:asdfghjkl1234qwertyuiop@aws-1-us-east-1.pooler.supabase.com:6543/postgres"
PROJECT_ID="e58fbdec-5d3b-4686-9743-d283d2e1ef0f"

echo "============================================"
echo "Kit Carson Issues Migration"
echo "============================================"

# Step 1: Export from SOURCE
echo ""
echo "Step 1: Exporting data from SOURCE database..."

echo "  - Exporting test_urls..."
psql "$SOURCE_DB" -c "\COPY (SELECT * FROM test_urls WHERE project_id = '$PROJECT_ID') TO '/tmp/kit_carson_test_urls.csv' WITH CSV HEADER"

echo "  - Exporting accessibility_issues..."
psql "$SOURCE_DB" -c "\COPY (SELECT * FROM accessibility_issues WHERE project_id = '$PROJECT_ID') TO '/tmp/kit_carson_issues.csv' WITH CSV HEADER"

# Count exported records
TEST_URLS_COUNT=$(psql "$SOURCE_DB" -t -c "SELECT COUNT(*) FROM test_urls WHERE project_id = '$PROJECT_ID'")
ISSUES_COUNT=$(psql "$SOURCE_DB" -t -c "SELECT COUNT(*) FROM accessibility_issues WHERE project_id = '$PROJECT_ID'")
echo "  - Exported: $TEST_URLS_COUNT test_urls, $ISSUES_COUNT issues"

# Step 2: Delete from TARGET
echo ""
echo "Step 2: Deleting existing data from TARGET database..."

psql "$TARGET_DB" -c "
DELETE FROM report_issues WHERE issue_id IN (SELECT id FROM accessibility_issues WHERE project_id = '$PROJECT_ID');
DELETE FROM accessibility_issues WHERE project_id = '$PROJECT_ID';
DELETE FROM test_urls WHERE project_id = '$PROJECT_ID';
"
echo "  - Deleted existing data"

# Step 3: Import to TARGET
echo ""
echo "Step 3: Importing data to TARGET database..."

echo "  - Importing test_urls..."
psql "$TARGET_DB" -c "\COPY test_urls FROM '/tmp/kit_carson_test_urls.csv' WITH CSV HEADER"

echo "  - Importing accessibility_issues..."
psql "$TARGET_DB" -c "\COPY accessibility_issues FROM '/tmp/kit_carson_issues.csv' WITH CSV HEADER"

# Step 4: Verify
echo ""
echo "Step 4: Verifying migration..."
TARGET_TEST_URLS=$(psql "$TARGET_DB" -t -c "SELECT COUNT(*) FROM test_urls WHERE project_id = '$PROJECT_ID'")
TARGET_ISSUES=$(psql "$TARGET_DB" -t -c "SELECT COUNT(*) FROM accessibility_issues WHERE project_id = '$PROJECT_ID'")

echo "  - TARGET now has: $TARGET_TEST_URLS test_urls, $TARGET_ISSUES issues"

# Cleanup
rm -f /tmp/kit_carson_test_urls.csv /tmp/kit_carson_issues.csv

echo ""
echo "============================================"
echo "Migration complete!"
echo "============================================"

