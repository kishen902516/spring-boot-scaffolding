# Spring Boot CLI Claude Plugin

[![npm version](https://img.shields.io/npm/v/springboot-cli-claude-plugin.svg)](https://www.npmjs.com/package/springboot-cli-claude-plugin)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Claude Code plugin for generating production-ready Spring Boot microservices with Clean Architecture, CQRS, TDD, and Java 21 best practices.

## 🚀 Quick Install

```bash
# Install the plugin in your project
npm install springboot-cli-claude-plugin

# Or install globally
npm install -g springboot-cli-claude-plugin
```

## 📋 Prerequisites

- Node.js 16+ and npm 8+
- Java 21+
- Maven 3.9+
- Docker (for Testcontainers)
- GitHub CLI (`gh`) configured
- Claude Code CLI
- Spring Boot CLI (from the main repository)

## 🔧 Installation & Setup

### 1. Install the Plugin

```bash
# In your project directory
npm install springboot-cli-claude-plugin

# The post-install script will automatically:
# - Copy .claude directory to your project
# - Make hooks executable
# - Create local configuration
```

### 2. Set Environment Variables

Add to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
export SPRINGBOOT_CLI_PATH="/path/to/springboot-cli"
export GITHUB_TOKEN="your-github-personal-access-token"
```

### 3. Validate Installation

```bash
npx springboot-claude-init validate
```

### 4. Initialize Plugin (Optional)

```bash
npx springboot-claude-init init
```

## 🎯 Features

- **Test-Driven Development (TDD)** - Enforces test-first approach
- **Clean Architecture** - Maintains strict architectural boundaries
- **CQRS Pattern** - Separates commands and queries
- **Java 21 Features** - Records, pattern matching, virtual threads
- **GitHub Integration** - Automated PR creation and project management
- **Comprehensive Testing** - Unit, integration, architecture, and E2E tests
- **Automated Validation** - Architecture, coverage, and style checks

## 📦 What's Included

```
.claude/
├── commands/        # 10 slash commands for Claude Code
├── agents/          # 3 specialized AI agents
├── hooks/           # Automated validation hooks
├── config/          # Plugin configuration
└── workflows/       # Development workflows
```

## 🚀 Usage in Claude Code

### Slash Commands

```bash
# Initialize a new project
/springboot-init --name user-service --package com.example --database mongodb

# Add domain entity
/springboot-add-entity --name User --attributes "id:UUID,email:String"

# Add use case
/springboot-add-usecase --type command --name CreateUser --entity User

# Validate architecture
/springboot-validate --aspect all
```

### AI Agents

```bash
# Feature development with TDD
@feature-developer: Implement user registration with email verification

# Test coverage improvement
@test-engineer: Improve test coverage for the order module

# Architecture review
@architecture-guardian: Review current implementation for violations
```

## 🧪 Testing

The plugin enforces a proper test pyramid:

- 75% Unit Tests
- 20% Integration Tests
- 5% End-to-End Tests

Run tests:

```bash
# All tests
mvn test

# Validate with plugin hooks
.claude/hooks/post-feature-complete.sh
```

## 📊 API Reference

### Node.js API

```javascript
const plugin = require('springboot-cli-claude-plugin');

// Check if installed
if (plugin.isInstalled()) {
  console.log('Plugin is installed');
}

// Validate installation
await plugin.validate();

// Get available commands
const commands = plugin.getCommands();
// Returns: ['/springboot-init', '/springboot-add-entity', ...]

// Get available agents
const agents = plugin.getAgents();
// Returns: ['feature-developer', 'test-engineer', 'architecture-guardian']
```

### CLI Commands

```bash
# Show version
npx springboot-claude-init version

# List commands
npx springboot-claude-init commands

# List agents
npx springboot-claude-init agents

# Validate installation
npx springboot-claude-init validate

# Initialize in project
npx springboot-claude-init init
```

## 📁 Project Structure After Installation

```
your-project/
├── .claude/                 # Plugin files
│   ├── commands/           # Slash commands
│   ├── agents/             # AI agents
│   ├── hooks/              # Validation hooks
│   ├── config/             # Configuration
│   └── workflows/          # Workflows
├── src/
│   └── main/java/          # Your Spring Boot code
└── package.json            # With plugin dependency
```

## 🔍 Troubleshooting

### Plugin not found

```bash
# Ensure plugin is installed
npm list springboot-cli-claude-plugin

# Reinstall if needed
npm install springboot-cli-claude-plugin
```

### Spring Boot CLI not found

```bash
# Set the path
export SPRINGBOOT_CLI_PATH="/path/to/springboot-cli"

# Validate
npx springboot-claude-init validate
```

### Hooks not executable

```bash
chmod +x .claude/hooks/*.sh
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Follow TDD approach
4. Ensure all validations pass
5. Create a Pull Request

## 📄 License

MIT License - see LICENSE file for details

## 🔗 Links

- [GitHub Repository](https://github.com/your-org/springboot-cli)
- [Spring Boot CLI Documentation](https://github.com/your-org/springboot-cli/blob/main/README.md)
- [Claude Code Documentation](https://claude.ai/docs)

## 🆘 Support

For issues or questions:

1. Check the [troubleshooting guide](.claude/README.md#troubleshooting)
2. Create an issue on GitHub
3. Check logs in `/tmp/` directory

---

Made with ❤️ for Spring Boot developers who love Clean Architecture, CQRS, and TDD