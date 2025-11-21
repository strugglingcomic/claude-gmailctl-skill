#!/bin/bash
# Backup gmailctl configuration with timestamp
# Usage: ./backup_config.sh [config_path] [backup_dir]

set -e

CONFIG_PATH="${1:-$HOME/.gmailctl/config.jsonnet}"
BACKUP_DIR="${2:-$HOME/.gmailctl/backups}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "💾 Backing up gmailctl configuration..."
echo ""

# Check if config exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "❌ Error: Config file not found: $CONFIG_PATH"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Generate backup filename
BACKUP_FILE="$BACKUP_DIR/config_$TIMESTAMP.jsonnet"

# Copy config
cp "$CONFIG_PATH" "$BACKUP_FILE"
echo "✅ Configuration backed up to: $BACKUP_FILE"

# Also backup credentials if they exist
CRED_PATH="$HOME/.gmailctl/credentials.json"
if [ -f "$CRED_PATH" ]; then
    CRED_BACKUP="$BACKUP_DIR/credentials_$TIMESTAMP.json"
    cp "$CRED_PATH" "$CRED_BACKUP"
    echo "✅ Credentials backed up to: $CRED_BACKUP"
fi

# Download current Gmail state
echo ""
echo "📥 Downloading current Gmail filter state..."
STATE_FILE="$BACKUP_DIR/gmail_state_$TIMESTAMP.txt"
if gmailctl download > "$STATE_FILE" 2>&1; then
    echo "✅ Gmail state saved to: $STATE_FILE"
else
    echo "⚠️  Warning: Could not download Gmail state (authentication may be needed)"
fi

echo ""
echo "─────────────────────────────────────────"
echo "✅ Backup complete!"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
echo "To restore from backup:"
echo "  cp $BACKUP_FILE $CONFIG_PATH"
echo "  gmailctl apply"
echo ""

# Show recent backups
echo "Recent backups:"
ls -lt "$BACKUP_DIR"/config_*.jsonnet | head -5 | awk '{print "  " $9 " (" $6 " " $7 " " $8 ")"}'
