# Installation Guide - Spring Boot CLI Claude Plugin

## 📦 Package Information

The Spring Boot CLI Claude Plugin has been packaged as: `springboot-cli-claude-plugin-1.0.0.tgz`

This package contains all the necessary files to enhance Claude Code with Spring Boot development capabilities using Clean Architecture, CQRS, and TDD.

## 🚀 Installation Methods

### Method 1: Install from Local Package (Recommended for Testing)

```bash
# Navigate to your Spring Boot project
cd /path/to/your/spring-boot-project

# Install the plugin from the local tarball
npm install /home/kishen90/java/springboot-cli-claude-plugin-1.0.0.tgz

# The post-install script will automatically set up the plugin
```

### Method 2: Install from NPM Registry (When Published)

```bash
# Install locally in your project
npm install springboot-cli-claude-plugin

# Or install globally
npm install -g springboot-cli-claude-plugin
```

### Method 3: Direct Installation via Path

```bash
# Install directly from the source directory
cd /path/to/your/spring-boot-project
npm install /home/kishen90/java

# This will use the package.json in the source directory
```

## 📋 Post-Installation Setup

### 1. Set Required Environment Variables

Add these to your shell profile (`~/.bashrc`, `~/.zshrc`, or `~/.profile`):

```bash
# Path to Spring Boot CLI
export SPRINGBOOT_CLI_PATH="/home/kishen90/java/springboot-cli"

# GitHub Personal Access Token (for GitHub integration)
export GITHUB_TOKEN="ghp_your_github_token_here"

# Optional: Enable debug mode
export CLAUDE_PLUGIN_DEBUG=false
```

Reload your shell configuration:

```bash
source ~/.bashrc  # or ~/.zshrc
```

### 2. Validate Installation

After installation, validate that everything is set up correctly:

```bash
# Run validation
npx springboot-claude-init validate

# Expected output:
# ✅ .claude directory exists
# ✅ commands/ (10 files)
# ✅ agents/ (3 files)
# ✅ hooks/ (3 files)
# ✅ Spring Boot CLI found
# ✅ GitHub token configured
# ✅ All hooks are executable
```

### 3. Configure Claude Code

Add the GitHub MCP server to your Claude Code configuration:

1. Open Claude Code settings
2. Find MCP Servers configuration
3. Add this configuration:

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

### 4. Initialize Plugin in Your Project

```bash
# Initialize the plugin (optional, for additional setup)
npx springboot-claude-init init

# This will:
# - Make all hooks executable
# - Optionally link git hooks
# - Create environment template file
```

## 🧪 Testing the Installation

### Test 1: Check Available Commands

```bash
# List all available slash commands
npx springboot-cli-claude-plugin commands

# Output:
# /springboot-init
# /springboot-add-entity
# /springboot-add-aggregate
# ...
```

### Test 2: Check Available Agents

```bash
# List all available agents
npx springboot-cli-claude-plugin agents

# Output:
# feature-developer
# test-engineer
# architecture-guardian
```

### Test 3: Test in Claude Code

Open Claude Code and try:

```bash
# Test a slash command
/springboot-validate --aspect all

# Test an agent
@feature-developer: Create a simple hello world REST endpoint
```

## 📁 What Gets Installed

After installation, your project structure will include:

```
your-project/
├── .claude/                        # Plugin directory
│   ├── commands/                   # 10 slash commands
│   │   ├── springboot-init.md
│   │   ├── springboot-add-entity.md
│   │   └── ...
│   ├── agents/                     # 3 AI agents
│   │   ├── feature-developer.md
│   │   ├── test-engineer.md
│   │   └── architecture-guardian.md
│   ├── hooks/                      # Validation hooks
│   │   ├── pre-commit-validation.sh
│   │   ├── post-feature-complete.sh
│   │   └── e2e-test-updater.sh
│   ├── config/                     # Configuration files
│   │   ├── mcp-servers.json
│   │   ├── plugin-settings.yaml
│   │   └── local.json
│   └── workflows/                  # Development workflows
│       └── feature-workflow.md
├── node_modules/
│   └── springboot-cli-claude-plugin/
└── package.json                    # Updated with plugin dependency
```

## 🔧 Configuration Options

### Environment Variables

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `SPRINGBOOT_CLI_PATH` | Yes | Path to Spring Boot CLI | `/home/kishen90/java/springboot-cli` |
| `GITHUB_TOKEN` | Yes* | GitHub Personal Access Token | - |
| `CLAUDE_PLUGIN_DEBUG` | No | Enable debug output | `false` |
| `CLAUDE_PLUGIN_AUTO_VALIDATE` | No | Auto-validate on commands | `true` |

*Required for GitHub integration features

### Local Configuration

The plugin creates a local configuration file at `.claude/config/local.json`:

```json
{
  "installed": "2024-01-15T10:00:00.000Z",
  "version": "1.0.0",
  "projectRoot": "/path/to/your/project",
  "springbootCliPath": "/home/kishen90/java/springboot-cli",
  "features": {
    "slashCommands": true,
    "agents": true,
    "hooks": true,
    "githubIntegration": true
  }
}
```

## 🚨 Troubleshooting

### Issue: "Spring Boot CLI not found"

```bash
# Solution 1: Set the environment variable
export SPRINGBOOT_CLI_PATH="/actual/path/to/springboot-cli"

# Solution 2: Create a symlink
ln -s /actual/path/to/springboot-cli /home/kishen90/java/springboot-cli
```

### Issue: "Hooks are not executable"

```bash
# Make all hooks executable
chmod +x .claude/hooks/*.sh
```

### Issue: "GitHub token not configured"

```bash
# Create a GitHub Personal Access Token:
# 1. Go to GitHub Settings > Developer Settings > Personal Access Tokens
# 2. Generate new token with repo, workflow, and project scopes
# 3. Set the token:
export GITHUB_TOKEN="ghp_your_token_here"
```

### Issue: "Command not found: springboot-claude-init"

```bash
# Solution 1: Use npx
npx springboot-claude-init validate

# Solution 2: Install globally
npm install -g /home/kishen90/java/springboot-cli-claude-plugin-1.0.0.tgz
```

### Issue: "Plugin files not copied to project"

```bash
# Manually trigger post-install
node node_modules/springboot-cli-claude-plugin/scripts/postinstall.js

# Or reinstall
npm uninstall springboot-cli-claude-plugin
npm install /home/kishen90/java/springboot-cli-claude-plugin-1.0.0.tgz
```

## 🔄 Updating the Plugin

To update to a new version:

```bash
# Uninstall old version
npm uninstall springboot-cli-claude-plugin

# Install new version
npm install /path/to/new/springboot-cli-claude-plugin-1.x.x.tgz
```

## 🗑️ Uninstalling

To remove the plugin:

```bash
# Remove npm package
npm uninstall springboot-cli-claude-plugin

# Remove .claude directory (optional)
rm -rf .claude

# Remove git hooks if linked
rm .git/hooks/pre-commit
```

## ✅ Verification Checklist

After installation, verify:

- [ ] `.claude` directory exists in your project
- [ ] All subdirectories are present (commands, agents, hooks, config, workflows)
- [ ] Hooks are executable (`ls -la .claude/hooks/*.sh`)
- [ ] Environment variables are set (`echo $SPRINGBOOT_CLI_PATH`)
- [ ] Spring Boot CLI is accessible
- [ ] GitHub token is configured (for GitHub features)
- [ ] Slash commands work in Claude Code
- [ ] Agents respond in Claude Code

## 📚 Next Steps

1. **Quick Start**: Read `.claude/QUICKSTART.md`
2. **Full Documentation**: Read `.claude/README.md`
3. **Try Your First Feature**:
   ```
   @feature-developer: Create a product management system with CRUD operations
   ```

## 🆘 Support

If you encounter issues:

1. Run validation: `npx springboot-claude-init validate`
2. Check logs in `/tmp/` directory
3. Enable debug mode: `export CLAUDE_PLUGIN_DEBUG=true`
4. Review `.claude/README.md` troubleshooting section
5. Create an issue on GitHub

## 📝 Package Contents

The `springboot-cli-claude-plugin-1.0.0.tgz` package includes:

- **Size**: 34.8 KB (packed), 130.4 KB (unpacked)
- **Files**: 28 total files
- **Main Components**:
  - 10 slash commands
  - 3 AI agents
  - 3 validation hooks
  - 2 configuration files
  - 1 workflow guide
  - Installation scripts
  - Documentation

---

**Installation Complete! 🎉**

You're now ready to build production-ready Spring Boot microservices with Clean Architecture, CQRS, and TDD using Claude Code!