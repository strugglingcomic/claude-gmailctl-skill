# Troubleshooting Guide

Common issues and solutions when using gmailctl for Gmail filter management.

## Table of Contents

- [Installation Issues](#installation-issues) - gmailctl not found, permission errors
- [Authentication Issues](#authentication-issues) - OAuth, credentials, 403 errors
- [Configuration Issues](#configuration-issues) - Syntax errors, label problems
- [Apply Issues](#apply-issues) - Deployment failures, API errors
- [Runtime Issues](#runtime-issues) - Filter not matching, unexpected behavior
- [Performance Issues](#performance-issues) - Slow operations, timeouts
- [Testing Issues](#testing-issues) - Validation problems, diff output
- [File and Path Issues](#file-and-path-issues) - Config location, permissions
- [Backup and Recovery](#backup-and-recovery) - Rollback, restore configurations
- [Getting Help](#getting-help) - When to use WebFetch, GitHub issues
- [Quick Reference](#quick-reference) - Common error messages and fixes

---

## Installation Issues

### gmailctl command not found

**Symptoms**:
```bash
$ gmailctl version
command not found: gmailctl
```

**Solutions**:

**macOS (Homebrew)**:
```bash
# Install gmailctl
brew install gmailctl

# Verify installation
which gmailctl
gmailctl version
```

**Linux (Manual)**:
```bash
# Download latest release
curl -L https://github.com/mbrt/gmailctl/releases/latest/download/gmailctl-linux-amd64 -o gmailctl

# Make executable
chmod +x gmailctl

# Move to PATH
sudo mv gmailctl /usr/local/bin/

# Verify
gmailctl version
```

### Permission denied when running gmailctl

**Symptoms**:
```bash
$ ./gmailctl version
permission denied: ./gmailctl
```

**Solution**:
```bash
chmod +x gmailctl
```

## Authentication Issues

### Failed to load credentials

**Symptoms**:
```bash
$ gmailctl apply
Error: failed to load credentials
```

**Root Cause**: Missing or expired OAuth credentials

**Solution**:
```bash
# Remove old credentials
rm ~/.gmailctl/credentials.json

# Re-authenticate
gmailctl download

# This will:
# 1. Open browser for OAuth flow
# 2. Request Gmail permissions
# 3. Save new credentials
```

### OAuth consent screen error

**Symptoms**: Browser shows "This app isn't verified" or "Access blocked"

**Solution**:
1. Click "Advanced" or "Show Advanced"
2. Click "Go to gmailctl (unsafe)"
3. Review permissions
4. Click "Allow"

**Note**: This is expected for personal API projects

### Insufficient permissions

**Symptoms**:
```bash
Error: insufficient permissions for gmail.settings.basic
```

**Root Cause**: OAuth scope doesn't include required permissions

**Solution**:
```bash
# Delete credentials
rm ~/.gmailctl/credentials.json

# Re-authenticate with correct scopes
gmailctl download
```

**Required Scope**: `https://www.googleapis.com/auth/gmail.settings.basic`

### Token expired

**Symptoms**: Commands fail with "token expired" or "invalid credentials"

**Solution**:
```bash
# Download refreshes token automatically
gmailctl download

# If that fails, re-authenticate
rm ~/.gmailctl/credentials.json
gmailctl download
```

## Configuration Issues

### Jsonnet syntax error

**Symptoms**:
```bash
$ gmailctl debug
RUNTIME ERROR: Expected a comma before next field.
```

**Common Causes**:

**Missing comma**:
```jsonnet
// ❌ Wrong
{
  labels: [
    { name: "Work" }
    { name: "Personal" }  // Missing comma above!
  ]
}

// ✅ Correct
{
  labels: [
    { name: "Work" },
    { name: "Personal" }
  ]
}
```

**Unclosed braces**:
```jsonnet
// ❌ Wrong
{
  rules: [
    {
      filter: { query: "from:example.com" },
      actions: { labels: ["Work"] }
    // Missing closing brace!
  ]
}

// ✅ Correct
{
  rules: [
    {
      filter: { query: "from:example.com" },
      actions: { labels: ["Work"] }
    }
  ]
}
```

**Solution**:
```bash
# Validate syntax
gmailctl debug

# Check line number in error message
# Fix syntax error at that location
```

### Invalid query syntax

**Symptoms**:
```bash
$ gmailctl apply
Error: invalid query: 'from @example.com'
```

**Common Mistakes**:

**Missing colon**:
```jsonnet
// ❌ Wrong
filter: { query: "from @example.com" }

// ✅ Correct
filter: { query: "from:@example.com" }
```

**Invalid operator**:
```jsonnet
// ❌ Wrong (AND is not an explicit operator)
filter: { query: "from:a.com AND subject:test" }

// ✅ Correct (space implies AND)
filter: { query: "from:a.com subject:test" }
```

**Incorrect OR syntax**:
```jsonnet
// ❌ Wrong
filter: { query: "from:a.com or from:b.com" }

// ✅ Correct (uppercase OR)
filter: { query: "from:a.com OR from:b.com" }
```

**Solution**:
1. Test query in Gmail search bar first
2. Copy exact working query to config
3. Validate with `gmailctl debug`

### Label not found

**Symptoms**:
```bash
Error: label 'Work/Projects' not found
```

**Root Cause**: Label used in actions but not defined in labels section

**Solution**:
```jsonnet
{
  // Define all labels first
  labels: [
    { name: "Work" },
    { name: "Work/Projects" }  // Must define before using
  ],

  rules: [
    {
      filter: { query: "from:example.com" },
      actions: { labels: ["Work/Projects"] }  // Now valid
    }
  ]
}
```

### Labels must be an array

**Symptoms**:
```bash
Error: actions.labels must be an array
```

**Problem**:
```jsonnet
// ❌ Wrong (string, not array)
actions: {
  labels: "Work"
}

// ✅ Correct (array of strings)
actions: {
  labels: ["Work"]
}
```

## Apply Issues

### No filters to apply

**Symptoms**:
```bash
$ gmailctl apply
No filters to apply. Configuration matches Gmail.
```

**Meaning**: Local config matches current Gmail state (not an error!)

**Verify**:
```bash
# Check for any differences
gmailctl diff

# Should show no changes
```

**If you expected changes**:
1. Verify config.jsonnet was saved
2. Check if filter already exists in Gmail
3. Ensure query or actions actually changed

### Cannot delete filter

**Symptoms**:
```bash
Error: cannot delete filter: filter not found
```

**Cause**: Trying to remove filter that doesn't exist in Gmail

**Solution**:
```bash
# Download current Gmail state
gmailctl download

# Review what exists
gmailctl diff

# Remove conflicting rule from config.jsonnet
```

### Conflict with existing filters

**Symptoms**: `gmailctl diff` shows unexpected deletions

**Cause**: gmailctl wants to remove filters not in config

**Solution**:

**Option 1**: Keep gmailctl as source of truth
```bash
# Review diff carefully
gmailctl diff

# Apply (will remove filters not in config)
gmailctl apply
```

**Option 2**: Import existing filters
```bash
# Download current Gmail filters
gmailctl download

# Manually add missing rules to config.jsonnet
# based on downloaded state
```

## Runtime Issues

### Too many filters

**Symptoms**: Filter creation fails or Gmail UI becomes slow

**Gmail Limits**:
- Maximum ~1000 filters per account
- Complex queries can slow down Gmail

**Solution**:
```bash
# Count current filters
gmailctl download
# Review output for filter count

# Consolidate filters
# Use OR to combine similar rules
# Remove unused/duplicate filters
```

**Example Consolidation**:
```jsonnet
// ❌ Wrong (5 separate filters)
{
  rules: [
    { filter: { query: "from:a@news.com" }, actions: { archive: true, labels: ["Newsletters"] } },
    { filter: { query: "from:b@news.com" }, actions: { archive: true, labels: ["Newsletters"] } },
    { filter: { query: "from:c@news.com" }, actions: { archive: true, labels: ["Newsletters"] } },
    { filter: { query: "from:d@news.com" }, actions: { archive: true, labels: ["Newsletters"] } },
    { filter: { query: "from:e@news.com" }, actions: { archive: true, labels: ["Newsletters"] } },
  ]
}

// ✅ Correct (1 consolidated filter)
{
  rules: [
    {
      filter: { query: "{from:a@news.com from:b@news.com from:c@news.com from:d@news.com from:e@news.com}" },
      actions: { archive: true, labels: ["Newsletters"] }
    }
  ]
}
```

### Filter not working as expected

**Symptoms**: Emails not being filtered correctly

**Debugging Steps**:

**1. Test the query**:
```bash
# Search in Gmail web UI with exact query
# Verify it matches expected emails
```

**2. Check filter order**:
```jsonnet
// Filters are evaluated top-to-bottom
// More specific filters should come first

// ❌ Wrong order
{
  rules: [
    { filter: { query: "from:@company.com" }, actions: { labels: ["Work"] } },
    { filter: { query: "from:boss@company.com" }, actions: { labels: ["Work/Priority"] } }
  ]
}

// ✅ Correct order (specific first)
{
  rules: [
    { filter: { query: "from:boss@company.com" }, actions: { labels: ["Work/Priority"] } },
    { filter: { query: "from:@company.com" }, actions: { labels: ["Work"] } }
  ]
}
```

**3. Verify label exists**:
```bash
# Check label is defined
gmailctl debug

# Ensure label name matches exactly (case-sensitive)
```

**4. Test with a single email**:
```bash
# Add very specific query temporarily
# Example: "from:exact@email.com subject:exact subject"
# Verify that specific email gets filtered
# Then broaden query
```

### Filters applied to old emails

**Symptoms**: Want filters to only affect new emails

**Explanation**: Gmail filters apply to **future** emails by default (this is desired behavior)

**To manually apply to existing emails**:
1. Search with filter query in Gmail
2. Select emails
3. Apply labels manually

**Not supported by gmailctl**: Automatic application to existing emails

### Rate limiting

**Symptoms**:
```bash
Error: rate limit exceeded
```

**Cause**: Too many API requests in short time

**Solution**:
```bash
# Wait 1-2 minutes
# Try again

# If persistent, check for:
# - Multiple gmailctl processes running
# - Other apps using Gmail API
```

## Performance Issues

### gmailctl commands are slow

**Common Causes**:

**1. Network latency**:
- API calls to Google servers
- Check internet connection

**2. Large configuration**:
- Many filters (>100)
- Complex Jsonnet logic

**Solution**:
```bash
# Profile command execution
time gmailctl diff

# Optimize Jsonnet
# - Reduce function complexity
# - Cache repeated computations
```

**3. First authentication**:
- OAuth flow is slow
- Subsequent commands are faster

### Gmail UI is slow after applying filters

**Cause**: Too many filters or complex queries

**Solution**:
```bash
# Simplify queries
# - Remove wildcards where possible
# - Use specific operators
# - Consolidate with OR

# Reduce filter count
# - Merge similar filters
# - Remove unused filters
```

## Testing Issues

### Tests failing unexpectedly

**Symptoms**:
```bash
$ gmailctl test
FAIL: Expected archive=true, got archive=false
```

**Debugging**:

**1. Check test structure**:
```jsonnet
{
  tests: [
    {
      message: {
        from: "sender@example.com",
        to: "me@example.com",
        subject: "Test Subject"
      },
      expected: {
        archive: true,
        labels: ["Work"]
      }
    }
  ]
}
```

**2. Verify filter matches message**:
```jsonnet
// Test message must match filter query exactly

// Filter:
filter: { query: "from:sender@example.com subject:test" }

// Test message must have BOTH:
message: {
  from: "sender@example.com",
  subject: "Test Message"  // Must contain "test"
}
```

**3. Check action values**:
```jsonnet
// Boolean actions
expected: {
  archive: true,    // Not "true" (string)
  markRead: true
}

// Array actions
expected: {
  labels: ["Work"]  // Array of strings
}
```

## File and Path Issues

### Config file not found

**Symptoms**:
```bash
Error: config file not found
```

**Default location**: `~/.gmailctl/config.jsonnet`

**Solution**:
```bash
# Create config directory
mkdir -p ~/.gmailctl

# Initialize configuration
gmailctl init

# Or specify custom path
gmailctl --config /path/to/config.jsonnet apply
```

### Cannot write to config directory

**Symptoms**:
```bash
Error: permission denied writing to ~/.gmailctl/
```

**Solution**:
```bash
# Fix permissions
chmod 755 ~/.gmailctl

# Verify
ls -la ~/.gmailctl
```

## Backup and Recovery

### Accidentally deleted all filters

**Prevention**:
```bash
# Before major changes
gmailctl download > backup.txt
cp ~/.gmailctl/config.jsonnet ~/.gmailctl/config.jsonnet.backup
```

**Recovery**:
```bash
# Restore from backup
cp ~/.gmailctl/config.jsonnet.backup ~/.gmailctl/config.jsonnet

# Re-apply
gmailctl apply
```

### Lost config file

**Recovery**:
```bash
# Download current Gmail state
gmailctl download

# Manually recreate config.jsonnet
# based on downloaded filter descriptions
```

## Getting Help

### Collecting diagnostic information

```bash
# Version info
gmailctl version

# Configuration debug
gmailctl debug

# Show diff without applying
gmailctl diff

# Verbose output
gmailctl --debug apply
```

### Reporting issues

Include in bug reports:
1. gmailctl version
2. Operating system
3. Error message (full text)
4. Minimal config that reproduces issue
5. Steps to reproduce

### Community resources

- **GitHub Issues**: https://github.com/mbrt/gmailctl/issues
- **Documentation**: https://github.com/mbrt/gmailctl/blob/master/README.md
- **Gmail Support**: https://support.google.com/mail

## Quick Reference

### Common Commands

```bash
# Initialize
gmailctl init

# Authenticate
gmailctl download

# Validate config
gmailctl debug

# Preview changes
gmailctl diff

# Apply filters
gmailctl apply

# Run tests
gmailctl test
```

### Diagnostic Workflow

```bash
# 1. Validate syntax
gmailctl debug

# 2. Check what would change
gmailctl diff

# 3. Test queries in Gmail UI

# 4. Apply changes
gmailctl apply

# 5. Verify in Gmail web interface
```
