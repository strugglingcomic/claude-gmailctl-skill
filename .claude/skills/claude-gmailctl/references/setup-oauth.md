# OAuth Setup for gmailctl

Complete guide for setting up Google Cloud OAuth credentials for gmailctl.

## When to Use This Guide

Use this guide when:
- Running `gmailctl init` fails with "credentials.json: no such file or directory"
- Setting up gmailctl for the first time
- Creating OAuth credentials for a new Google account
- User receives "403 Access denied" errors during authentication

## Prerequisites

- Google account with Gmail enabled
- Web browser
- gmailctl installed on your system

## Complete OAuth Setup Steps

### Step 1: Access Google Cloud Console

1. Navigate to https://console.developers.google.com
2. Sign in with your Google account

### Step 2: Create or Select Project

1. Click the project dropdown at the top of the page
2. Either:
   - **Create new project**: Click "New Project", enter a name (e.g., "gmailctl"), click "Create"
   - **Use existing**: Select an existing project from the list

### Step 3: Enable Gmail API

1. In the left sidebar, go to "APIs & Services" → "Library"
2. Search for "Gmail API"
3. Click on "Gmail API" in the results
4. Click the "Enable" button
5. Wait for the API to be enabled (takes a few seconds)

### Step 4: Configure OAuth Consent Screen

1. In the left sidebar, go to "OAuth consent screen"
2. **User Type**:
   - Select "External" if using personal Gmail account
   - Select "Internal" if using Google Workspace account
3. Click "Create"

**App Information:**
- **App name**: Enter "gmailctl" (or any name you prefer)
- **User support email**: Select your email from dropdown
- **App logo**: (Optional) Leave blank
- **Application home page**: (Optional) Leave blank
- **Application privacy policy link**: (Optional) Leave blank
- **Application terms of service link**: (Optional) Leave blank
- **Developer contact information**: Enter your email address
4. Click "Save and Continue"

**Scopes Configuration:**
5. Click "Add or Remove Scopes"
6. In the filter box, search for "gmail"
7. Select these two scopes (required):
   - `https://www.googleapis.com/auth/gmail.labels`
   - `https://www.googleapis.com/auth/gmail.settings.basic`
8. Click "Update" at the bottom
9. Verify both scopes are listed
10. Click "Save and Continue"

**Test Users (CRITICAL STEP):**
11. Scroll to the "Test users" section
12. Click "+ ADD USERS" button
13. Enter your Gmail address (the account you'll manage with gmailctl)
14. Click "Add"
15. Verify your email appears in the test users list
16. Click "Save and Continue"

**Summary:**
17. Review the summary page
18. Click "Back to Dashboard"

**⚠️ IMPORTANT:** Keep the app in "Testing" mode. Do NOT publish to Production.

### Step 5: Create OAuth Credentials

1. In the left sidebar, go to "Credentials"
2. Click "+ CREATE CREDENTIALS" at the top
3. Select "OAuth client ID" from the dropdown

**Application Type:**
4. **Application type**: Select **"Desktop app"** (NOT "Web application")
5. **Name**: Enter a descriptive name (e.g., "gmailctl-desktop")
6. Click "Create"

**Download Credentials:**
7. A popup will appear showing your client ID and secret
8. Click the download icon (⬇️) or "Download JSON"
9. Save the JSON file

### Step 6: Install Credentials

1. Create gmailctl directory if it doesn't exist:
   ```bash
   mkdir -p ~/.gmailctl
   ```

2. Move the downloaded JSON file:
   ```bash
   mv ~/Downloads/client_secret_*.json ~/.gmailctl/credentials.json
   ```

3. Verify the file exists:
   ```bash
   ls -la ~/.gmailctl/credentials.json
   ```

## Verification

Test that OAuth credentials are working:

```bash
# Initialize gmailctl (creates config template)
gmailctl init

# Authenticate with Gmail (opens browser for OAuth)
gmailctl download

# Verify authentication succeeded
gmailctl diff
```

**Expected behavior:**
- Browser opens automatically
- You see Google OAuth consent screen
- After clicking "Allow", browser shows success message
- Command line shows download progress
- `gmailctl diff` runs without authentication errors

## Common Issues

### 403 "Access denied" Error

**Symptom**: Browser shows "403. That's an error. Error: access_denied"

**Root cause**: You forgot to add yourself as a test user (Step 4, item 11-16)

**Solution**:
1. Return to Google Cloud Console
2. Go to "OAuth consent screen"
3. Scroll to "Test users" section
4. Click "+ ADD USERS"
5. Add your Gmail address
6. Try `gmailctl download` again

### "This app isn't verified" Warning

**Symptom**: Browser shows scary warning about unverified app

**This is normal for personal projects!**

**Solution**:
1. Click "Advanced" (or "Show Advanced")
2. Click "Go to gmailctl (unsafe)"
3. Review the permissions
4. Click "Allow"

**Why this happens**: Google shows this warning for apps in "Testing" mode that haven't gone through their verification process. For personal use, this is expected and safe to bypass.

### Wrong Application Type Selected

**Symptom**: OAuth flow fails or behaves unexpectedly

**Solution**: Delete the credential and create a new one
1. Go to "Credentials" in Google Cloud Console
2. Find your OAuth credential
3. Click the trash icon to delete it
4. Create new credential with "Desktop app" type (not "Web application")

### Missing Scopes

**Symptom**: Error message mentions "insufficient permissions" or specific scope issues

**Solution**:
1. Return to "OAuth consent screen" in Google Cloud Console
2. Click "Edit App"
3. Navigate to "Scopes" step
4. Verify both scopes are present:
   - `https://www.googleapis.com/auth/gmail.labels`
   - `https://www.googleapis.com/auth/gmail.settings.basic`
5. Add any missing scopes
6. Save changes
7. Delete `~/.gmailctl/token.json` and re-run `gmailctl download`

### Browser Doesn't Open

**Symptom**: `gmailctl download` shows URL but browser doesn't open

**Solution**: Use the `--no-browser` flag
```bash
gmailctl download --no-browser
```

This will display the OAuth URL. Copy and paste it into your browser manually.

## Why Testing Mode is Sufficient

**Benefits of keeping app in Testing mode:**
- No Google app verification required (saves weeks/months)
- Works immediately after setup
- No scary warning screens for test users
- Sufficient for personal use
- Can add up to 100 test users

**Production mode requirements:**
- Extensive app verification process
- Privacy policy required
- Terms of service required
- App homepage required
- Google review (can take weeks)
- **Only needed for public apps with >100 users**

For personal gmailctl use, Testing mode is the right choice.

## Security Best Practices

### Protect Your Credentials

**⚠️ NEVER commit credentials to git:**

```bash
# Add to .gitignore
echo "credentials.json" >> ~/.gmailctl/.gitignore
echo "token.json" >> ~/.gmailctl/.gitignore
```

**Files to protect:**
- `~/.gmailctl/credentials.json` - OAuth client secret
- `~/.gmailctl/token.json` - Access/refresh tokens

**Safe to commit:**
- `~/.gmailctl/config.jsonnet` - Filter configuration (no secrets)

### Rotate Credentials

If credentials are compromised:

1. Go to Google Cloud Console → Credentials
2. Delete the compromised OAuth client
3. Create a new OAuth client ID
4. Download new credentials.json
5. Replace `~/.gmailctl/credentials.json`
6. Delete `~/.gmailctl/token.json`
7. Run `gmailctl download` to re-authenticate

## Multiple Gmail Accounts

To manage multiple Gmail accounts with gmailctl:

**Option 1: Separate Projects**
- Create different Google Cloud projects for each account
- Use different credential files
- Use `--config` flag to specify config path

**Option 2: Same Project, Multiple Test Users**
- Use one Google Cloud project
- Add all Gmail accounts as test users
- Use separate config directories

Example for multiple accounts:
```bash
# Account 1 (personal)
gmailctl --config ~/.gmailctl-personal/config.jsonnet apply

# Account 2 (work)
gmailctl --config ~/.gmailctl-work/config.jsonnet apply
```

## Reference

- **Google Cloud Console**: https://console.developers.google.com
- **Gmail API Documentation**: https://developers.google.com/gmail/api
- **OAuth 2.0 Overview**: https://developers.google.com/identity/protocols/oauth2

## Summary Checklist

Before proceeding with gmailctl setup:

- [ ] Google Cloud project created or selected
- [ ] Gmail API enabled for the project
- [ ] OAuth consent screen configured with app name and email
- [ ] Required scopes added (gmail.labels, gmail.settings.basic)
- [ ] **Your Gmail address added as a test user**
- [ ] App kept in Testing mode (not published)
- [ ] OAuth client ID created as "Desktop app" type
- [ ] Credentials JSON downloaded
- [ ] Credentials saved to `~/.gmailctl/credentials.json`
- [ ] Successfully ran `gmailctl download` without errors

Once all items are checked, you're ready to configure filters with gmailctl!
