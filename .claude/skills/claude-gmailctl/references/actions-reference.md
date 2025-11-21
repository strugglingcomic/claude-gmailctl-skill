# gmailctl Filter Actions Reference

Complete reference for all available filter actions in gmailctl configuration.

## Complete Action List

### Archive & Deletion

**`archive: true`**
- The message will skip the inbox
- Message is still accessible via labels, search, and "All Mail"
- Commonly used for newsletters, notifications, and automated emails

**`delete: true`**
- The message will go directly to the trash can
- ⚠️ Use with caution - requires explicit user approval
- Message will be permanently deleted after 30 days

### Message Status

**`markRead: true`**
- The message will be marked as read automatically
- Useful for notifications and automated emails you don't need to review

**`star: true`**
- Star the message
- Marks message as important using Gmail's star system

### Importance Control

**`markImportant: true`**
- Always mark the message as important
- Overrides Gmail's automatic importance heuristics
- Use for high-priority senders or urgent topics

**`markImportant: false`**
- Never mark the message as important
- Overrides Gmail's automatic importance heuristics
- Use for newsletters, notifications, and low-priority automated emails
- **Common mistake**: This is NOT `markNotImportant: true`

### Spam Handling

**`markSpam: false`**
- Prevent automatic spam classification
- Ensures legitimate messages aren't mistakenly filtered to spam
- Useful for automated notifications that might trigger spam filters
- **Note**: `markSpam: true` is NOT supported (Gmail doesn't allow auto-spam marking)

### Organization

**`category: <CATEGORY>`**
- Force message into a Gmail category
- Available categories:
  - `"personal"` - Personal emails
  - `"social"` - Social network notifications
  - `"updates"` - Confirmations, receipts, bills, statements
  - `"forums"` - Messages from online groups, discussion boards
  - `"promotions"` - Deals, offers, marketing emails
- **Note**: Category names are case-sensitive and must be lowercase

**`labels: [list, of, labels]`**
- Array of labels to apply to the message
- Labels can use nested hierarchies with `/` separator
- Examples:
  - `['Work']` - Single label
  - `['Work', 'Priority']` - Multiple labels
  - `['Family/Personal']` - Nested label
  - `['Family/zz_Financial-Legal/Taxes']` - Multiple levels
- **Important**: All labels must be defined in the `labels:` section of config

### Forwarding

**`forward: 'address@example.com'`**
- Forward the message to another email address
- **Requirements**:
  - Forwarding address must be verified in Gmail settings first
  - Maximum 20 forwarding filters allowed per Gmail account
- **Use case**: Auto-forward work emails to personal account, family emails to shared inbox

## Syntax Examples

### Basic Actions

```jsonnet
{
  filter: { from: 'newsletters@example.com' },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Newsletters'],
  }
}
```

### Never Mark Important (Common Pattern)

```jsonnet
{
  filter: { from: 'notifications@service.com' },
  actions: {
    archive: true,
    markImportant: false,  // NOT markNotImportant: true
    labels: ['Notifications'],
  }
}
```

### Prevent Spam Classification

```jsonnet
{
  filter: { from: 'automated-system@company.com' },
  actions: {
    markSpam: false,  // Prevent false spam detection
    labels: ['Automated'],
  }
}
```

### Category Assignment

```jsonnet
{
  filter: { from: 'deals@store.com' },
  actions: {
    archive: true,
    category: 'promotions',
    labels: ['Shopping/Deals'],
  }
}
```

### Multiple Labels with Hierarchy

```jsonnet
{
  filter: { from: 'receipts@vendor.com' },
  actions: {
    archive: true,
    labels: ['Reference/Receipts', 'Finance'],
  }
}
```

### Forwarding

```jsonnet
{
  filter: { subject: 'urgent', from: 'work@company.com' },
  actions: {
    forward: 'personal@gmail.com',
    markImportant: true,
    labels: ['Work/Urgent'],
  }
}
```

## Common Mistakes

### 1. Using `markNotImportant` instead of `markImportant: false`

**❌ Wrong:**
```jsonnet
actions: {
  markNotImportant: true  // This field doesn't exist
}
```

**✅ Correct:**
```jsonnet
actions: {
  markImportant: false  // Never mark as important
}
```

### 2. Trying to mark messages as spam

**❌ Wrong:**
```jsonnet
actions: {
  markSpam: true  // Not supported by Gmail
}
```

**✅ Correct:**
```jsonnet
actions: {
  markSpam: false  // Only prevent spam classification
}
```

### 3. Using undefined labels

**❌ Wrong:**
```jsonnet
{
  labels: [],  // Empty labels array in config
  rules: [
    {
      actions: { labels: ['Work'] }  // 'Work' not defined!
    }
  ]
}
```

**✅ Correct:**
```jsonnet
{
  labels: [
    { name: 'Work' }  // Define label first
  ],
  rules: [
    {
      actions: { labels: ['Work'] }  // Now it's valid
    }
  ]
}
```

### 4. Wrong category names

**❌ Wrong:**
```jsonnet
actions: {
  category: 'Promotions'  // Capital P - won't work
}
```

**✅ Correct:**
```jsonnet
actions: {
  category: 'promotions'  // Lowercase only
}
```

## Action Combinations

Common patterns for combining actions:

### Newsletter Pattern
```jsonnet
actions: {
  archive: true,
  markRead: true,
  markImportant: false,
  category: 'updates',
  labels: ['Newsletters']
}
```

### VIP Sender Pattern
```jsonnet
actions: {
  markImportant: true,
  star: true,
  labels: ['Priority']
}
```

### Automated Notification Pattern
```jsonnet
actions: {
  archive: true,
  markRead: true,
  markSpam: false,
  labels: ['Notifications']
}
```

### Receipt Filing Pattern
```jsonnet
actions: {
  archive: true,
  labels: ['Reference/Receipts', 'Finance']
}
```

## Constraints & Limits

- **Labels**: Must be defined in `labels:` section before use
- **Forwarding addresses**: Must be verified in Gmail settings
- **Forwarding filters**: Maximum 20 per account
- **Categories**: Only 5 valid values (personal, social, updates, forums, promotions)
- **delete/markSpam**: Require explicit user approval before applying

## Reference

Source: https://github.com/mbrt/gmailctl/blob/master/README.md

Last verified: 2024-11
