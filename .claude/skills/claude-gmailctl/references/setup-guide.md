# Setup & Installation Guide - WebFetch Reference

## Purpose

This reference provides guidance on **when and how** to use WebFetch to retrieve setup/installation information from the official gmailctl documentation.

**Do NOT duplicate installation instructions here.** Instead, use WebFetch to get the latest authoritative information.

---

## When to Use WebFetch for Setup Info

### Installation Issues
**User scenario:** "How do I install gmailctl on Windows?" or platform-specific installation questions

**Action:**
```
WebFetch: https://github.com/mbrt/gmailctl/blob/master/README.md
Prompt: "Extract installation instructions for all platforms"
```

**What to look for:**
- Installation section (usually near top of README)
- Platform-specific commands (macOS, Linux, Windows)
- Alternative installation methods (Homebrew, Go install, binary download)
- Version requirements

### Authentication/OAuth Troubleshooting
**User scenario:** "OAuth isn't working" or "Browser won't open during setup" or "403 Access denied"

**Common OAuth issues (no WebFetch needed):**
- **403 "Access denied"**: User forgot to add themselves as a test user in Google Cloud Console OAuth consent screen
- **Missing credentials.json**: User needs to create OAuth credentials in Google Cloud Console (see SKILL.md Component 1 step 3)
- **Wrong application type**: Must use "Desktop app" not "Web application"
- **Missing scopes**: Must include both gmail.labels and gmail.settings.basic scopes

**Action for detailed troubleshooting:**
```
WebFetch: https://github.com/mbrt/gmailctl/blob/master/README.md
Prompt: "Extract authentication and OAuth setup information, including troubleshooting"
```

**What to look for:**
- Authentication flow description
- OAuth scope requirements
- Common authentication errors
- Troubleshooting section

### Advanced Setup (Multiple Accounts, Custom Config)
**User scenario:** "How do I manage multiple Gmail accounts?"

**Action:**
```
WebFetch: https://github.com/mbrt/gmailctl/blob/master/README.md
Prompt: "Find information about managing multiple Gmail accounts or custom configuration paths"
```

**What to look for:**
- `--config` flag usage
- Multiple account patterns
- Configuration file locations

---

## Quick Setup Commands (No WebFetch Needed)

These basic commands are safe to provide directly without fetching:

```bash
# Check installation
gmailctl version

# Initialize
gmailctl init

# Authenticate
gmailctl download

# Verify
gmailctl diff
```

**Expected behavior:**
- `gmailctl init` creates `~/.gmailctl/config.jsonnet`
- `gmailctl download` opens browser for OAuth
- `gmailctl diff` shows current filter state

---

## Common Issues - When to WebFetch

| User Issue | Quick Fix (no WebFetch) | WebFetch For |
|------------|-------------------------|--------------|
| "403 Access denied" | Add yourself as test user in OAuth consent screen | - |
| "credentials.json missing" | Complete Google Cloud OAuth setup (SKILL.md step 3) | - |
| "Installation failed" | - | Installation section + GitHub issues |
| "OAuth permission denied" | Check scopes (gmail.labels, gmail.settings.basic) | Authentication section |
| "Browser doesn't open" | Use `--no-browser` flag | Troubleshooting section |
| "Multiple accounts" | - | Advanced usage section |
| "Config file location" | - | Configuration section |
| "Upgrade gmailctl" | - | Installation/upgrade section |

---

## WebFetch Strategy

**Pattern:**
1. Identify user's specific issue
2. WebFetch relevant section from https://github.com/mbrt/gmailctl/blob/master/README.md
3. Summarize findings for user
4. Provide specific commands/steps from fetched content
5. If issue not in README, search GitHub issues: `https://github.com/mbrt/gmailctl/issues?q=<search-term>`

**Benefits:**
- Always current with latest gmailctl version
- No risk of stale documentation
- Reduced maintenance burden
- Authoritative source material

---

## Files Created by gmailctl init/download

**Safe to document (stable across versions):**
```
~/.gmailctl/
├── config.jsonnet          # Edit this (user's filter rules)
├── credentials.json        # OAuth tokens (do NOT commit to git)
└── cache/                  # Downloaded Gmail state (auto-managed)
```

**Credentials warning:** Always remind users NOT to commit `credentials.json` to git.

---

## Summary

**Do:**
- Use WebFetch to get latest setup info from gmailctl README
- Provide quick setup commands directly (4-step process)
- Guide users to specific sections of upstream docs

**Don't:**
- Duplicate installation instructions in this file
- Copy/paste large sections from gmailctl README
- Maintain separate troubleshooting documentation
- Create comprehensive guides that will become stale
