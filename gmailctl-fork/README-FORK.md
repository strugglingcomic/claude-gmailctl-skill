# gmailctl-fork - Email Analysis & Auto-Suggestion

This is a fork of [mbrt/gmailctl](https://github.com/mbrt/gmailctl) with added email metadata analysis capabilities.

## Key Additions

### 1. Gmail Metadata Scope

Added `gmail.metadata` scope to enable reading email headers without accessing full message content.

**Modified files:**
- `internal/engine/api/auth.go` - Added `gmail.GmailMetadataScope`
- `cmd/gmailctl/localcred/local_provider.go` - Updated OAuth setup documentation

### 2. New `analyze` Command

A new command that analyzes recent emails and suggests filter rules based on patterns, implementing Inbox Zero principles.

**Features:**
- Fetches email metadata (from, to, subject, list-id)
- Identifies patterns (newsletters, notifications, receipts, bulk)
- Groups similar emails by domain and type
- Generates filter suggestions with appropriate actions
- Outputs Jsonnet-compatible filter rules

**Usage:**
```bash
# Analyze last 30 days, max 1000 messages
gmailctl analyze

# Custom parameters
gmailctl analyze --days 60 --max 2000

# Save suggestions to file
gmailctl analyze --output suggestions.txt
```

**Example Output:**
```
=== Suggested Filters (based on Inbox Zero principles) ===

Found 15 patterns to consider:

## Newsletter (5 items)

- Auto-archive newsletters from substack.com (found 47)
  Filter: { query: "list:newsletter@substack.com" }
  Actions: { archive: true, markRead: true, markImportant: false }

- Auto-archive newsletters from medium.com (found 32)
  Filter: { query: "from:@medium.com" }
  Actions: { archive: true, markRead: true, markImportant: false }

## Notification (4 items)

- Auto-label notifications from github.com (found 156)
  Filter: { query: "from:@github.com" }
  Actions: { archive: true, markRead: true, markSpam: false }

...
```

## Installation

### Prerequisites

- Go 1.24 or higher
- Gmail API credentials (see [gmailctl documentation](https://github.com/mbrt/gmailctl#quickstart))

### Build from Source

```bash
cd gmailctl-fork
go build -o gmailctl-analyze ./cmd/gmailctl
sudo mv gmailctl-analyze /usr/local/bin/
```

### OAuth Setup

The fork requires an additional OAuth scope. When setting up credentials at https://console.developers.google.com:

1. Enable Gmail API
2. Create OAuth consent screen
3. Add these scopes:
   - `https://www.googleapis.com/auth/gmail.labels`
   - `https://www.googleapis.com/auth/gmail.settings.basic`
   - **`https://www.googleapis.com/auth/gmail.metadata`** (NEW)
4. Add yourself as a test user
5. Create OAuth client ID (Desktop app)
6. Download credentials to `~/.gmailctl/credentials.json`

**Note:** If you previously used gmailctl, you'll need to:
1. Add the metadata scope to your OAuth consent screen
2. Delete your token: `rm ~/.gmailctl/token.json`
3. Re-authenticate: `gmailctl init` and `gmailctl download`

## Workflow: From Analysis to Filters

### Step 1: Analyze Email Patterns

```bash
gmailctl analyze --days 30 --max 1000
```

This will output suggested filters grouped by category.

### Step 2: Review Suggestions

Examine the output and identify patterns you want to automate.

### Step 3: Add to Config

Edit `~/.gmailctl/config.jsonnet` and add selected rules:

```jsonnet
{
  version: "v1alpha3",

  labels: [
    { name: "Newsletters" },
    { name: "Notifications" },
    { name: "Reference/Receipts" }
  ],

  rules: [
    // From analyze output:
    {
      filter: { query: "list:newsletter@substack.com" },
      actions: { archive: true, markRead: true, markImportant: false, labels: ["Newsletters"] }
    },
    {
      filter: { query: "from:@github.com" },
      actions: { archive: true, markRead: true, markSpam: false, labels: ["Notifications"] }
    },
    // Add more rules...
  ]
}
```

### Step 4: Preview Changes

```bash
gmailctl diff
```

### Step 5: Apply Filters

```bash
gmailctl apply
```

## Pattern Detection Logic

The analyze command categorizes emails into:

### Newsletters
- Has `List-ID` header
- Subject contains "newsletter"
- **Actions:** Archive, mark read, never mark important

### Notifications
- Domain contains "notification" or "noreply"
- Subject contains "notification"
- **Actions:** Archive, mark read, prevent spam classification

### Receipts
- Subject contains "receipt", "invoice", or "order confirmation"
- **Actions:** Archive only (keep unread for review)

### Bulk
- High volume from single domain (5+ messages)
- Doesn't match other categories
- **Actions:** Never mark important

## Inbox Zero Integration

The analyze command implements [Inbox Zero principles](https://www.lesswrong.com/posts/7hFeMWC6Y5eaSixbD/100-messages-per-day-is-normaland-requires-an-inbox-system) by suggesting filters that:

1. **Auto-archive newsletters** - Batch-process later
2. **Auto-file notifications** - Reference when needed
3. **Auto-label receipts** - Organized for tax time
4. **Reduce noise** - Mark bulk as not important
5. **Surface priority** - Only actionable emails in inbox

## Differences from Upstream

This fork adds:
- `gmail.metadata` OAuth scope
- `analyze` command (`cmd/gmailctl/cmd/analyze_cmd.go`)
- Pattern detection and categorization logic
- Inbox Zero-oriented rule suggestions

All other gmailctl functionality remains unchanged.

## Contributing Back

This fork is intended as a proof-of-concept for email analysis features. If you'd like to see this functionality in mainline gmailctl, please:

1. Test the analyze command
2. Provide feedback on suggested rules
3. Submit feature request to [mbrt/gmailctl](https://github.com/mbrt/gmailctl/issues)

## License

Same as upstream gmailctl: MIT License

## Credits

- Original gmailctl: [mbrt/gmailctl](https://github.com/mbrt/gmailctl)
- Fork maintainer: [Your GitHub username]
- Inbox Zero methodology: [LessWrong post by Daniel Filan](https://www.lesswrong.com/posts/7hFeMWC6Y5eaSixbD/100-messages-per-day-is-normaland-requires-an-inbox-system)
