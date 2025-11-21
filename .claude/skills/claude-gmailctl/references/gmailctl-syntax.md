# gmailctl Syntax Reference

Comprehensive reference for gmailctl's Jsonnet configuration syntax and Gmail API capabilities.

## Configuration Structure

```jsonnet
{
  version: "v1alpha3",  // Required

  author: {             // Optional
    name: "Your Name",
    email: "you@example.com"
  },

  labels: [             // Optional but recommended
    { name: "LabelName" },
    { name: "Parent/Child" }
  ],

  rules: [              // Required
    {
      filter: { /* search criteria */ },
      actions: { /* what to do */ }
    }
  ]
}
```

## Search Operators

### Basic Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `from:` | Sender email address | `from:sender@example.com` |
| `to:` | Recipient email address | `to:recipient@example.com` |
| `subject:` | Subject line text | `subject:"meeting notes"` |
| `list:` | Mailing list address | `list:updates@example.com` |
| `cc:` | CC recipient | `cc:colleague@example.com` |
| `bcc:` | BCC recipient (limited) | `bcc:hidden@example.com` |
| `replyto:` | Reply-To address | `replyto:support@example.com` |

### Content Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `has:attachment` | Has file attachments | `has:attachment` |
| `has:drive` | Has Google Drive attachments | `has:drive` |
| `has:document` | Has Google Docs | `has:document` |
| `has:spreadsheet` | Has Google Sheets | `has:spreadsheet` |
| `has:presentation` | Has Google Slides | `has:presentation` |
| `has:youtube` | Has YouTube links | `has:youtube` |
| `filename:` | Attachment filename | `filename:pdf` |

### State Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `is:unread` | Unread messages | `is:unread` |
| `is:read` | Read messages | `is:read` |
| `is:starred` | Starred messages | `is:starred` |
| `is:important` | Marked important | `is:important` |
| `is:snoozed` | Snoozed messages | `is:snoozed` |
| `in:inbox` | Currently in inbox | `in:inbox` |
| `in:trash` | In trash | `in:trash` |
| `in:spam` | In spam folder | `in:spam` |

### Time Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `after:` | After date | `after:2024/01/01` |
| `before:` | Before date | `before:2024/12/31` |
| `older_than:` | Older than period | `older_than:30d` |
| `newer_than:` | Newer than period | `newer_than:7d` |

Time periods: `d` (days), `m` (months), `y` (years)

### Size Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `size:` | Exact size | `size:1000000` |
| `larger:` | Larger than size | `larger:5M` |
| `smaller:` | Smaller than size | `smaller:1M` |

Sizes: bytes (default), `K` (kilobytes), `M` (megabytes)

### Logical Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `OR` | Either condition | `from:a@example.com OR from:b@example.com` |
| `{ }` | OR grouping | `{from:a.com from:b.com}` |
| `-` | NOT/exclude | `-from:spam@example.com` |
| `( )` | Grouping | `(from:a.com OR from:b.com) subject:urgent` |

**Note**: AND is implicit (space between terms)

## Actions

### Core Actions

```jsonnet
actions: {
  archive: true,           // Remove from inbox
  delete: true,            // Move to trash (DESTRUCTIVE!)
  markRead: true,          // Mark as read
  markImportant: true,     // Star the message
  markSpam: true,          // Move to spam

  labels: ["Label1"],      // Apply labels (array)

  forward: "email@example.com",  // Forward to address

  category: "personal"     // Set category (personal, social, promotions, updates, forums)
}
```

### Action Constraints

**Mutually Exclusive:**
- Cannot combine `delete` with other actions
- `archive` and `delete` cannot both be true

**Label Requirements:**
- Labels must be defined in `labels:` section first
- Label names are case-sensitive
- Nested labels use `/` separator: `"Parent/Child"`

## Advanced Jsonnet Features

### Variables

```jsonnet
local workDomain = "company.com";
local personalDomains = ["gmail.com", "personal.com"];

{
  rules: [
    {
      filter: { query: "from:@" + workDomain },
      actions: { labels: ["Work"] }
    }
  ]
}
```

### Helper Functions

```jsonnet
local archiveAndLabel(query, label) = {
  filter: { query: query },
  actions: { archive: true, labels: [label] }
};

local prioritize(query, label) = {
  filter: { query: query },
  actions: { markImportant: true, labels: [label] }
};

{
  rules: [
    archiveAndLabel("from:newsletter@example.com", "Newsletters"),
    prioritize("from:boss@work.com", "Work/Priority")
  ]
}
```

### Standard Library Functions

```jsonnet
// String manipulation
std.join(" OR ", ["from:a@example.com", "from:b@example.com"])
// Result: "from:a@example.com OR from:b@example.com"

// Array operations
std.map(function(d) "from:@" + d, domains)
// Applies function to each element

// Conditionals
if condition then value1 else value2
```

### Importing External Files

```jsonnet
local helpers = import "helpers.libsonnet";
local workRules = import "work-rules.jsonnet";

{
  rules: workRules.rules + [
    // Additional rules here
  ]
}
```

## Library Functions (from gmailctl)

### chainFilters

Combine multiple filters into one:

```jsonnet
local chainFilters = function(query) {
  filter: { query: query },
  actions: {}
};
```

### directlyTo

Match emails sent directly to an address (not via CC or lists):

```jsonnet
local directlyTo = function(email) {
  "deliveredto:" + email + " -cc:" + email
};
```

## Query Examples

### Common Patterns

**Newsletters and marketing:**
```
from:@newsletter.com OR list:@announce.com OR subject:unsubscribe
```

**Automated notifications:**
```
from:no-reply@ OR from:noreply@ OR from:do-not-reply@
```

**Important work emails:**
```
from:@company.com (subject:urgent OR subject:important OR subject:action required)
```

**Receipts and confirmations:**
```
subject:(receipt OR invoice OR order confirmation OR purchase) has:attachment
```

**Calendar invites:**
```
from:calendar-notification@google.com OR subject:(invited OR calendar)
```

**Social media:**
```
from:@facebook.com OR from:@twitter.com OR from:@linkedin.com OR from:@instagram.com
```

**GitHub notifications:**
```
from:notifications@github.com
```

**Old unread emails:**
```
is:unread older_than:30d
```

### Complex Queries

**Work projects from specific people:**
```
from:{boss@company.com manager@company.com} (subject:project OR subject:milestone)
```

**Large emails with attachments:**
```
has:attachment larger:5M
```

**Exclude certain senders from a domain:**
```
from:@company.com -from:spam@company.com -from:noreply@company.com
```

## Testing Queries

Always test queries in Gmail search bar before using in gmailctl:

1. Go to Gmail web interface
2. Click search box
3. Enter query exactly as it would appear in `filter: { query: "..." }`
4. Verify results match expectations
5. Refine query if needed
6. Copy final query to config.jsonnet

## Validation and Testing

### Syntax Validation

```bash
# Check for Jsonnet syntax errors
gmailctl debug
```

### Configuration Testing

```jsonnet
{
  version: "v1alpha3",

  // ... labels and rules ...

  tests: [
    {
      message: {
        from: "newsletter@example.com",
        to: "me@example.com",
        subject: "Weekly Update"
      },
      expected: {
        archive: true,
        labels: ["Newsletters"]
      }
    }
  ]
}
```

Run tests:
```bash
gmailctl test
```

## Performance Considerations

### Filter Order

- More specific filters should come first
- Gmail evaluates filters top-to-bottom
- Later filters can override earlier ones

### Query Efficiency

- Use specific operators when possible
- Avoid overly broad queries that match thousands of emails
- Test queries on small date ranges first

### Label Management

- Limit nesting depth to 2-3 levels
- Use clear, descriptive names
- Consolidate similar labels
- Regularly review and prune unused labels

## Common Pitfalls

### Syntax Errors

❌ **Wrong:**
```jsonnet
actions: {
  labels: "Work"  // Labels must be array
}
```

✅ **Correct:**
```jsonnet
actions: {
  labels: ["Work"]
}
```

### Query Mistakes

❌ **Wrong:**
```jsonnet
filter: { query: "from @example.com" }  // Missing colon
```

✅ **Correct:**
```jsonnet
filter: { query: "from:@example.com" }
```

### Undefined Labels

❌ **Wrong:**
```jsonnet
{
  rules: [
    {
      filter: { query: "from:example.com" },
      actions: { labels: ["Work"] }  // "Work" not defined!
    }
  ]
}
```

✅ **Correct:**
```jsonnet
{
  labels: [
    { name: "Work" }
  ],
  rules: [
    {
      filter: { query: "from:example.com" },
      actions: { labels: ["Work"] }
    }
  ]
}
```

## Resources

- [Gmail Search Operators Documentation](https://support.google.com/mail/answer/7190)
- [Jsonnet Tutorial](https://jsonnet.org/learning/tutorial.html)
- [gmailctl GitHub Repository](https://github.com/mbrt/gmailctl)
