---
name: Gmail Control
description: Manage Gmail filters and labels using gmailctl to implement Inbox Zero email management workflows. Use when helping users organize email, create automated triage rules, or maintain filter configurations as code.
---

# Gmail Control Skill

## Purpose

Assist users in managing Gmail filters and labels through `gmailctl`, a declarative configuration tool that treats email filtering as code. Enable users to achieve and maintain Inbox Zero by automating email triage, organizing messages with labels, and implementing systematic email processing workflows.

## When to Use

Activate this skill when users request help with:
- Creating or modifying Gmail filters
- Organizing email with labels and categories
- Implementing Inbox Zero or automated email triage
- Reviewing and optimizing existing filter configurations
- Converting manual email processing into automated rules
- Managing `~/.gmailctl/config.jsonnet` configuration

## Core Workflow

### 1. Understand User's Email Patterns

Before proposing filters, understand the user's email workflow:
- Ask about common senders, types of emails, and current pain points
- Identify repetitive manual processing that could be automated
- Determine priority levels and organizational preferences

### 2. Review Current Configuration

Read existing setup to avoid conflicts:
```bash
# View current configuration
cat ~/.gmailctl/config.jsonnet

# Download Gmail's current filter state
gmailctl download
```

### 3. Design Filter Rules

Create filters using Jsonnet configuration syntax:

**Basic structure**:
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

**Query syntax**: Uses Gmail search operators (`from:`, `subject:`, `has:attachment`, `OR`, `-`, etc.)

**Available actions**:
- `archive: true` - Remove from inbox
- `markRead: true` - Mark as read
- `markImportant: true` - Star the message
- `labels: ["Label"]` - Apply labels (array)
- `delete: true` - Move to trash (⚠️ use cautiously)
- `markSpam: true` - Move to spam (⚠️ affects future delivery)

### 4. Validate and Test

Always validate before applying:
```bash
# Check syntax
gmailctl debug

# Preview changes (REQUIRED before applying)
gmailctl diff

# Run validation script
scripts/validate_config.sh
```

**Critical**: Show `gmailctl diff` output to user for approval before proceeding.

### 5. Apply Configuration

After user approval:
```bash
# Apply filters to Gmail
gmailctl apply
```

### 6. Monitor and Iterate

Filters require iteration:
- Monitor for misfiled emails
- Refine queries based on actual behavior
- Add new patterns as they emerge
- Remove obsolete rules

## Bundled Resources

### References (Load as Needed)

**`references/gmailctl-syntax.md`**
- Comprehensive syntax reference
- All Gmail search operators
- Jsonnet features and functions
- Query examples and patterns
- **Load when**: User needs detailed syntax help, advanced features, or query troubleshooting

**`references/inbox-zero.md`**
- Inbox Zero methodology and principles
- Recommended label structures
- Common filter patterns by use case
- Progressive implementation guide
- **Load when**: User is new to Inbox Zero, needs organizational strategies, or wants systematic approach

**`references/troubleshooting.md`**
- Detailed error solutions
- Installation and authentication issues
- Configuration debugging
- Performance optimization
- **Load when**: Encountering errors, authentication problems, or unexpected behavior

### Scripts (Execute as Needed)

**`scripts/validate_config.sh [config_path]`**
- Validates Jsonnet syntax
- Checks for undefined labels
- Warns about destructive actions
- Shows preview of changes
- **Use before**: Applying configuration changes

**`scripts/backup_config.sh [config_path] [backup_dir]`**
- Creates timestamped backup
- Saves credentials and Gmail state
- Lists recent backups
- **Use before**: Major configuration changes

### Assets (Templates)

**`assets/templates/basic-config.jsonnet`**
- Simple Inbox Zero setup
- Newsletter archiving
- Receipt filing
- Priority routing
- **Use for**: New users or starting from scratch

**`assets/templates/advanced-config.jsonnet`**
- Jsonnet variables and functions
- Reusable helper functions
- Complex organizational structure
- Advanced filtering patterns
- **Use for**: Power users or complex workflows

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

### Inbox Zero Focus

1. **Automate triage**: Pre-sort 80% of email automatically
2. **Surface important messages**: Keep only actionable items in inbox
3. **Archive aggressively**: Email is not a TODO list
4. **Process to zero daily**: Empty inbox doesn't mean zero unread

### Configuration as Code

1. **Version control**: Keep config.jsonnet in git
2. **Document complex rules**: Add comments explaining rationale
3. **Use Jsonnet features**: Variables and functions for maintainability
4. **Consolidate filters**: Use OR to combine similar rules

## Common Patterns

### Auto-Archive Newsletters
```jsonnet
{
  filter: { query: "list:newsletter@example.com" },
  actions: { archive: true, markRead: true, labels: ["Newsletters"] }
}
```

### Priority Routing
```jsonnet
{
  filter: { query: "from:vip@example.com" },
  actions: { markImportant: true, labels: ["Priority"] }
}
```

### Receipt Filing
```jsonnet
{
  filter: { query: "subject:(receipt OR invoice) has:attachment" },
  actions: { archive: true, labels: ["Reference/Receipts"] }
}
```

### Notification Filtering
```jsonnet
{
  filter: { query: "from:notifications@github.com -mentions:me" },
  actions: { archive: true, labels: ["Notifications"] }
}
```

**For more patterns**, reference `references/inbox-zero.md` (search for "Common Filter Patterns").

## User Interaction Guidelines

### When to Ask Questions

- **Before destructive actions** (delete, spam)
- **When intent is ambiguous** (multiple valid approaches)
- **For organizational preferences** (label naming, hierarchy)
- **When filters might be too aggressive** (risk of missing important emails)

### When to Proceed Autonomously

- **Reading current configuration** (always safe)
- **Proposing filter changes** (user reviews before applying)
- **Running validation commands** (`gmailctl debug`, `gmailctl diff`)
- **Loading reference documentation** (as needed for context)

### Communication Style

Use imperative/objective language:
- **Explain logic in plain English** before showing Jsonnet code
- **Show both Jsonnet config and equivalent Gmail search query** for clarity
- **Highlight impact** ("This will archive ~50 newsletter emails per week")
- **Provide rationale** ("Archiving instead of deleting allows future search")

## Example Interactions

### "Help me auto-archive newsletters"

**Workflow**:
1. Ask which newsletters/senders to target
2. Read current config to check for conflicts
3. Propose filter with clear query
4. Explain: "This will automatically archive future emails from X, label them as 'Newsletters', and mark as read. Existing emails remain unchanged."
5. Show: `gmailctl diff` output
6. Wait for user approval before applying

### "Set up Inbox Zero for my work email"

**Workflow**:
1. Ask about work patterns: VIPs, team communications, notification sources
2. Propose label structure (reference `references/inbox-zero.md` if needed)
3. Start with `assets/templates/basic-config.jsonnet` as base
4. Customize for their specific domains and senders
5. Implement progressively: Week 1 (newsletters), Week 2 (notifications), etc.

### "My filter isn't working"

**Workflow**:
1. Read current config
2. Test their query in Gmail search to verify syntax
3. Check filter order (more specific should come first)
4. Verify labels are defined
5. If needed, load `references/troubleshooting.md` for specific error
6. Propose corrected filter with explanation

### "Review my filters and suggest improvements"

**Workflow**:
1. Read `~/.gmailctl/config.jsonnet`
2. Analyze for:
   - Overlapping or conflicting rules
   - Inefficient queries (could be consolidated)
   - Undefined or unused labels
   - Missing common patterns (based on Inbox Zero principles)
3. Load `references/inbox-zero.md` for pattern matching
4. Provide specific suggestions with rationale
5. Offer to implement approved changes

## Technical Notes

### Configuration File Location

Default: `~/.gmailctl/config.jsonnet`

Override with: `gmailctl --config=/path/to/config.jsonnet [command]`

### Jsonnet Features

**Variables**:
```jsonnet
local domain = "company.com";
filter: { query: "from:@" + domain }
```

**Functions**:
```jsonnet
local archiveAndLabel(query, label) = {
  filter: { query: query },
  actions: { archive: true, labels: [label] }
};
```

**For comprehensive syntax**, load `references/gmailctl-syntax.md`.

### Filter Evaluation

- Gmail processes filters **top-to-bottom**
- **Order matters**: More specific filters should come first
- Multiple filters can match the same email (actions combine)
- Labels accumulate (email can have multiple labels)

### Testing Approach

1. **Test query in Gmail search bar first** - Verify it matches expected emails
2. **Use narrow query initially** - E.g., add `newer_than:7d` for recent testing
3. **Run `gmailctl diff`** - See exactly what changes
4. **Apply and monitor** - Check Gmail for misfiled messages
5. **Broaden query** - After validating behavior

## Troubleshooting Quick Reference

**Syntax error**: Run `gmailctl debug`, check line number, fix Jsonnet syntax

**Label not found**: Ensure label defined in `labels:` section before use in `actions:`

**No filters to apply**: Config matches Gmail (not an error, means already in sync)

**Authentication failed**: Re-authenticate with `gmailctl download`

**For detailed troubleshooting**, load `references/troubleshooting.md`.

## Success Metrics

Track filter effectiveness:
- **Time to inbox zero** - Should decrease over time
- **Manual processing** - Should be <20% of emails
- **Misfiled emails** - Should be rare (adjust filters if frequent)
- **Filter count** - Keep manageable (<50 rules for performance)

---

**Remember**: Email management is personal. Understand the user's workflow before proposing structure. Start simple, iterate based on real usage, and prioritize user goals over prescriptive systems.
