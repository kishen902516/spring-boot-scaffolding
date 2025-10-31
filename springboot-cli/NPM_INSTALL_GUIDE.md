# NPM Installation Guide - Spring Boot CLI with Orchestration

## 📦 Installation

### Global Installation (Recommended)

```bash
# Install globally to use commands anywhere
npm install -g @springboot-cli/generator

# Or from the project directory
npm install -g .
```

### Local Installation

```bash
# Install in your project
npm install @springboot-cli/generator

# Use with npx
npx springboot-cli init --name my-service
npx orchestrator validate --fix
```

### Development Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/springboot-cli.git
cd springboot-cli

# Install dependencies
npm install

# Link globally for development
npm link

# Now you can use the commands
springboot-cli --help
orchestrator validate
```

## 🚀 Post-Installation

After installation, the package will automatically:

1. **Set executable permissions** on all scripts
2. **Create data directories** for orchestration and learning
3. **Initialize the learning database** (if SQLite is installed)
4. **Check system dependencies** and provide installation guidance

## 📋 Available Commands

After installation, you'll have access to these commands:

### Main Commands

```bash
# Spring Boot CLI
springboot-cli init --name my-service
springboot-cli add entity --name Product
springboot-cli validate architecture

# Short alias
sbcli init --name my-service
```

### Orchestration Commands

```bash
# Architecture validation with auto-fix
orchestrator validate --fix

# Continuous monitoring
orchestrator continuous .

# View learning report
orchestrator report

# Quick validation (always with --fix)
validate-arch
```

### Learning System

```bash
# View dashboard
learning-system dashboard

# Analyze patterns
learning-system analyze feature-developer

# Generate feedback
learning-system feedback feature-developer
```

## 📝 NPM Scripts

You can also use npm scripts:

```bash
# Run validation
npm run validate

# Validate with auto-fix
npm run validate:fix

# Start monitoring
npm run monitor

# View learning dashboard
npm run learning:dashboard

# View learning report
npm run learning:report
```

## 🔧 Manual Setup

If the automatic setup fails, run:

```bash
npm run setup
```

This will:
- Set file permissions
- Create directories
- Initialize databases
- Configure PATH
- Test installation

## 🧪 Testing

Verify the installation:

```bash
npm test
```

This runs a comprehensive test suite checking:
- CLI functionality
- Orchestrator availability
- Learning system initialization
- Template availability
- Configuration files

## 🐛 Troubleshooting

### Permission Denied

```bash
# Fix permissions manually
chmod +x node_modules/@springboot-cli/generator/bin/*.sh
chmod +x node_modules/@springboot-cli/generator/bin/**/*.sh
```

### Command Not Found

```bash
# For global install, ensure npm bin is in PATH
export PATH="$(npm bin -g):$PATH"

# For local install, use npx
npx springboot-cli --help
```

### SQLite Not Found

The learning system requires SQLite:

```bash
# macOS
brew install sqlite3

# Ubuntu/Debian
sudo apt-get install sqlite3

# RHEL/CentOS
sudo yum install sqlite
```

### Bash Not Available (Windows)

On Windows, use one of these:
- WSL (Windows Subsystem for Linux)
- Git Bash
- Cygwin

## 📁 Package Structure

```
@springboot-cli/generator/
├── bin/                      # Executable scripts
│   ├── cli.js               # Node.js entry point
│   ├── springboot-cli.sh    # Main bash script
│   ├── orchestrator.sh      # Architecture orchestration
│   ├── agent-learning-system.sh # Learning system
│   └── commands/            # CLI commands
├── config/                  # Configuration files
│   └── auto-correction-rules.yaml
├── data/                    # Runtime data
│   ├── orchestrator/        # Session data
│   └── learning/           # Learning database
├── templates/              # Code templates
├── scripts/                # NPM scripts
│   ├── postinstall.js     # Auto-setup
│   ├── setup.js           # Manual setup
│   └── test-all.js        # Test suite
└── docs/                   # Documentation
```

## 🔄 Updating

To update to the latest version:

```bash
# Global update
npm update -g @springboot-cli/generator

# Local update
npm update @springboot-cli/generator
```

## 🗑️ Uninstallation

```bash
# Global uninstall
npm uninstall -g @springboot-cli/generator

# Local uninstall
npm uninstall @springboot-cli/generator

# Clean up data (optional)
rm -rf ~/.springboot-cli-data
```

## 🤝 Integration with Claude Agents

If you're using this with Claude agents, see:
- `CLAUDE_AGENT_QUICK_START.md` - Quick start guide
- `docs/CLAUDE_AGENT_INTEGRATION_GUIDE.md` - Full integration guide

The package includes:
- Slash commands for Claude (`/validate-arch`, `/develop-feature`)
- Agent configurations
- Learning feedback system
- Automatic architecture compliance

## 📚 Documentation

- [README.md](README.md) - Main documentation
- [CLAUDE_AGENT_QUICK_START.md](CLAUDE_AGENT_QUICK_START.md) - For Claude agents
- [docs/](docs/) - Detailed documentation
  - Architecture Orchestration Workflow
  - Agent Integration Guide
  - Learning System Guide

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/springboot-cli/issues)
- **Documentation**: [Full Docs](docs/)
- **Examples**: [templates/](templates/)

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details