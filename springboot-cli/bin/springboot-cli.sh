#!/bin/bash

# Spring Boot Standardization CLI
# Main entry point for the CLI tool

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_ROOT="$(dirname "$SCRIPT_DIR")"
COMMANDS_DIR="$SCRIPT_DIR/commands"
TEMPLATES_DIR="$CLI_ROOT/templates"
GENERATORS_DIR="$CLI_ROOT/generators"
CONFIG_DIR="$CLI_ROOT/config"

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

# Show usage
show_usage() {
    cat << EOF
Spring Boot Standardization CLI

Usage: springboot-cli.sh <command> [options]

Commands:
    init                Initialize a new Spring Boot project
    add                 Add components to an existing project
        usecase         Add a new use case
        entity          Add a new domain entity
        repository      Add a new repository
        client          Add an external client
        camel-route     Add a Camel route
    generate            Generate code from specifications
        openapi         Generate from OpenAPI spec
        contracts       Generate contract tests
    validate            Validate project structure
        architecture    Validate clean architecture rules
        coverage        Validate test coverage
        openapi         Validate OpenAPI specification
    assess              Assess project needs
        camel           Assess need for Camel integration
    help                Show this help message

Examples:
    # Initialize new project
    springboot-cli.sh init --name my-service --package com.company.myservice --database mssql

    # Add a use case
    springboot-cli.sh add usecase --name ProcessOrder --aggregate Order

    # Validate architecture
    springboot-cli.sh validate architecture

For detailed help on a command, run:
    springboot-cli.sh <command> --help
EOF
}

# Check if command exists
check_command() {
    local cmd=$1
    local subcmd=$2

    if [ -z "$subcmd" ]; then
        if [ -f "$COMMANDS_DIR/${cmd}.sh" ]; then
            return 0
        fi
    else
        if [ -f "$COMMANDS_DIR/${cmd}-${subcmd}.sh" ]; then
            return 0
        fi
    fi

    return 1
}

# Execute command
execute_command() {
    local cmd=$1
    shift

    local script_path="$COMMANDS_DIR/${cmd}.sh"

    if [ -f "$script_path" ]; then
        # Export environment variables for commands
        export CLI_ROOT
        export TEMPLATES_DIR
        export GENERATORS_DIR
        export CONFIG_DIR

        # Execute the command
        bash "$script_path" "$@"
    else
        log_error "Command script not found: $script_path"
        exit 1
    fi
}

# Main execution
main() {
    # Check if no arguments provided
    if [ $# -eq 0 ]; then
        show_usage
        exit 0
    fi

    # Parse main command
    COMMAND=$1
    shift

    case $COMMAND in
        init)
            execute_command "init" "$@"
            ;;
        add)
            if [ $# -eq 0 ]; then
                log_error "Add command requires a subcommand (usecase, entity, repository, client, camel-route)"
                exit 1
            fi
            SUBCOMMAND=$1
            shift
            case $SUBCOMMAND in
                usecase|entity|repository|client|camel-route)
                    execute_command "add-${SUBCOMMAND}" "$@"
                    ;;
                *)
                    log_error "Unknown add subcommand: $SUBCOMMAND"
                    log_info "Valid subcommands: usecase, entity, repository, client, camel-route"
                    exit 1
                    ;;
            esac
            ;;
        generate)
            if [ $# -eq 0 ]; then
                log_error "Generate command requires a subcommand (openapi, contracts)"
                exit 1
            fi
            SUBCOMMAND=$1
            shift
            case $SUBCOMMAND in
                openapi|contracts)
                    execute_command "generate-${SUBCOMMAND}" "$@"
                    ;;
                *)
                    log_error "Unknown generate subcommand: $SUBCOMMAND"
                    log_info "Valid subcommands: openapi, contracts"
                    exit 1
                    ;;
            esac
            ;;
        validate)
            if [ $# -eq 0 ]; then
                log_error "Validate command requires a subcommand (architecture, coverage, openapi)"
                exit 1
            fi
            SUBCOMMAND=$1
            shift
            case $SUBCOMMAND in
                architecture|coverage|openapi)
                    execute_command "validate-${SUBCOMMAND}" "$@"
                    ;;
                *)
                    log_error "Unknown validate subcommand: $SUBCOMMAND"
                    log_info "Valid subcommands: architecture, coverage, openapi"
                    exit 1
                    ;;
            esac
            ;;
        assess)
            if [ $# -eq 0 ]; then
                log_error "Assess command requires a subcommand (camel)"
                exit 1
            fi
            SUBCOMMAND=$1
            shift
            case $SUBCOMMAND in
                camel)
                    execute_command "assess-${SUBCOMMAND}" "$@"
                    ;;
                *)
                    log_error "Unknown assess subcommand: $SUBCOMMAND"
                    log_info "Valid subcommands: camel"
                    exit 1
                    ;;
            esac
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown command: $COMMAND"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"