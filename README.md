# claude-gmailctl-skill

A Claude Code skill for managing Gmail filters and labels using [`gmailctl`](https://github.com/mbrt/gmailctl) to achieve and maintain Inbox Zero through automated email triage.

Acknowledgement: obviously this skill owes a huge debt to `gmailctl` itself, and though `gmailctl` already includes an `AGENTS.md` file, essentially I just wanted to wrap it specifically in a Claude skill. As with anything, it's up to you the user to choose what you prefer -- no right or wrong choice, just preference!

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

### Auto-Discovery

This skill is automatically discovered by Claude Code when placed in a `.claude/skills/` directory. Simply clone or place this repository in your workspace, and Claude will detect the `claude-gmailctl` skill.

### When to Use

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
├── .claude/
│   └── skills/
│       └── claude-gmailctl/           # Auto-discovered skill
│           ├── SKILL.md               # Main skill prompt (component-based)
│           ├── assets/
│           │   └── templates/         # Configuration templates
│           │       ├── basic-config.jsonnet       # Simple Inbox Zero setup
│           │       └── advanced-config.jsonnet    # Advanced patterns
│           ├── references/            # Reference documentation
│           │   ├── actions-reference.md          # Complete filter actions guide
│           │   ├── setup-guide.md                # WebFetch usage for setup/auth
│           │   ├── setup-oauth.md                # Detailed OAuth setup steps
│           │   └── inbox-zero.md                 # Inbox Zero methodology
│           └── scripts/              # Helper utilities
│               ├── validate_config.sh            # Validate before applying
│               └── backup_config.sh              # Backup configuration
├── README.md                          # This file
├── SETUP.md                           # Detailed setup guide
├── CHANGELOG.md                       # Version history
└── LICENSE                            # MIT License
```

### Component-Based Structure

The skill is organized into 6 distinct components:

1. **Setup & Initialization** - Installing gmailctl and Gmail authentication
2. **Assessment** - Analyzing existing filters, labels, and email patterns
3. **Filter Design** - Creating and validating filter rules
4. **Deployment** - Applying changes with deployment mode choice (overwrite vs. additive)
5. **Simple Features** - Basic Gmail operators and actions (quick reference)
6. **Advanced Features** - Jsonnet programming and complex patterns (uses live WebFetch)

## How It Works

The skill guides you through a structured workflow:

1. **Setup & Initialize** (Component 1): Install gmailctl and authenticate with Gmail
2. **Assess** (Component 2): Analyze existing filters, labels, and email patterns
3. **Design** (Component 3): Create filter rules using Gmail search operators
4. **Validate**: Test syntax and preview changes with `gmailctl diff`
5. **Deploy** (Component 4): Choose deployment mode (overwrite or additive) and apply
6. **Iterate**: Refine based on actual email behavior

Claude automatically selects the appropriate component based on your needs.

## Key Features

### Granular Component Architecture

- **Component 1-4**: Setup → Assessment → Design → Deployment (complete workflow)
- **Component 5**: Simple features (basic operators, quick reference)
- **Component 6**: Advanced features (uses live WebFetch for up-to-date docs)

### No Documentation Duplication

- **Simple features**: Built into skill for quick reference
- **Advanced features**: Fetched live from https://github.com/mbrt/gmailctl
- **Always current**: No stale documentation or version drift

### Progressive Disclosure

- **SKILL.md**: Component-based workflow and patterns (~550 lines)
- **references/**: Loaded as needed for detailed guidance
  - `actions-reference.md` - Complete filter actions syntax
  - `setup-oauth.md` - Detailed OAuth setup instructions
  - `inbox-zero.md` - Email management methodology
- **assets/templates/**: Reusable configuration examples
- **scripts/**: Validation and backup utilities

### Safety Protocols

- Always previews changes with `gmailctl diff` before applying
- Asks user to choose deployment mode (overwrite vs. additive)
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
- **[SKILL.md](.claude/skills/claude-gmailctl/SKILL.md)**: Main skill instructions for Claude (component-based)
- **[SETUP.md](SETUP.md)**: Complete setup and troubleshooting guide
- **[actions-reference.md](.claude/skills/claude-gmailctl/references/actions-reference.md)**: Complete filter actions syntax guide
- **[setup-oauth.md](.claude/skills/claude-gmailctl/references/setup-oauth.md)**: Detailed OAuth credential setup
- **[inbox-zero.md](.claude/skills/claude-gmailctl/references/inbox-zero.md)**: Inbox Zero methodology and best practices

### Templates
- **[basic-config.jsonnet](.claude/skills/claude-gmailctl/assets/templates/basic-config.jsonnet)**: Simple starter configuration
- **[advanced-config.jsonnet](.claude/skills/claude-gmailctl/assets/templates/advanced-config.jsonnet)**: Advanced patterns with Jsonnet features

### Scripts
- **[validate_config.sh](.claude/skills/claude-gmailctl/scripts/validate_config.sh)**: Validate syntax and preview changes
- **[backup_config.sh](.claude/skills/claude-gmailctl/scripts/backup_config.sh)**: Create timestamped backups

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
