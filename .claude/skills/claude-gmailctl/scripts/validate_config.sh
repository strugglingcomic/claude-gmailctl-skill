#!/bin/bash
# Validate gmailctl configuration before applying
# Usage: ./validate_config.sh [config_path]

set -e

CONFIG_PATH="${1:-$HOME/.gmailctl/config.jsonnet}"

echo "🔍 Validating gmailctl configuration..."
echo "Config: $CONFIG_PATH"
echo ""

# Check if gmailctl is installed
if ! command -v gmailctl &> /dev/null; then
    echo "❌ Error: gmailctl is not installed"
    echo "Install with: brew install gmailctl"
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "❌ Error: Config file not found: $CONFIG_PATH"
    exit 1
fi

# Validate Jsonnet syntax
echo "1️⃣  Checking Jsonnet syntax..."
if gmailctl --config="$CONFIG_PATH" debug > /dev/null 2>&1; then
    echo "✅ Syntax is valid"
else
    echo "❌ Syntax error detected:"
    gmailctl --config="$CONFIG_PATH" debug
    exit 1
fi

# Check for common issues
echo ""
echo "2️⃣  Checking for common issues..."

# Check if labels are defined before use
echo "   - Checking label definitions..."
LABELS=$(jsonnet "$CONFIG_PATH" | jq -r '.labels[]?.name // empty' 2>/dev/null || echo "")
USED_LABELS=$(jsonnet "$CONFIG_PATH" | jq -r '.rules[].actions.labels[]? // empty' 2>/dev/null || echo "")

UNDEFINED_LABELS=""
while IFS= read -r label; do
    if [ -n "$label" ] && ! echo "$LABELS" | grep -q "^${label}$"; then
        UNDEFINED_LABELS+="$label\n"
    fi
done <<< "$USED_LABELS"

if [ -n "$UNDEFINED_LABELS" ]; then
    echo "   ⚠️  Warning: Labels used but not defined:"
    echo -e "$UNDEFINED_LABELS" | sort -u | sed 's/^/     - /'
else
    echo "   ✅ All labels are properly defined"
fi

# Check for destructive actions
echo "   - Checking for destructive actions..."
HAS_DELETE=$(jsonnet "$CONFIG_PATH" | jq '.rules[].actions.delete // false' 2>/dev/null | grep -c "true" || echo "0")
HAS_SPAM=$(jsonnet "$CONFIG_PATH" | jq '.rules[].actions.markSpam // false' 2>/dev/null | grep -c "true" || echo "0")

if [ "$HAS_DELETE" -gt 0 ]; then
    echo "   ⚠️  Warning: Configuration contains DELETE actions ($HAS_DELETE rules)"
fi

if [ "$HAS_SPAM" -gt 0 ]; then
    echo "   ⚠️  Warning: Configuration contains SPAM actions ($HAS_SPAM rules)"
fi

if [ "$HAS_DELETE" -eq 0 ] && [ "$HAS_SPAM" -eq 0 ]; then
    echo "   ✅ No destructive actions found"
fi

# Show preview of changes
echo ""
echo "3️⃣  Preview of changes:"
echo "─────────────────────────────────────────"
if gmailctl --config="$CONFIG_PATH" diff 2>&1 | grep -q "No changes"; then
    echo "✅ No changes to apply (config matches Gmail)"
else
    gmailctl --config="$CONFIG_PATH" diff || true
fi

echo ""
echo "─────────────────────────────────────────"
echo "✅ Validation complete!"
echo ""
echo "To apply changes, run:"
echo "  gmailctl --config=\"$CONFIG_PATH\" apply"
