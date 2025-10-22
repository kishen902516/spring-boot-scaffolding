#!/bin/bash

# Spring Boot CLI Claude Plugin - Initialization Script
# This script initializes or validates the plugin installation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Banner
echo "═══════════════════════════════════════════════════════════════"
echo "🚀 Spring Boot CLI Claude Plugin - Initialization"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Get command
COMMAND=${1:-"help"}

# Functions
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "${BLUE}📝 $1${NC}"
}

# Validate installation
validate() {
    echo "🔍 Validating plugin installation..."
    echo ""

    local VALID=true

    # Check .claude directory
    if [ -d ".claude" ]; then
        success ".claude directory exists"

        # Check subdirectories
        for dir in commands agents hooks config workflows; do
            if [ -d ".claude/$dir" ]; then
                FILE_COUNT=$(ls -1 .claude/$dir 2>/dev/null | wc -l)
                success "$dir/ ($FILE_COUNT files)"
            else
                error "$dir/ missing"
                VALID=false
            fi
        done
    else
        error ".claude directory not found"
        VALID=false
    fi

    echo ""

    # Check Spring Boot CLI
    SPRINGBOOT_CLI_PATH="${SPRINGBOOT_CLI_PATH:-/home/kishen90/java/springboot-cli}"
    if [ -f "$SPRINGBOOT_CLI_PATH/bin/springboot-cli.sh" ]; then
        success "Spring Boot CLI found at: $SPRINGBOOT_CLI_PATH"
    else
        error "Spring Boot CLI not found at: $SPRINGBOOT_CLI_PATH"
        info "Set SPRINGBOOT_CLI_PATH environment variable"
        VALID=false
    fi

    # Check GitHub token
    if [ -n "$GITHUB_TOKEN" ]; then
        success "GitHub token configured"
    else
        warning "GitHub token not set"
        info "Set GITHUB_TOKEN for GitHub integration"
    fi

    # Check executability of hooks
    if [ -d ".claude/hooks" ]; then
        NON_EXEC=$(find .claude/hooks -name "*.sh" ! -perm -u+x | wc -l)
        if [ "$NON_EXEC" -eq 0 ]; then
            success "All hooks are executable"
        else
            warning "$NON_EXEC hooks are not executable"
            info "Run: chmod +x .claude/hooks/*.sh"
        fi
    fi

    echo ""

    # Final status
    if [ "$VALID" = true ]; then
        echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║           ✅ Plugin is properly installed!            ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
        return 0
    else
        echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║           ❌ Plugin installation incomplete           ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
        return 1
    fi
}

# Initialize plugin
init() {
    echo "🔧 Initializing plugin..."
    echo ""

    # Create .claude directory if it doesn't exist
    if [ ! -d ".claude" ]; then
        error ".claude directory not found"
        info "Please run: npm install springboot-cli-claude-plugin"
        exit 1
    fi

    # Make hooks executable
    if [ -d ".claude/hooks" ]; then
        chmod +x .claude/hooks/*.sh
        success "Made hooks executable"
    fi

    # Set up git hooks (optional)
    read -p "Link pre-commit hook to git? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -d ".git" ]; then
            ln -sf ../../.claude/hooks/pre-commit-validation.sh .git/hooks/pre-commit
            success "Linked pre-commit hook"
        else
            warning "Not a git repository"
        fi
    fi

    # Create environment file template
    if [ ! -f ".env.claude" ]; then
        cat > .env.claude << EOF
# Spring Boot CLI Claude Plugin Environment Variables
# Copy these to your shell profile (~/.bashrc or ~/.zshrc)

export SPRINGBOOT_CLI_PATH="/home/kishen90/java/springboot-cli"
export GITHUB_TOKEN="your-github-token-here"

# Optional settings
export CLAUDE_PLUGIN_DEBUG=false
export CLAUDE_PLUGIN_AUTO_VALIDATE=true
EOF
        success "Created .env.claude template"
        info "Update .env.claude with your values"
    fi

    echo ""
    validate
}

# Test slash commands
test_commands() {
    echo "🧪 Testing slash commands..."
    echo ""

    # Check if commands exist
    if [ -d ".claude/commands" ]; then
        COMMAND_COUNT=$(ls -1 .claude/commands/*.md 2>/dev/null | wc -l)
        success "Found $COMMAND_COUNT slash commands"

        echo ""
        echo "Available commands:"
        for cmd in .claude/commands/*.md; do
            CMD_NAME=$(basename "$cmd" .md)
            echo "  /${CMD_NAME}"
        done
    else
        error "Commands directory not found"
    fi
}

# Show configuration
show_config() {
    echo "⚙️  Current Configuration"
    echo ""

    echo "Environment Variables:"
    echo "  SPRINGBOOT_CLI_PATH: ${SPRINGBOOT_CLI_PATH:-[not set]}"
    echo "  GITHUB_TOKEN: ${GITHUB_TOKEN:+[set]}"
    echo ""

    if [ -f ".claude/config/local.json" ]; then
        echo "Local Configuration:"
        cat .claude/config/local.json
    else
        warning "No local configuration found"
    fi
}

# Show help
show_help() {
    echo "Usage: springboot-claude-init [command]"
    echo ""
    echo "Commands:"
    echo "  init      - Initialize the plugin in current directory"
    echo "  validate  - Validate plugin installation"
    echo "  test      - Test slash commands"
    echo "  config    - Show current configuration"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  springboot-claude-init init"
    echo "  springboot-claude-init validate"
    echo "  npx springboot-claude-init test"
}

# Main execution
case "$COMMAND" in
    init)
        init
        ;;
    validate)
        validate
        ;;
    test)
        test_commands
        ;;
    config)
        show_config
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        error "Unknown command: $COMMAND"
        echo ""
        show_help
        exit 1
        ;;
esac