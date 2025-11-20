# Reference Documentation - DEPRECATION NOTICE

## ⚠️ These files are being deprecated

The reference documents in this directory (`gmailctl-syntax.md`, `inbox-zero.md`, `troubleshooting.md`) contain duplicated content from upstream sources and are at risk of becoming stale.

## New Approach: Live Web Fetches

Instead of maintaining copied documentation, the skill now instructs Claude to:

1. **Use WebFetch** to read the latest documentation directly from:
   - https://github.com/mbrt/gmailctl/blob/master/README.md (primary source)
   - https://support.google.com/mail/answer/7190 (Gmail search operators)

2. **Fetch on-demand** when advanced features are needed, ensuring:
   - Always up-to-date information
   - No documentation drift
   - Reduced maintenance burden
   - Authoritative source material

## What's Changed

**OLD approach (Component 6: Advanced Features):**
- Read from `references/gmailctl-syntax.md`
- Risk of outdated information
- ~1,580 lines of duplicated content

**NEW approach (Component 6: Advanced Features):**
```
When user asks about advanced feature:
1. Use WebFetch on https://github.com/mbrt/gmailctl/blob/master/README.md
2. Search for relevant section (e.g., "Tips and Tricks")
3. Provide summary and examples from live docs
```

## Migration Plan

1. **Keep these files temporarily** for backward compatibility
2. **Add this README** to explain the deprecation
3. **Monitor usage** - if Claude attempts to read these files, update SKILL.md
4. **Remove files in future version** once confirmed not needed

## If You Need These Files

If you prefer local reference docs:
- **Basic syntax**: Use Component 5 (Simple Features) in SKILL.md
- **Advanced features**: Component 6 now uses WebFetch for latest docs
- **Troubleshooting**: Quick reference in SKILL.md, detailed via WebFetch

---

**Last updated:** 2025-11-20
