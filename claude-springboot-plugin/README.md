# Claude Code Spring Boot Plugin

A comprehensive Claude Code plugin for generating production-ready Spring Boot microservices with Clean Architecture, TDD, CQRS, and Java 21 best practices.

## 🚀 Quick Install

### Install in Your Project

```bash
# Install as dev dependency
npm install --save-dev @claude-code/springboot-plugin

# Or install and setup in one command
npx claude-springboot-install
```

### Install Globally

```bash
# Install globally
npm install -g @claude-code/springboot-plugin

# Then install in your project
npx claude-springboot-install
```

## ✨ Features

This plugin adds powerful Spring Boot development capabilities to Claude Code:

### 📝 **10 Slash Commands**
- `/springboot-init` - Initialize new Spring Boot project
- `/springboot-add-entity` - Add domain entities
- `/springboot-add-aggregate` - Add aggregate roots
- `/springboot-add-usecase` - Add CQRS command/query handlers
- `/springboot-add-repository` - Add repository implementations
- `/springboot-add-client` - Add external REST clients
- `/springboot-add-event` - Add domain events
- `/springboot-generate-api` - Generate API from OpenAPI spec
- `/springboot-generate-tests` - Generate comprehensive test suites
- `/springboot-validate` - Validate architecture, coverage, and style

### 🤖 **3 Backend Agents**
- `@feature-developer` - TDD-driven feature development with GitHub integration
- `@test-engineer` - Test coverage optimization and quality assurance
- `@architecture-guardian` - Clean Architecture enforcement and validation

### 🪝 **3 Automation Hooks**
- `pre-commit-validation.sh` - Fast pre-commit checks (compilation, tests, architecture)
- `post-feature-complete.sh` - Comprehensive post-feature validation
- `e2e-test-updater.sh` - Automatic E2E test generation

### 🔄 **Workflows**
- Feature development workflow with TDD cycle
- Automated GitHub issue and PR creation
- Project board integration

### ⚙️ **Configuration**
- MCP server setup for GitHub integration
- Plugin settings and permissions
- Customizable validation rules

## 📋 Prerequisites

Before using this plugin, ensure you have:

1. **Claude Code CLI** installed
2. **Spring Boot CLI** - The underlying generator (install separately)
3. **Java 21** or higher
4. **Maven 3.9+**
5. **Git**
6. **Docker** (optional, for Testcontainers)
7. **GitHub CLI (`gh`)** (optional, for GitHub integration)

## 🔧 Installation

### Method 1: NPM Install (Recommended)

```bash
# In your Spring Boot project directory
npm install --save-dev @claude-code/springboot-plugin

# The postinstall script will automatically set up .claude directory
```

### Method 2: NPX One-Liner

```bash
# Install in current directory
npx claude-springboot-install

# Install in specific directory
npx claude-springboot-install /path/to/your/project

# Force overwrite existing configuration
npx claude-springboot-install --force
```

### Method 3: Global Install + Project Setup

```bash
# Install globally
npm install -g @claude-code/springboot-plugin

# Then in each project
cd /path/to/your/project
npx claude-springboot-install
```

## 🏗️ What Gets Installed

After installation, your project will have a `.claude/` directory with:

```
.claude/
├── commands/               # 10 slash commands
│   ├── springboot-init.md
│   ├── springboot-add-entity.md
│   ├── springboot-add-aggregate.md
│   ├── springboot-add-usecase.md
│   ├── springboot-add-repository.md
│   ├── springboot-add-client.md
│   ├── springboot-add-event.md
│   ├── springboot-generate-api.md
│   ├── springboot-generate-tests.md
│   └── springboot-validate.md
├── agents/                 # 3 backend agents
│   ├── feature-developer.md
│   ├── test-engineer.md
│   └── architecture-guardian.md
├── hooks/                  # 3 automation scripts
│   ├── pre-commit-validation.sh
│   ├── post-feature-complete.sh
│   └── e2e-test-updater.sh
├── workflows/              # Feature workflow
│   └── feature-workflow.md
├── config/                 # Configuration files
│   ├── mcp-servers.json
│   └── plugin-settings.yaml
├── settings.local.json     # Claude Code permissions
├── README.md               # Full documentation
└── QUICKSTART.md           # Quick start guide
```

## ⚙️ Configuration

### 1. Install Spring Boot CLI

This plugin requires the Spring Boot CLI generator:

```bash
# Clone or install the Spring Boot CLI
cd /home/kishen90/java
git clone <springboot-cli-repo> springboot-cli

# Set environment variable
export SPRINGBOOT_CLI_PATH="/home/kishen90/java/springboot-cli"

# Add to your shell profile
echo 'export SPRINGBOOT_CLI_PATH="/home/kishen90/java/springboot-cli"' >> ~/.bashrc
```

### 2. Configure GitHub Integration (Optional)

For GitHub MCP server integration:

```bash
# Install GitHub MCP server
npm install -g @modelcontextprotocol/server-github

# Set GitHub token
export GITHUB_TOKEN="your-github-personal-access-token"

# Add to shell profile
echo 'export GITHUB_TOKEN="your-github-personal-access-token"' >> ~/.bashrc
```

The MCP server configuration is in `.claude/config/mcp-servers.json`.

### 3. Enable Git Hooks (Optional)

To enable pre-commit validation:

```bash
cd your-project
ln -s ../../.claude/hooks/pre-commit-validation.sh .git/hooks/pre-commit
```

## 🎯 Usage

### Quick Start

1. **Initialize a new Spring Boot project:**

```
/springboot-init --name user-service --package com.example.users --database mongodb --features oauth2
```

2. **Start feature development:**

```
@feature-developer: Implement user registration with email verification
```

The agent will guide you through TDD implementation!

### Using Slash Commands

```
# Add a domain entity
/springboot-add-entity --name Product --attributes "id:UUID,name:String,price:BigDecimal"

# Add a use case (CQRS command)
/springboot-add-usecase --type command --name CreateProduct --entity Product --operation create

# Add a repository
/springboot-add-repository --entity Product --type mongodb

# Validate everything
/springboot-validate --aspect all
```

### Using Agents

#### Feature Developer

```
@feature-developer: Create product catalog with search and filtering
```

This agent will:
- Analyze requirements
- Create GitHub issue and branch
- Write tests first (TDD)
- Generate implementation
- Validate architecture
- Create pull request

#### Test Engineer

```
@test-engineer: Improve test coverage for order processing module
```

#### Architecture Guardian

```
@architecture-guardian: Review current architecture for Clean Architecture violations
```

## 🏗️ Architecture Principles

The plugin enforces:

- **Clean Architecture** - Strict layer separation
- **CQRS** - Command-query responsibility segregation
- **DDD** - Domain-driven design patterns
- **TDD** - Test-driven development
- **Java 21** - Modern Java features (records, pattern matching, virtual threads)

### Layer Structure

```
API Layer (Controllers, DTOs)
    ↓ depends on
Infrastructure Layer (Adapters, Spring Config)
    ↓ implements
Application Layer (Use Cases, CQRS Handlers)
    ↓ depends on
Domain Layer (Entities, Value Objects, Events)
    ← NO FRAMEWORK DEPENDENCIES
```

## 📚 Documentation

After installation, check these files in `.claude/`:

- **README.md** - Comprehensive documentation
- **QUICKSTART.md** - Quick start guide
- **commands/** - Individual command documentation
- **agents/** - Agent behavior and workflows
- **hooks/** - Hook script details

## 🧪 Testing

The plugin generates projects with comprehensive testing:

- **75% Unit Tests** - Fast, isolated domain logic tests
- **20% Integration Tests** - Database, API, external service tests
- **5% E2E/Contract Tests** - Full system and contract validation

### Test Coverage Validation

```bash
# Run in generated project
/springboot-validate --aspect coverage
```

## 🔍 Examples

### Example 1: Simple REST API

```
/springboot-init --name product-api --package com.shop.products --database mongodb

@feature-developer: Create CRUD operations for products with price validation
```

### Example 2: Complex Microservice

```
/springboot-init --name order-service --package com.shop.orders --database mssql --features oauth2,eventsourcing-lite,resilience

@feature-developer: Implement order processing with payment integration, inventory validation, and event publishing
```

## 🛠️ Troubleshooting

### Issue: Spring Boot CLI not found

```bash
# Set the environment variable
export SPRINGBOOT_CLI_PATH="/path/to/springboot-cli"
```

### Issue: Commands not showing up

1. Restart Claude Code CLI
2. Check `.claude/commands/` directory exists
3. Verify file permissions

### Issue: Hooks not executing

```bash
# Make hooks executable
chmod +x .claude/hooks/*.sh

# Link to git hooks
ln -s ../../.claude/hooks/pre-commit-validation.sh .git/hooks/pre-commit
```

### Issue: GitHub MCP server not working

1. Check GitHub token: `echo $GITHUB_TOKEN`
2. Verify MCP server installed: `npm list -g @modelcontextprotocol/server-github`
3. Check `.claude/config/mcp-servers.json` configuration

## 🔄 Updating

To update to the latest version:

```bash
# If installed as dependency
npm update @claude-code/springboot-plugin

# If installed globally
npm update -g @claude-code/springboot-plugin

# Then reinstall in project
npx claude-springboot-install --force
```

## 📦 Package Contents

| Item | Count | Description |
|------|-------|-------------|
| Commands | 10 | Slash commands for code generation |
| Agents | 3 | Backend agents for workflows |
| Hooks | 3 | Automation scripts |
| Workflows | 1 | Feature development workflow |
| Config Files | 2 | MCP and plugin settings |

## 🤝 Contributing

Found a bug or have a suggestion?

1. Check existing issues
2. Create a new issue with details
3. Submit a pull request

## 📄 License

MIT License - See LICENSE file for details

## 🆘 Support

- **GitHub Issues**: Report bugs or request features
- **Documentation**: Check `.claude/README.md` after installation
- **Spring Boot CLI**: See Spring Boot CLI documentation

## 🎯 Quick Reference

### Essential Commands

```bash
# Initialize
/springboot-init --name my-service --package com.example --database mongodb

# Add entity
/springboot-add-entity --name User --attributes "id:UUID,email:String"

# Add use case
/springboot-add-usecase --type command --name CreateUser --entity User

# Validate
/springboot-validate --aspect all
```

### Agent Invocations

```
@feature-developer: [feature description]
@test-engineer: [test improvement request]
@architecture-guardian: [architecture review request]
```

## 🚀 What's Next?

After installation:

1. ✅ Review `.claude/QUICKSTART.md`
2. ✅ Set up Spring Boot CLI
3. ✅ Configure GitHub token (optional)
4. ✅ Try your first command: `/springboot-init`
5. ✅ Start building with `@feature-developer`

---

**Built with ❤️ for Spring Boot developers using Claude Code**
