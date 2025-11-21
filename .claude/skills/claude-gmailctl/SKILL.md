---
name: Gmail Control
description: Manage Gmail filters and labels using gmailctl to implement Inbox Zero email management workflows. Use when helping users organize email, create automated triage rules, or maintain filter configurations as code.
---

# Gmail Control Skill

## Purpose

Assist users in managing Gmail filters and labels through `gmailctl`, a declarative configuration tool that treats email filtering as code. Enable users to achieve and maintain Inbox Zero by automating email triage, organizing messages with labels, and implementing systematic email processing workflows.

## When to Use

Activate this skill when users request help with:
- Setting up gmailctl with Gmail credentials
- Creating or modifying Gmail filters
- Organizing email with labels and categories
- Implementing Inbox Zero or automated email triage
- Reviewing and optimizing existing filter configurations
- Converting manual email processing into automated rules
- Managing `~/.gmailctl/config.jsonnet` configuration

## Skill Components

This skill is organized into distinct components for granular understanding:

1. **[Setup & Initialization](#component-1-setup--initialization)** - Installing gmailctl and authenticating with Gmail
2. **[Assessment](#component-2-assessment)** - Understanding existing filters, labels, and email patterns
3. **[Filter Design](#component-3-filter-design)** - Creating and validating filter rules
4. **[Deployment](#component-4-deployment)** - Applying changes safely with deployment mode choice
5. **[Simple Features](#component-5-simple-features)** - Basic filter operators and actions
6. **[Advanced Features](#component-6-advanced-features)** - Jsonnet programming, reusable patterns, and complex workflows

## Reference Files Guide

Load these reference files as needed for detailed guidance:

| Reference File | When to Read | Contents |
|----------------|--------------|----------|
| `references/setup-oauth.md` | OAuth setup, "403 Access denied", credentials.json issues | Complete Google Cloud OAuth setup with screenshots-level detail (6 steps) |
| `references/actions-reference.md` | User needs complete action syntax, common mistakes, or action combinations | All available filter actions with examples and constraints |
| `references/inbox-zero.md` | User asks about email organization strategy, label structure, or Inbox Zero methodology | Inbox Zero principles, label design, processing workflows |
| `references/troubleshooting.md` | Installation issues, authentication problems, or error resolution beyond quick fixes | Comprehensive troubleshooting for installation, auth, syntax, and runtime errors |
| `references/setup-guide.md` | Need guidance on when/how to use WebFetch for setup questions | WebFetch strategy reference for setup-related queries |

**Important**: Only load reference files when needed. Use the table above to determine relevance.

---

## Component 1: Setup & Initialization

### When to Use This Component
- User is new to gmailctl
- User needs to authenticate or re-authenticate with Gmail
- Installation or credential issues occur

### Quick Setup

**1. Check installation:**
```bash
gmailctl version
```

**2. Install if needed:**
```bash
# macOS
brew install gmailctl

# Linux
curl -L https://github.com/mbrt/gmailctl/releases/latest/download/gmailctl-linux-amd64 -o gmailctl
chmod +x gmailctl && sudo mv gmailctl /usr/local/bin/
```

**3. Set up Google Cloud OAuth credentials (first-time only):**

If running `gmailctl init` fails with "credentials.json: no such file or directory", you need to create OAuth credentials.

**For detailed OAuth setup instructions, read `references/setup-oauth.md`** which covers:
- Creating Google Cloud project
- Enabling Gmail API
- Configuring OAuth consent screen
- Adding yourself as test user (critical!)
- Creating Desktop app credentials
- Downloading credentials.json

**Quick summary:**
- Create OAuth credentials at https://console.developers.google.com
- Enable Gmail API
- Add required scopes: `gmail.labels`, `gmail.settings.basic`
- **Critical**: Add your Gmail address as a test user
- Download credentials as Desktop app (not Web app)
- Save to `~/.gmailctl/credentials.json`

**Common error**: 403 "Access denied" → You forgot to add yourself as a test user. See `references/setup-oauth.md` for fix.

**4. Initialize and authenticate:**
```bash
# Initialize (creates config template)
gmailctl init

# Authenticate (browser opens for OAuth)
gmailctl download
```

**5. Verify:**
```bash
gmailctl diff  # Should show "No changes" or list current filters
```

### What Happens During Setup

- **Google Cloud setup (first-time)**: Create OAuth credentials for Gmail API access
- **`gmailctl init`**: Creates `~/.gmailctl/config.jsonnet` template
- **`gmailctl download`**: Opens browser → OAuth consent → saves credentials → downloads Gmail filters

**Files created:**
- `~/.gmailctl/config.jsonnet` - Edit this to define filters
- `~/.gmailctl/credentials.json` - OAuth credentials from Google Cloud (⚠️ do NOT commit to git)
- `~/.gmailctl/token.json` - Access token (created after OAuth flow)
- `~/.gmailctl/cache/` - Downloaded Gmail state

### For Installation/Setup Issues

**Quick troubleshooting:**
- **"403 Access denied"** → Read `references/setup-oauth.md` for test user setup
- **"Failed to load credentials"** → `rm ~/.gmailctl/credentials.json && gmailctl download`
- **"credentials.json: no such file"** → Read `references/setup-oauth.md` for complete OAuth setup
- **"Browser doesn't open"** → Use `--no-browser` flag, manually visit shown URL
- **"insufficient permissions"** → Re-run `gmailctl download`, click "Allow" for all permissions

**For advanced troubleshooting:**
- Read `references/setup-guide.md` for WebFetch usage patterns
- Read `references/troubleshooting.md` for comprehensive issue resolution
- Use WebFetch for platform-specific issues: https://github.com/mbrt/gmailctl/blob/master/README.md

---

## Component 2: Assessment

### When to Use This Component
- Before creating new filters (to avoid conflicts)
- When user asks to "review my filters"
- When troubleshooting filter behavior
- Before major configuration changes

### Assess Current Configuration

**1. Read local configuration:**
```bash
cat ~/.gmailctl/config.jsonnet
```

**Analysis checklist:**
- What labels are defined?
- How many rules exist?
- What email patterns are already handled?
- Are there Jsonnet variables or functions in use?

**2. Download current Gmail state:**
```bash
gmailctl download
```

This refreshes local cache to match Gmail's actual filter state, accounting for any manual changes made in Gmail UI.

**3. Check for configuration drift:**
```bash
gmailctl diff
```

**Interpret output:**
- **No output** → Local config matches Gmail perfectly (normal after successful apply)
- **Changes shown** → Differences between config.jsonnet and Gmail
  - Green (+) = Would be added
  - Red (-) = Would be removed
  - Yellow (~) = Would be modified

**Note:** `gmailctl diff` returns no output when there are no differences. This is expected behavior and indicates the last `gmailctl apply` completed successfully.

### Analyze Existing Filters

**Count and categorize rules:**
```bash
# Count total rules
grep -c "filter:" ~/.gmailctl/config.jsonnet

# List all labels
grep "name:" ~/.gmailctl/config.jsonnet | grep -v version
```

**Identify patterns:**
- Which senders are most frequently filtered?
- What actions are used most (archive, label, delete)?
- Are there overlapping or redundant filters?
- Any undefined labels referenced in actions?

### Understand User's Email Patterns

**Before proposing changes, ask:**
- What types of emails do you receive most frequently?
- Which emails require immediate attention vs. can be batched?
- What manual processing do you do repeatedly?
- Any specific senders or domains to prioritize?
- Current pain points with email management?
- Are you aiming for Inbox Zero or another organizational system?

**Use Gmail search to analyze:**
```
Test queries like:
- in:inbox newer_than:7d
- from:@domain.com
- has:attachment larger:10MB
```

This reveals actual email volumes and patterns to inform filter design.

**For Inbox Zero methodology:**
If user mentions "Inbox Zero" or wants comprehensive email organization strategy, read `references/inbox-zero.md` for:
- Core Inbox Zero principles (5 categories: Delete, Delegate, Respond, Defer, Archive)
- Recommended label structures (Work, Personal, Reference, Low-Priority, Action-Required)
- Automated triage workflows
- Email processing best practices
- Decision fatigue reduction strategies

---

## Component 3: Filter Design

### When to Use This Component
- Creating new filters based on user requirements
- Modifying existing filters
- Consolidating redundant rules

### Basic Filter Structure

```jsonnet
{
  version: "v1alpha3",

  labels: [
    { name: "CategoryName" },
    { name: "Parent/Child" }
  ],

  rules: [
    {
      filter: { query: "from:sender@example.com" },
      actions: { archive: true, labels: ["CategoryName"] }
    }
  ]
}
```

### Design Process

**1. Identify the email pattern**
- What makes these emails identifiable? (sender, subject, content)
- How frequently do they arrive?
- What should happen to them?

**2. Test query in Gmail search bar first**
```
from:sender@example.com
subject:"weekly report"
has:attachment larger:5MB
```

**3. Create filter rule**
```jsonnet
{
  filter: { query: "your-tested-query" },
  actions: { /* desired actions */ }
}
```

**4. Validate before applying** (see validation section below)

### Common Filter Patterns

**Auto-archive newsletters:**
```jsonnet
{
  filter: { query: "list:newsletter@example.com" },
  actions: { archive: true, markRead: true, labels: ["Newsletters"] }
}
```

**Priority routing:**
```jsonnet
{
  filter: { query: "from:vip@example.com" },
  actions: { markImportant: true, labels: ["Priority"] }
}
```

**Receipt filing:**
```jsonnet
{
  filter: { query: "subject:(receipt OR invoice) has:attachment" },
  actions: { archive: true, labels: ["Reference/Receipts"] }
}
```

**Notification filtering:**
```jsonnet
{
  filter: { query: "from:notifications@github.com -mentions:me" },
  actions: { archive: true, labels: ["Notifications"] }
}
```

### Validation

**Always validate before deployment:**

```bash
# 1. Check syntax errors
gmailctl debug

# 2. Preview changes (REQUIRED)
gmailctl diff

# 3. Run validation script (checks for common issues)
scripts/validate_config.sh
```

**Show `gmailctl diff` output to user for approval before proceeding.**

**Validation checklist:**
- [ ] All labels are defined in `labels:` section
- [ ] Queries tested in Gmail search bar
- [ ] No conflicting or overlapping rules
- [ ] Destructive actions (`delete`, `markSpam`) explicitly approved
- [ ] Filter order appropriate (specific before general)

---

## Component 4: Deployment

### When to Use This Component
- After designing and validating filters
- When ready to apply changes to Gmail

### Deployment Modes

**IMPORTANT: Ask user which deployment approach they prefer:**

#### Mode 1: Overwrite (Replace Existing)

**What it does:**
- Removes all existing Gmail filters
- Replaces with exactly what's in config.jsonnet
- Ensures Gmail matches configuration perfectly

**When to use:**
- You maintain all filters in config.jsonnet
- Want clean slate with no manual Gmail filters
- Treating configuration as single source of truth

**Command:**
```bash
gmailctl apply
```

**⚠️ Warning:** Any filters created manually in Gmail will be deleted if not in config.jsonnet.

#### Mode 2: Additive (Merge with Existing)

**What it does:**
- Adds new filters from config.jsonnet
- Keeps existing Gmail filters not in config
- Allows hybrid management (some filters in config, some manual)

**When to use:**
- Migrating gradually to gmailctl
- Want to keep some manual Gmail filters
- Collaborating with others who use Gmail UI

**Implementation approach:**
1. Run `gmailctl download` to capture current state
2. Review diff carefully to understand what exists
3. Add only new filters to config.jsonnet
4. Apply incrementally

**Note:** gmailctl doesn't have a native "additive mode" flag, so this requires:
- Maintaining awareness of what's in Gmail vs. config
- Being careful not to delete existing filters
- Potentially using multiple config files for different purposes

### Deployment Workflow

**Pre-deployment checklist:**
- [ ] Configuration validated with `gmailctl debug`
- [ ] Diff reviewed with `gmailctl diff`
- [ ] User approved changes
- [ ] Backup created with `scripts/backup_config.sh`
- [ ] Deployment mode confirmed with user

**Execute deployment:**
```bash
# Create backup first
scripts/backup_config.sh ~/.gmailctl/config.jsonnet

# Apply changes (interactive confirmation)
gmailctl apply

# Or apply without confirmation (for programmatic use)
gmailctl apply --yes
```

**Note:** Use `--yes` flag when running gmailctl programmatically or in automated workflows to skip interactive confirmation.

**Post-deployment:**
1. Verify filters in Gmail UI
2. Monitor inbox for misfiled emails
3. Refine queries if needed
4. Document any issues encountered

### Rollback

If deployment causes issues:

```bash
# Option 1: Revert config.jsonnet to previous version
git checkout HEAD~1 ~/.gmailctl/config.jsonnet
gmailctl apply

# Option 2: Restore from backup
cp ~/.gmailctl/backups/config.jsonnet.YYYYMMDD ~/.gmailctl/config.jsonnet
gmailctl apply
```

---

## Component 5: Simple Features

### When to Use This Component
- User is new to gmailctl
- Creating basic filters
- Needs quick reference for common operators

### Basic Gmail Search Operators

**Sender/Recipient:**
- `from:sender@example.com` - From specific address
- `to:recipient@example.com` - To specific address
- `cc:person@example.com` - CC'd to person
- `list:mailinglist@example.com` - From mailing list

**Subject and Content:**
- `subject:keyword` - Subject contains keyword
- `subject:"exact phrase"` - Subject contains exact phrase
- `keyword` - Body or subject contains keyword
- `"exact phrase"` - Body or subject contains exact phrase

**Attachments:**
- `has:attachment` - Has any attachment
- `has:drive` - Has Google Drive attachment
- `has:document` - Has Google Docs
- `filename:pdf` - Attachment filename contains "pdf"
- `larger:5MB` - Larger than 5MB

**Date:**
- `newer_than:7d` - Newer than 7 days
- `older_than:1y` - Older than 1 year
- `after:2024/01/01` - After specific date
- `before:2024/12/31` - Before specific date

**Logic Operators:**
- `OR` - Either condition (e.g., `from:alice OR from:bob`)
- `-` - Negation (e.g., `-from:spam.com`)
- `( )` - Grouping (e.g., `(from:alice OR from:bob) subject:report`)

**Status:**
- `is:unread` - Unread emails
- `is:read` - Read emails
- `is:starred` - Starred/important
- `is:important` - Marked as important by Gmail

### Basic Actions

**Available actions in filter rules:**

```jsonnet
actions: {
  archive: true,              // Remove from inbox
  markRead: true,             // Mark as read
  star: true,                 // Star the message
  markImportant: true,        // Always mark as important (overrides Gmail heuristics)
  markImportant: false,       // Never mark as important (NOT markNotImportant!)
  markSpam: false,            // Prevent spam classification (markSpam: true not supported)
  category: "updates",        // Categorize: personal, social, updates, forums, promotions
  labels: ["Label1", "Label2"],  // Apply labels (array)
  forward: "email@example.com",  // Forward to another address

  // ⚠️ Destructive actions - require explicit user approval:
  delete: true,               // Move to trash
}
```

**Common mistakes:**
- ❌ `markNotImportant: true` - This field doesn't exist
- ✅ `markImportant: false` - Use this instead to never mark as important
- ❌ `markSpam: true` - Not supported by Gmail
- ✅ `markSpam: false` - Only prevent spam classification

**For complete actions reference with examples and common patterns:**
- Read `references/actions-reference.md` for comprehensive syntax guide
- Includes all available actions, constraints, and common mistake corrections

### Simple Configuration Example

```jsonnet
{
  version: "v1alpha3",

  labels: [
    { name: "Work" },
    { name: "Personal" },
    { name: "Newsletters" }
  ],

  rules: [
    // Archive work emails and label
    {
      filter: { query: "from:@company.com" },
      actions: { labels: ["Work"] }
    },

    // Auto-archive newsletters
    {
      filter: { query: "list:news@example.com" },
      actions: { archive: true, markRead: true, labels: ["Newsletters"] }
    },

    // Priority personal emails
    {
      filter: { query: "from:family@example.com" },
      actions: { markImportant: true, labels: ["Personal"] }
    }
  ]
}
```

### Need More Detail?

**For comprehensive syntax reference:**
- Use WebFetch to read: https://github.com/mbrt/gmailctl/blob/master/README.md
- Focus on "Configuration" and "Query Language" sections
- Also see: https://support.google.com/mail/answer/7190 (Gmail search operators)

---

## Component 6: Advanced Features

### When to Use This Component
- User has complex filtering needs
- Wants to use Jsonnet programming features
- Needs reusable filter patterns
- Managing large configurations

### Advanced Topics Overview

For advanced features, **use WebFetch to read live documentation instead of duplicating here:**

🌐 **Primary source:** https://github.com/mbrt/gmailctl/blob/master/README.md

**Key sections to fetch:**
- "Tips and Tricks" - Advanced patterns and techniques
- "Library functions" - Reusable helper functions
- "Testing" - Validating filter behavior
- "Examples" - Real-world complex configurations

### Advanced Patterns Quick Reference

**When user needs these features, fetch details from source docs:**

1. **Jsonnet Variables**
   - Define reusable values
   - Example: `local workDomain = "company.com";`
   - **Fetch details:** Search README for "Variables" or "local"

2. **Jsonnet Functions**
   - Create reusable filter generators
   - Example: `local archiveAndLabel(query, label) = { ... }`
   - **Fetch details:** Search README for "Functions" or "Tips and Tricks"

3. **Chain Filtering**
   - Simulate if-else logic with `chainFilters()`
   - Prevents multiple filters from matching same email
   - **Fetch details:** Search README for "chainFilters" or "Tips and Tricks"

4. **Library Functions**
   - `directlyTo()` - Match emails sent directly to you
   - `toMe()` - Reference your email address
   - **Fetch details:** Search README for "Library" or "directlyTo"

5. **Label Management**
   - Color customization for labels
   - Nested label hierarchies
   - **Fetch details:** Search README for "Labels" or "color"

6. **Import External Files**
   - Split configuration into modules
   - Share common patterns across configs
   - **Fetch details:** Search README for "import" or "library"

7. **Multi-Account Management**
   - Manage filters for multiple Gmail accounts
   - **Fetch details:** Search README for "account" or "multiple"

### Example: Fetching Advanced Documentation

**When user asks about advanced feature:**

```
User: "How do I use chain filtering?"

Response:
Let me fetch the latest documentation on chain filtering from the gmailctl repository.

[Use WebFetch on https://github.com/mbrt/gmailctl/blob/master/README.md]
[Search for "chain" or "Tips and Tricks"]
[Provide summary and example from live docs]
```

**Benefits of this approach:**
- Always up-to-date with latest gmailctl version
- Avoids documentation duplication and drift
- Reduces skill file size and maintenance burden
- Users get authoritative information directly from source

### Advanced Configuration Example

**Simple example to demonstrate Jsonnet features:**

```jsonnet
// Define reusable variables
local workDomain = "company.com";
local personalDomains = ["personal.com", "family.org"];

// Helper function for archiving and labeling
local archiveAndLabel(query, label) = {
  filter: { query: query },
  actions: { archive: true, labels: [label] }
};

{
  version: "v1alpha3",

  labels: [
    { name: "Work" },
    { name: "Personal" }
  ],

  rules: [
    // Use variable in filter
    {
      filter: { query: "from:@" + workDomain },
      actions: { labels: ["Work"] }
    },

    // Use helper function
    archiveAndLabel("list:newsletter@example.com", "Newsletters"),
    archiveAndLabel("subject:receipt", "Receipts")
  ]
}
```

**For complex patterns, always fetch from source docs using WebFetch.**

---

## Bundled Resources

### Templates

**`assets/templates/basic-config.jsonnet`**
- Simple Inbox Zero setup
- Newsletter archiving, receipt filing, priority routing
- **Use for:** New users or starting from scratch

**`assets/templates/advanced-config.jsonnet`**
- Jsonnet variables and functions
- Reusable helper patterns
- Complex organizational structure
- **Use for:** Power users or complex workflows

### Scripts

**`scripts/validate_config.sh [config_path]`**
- Validates Jsonnet syntax
- Checks for undefined labels
- Warns about destructive actions
- Shows preview of changes
- **Use before:** Applying configuration changes

**`scripts/backup_config.sh [config_path] [backup_dir]`**
- Creates timestamped backup
- Saves configuration and Gmail state
- Lists recent backups
- **Use before:** Major configuration changes

---

## Key Principles

### Safety First

1. **Always preview with `gmailctl diff` before applying**
2. **Never use `delete: true` or `markSpam: true` without explicit user confirmation**
3. **Backup configuration before major changes**: Use `scripts/backup_config.sh`
4. **Test queries in Gmail search bar** before adding to filters
5. **Start with narrow queries**, broaden after validation

### Progressive Implementation

1. **Start simple**: Begin with 2-3 obvious patterns (newsletters, receipts)
2. **Iterate based on usage**: Add filters as new patterns emerge
3. **Monitor for a week**: Ensure filters work as intended before expanding
4. **Refine queries**: Adjust based on misfiled or missed emails

### Configuration as Code

1. **Version control**: Keep config.jsonnet in git
2. **Document complex rules**: Add comments explaining rationale
3. **Use Jsonnet features**: Variables and functions for maintainability
4. **Consolidate filters**: Use OR to combine similar rules

---

## User Interaction Guidelines

### When to Ask Questions

- **Before destructive actions** (delete, spam)
- **When intent is ambiguous** (multiple valid approaches)
- **For deployment mode preference** (overwrite vs. additive)
- **For organizational preferences** (label naming, hierarchy)
- **When filters might be too aggressive** (risk of missing important emails)

### When to Proceed Autonomously

- **Reading current configuration** (always safe)
- **Proposing filter changes** (user reviews before applying)
- **Running validation commands** (`gmailctl debug`, `gmailctl diff`)
- **Fetching documentation** (WebFetch for advanced features)
- **Analyzing email patterns** (based on user's description)

### Communication Style

- **Explain logic in plain English** before showing Jsonnet code
- **Show both Jsonnet config and equivalent Gmail search query** for clarity
- **Highlight impact** ("This will archive ~50 newsletter emails per week")
- **Provide rationale** ("Archiving instead of deleting allows future search")
- **Use imperative/objective language** (avoid excessive praise)

---

## Typical Workflows

**Setup**: Component 1 → Initialize → Authenticate → Verify with `gmailctl diff`

**Review existing**: Component 2 → Read config → Download state → Analyze patterns → Suggest improvements

**Create filters**: Component 2 (assess) → Component 3 (design) → Validate → Component 4 (deploy)

**Advanced patterns**: Component 6 → WebFetch gmailctl docs → Implement Jsonnet features

---

## Troubleshooting Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| Syntax error | `gmailctl debug` |
| Auth failed | `rm ~/.gmailctl/credentials.json && gmailctl download` |
| 403 Access denied | Read `references/setup-oauth.md` - add test user |
| Label not found | Define in `labels:` section first |
| Filter not matching | Test query in Gmail search bar, check syntax |
| Changes not applied | Verify `gmailctl diff` shows changes, check credentials |

**For comprehensive troubleshooting**: Read `references/troubleshooting.md`

---

## Success Metrics

Track filter effectiveness:
- **Time to inbox zero** - Should decrease over time
- **Manual processing** - Should be <20% of emails
- **Misfiled emails** - Should be rare (adjust filters if frequent)
- **Filter count** - Keep manageable (<50 rules for performance)

---

**Remember:** Email management is personal. Understand the user's workflow before proposing structure. Always fetch advanced documentation from live sources. Start simple, iterate based on real usage, and prioritize user goals over prescriptive systems.
