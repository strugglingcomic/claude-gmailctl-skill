# claude-gmailctl-skill

A Claude Code skill for managing Gmail filters and labels using [`gmailctl`](https://github.com/mbrt/gmailctl) to achieve and maintain Inbox Zero through automated email triage.

## Overview

This skill enables Claude to help you:
- **Manage Gmail filters as code** using declarative Jsonnet configuration
- **Implement Inbox Zero workflows** with automated triage and organization
- **Design filter rules** based on email patterns and priorities
- **Validate and test** configurations before applying to Gmail
- **Maintain version-controlled** email management system

## Quick Start

### Installation

**macOS:**
```bash
brew install gmailctl
```

**Linux:**
```bash
curl -L https://github.com/mbrt/gmailctl/releases/latest/download/gmailctl-linux-amd64 -o gmailctl
chmod +x gmailctl
sudo mv gmailctl /usr/local/bin/
```

### Setup

```bash
# Initialize configuration
gmailctl init

# Authenticate with Gmail
gmailctl download
```

See [SETUP.md](SETUP.md) for detailed setup instructions.

## Usage with Claude Code

Invoke this skill when you need help with:
- Creating or modifying Gmail filters
- Organizing email with labels and categories
- Implementing Inbox Zero or automated triage
- Reviewing and optimizing existing filter configurations
- Managing `~/.gmailctl/config.jsonnet` configuration

**Example prompts:**
- "Help me auto-archive newsletters"
- "Set up Inbox Zero for my work email"
- "Review my filters and suggest improvements"
- "Create a filter for GitHub notifications"

## Skill Structure

```
claude-gmailctl-skill/
├── SKILL.md                           # Main skill prompt
├── README.md                          # This file
├── SETUP.md                           # Detailed setup guide
├── assets/
│   └── templates/                     # Configuration templates
│       ├── basic-config.jsonnet       # Simple Inbox Zero setup
│       └── advanced-config.jsonnet    # Advanced patterns
├── references/                        # Detailed documentation (loaded as needed)
│   ├── gmailctl-syntax.md            # Complete syntax reference
│   ├── inbox-zero.md                 # Inbox Zero methodology
│   └── troubleshooting.md            # Error solutions
└── scripts/                          # Helper utilities
    ├── validate_config.sh            # Validate before applying
    └── backup_config.sh              # Backup configuration
```

## How It Works

1. **Understand patterns**: Claude asks about your email workflow
2. **Design filters**: Creates Jsonnet configuration with Gmail search operators
3. **Validate**: Tests syntax and previews changes with `gmailctl diff`
4. **Apply safely**: Waits for your approval before applying to Gmail
5. **Iterate**: Refines based on actual email behavior

## Key Features

### Progressive Disclosure

- **SKILL.md**: Core workflow and common patterns (~3k words)
- **references/**: Detailed docs loaded as needed (syntax, methodology, troubleshooting)
- **assets/templates/**: Reusable configuration examples
- **scripts/**: Validation and backup utilities

### Safety Protocols

- Always previews changes with `gmailctl diff` before applying
- Never uses destructive actions (`delete`, `markSpam`) without explicit confirmation
- Includes backup script for configuration safety
- Tests queries in Gmail search bar before adding to filters

### Inbox Zero Focus

- Automates 80% of email triage
- Surfaces only actionable messages in inbox
- Pre-sorts newsletters, notifications, and reference material
- Implements systematic label organization

## Configuration Example

```jsonnet
{
  version: "v1alpha3",

  labels: [
    { name: "Work/Priority" },
    { name: "Newsletters" },
    { name: "Reference/Receipts" }
  ],

  rules: [
    {
      filter: { query: "from:boss@company.com" },
      actions: { markImportant: true, labels: ["Work/Priority"] }
    },
    {
      filter: { query: "list:newsletter@example.com" },
      actions: { archive: true, markRead: true, labels: ["Newsletters"] }
    },
    {
      filter: { query: "subject:(receipt OR invoice) has:attachment" },
      actions: { archive: true, labels: ["Reference/Receipts"] }
    }
  ]
}
```

## Resources

### Documentation
- **[SKILL.md](SKILL.md)**: Main skill instructions for Claude
- **[SETUP.md](SETUP.md)**: Complete setup and troubleshooting guide
- **[references/gmailctl-syntax.md](references/gmailctl-syntax.md)**: Comprehensive syntax reference
- **[references/inbox-zero.md](references/inbox-zero.md)**: Inbox Zero methodology and patterns
- **[references/troubleshooting.md](references/troubleshooting.md)**: Detailed error solutions

### Templates
- **[basic-config.jsonnet](assets/templates/basic-config.jsonnet)**: Simple starter configuration
- **[advanced-config.jsonnet](assets/templates/advanced-config.jsonnet)**: Advanced patterns with Jsonnet features

### Scripts
- **[validate_config.sh](scripts/validate_config.sh)**: Validate syntax and preview changes
- **[backup_config.sh](scripts/backup_config.sh)**: Create timestamped backups

### External Links
- [gmailctl GitHub Repository](https://github.com/mbrt/gmailctl)
- [Gmail Search Operators](https://support.google.com/mail/answer/7190)
- [Jsonnet Documentation](https://jsonnet.org/)
- [Inbox Zero Philosophy](https://www.43folders.com/izero)

## Version Control

Keep your email configuration in git:
```bash
cd ~/.gmailctl
git init
git add config.jsonnet
git commit -m "Initial email filter configuration"
```

This enables:
- Track changes over time
- Roll back problematic filters
- Share configurations across accounts
- Document filter rationale in commits

---

**Last updated**: 2025-11-19
