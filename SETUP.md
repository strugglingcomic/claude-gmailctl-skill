# Setup Guide

Complete setup instructions for the Claude Gmail Control skill.

## Step 1: Install gmailctl

### macOS

```bash
brew install gmailctl
```

### Linux

```bash
# Download latest release
curl -L https://github.com/mbrt/gmailctl/releases/latest/download/gmailctl-linux-amd64 -o gmailctl
chmod +x gmailctl
sudo mv gmailctl /usr/local/bin/

# Verify installation
gmailctl version
```

### Windows (WSL recommended)

Follow Linux instructions in WSL environment.

## Step 2: Initialize gmailctl

```bash
# Create configuration directory and template
gmailctl init

# This creates:
# - ~/.gmailctl/config.jsonnet (your filter configuration)
# - ~/.gmailctl/ directory structure
```

## Step 3: Authenticate with Gmail

```bash
# Download current filters and authenticate
gmailctl download
```

This will:
1. Open your browser for Google OAuth authentication
2. Request permissions to manage Gmail filters
3. Save credentials to `~/.gmailctl/credentials.json`
4. Download your current Gmail filters

**Note**: The OAuth flow requires `https://www.googleapis.com/auth/gmail.settings.basic` scope.

## Step 4: Configure Your Filters

### Option A: Start with Example Configuration

```bash
# Copy basic example to your config
cp examples/basic-config.jsonnet ~/.gmailctl/config.jsonnet

# Edit to match your needs
open ~/.gmailctl/config.jsonnet
```

### Option B: Build from Scratch

Edit `~/.gmailctl/config.jsonnet`:

```jsonnet
{
  version: "v1alpha3",

  labels: [
    { name: "MyLabel" },
  ],

  rules: [
    {
      filter: { query: "from:example@example.com" },
      actions: { labels: ["MyLabel"] }
    },
  ],
}
```

## Step 5: Test Your Configuration

```bash
# Check for syntax errors
gmailctl debug

# Preview what changes would be made
gmailctl diff
```

The diff will show:
- **Green (+)**: Filters/labels to be added
- **Red (-)**: Filters/labels to be removed
- **Yellow (~)**: Filters to be modified

## Step 6: Apply Your Configuration

```bash
# Apply changes to Gmail
gmailctl apply
```

**IMPORTANT**: This will update your actual Gmail filters. Make sure you've reviewed the diff first!

## Step 7: Use with Claude Code

### Install as a Claude Code Skill

```bash
# Option 1: Clone as submodule in your workspace (already done in yyy_local_hacky_sandbox)
git submodule add git@github.com:betfanatics-codywang/claude-gmailctl-skill.git

# Option 2: Clone to Claude skills directory
mkdir -p ~/.claude/skills
git clone git@github.com:betfanatics-codywang/claude-gmailctl-skill.git ~/.claude/skills/gmail
```

### Invoke the Skill

In Claude Code:
```
/skill gmail
```

Or simply mention your email management needs:
```
"Help me organize my inbox"
"Create filters for work emails"
"Set up automated newsletter archiving"
```

## Configuration Tips

### Start Simple

Begin with a few basic rules:
1. Auto-archive newsletters
2. Label work emails
3. File receipts

### Test Incrementally

- Add one or two filters at a time
- Run `gmailctl diff` to verify changes
- Apply and observe behavior for a few days
- Iterate and refine

### Use Version Control

```bash
# Create a git repo for your configuration
cd ~/.gmailctl
git init
git add config.jsonnet
git commit -m "Initial Gmail filter configuration"

# Optional: Push to private repo for backup
gh repo create gmail-config --private
git remote add origin git@github.com:username/gmail-config.git
git push -u origin main
```

### Back Up Before Major Changes

```bash
# Download current Gmail state
gmailctl download

# This creates a local backup of your existing filters
# You can restore by reverting your config.jsonnet and running gmailctl apply
```

## Troubleshooting

### Authentication Issues

**Error**: "Failed to load credentials"

**Solution**:
```bash
# Re-authenticate
rm ~/.gmailctl/credentials.json
gmailctl download
```

### Syntax Errors

**Error**: "jsonnet error: ..."

**Solution**:
```bash
# Check syntax
gmailctl debug

# Common issues:
# - Missing commas between array elements
# - Unclosed braces or brackets
# - Invalid Jsonnet syntax
```

### Permission Denied

**Error**: "insufficient permissions"

**Solution**:
- Ensure you authenticated with the correct Google account
- Re-authenticate: `gmailctl download`
- Check that OAuth scope includes `gmail.settings.basic`

### No Changes Applied

**Error**: "No filters to apply"

**Solution**:
- Your configuration matches current Gmail state
- Run `gmailctl diff` to verify
- Make changes to config.jsonnet if needed

### Filters Not Working as Expected

**Debug approach**:
1. Test queries directly in Gmail search bar
2. Check query syntax (quotes, operators, etc.)
3. Verify labels exist and are spelled correctly
4. Review filter order (earlier filters take precedence)
5. Check for conflicting rules

## Advanced Configuration

### Using Jsonnet Variables

```jsonnet
local workDomain = "company.com";

{
  rules: [
    {
      filter: { query: "from:@" + workDomain },
      actions: { labels: ["Work"] }
    }
  ]
}
```

### Importing External Files

```jsonnet
local lib = import "lib.jsonnet";

{
  rules: lib.workRules + lib.personalRules
}
```

### Environment-Specific Configs

```bash
# Work config
gmailctl --config ~/.gmailctl/work-config.jsonnet apply

# Personal config
gmailctl --config ~/.gmailctl/personal-config.jsonnet apply
```

## Maintenance

### Regular Review

Schedule periodic reviews:
- **Weekly**: Check inbox to see if filters are working as intended
- **Monthly**: Review `gmailctl diff` for any drift
- **Quarterly**: Optimize and clean up unused labels/filters

### Keep Up to Date

```bash
# Update gmailctl
brew upgrade gmailctl  # macOS

# Check version
gmailctl version
```

### Backup Strategy

1. **Version control**: Keep config.jsonnet in git
2. **Download state**: Periodically run `gmailctl download` to capture current Gmail state
3. **Export filters**: Use Gmail Takeout for complete backup

## Resources

- [gmailctl Documentation](https://github.com/mbrt/gmailctl)
- [Gmail Search Operators](https://support.google.com/mail/answer/7190)
- [Jsonnet Tutorial](https://jsonnet.org/learning/tutorial.html)
- [Inbox Zero Philosophy](https://www.43folders.com/izero)

---

**Need help?** Invoke the skill with `/skill gmail` and ask Claude for assistance!
