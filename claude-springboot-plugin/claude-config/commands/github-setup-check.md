# GitHub Integration Setup Check

You are a GitHub integration validator. Your task is to verify that GitHub MCP integration is properly configured for the Spring Boot CLI plugin workflow.

## Validation Steps

Perform the following checks and provide a comprehensive status report:

### 1. Check GitHub MCP Availability

Try to use GitHub MCP tools. If available:
- ✅ GitHub MCP is installed and configured
- Continue with validation

If NOT available:
- ❌ GitHub MCP is not configured
- Skip to Setup Instructions section

### 2. Repository Information

If MCP is available, gather:
- Repository name and owner
- Default branch
- Remote URL
- Repository visibility (public/private)
- Number of open issues
- Number of open PRs

### 3. GitHub Projects Status

Check for GitHub Projects:
- List all projects accessible to the user
- Identify project boards linked to this repository
- Show project columns/status fields
- Count items in each column

### 4. Token Permissions

Verify GitHub token has required scopes:
- repo (repository access)
- workflow (GitHub Actions)
- project (Projects access)
- read:org (organization reading)

### 5. Branch Protection

Check if default branch has protection rules:
- Require PR reviews
- Require status checks
- Enforce admins
- Restrict pushes

## Status Report Format

Provide the results in this format:

```
╔════════════════════════════════════════════════════════════╗
║         GitHub MCP Integration Status Report              ║
╚════════════════════════════════════════════════════════════╝

1. GitHub MCP Server
   Status: [✅ Configured | ❌ Not Configured]

2. Repository Information
   Name: {owner}/{repo}
   Default Branch: {branch}
   Visibility: {public|private}
   Open Issues: {count}
   Open PRs: {count}

3. GitHub Projects
   Found: {count} project(s)

   Projects:
   - {Project Name} (ID: {id})
     Columns: {column1}, {column2}, ...
     Items: {count}

4. Token Permissions
   ✅ repo - Full repository access
   ✅ workflow - GitHub Actions access
   ✅ project - Projects access
   ✅ read:org - Organization access

5. Branch Protection (main)
   {Protection rules status}

Overall Status: [✅ Fully Configured | ⚠️ Partially Configured | ❌ Not Configured]
```

## If NOT Configured

If GitHub MCP is not available or partially configured, provide:

```
❌ GitHub MCP Integration Not Configured

Missing Components:
{List what's missing}

📚 Quick Setup Guide:

Step 1: Install GitHub MCP Server
  npm install -g @modelcontextprotocol/server-github

Step 2: Create GitHub Personal Access Token
  1. Go to: https://github.com/settings/tokens/new
  2. Select scopes: repo, workflow, project, read:org
  3. Generate and copy token

Step 3: Set Environment Variable
  # Linux/macOS
  export GITHUB_TOKEN='your-token-here'
  echo 'export GITHUB_TOKEN="your-token-here"' >> ~/.bashrc
  source ~/.bashrc

  # Windows PowerShell
  $env:GITHUB_TOKEN = 'your-token-here'
  [Environment]::SetEnvironmentVariable('GITHUB_TOKEN', 'your-token-here', 'User')

Step 4: Create GitHub Project
  1. Go to your repository on GitHub
  2. Click "Projects" tab
  3. Create new project with "Board" template
  4. Add columns: Backlog, In Progress, In Review, Done

Step 5: Restart Claude Code
  Restart Claude Code CLI for changes to take effect

Step 6: Verify Setup
  Run this command again to verify: /github-setup-check

📖 Detailed Setup Guide:
   .claude/config/GITHUB_SETUP.md

Need help? I can guide you through each step!
```

## Troubleshooting

If validation fails, provide specific guidance:

### MCP Server Not Found
```
Issue: GitHub MCP server not responding

Possible Causes:
1. MCP server not installed
2. GITHUB_TOKEN not set
3. Token expired or invalid
4. Claude Code needs restart

Solutions:
1. Install: npm install -g @modelcontextprotocol/server-github
2. Set token: export GITHUB_TOKEN='your-token'
3. Verify token: gh auth status (if gh CLI installed)
4. Restart Claude Code
```

### No Projects Found
```
Issue: No GitHub Projects detected

Solutions:
1. Create a project board on GitHub
2. Link project to repository
3. Ensure token has 'project' scope
4. Verify project visibility matches token access
```

### Permission Denied
```
Issue: GitHub API permission denied

Solutions:
1. Regenerate token with correct scopes
2. Update GITHUB_TOKEN environment variable
3. Verify repository access
4. Check organization permissions
```

## Success Response

If fully configured:

```
╔════════════════════════════════════════════════════════════╗
║       ✅ GitHub MCP Integration Fully Configured!         ║
╚════════════════════════════════════════════════════════════╝

You're all set to use GitHub-integrated workflows!

Available Features:
✅ Automated issue creation
✅ Feature branch management
✅ Project board tracking
✅ Pull request automation
✅ Issue-to-code traceability

Try it out:
  @feature-developer: Implement user authentication

The agent will:
1. Create a GitHub issue
2. Create a feature branch
3. Add to project board
4. Implement with TDD
5. Create a pull request
6. Link everything together

Happy coding! 🚀
```

## Action Items

Based on validation results, suggest next steps:

1. If fully configured → Encourage feature development
2. If partially configured → List specific fixes needed
3. If not configured → Provide step-by-step setup guide
4. If errors detected → Provide troubleshooting steps

---

**Remember:** This plugin enforces GitHub-first workflow for traceability and team collaboration. Complete setup is required for @feature-developer agent.
