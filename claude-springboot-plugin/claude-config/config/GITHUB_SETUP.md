# GitHub MCP Integration Setup Guide

This guide helps you set up GitHub integration using the Model Context Protocol (MCP) for the Spring Boot CLI plugin.

## Overview

The plugin uses GitHub MCP server to enable:
- ✅ Automated issue creation
- ✅ Feature branch management
- ✅ GitHub Projects integration
- ✅ Pull request automation
- ✅ Workflow enforcement

## Prerequisites

1. **GitHub Account** with repository access
2. **GitHub Personal Access Token** with required scopes
3. **Node.js/NPM** installed (for MCP server)
4. **Claude Code CLI** with MCP support

## Step 1: Install GitHub MCP Server

```bash
# Install globally
npm install -g @modelcontextprotocol/server-github

# Verify installation
npx @modelcontextprotocol/server-github --version
```

## Step 2: Create GitHub Personal Access Token

1. Go to: https://github.com/settings/tokens/new

2. Configure token:
   - **Name**: `Claude Code Spring Boot Plugin`
   - **Expiration**: 90 days (or custom)

3. Select scopes:
   ```
   ✅ repo (Full control of private repositories)
      ✅ repo:status
      ✅ repo_deployment
      ✅ public_repo
      ✅ repo:invite
   ✅ workflow (Update GitHub Action workflows)
   ✅ project (Full control of projects)
      ✅ read:project
      ✅ write:project
   ✅ read:org (Read org data)
   ```

4. Click "Generate token" and **copy the token**

## Step 3: Set Environment Variable

### Linux/macOS

```bash
# Set for current session
export GITHUB_TOKEN='ghp_your_token_here'

# Make it permanent - add to ~/.bashrc or ~/.zshrc
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.bashrc
source ~/.bashrc

# Or use ~/.zshrc for Zsh
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.zshrc
source ~/.zshrc
```

### Windows (PowerShell)

```powershell
# Set for current session
$env:GITHUB_TOKEN = 'ghp_your_token_here'

# Make it permanent (User level)
[System.Environment]::SetEnvironmentVariable('GITHUB_TOKEN', 'ghp_your_token_here', 'User')
```

## Step 4: Verify MCP Configuration

The MCP server configuration is already set up in `.claude/config/mcp-servers.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

This configuration:
- Uses `npx` to run the MCP server
- Passes your `GITHUB_TOKEN` as `GITHUB_PERSONAL_ACCESS_TOKEN`
- Enables automatic GitHub integration

## Step 5: Set Up GitHub Projects

### Option A: Create via GitHub Web UI (Recommended)

1. **Go to your repository** on GitHub

2. **Navigate to Projects tab**
   - Click "Projects" in the repository menu

3. **Create new project**
   - Click "New project"
   - Choose **"Board"** template
   - Name it: `Development Board` (or your preferred name)

4. **Configure columns** (default columns work, but customize if needed):
   - **Backlog** - New tasks
   - **In Progress** - Active development
   - **In Review** - Code review stage
   - **Done** - Completed tasks

5. **Copy the project number** (visible in URL or project settings)

### Option B: Create via MCP (Automated)

Claude Code can create projects using MCP:

```
@feature-developer: Create a GitHub project board called "Development Board" with columns: Backlog, In Progress, In Review, Done
```

### Organization Projects (For Teams)

If working in a team:

1. Go to your GitHub organization
2. Click "Projects" at the top
3. Create organization-level project
4. Link repositories to the project
5. Set permissions for team members

## Step 6: Verify Integration

### Test 1: Check MCP Connection

In Claude Code, ask:
```
Can you check if GitHub MCP is connected and show me the current repository information?
```

Expected response should include repository details.

### Test 2: List Projects

```
List all GitHub projects available for this repository
```

You should see your project board listed.

### Test 3: Create Test Issue

```
Create a test issue titled "Test GitHub Integration" with label "test"
```

Check GitHub to verify the issue was created.

## Step 7: Configure Plugin Settings

Update `.claude/config/plugin-settings.yaml`:

```yaml
github:
  organization: "your-github-username-or-org"
  project_board:
    enabled: true
    project_number: 1  # Your project number from Step 5
    columns:
      - "Backlog"
      - "In Progress"
      - "In Review"
      - "Done"
  pr_template: true
  auto_link_issues: true
  require_pr_review: true
```

## Usage Examples

### Starting Feature Development

```
@feature-developer: Implement user registration with email verification
```

The agent will:
1. ✅ Check GitHub MCP is available
2. ✅ Create GitHub issue with requirements
3. ✅ Add issue to project board (Backlog)
4. ✅ Create feature branch
5. ✅ Move issue to "In Progress"
6. ✅ Implement feature with TDD
7. ✅ Create pull request
8. ✅ Link PR to issue
9. ✅ Move to "In Review"

### Manual Issue Creation

```
Create a GitHub issue:
- Title: "Add product search endpoint"
- Description: "Implement search with filters"
- Labels: feature, api
- Assignee: @me
- Project: Development Board (In Progress)
```

### Manual PR Creation

```
Create a pull request for branch feature/123-user-auth:
- Title: "feat: Add user authentication"
- Description: "Implements OAuth2 authentication"
- Link to issue #123
- Request review from @teammate
```

## Troubleshooting

### Issue: "GitHub MCP not available"

**Solution:**
1. Check token is set: `echo $GITHUB_TOKEN`
2. Verify MCP server installed: `npm list -g @modelcontextprotocol/server-github`
3. Restart Claude Code CLI
4. Check `.claude/config/mcp-servers.json` exists

### Issue: "Repository not found"

**Solution:**
1. Ensure you're in a git repository: `git status`
2. Check remote is GitHub: `git remote -v`
3. Verify token has repo access
4. Try: `git remote set-url origin https://github.com/username/repo.git`

### Issue: "Project not found"

**Solution:**
1. Verify project exists on GitHub
2. Check project visibility (must be accessible with token)
3. Update `project_number` in plugin settings
4. Ensure token has `project` scope

### Issue: "Permission denied"

**Solution:**
1. Regenerate token with correct scopes (see Step 2)
2. Update `GITHUB_TOKEN` environment variable
3. Restart shell/terminal
4. Restart Claude Code

### Issue: "MCP server crashes"

**Solution:**
1. Check Node.js version: `node --version` (needs 18+)
2. Reinstall MCP server: `npm install -g @modelcontextprotocol/server-github`
3. Check for conflicting environment variables
4. View Claude Code logs for error details

## Security Best Practices

1. **Never commit tokens** to git repositories
2. **Use minimal scopes** required for functionality
3. **Rotate tokens regularly** (every 90 days)
4. **Use organization tokens** for team projects
5. **Revoke unused tokens** in GitHub settings
6. **Store in secure location** (password manager)

## Validation Checklist

Before starting development, verify:

- [ ] GitHub token set in environment
- [ ] MCP server installed and accessible
- [ ] Repository has GitHub remote
- [ ] GitHub project created and configured
- [ ] Token has required scopes
- [ ] Can create issues via Claude Code
- [ ] Can create PRs via Claude Code
- [ ] Project board integration works

## Quick Validation Command

Ask Claude Code:

```
Validate GitHub MCP integration and show setup status
```

This will check all prerequisites and report any issues.

## Additional Resources

- [GitHub MCP Server Documentation](https://github.com/modelcontextprotocol/servers)
- [GitHub Personal Access Tokens Guide](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitHub Projects Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Claude Code MCP Integration](https://docs.anthropic.com/claude/docs)

## Support

If you encounter issues:

1. Check this guide's Troubleshooting section
2. Review Claude Code logs
3. Verify GitHub token permissions
4. Test MCP server independently
5. Open issue in plugin repository

---

**Last Updated:** 2025-10-27
**Plugin Version:** 1.0.0
