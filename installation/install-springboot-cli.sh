#!/bin/bash

# Spring Boot CLI - Installation Script
# This script clones/updates the CLI from GitHub and sets it up for use

set -e

# Configuration
GITHUB_REPO="https://github.com/kishen902516/spring-boot-scaffolding.git"
INSTALL_DIR="${HOME}/.springboot-cli"
CLI_SCRIPT="springboot-cli.sh"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed. Please install git first."
        exit 1
    fi
}

# Check if Java is installed
check_java() {
    if ! command -v java &> /dev/null; then
        log_warning "Java is not installed. You'll need Java 21+ to run generated projects."
        log_warning "Install Java from: https://adoptium.net/"
    else
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
        if [ "$JAVA_VERSION" -lt 21 ]; then
            log_warning "Java version $JAVA_VERSION detected. Java 21+ is recommended."
        else
            log_success "Java $JAVA_VERSION detected"
        fi
    fi
}

# Check if Maven is installed
check_maven() {
    if ! command -v mvn &> /dev/null; then
        log_warning "Maven is not installed. You'll need Maven 3.9+ to build generated projects."
        log_warning "Install Maven from: https://maven.apache.org/download.cgi"
    else
        MVN_VERSION=$(mvn -version 2>&1 | head -n 1 | awk '{print $3}')
        log_success "Maven $MVN_VERSION detected"
    fi
}

# Clone or update repository
install_cli() {
    log_info "Installing Spring Boot CLI..."

    if [ -d "$INSTALL_DIR" ]; then
        log_info "CLI already installed at $INSTALL_DIR"
        log_info "Updating to latest version..."

        cd "$INSTALL_DIR"

        # Stash any local changes
        if [ -n "$(git status --porcelain)" ]; then
            log_warning "Local changes detected, stashing..."
            git stash
        fi

        # Pull latest changes
        git pull origin main || git pull origin master || {
            log_error "Failed to pull updates. Checking current branch..."
            CURRENT_BRANCH=$(git branch --show-current)
            log_info "Current branch: $CURRENT_BRANCH"
            git pull origin "$CURRENT_BRANCH" || log_warning "Pull failed, using existing version"
        }

        log_success "CLI updated successfully"
    else
        log_info "Cloning CLI from GitHub..."
        git clone "$GITHUB_REPO" "$INSTALL_DIR"
        log_success "CLI cloned successfully"
    fi
}

# Set executable permissions
set_permissions() {
    log_info "Setting executable permissions..."
    chmod +x "$INSTALL_DIR/springboot-cli/bin/springboot-cli.sh"
    chmod +x "$INSTALL_DIR/springboot-cli/bin/commands/"*.sh
    log_success "Permissions set"
}

# Create symlink or add to PATH
setup_path() {
    log_info "Setting up CLI in PATH..."

    # Determine shell config file
    SHELL_CONFIG=""
    if [ -n "$BASH_VERSION" ]; then
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    fi

    # Check if already in PATH config
    PATH_EXPORT="export PATH=\"\$PATH:$INSTALL_DIR/springboot-cli/bin\""

    if [ -n "$SHELL_CONFIG" ]; then
        if grep -q "$INSTALL_DIR/springboot-cli/bin" "$SHELL_CONFIG" 2>/dev/null; then
            log_info "PATH already configured in $SHELL_CONFIG"
        else
            log_info "Adding CLI to PATH in $SHELL_CONFIG"
            echo "" >> "$SHELL_CONFIG"
            echo "# Spring Boot CLI" >> "$SHELL_CONFIG"
            echo "$PATH_EXPORT" >> "$SHELL_CONFIG"
            log_success "Added to PATH in $SHELL_CONFIG"
            log_warning "Run 'source $SHELL_CONFIG' or restart your terminal to use the CLI"
        fi
    else
        log_warning "Could not detect shell config file"
        log_info "Add the following to your shell config manually:"
        echo ""
        echo "    $PATH_EXPORT"
        echo ""
    fi

    # Try to create symlink in /usr/local/bin if writable
    if [ -w "/usr/local/bin" ]; then
        if [ -L "/usr/local/bin/springboot-cli" ]; then
            log_info "Symlink already exists in /usr/local/bin"
            rm -f "/usr/local/bin/springboot-cli"
        fi
        ln -s "$INSTALL_DIR/springboot-cli/bin/springboot-cli.sh" "/usr/local/bin/springboot-cli"
        log_success "Created symlink: /usr/local/bin/springboot-cli"
    fi
}

# Create alias helper script
create_alias_helper() {
    log_info "Creating alias helper..."

    ALIAS_SCRIPT="$INSTALL_DIR/springboot-cli-alias.sh"

    cat > "$ALIAS_SCRIPT" << 'EOF'
#!/bin/bash
# Source this file to create a convenient alias
# Usage: source ~/.springboot-cli/springboot-cli-alias.sh

alias springboot-cli="${HOME}/.springboot-cli/springboot-cli/bin/springboot-cli.sh"
alias sbc="${HOME}/.springboot-cli/springboot-cli/bin/springboot-cli.sh"

echo "Spring Boot CLI aliases created:"
echo "  springboot-cli - Full command"
echo "  sbc           - Short alias"
EOF

    chmod +x "$ALIAS_SCRIPT"
    log_success "Alias helper created at $ALIAS_SCRIPT"
}

# Display usage information
show_usage_info() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║      Spring Boot CLI installed successfully! 🚀           ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    log_info "Installation directory: $INSTALL_DIR"
    echo ""
    log_info "Quick Start:"
    echo ""
    echo "  1. Reload your shell or run:"
    echo "     source ~/.bashrc    # or ~/.zshrc"
    echo ""
    echo "  2. Or use directly:"
    echo "     $INSTALL_DIR/springboot-cli/bin/springboot-cli.sh"
    echo ""
    echo "  3. Or create an alias:"
    echo "     source $INSTALL_DIR/springboot-cli-alias.sh"
    echo ""
    log_info "Example usage:"
    echo ""
    echo "  # Initialize a new project"
    echo "  springboot-cli init --name my-service --package com.company.myservice --database mongodb"
    echo ""
    echo "  # Add a use case"
    echo "  springboot-cli add usecase --name ProcessOrder --aggregate Order"
    echo ""
    echo "  # Show help"
    echo "  springboot-cli help"
    echo ""
    log_info "Documentation:"
    echo "  - README: $INSTALL_DIR/springboot-cli/README.md"
    echo "  - LLM Guide: $INSTALL_DIR/springboot-cli/docs/llm-usage.md"
    echo "  - GitHub: $GITHUB_REPO"
    echo ""
}

# Main installation flow
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║         Spring Boot CLI - Installation Script             ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    # Prerequisites check
    log_info "Checking prerequisites..."
    check_git
    check_java
    check_maven
    echo ""

    # Install/update
    install_cli
    echo ""

    # Setup
    set_permissions
    echo ""

    setup_path
    echo ""

    create_alias_helper

    # Show usage
    show_usage_info

    log_success "Installation complete!"
}

# Run main installation
main "$@"
