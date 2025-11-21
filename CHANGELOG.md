# Changelog

## [2.1.0] - 2025-11-20

### Repository Restructure for Auto-Discovery

Refactored repository to use standard `.claude/skills/` directory structure for automatic skill discovery in Claude Code.

### Changed

#### Directory Structure
- **Before**: Skill files at repository root
- **After**: Skill files in `.claude/skills/claude-gmailctl/`

**New structure**:
```
claude-gmailctl-skill/
├── .claude/skills/claude-gmailctl/    # Auto-discovered skill
│   ├── SKILL.md
│   ├── assets/
│   ├── references/
│   └── scripts/
├── README.md                           # Repository documentation
├── SETUP.md
├── CHANGELOG.md
└── LICENSE
```

#### Documentation Updates
- Updated README.md with new directory structure
- Added auto-discovery explanation
- Updated all file path references in documentation
- Maintained all functionality and documentation from 2.0.0

### Benefits

1. **Auto-Discovery**: Claude Code automatically detects skill in `.claude/skills/`
2. **Standard Structure**: Follows Claude Code skill conventions
3. **Clean Separation**: Repository docs (README, SETUP, LICENSE) separate from skill files
4. **Better Organization**: Clear distinction between user documentation and skill prompt

---

## [2.0.0] - 2025-11-20

### Major Restructure: Component-Based Architecture

This release completely restructures the skill to provide granular understanding of different gmailctl components and eliminates documentation duplication.

### Added

#### Component-Based Structure (SKILL.md)
- **Component 1: Setup & Initialization** - Complete guide for installing gmailctl and authenticating with Gmail credentials
- **Component 2: Assessment** - Detailed process for analyzing existing filters, labels, and email patterns
- **Component 3: Filter Design** - Creating and validating filter rules with common patterns
- **Component 4: Deployment** - Safe deployment with explicit choice between deployment modes
- **Component 5: Simple Features** - Built-in quick reference for basic Gmail operators and actions
- **Component 6: Advanced Features** - Instructions to use WebFetch for live documentation

#### Deployment Modes
- **Overwrite Mode**: Replace all Gmail filters with config.jsonnet (single source of truth)
- **Additive Mode**: Merge new filters with existing Gmail filters (hybrid management)
- Clear guidance on when to use each mode
- Pre-deployment checklist and rollback procedures

#### Assessment Tools
- Commands to analyze current configuration state
- Configuration drift detection
- Email pattern analysis guidance
- Filter conflict identification

### Changed

#### SKILL.md Restructure
- **Before**: Linear workflow (~362 lines) with bundled references
- **After**: 6 distinct components (~790 lines) with granular understanding
- Each component has clear "When to Use This Component" guidance
- Example interactions now reference specific components

#### Documentation Strategy
- **Before**: 1,580 lines of duplicated reference docs
- **After**: WebFetch-based approach for advanced features
- Simple features built into Component 5 for quick access
- Advanced features fetched live from https://github.com/mbrt/gmailctl

#### README.md Updates
- Added component-based structure explanation
- Added deployment mode information
- Marked reference docs as deprecated
- Updated "How It Works" to reflect new workflow

### Deprecated

#### Reference Documents
- `references/gmailctl-syntax.md` - Use WebFetch for live docs
- `references/inbox-zero.md` - Use WebFetch for live docs
- `references/troubleshooting.md` - Use WebFetch for live docs
- Added `references/README.md` with deprecation notice and migration guide

**Reason**: Avoids documentation duplication and drift, ensures always up-to-date information from authoritative sources.

### Benefits

1. **Granular Understanding**: Claude can now select appropriate component based on user needs
2. **No Duplication**: Advanced docs fetched live from source, preventing staleness
3. **Clearer Workflows**: Explicit guidance on setup, assessment, design, and deployment
4. **Safer Deployments**: User chooses deployment mode with clear understanding of implications
5. **Better Maintenance**: Less content to maintain, more reliance on authoritative sources

### Migration Notes

For users of previous version:
- The skill still works the same way from user perspective
- Claude now has better understanding of when to use which features
- Advanced features will be fetched from live docs (always current)
- Reference docs temporarily kept for backward compatibility

### Technical Details

**SKILL.md**:
- Line count: 362 → 792 (component structure adds clarity)
- Sections: 7 → 6 components + 4 support sections
- External dependencies: 3 local reference files → WebFetch to upstream

**README.md**:
- Added component architecture explanation
- Added deployment mode documentation
- Updated structure diagram with deprecation notices

**New Files**:
- `references/README.md` - Deprecation notice and migration guide
- `CHANGELOG.md` - This file

---

## [1.0.0] - 2025-11-19

Initial release of Claude gmailctl skill.

### Features
- Core workflow for managing Gmail filters
- Reference documentation for syntax, inbox-zero, troubleshooting
- Template configurations (basic and advanced)
- Validation and backup scripts
- Progressive disclosure approach
