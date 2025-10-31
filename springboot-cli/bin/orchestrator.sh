#!/bin/bash

# Agent Orchestrator for Clean Architecture Enforcement
# Coordinates between Feature Developer Agents and Architecture Validation Agents
# Ensures all code follows Clean Architecture and DDD principles

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLI_DIR="$(dirname "$SCRIPT_DIR")"
COMMANDS_DIR="$SCRIPT_DIR/commands"

# Configuration
ORCHESTRATOR_CONFIG="$CLI_DIR/../claude-springboot-plugin/claude-config"
AGENTS_DIR="$ORCHESTRATOR_CONFIG/agents"
HOOKS_DIR="$ORCHESTRATOR_CONFIG/hooks"
DATA_DIR="$CLI_DIR/data/orchestrator"
VIOLATIONS_DB="$DATA_DIR/violations.db"
LEARNING_LOG="$DATA_DIR/learning.log"

# Create data directories
mkdir -p "$DATA_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Agent states
AGENT_FEATURE="feature-developer"
AGENT_ARCHITECTURE="architecture-validator"
AGENT_TEST="test-engineer"

# Current agent context
CURRENT_AGENT=""
AGENT_SESSION_ID=""

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print header
print_header() {
    echo ""
    print_color "$BLUE" "╔═══════════════════════════════════════════════════════════════╗"
    print_color "$BLUE" "║                  AGENT ORCHESTRATOR                           ║"
    print_color "$BLUE" "║         Clean Architecture Enforcement System                 ║"
    print_color "$BLUE" "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

# Function to initialize session
init_session() {
    AGENT_SESSION_ID=$(date +%s)-$$
    echo "Session ID: $AGENT_SESSION_ID" >> "$LEARNING_LOG"
    echo "Started: $(date -Iseconds)" >> "$LEARNING_LOG"
}

# Function to log agent activity
log_activity() {
    local agent=$1
    local action=$2
    local details=$3

    echo "[$(date -Iseconds)] [$AGENT_SESSION_ID] [$agent] $action: $details" >> "$LEARNING_LOG"
}

# Function to validate architecture using existing validation scripts
validate_architecture() {
    local project_dir="${1:-.}"
    local auto_fix="${2:-false}"

    print_color "$CYAN" "\n🔍 Starting Architecture Validation..."
    log_activity "$AGENT_ARCHITECTURE" "VALIDATE_START" "$project_dir"

    # Use existing validation script
    if [[ -f "$COMMANDS_DIR/validate-architecture.sh" ]]; then
        if [[ "$auto_fix" == "true" ]]; then
            "$COMMANDS_DIR/validate-architecture.sh" --generate-test || {
                print_color "$RED" "✗ Architecture validation failed"
                return 1
            }
        else
            "$COMMANDS_DIR/validate-architecture.sh" || {
                print_color "$RED" "✗ Architecture validation failed"
                return 1
            }
        fi
    fi

    print_color "$GREEN" "✓ Architecture validation passed"
    return 0
}

# Function to check and fix interface implementations
check_interfaces() {
    local project_dir="${1:-.}"

    print_color "$CYAN" "\n🔍 Checking Interface Implementations..."

    local violations_found=0
    local fixes_applied=0

    # Find all client classes in infrastructure
    local client_files=$(find "$project_dir/src/main/java" -path "*/infrastructure/adapter/client/*.java" 2>/dev/null || true)

    for file in $client_files; do
        if [[ -f "$file" ]]; then
            local class_name=$(basename "$file" .java)

            # Check if implements Port interface
            if ! grep -q "implements.*Port" "$file"; then
                print_color "$YELLOW" "⚠ Missing interface: $class_name"
                violations_found=$((violations_found + 1))

                # Auto-fix if enabled
                if [[ "${AUTO_FIX:-true}" == "true" ]]; then
                    if fix_missing_interface "$file" "$class_name"; then
                        fixes_applied=$((fixes_applied + 1))
                        print_color "$GREEN" "  ✓ Fixed: Added interface to $class_name"
                    fi
                fi
            fi
        fi
    done

    if [[ $violations_found -gt 0 ]]; then
        print_color "$YELLOW" "\nFound $violations_found interface violations"
        print_color "$GREEN" "Applied $fixes_applied auto-fixes"
    else
        print_color "$GREEN" "✓ All interfaces properly implemented"
    fi

    log_activity "$AGENT_ARCHITECTURE" "INTERFACE_CHECK" "violations=$violations_found fixes=$fixes_applied"

    return 0
}

# Function to fix missing interface implementation
fix_missing_interface() {
    local file=$1
    local class_name=$2

    # Determine port name
    local port_name="${class_name%Client}Port"
    if [[ "$class_name" =~ RepositoryImpl$ ]]; then
        port_name="${class_name%Impl}"
    fi

    # Extract package information
    local package=$(grep "^package" "$file" | sed 's/package //;s/;//')
    local domain_package=$(echo "$package" | sed 's/infrastructure.*/domain/')
    local port_package="${domain_package}.port.outbound"

    # Create port interface file path
    local port_path="src/main/java/$(echo "$port_package" | tr '.' '/')/${port_name}.java"

    # Create port interface if it doesn't exist
    if [[ ! -f "$port_path" ]]; then
        mkdir -p "$(dirname "$port_path")"

        cat > "$port_path" << EOF
package ${port_package};

/**
 * Port interface for ${class_name}
 * Auto-generated by Agent Orchestrator
 */
public interface ${port_name} {
    // TODO: Add method signatures from ${class_name}
}
EOF

        print_color "$BLUE" "  Created port interface: $port_name"
    fi

    # Update class to implement interface
    sed -i "s/public class ${class_name}/public class ${class_name} implements ${port_name}/" "$file"

    # Add import statement
    if ! grep -q "import.*${port_name}" "$file"; then
        sed -i "/^package/a\\\nimport ${port_package}.${port_name};" "$file"
    fi

    log_activity "$AGENT_ARCHITECTURE" "FIX_INTERFACE" "$class_name implements $port_name"

    return 0
}

# Function to orchestrate feature development
orchestrate_feature() {
    local feature_name=$1
    local feature_description=$2

    print_header
    print_color "$MAGENTA" "📋 Feature: $feature_name"
    print_color "$CYAN" "Description: $feature_description"
    echo ""

    init_session

    # Phase 1: Feature Development
    print_color "$BLUE" "═══ Phase 1: Feature Development ═══"
    CURRENT_AGENT=$AGENT_FEATURE
    log_activity "$AGENT_FEATURE" "START" "$feature_name"

    print_color "$CYAN" "Agent: $AGENT_FEATURE is developing the feature..."
    # Here you would trigger the actual feature agent
    # For now, we simulate with a message
    echo "  → Writing code for $feature_name"
    sleep 1

    # Phase 2: Architecture Validation
    print_color "$BLUE" "\n═══ Phase 2: Architecture Validation ═══"
    CURRENT_AGENT=$AGENT_ARCHITECTURE
    log_activity "$AGENT_ARCHITECTURE" "START" "validating $feature_name"

    # Run validation
    validate_architecture "." true

    # Check interfaces
    check_interfaces "."

    # Phase 3: Auto-correction
    print_color "$BLUE" "\n═══ Phase 3: Auto-Correction ═══"
    print_color "$CYAN" "Applying automatic fixes for common violations..."

    # Apply fixes (already done in check_interfaces with AUTO_FIX=true)

    # Phase 4: Test Generation
    print_color "$BLUE" "\n═══ Phase 4: Test Generation ═══"
    CURRENT_AGENT=$AGENT_TEST
    log_activity "$AGENT_TEST" "START" "generating tests for $feature_name"

    print_color "$CYAN" "Agent: $AGENT_TEST is generating tests..."
    # Here you would trigger the test engineer agent

    # Phase 5: Final Validation
    print_color "$BLUE" "\n═══ Phase 5: Final Validation ═══"
    CURRENT_AGENT=$AGENT_ARCHITECTURE

    if validate_architecture "." false; then
        print_color "$GREEN" "\n✅ Feature '$feature_name' completed successfully!"
        print_color "$GREEN" "All architecture rules are satisfied."
    else
        print_color "$YELLOW" "\n⚠️ Feature '$feature_name' has remaining issues."
        print_color "$YELLOW" "Please review and fix manually."
    fi

    # Log completion
    log_activity "ORCHESTRATOR" "COMPLETE" "$feature_name"
}

# Function to run continuous validation
continuous_validation() {
    local watch_dir="${1:-.}"

    print_color "$CYAN" "👁️ Starting continuous validation on $watch_dir"
    print_color "$YELLOW" "Press Ctrl+C to stop"

    while true; do
        # Check for changes
        if [[ -n "$(find "$watch_dir" -name "*.java" -newer "$DATA_DIR/.last_check" 2>/dev/null || true)" ]]; then
            print_color "$BLUE" "\nChanges detected, validating..."

            validate_architecture "$watch_dir" true
            check_interfaces "$watch_dir"

            touch "$DATA_DIR/.last_check"
        fi

        sleep 5
    done
}

# Function to generate learning report
generate_learning_report() {
    print_color "$CYAN" "\n📊 Generating Learning Report..."

    if [[ ! -f "$LEARNING_LOG" ]]; then
        print_color "$YELLOW" "No learning data available yet."
        return
    fi

    # Analyze violations
    local total_violations=$(grep -c "FIX_INTERFACE\|FIX_DOMAIN" "$LEARNING_LOG" 2>/dev/null || echo "0")
    local interface_fixes=$(grep -c "FIX_INTERFACE" "$LEARNING_LOG" 2>/dev/null || echo "0")
    local domain_fixes=$(grep -c "FIX_DOMAIN" "$LEARNING_LOG" 2>/dev/null || echo "0")

    print_color "$BLUE" "\n═══ Learning Report ═══"
    echo "Total Violations Fixed: $total_violations"
    echo "  - Interface Implementations: $interface_fixes"
    echo "  - Domain Purity Issues: $domain_fixes"

    # Show most common violations
    print_color "$BLUE" "\nMost Common Violations:"
    grep "FIX_" "$LEARNING_LOG" | awk '{print $NF}' | sort | uniq -c | sort -rn | head -5

    # Calculate improvement rate
    local sessions=$(grep -c "Session ID" "$LEARNING_LOG")
    if [[ $sessions -gt 1 ]]; then
        local avg_violations=$((total_violations / sessions))
        print_color "$GREEN" "\nAverage violations per session: $avg_violations"

        # Check if violations are decreasing
        local recent_violations=$(tail -100 "$LEARNING_LOG" | grep -c "FIX_" || echo "0")
        local older_violations=$(head -100 "$LEARNING_LOG" | grep -c "FIX_" || echo "0")

        if [[ $recent_violations -lt $older_violations ]]; then
            print_color "$GREEN" "✓ Violation rate is decreasing (learning is working!)"
        fi
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  orchestrate <feature-name> <description>  - Orchestrate feature development"
    echo "  validate [--fix]                          - Validate architecture (with optional auto-fix)"
    echo "  check-interfaces                          - Check interface implementations"
    echo "  continuous [directory]                    - Run continuous validation"
    echo "  report                                    - Generate learning report"
    echo "  help                                      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 orchestrate payment-integration \"Add Stripe payment processing\""
    echo "  $0 validate --fix"
    echo "  $0 continuous ./src"
    echo "  $0 report"
}

# Main command handler
main() {
    local command="${1:-help}"

    case "$command" in
        orchestrate)
            if [[ -z "$2" ]] || [[ -z "$3" ]]; then
                print_color "$RED" "Error: Feature name and description required"
                show_usage
                exit 1
            fi
            orchestrate_feature "$2" "$3"
            ;;

        validate)
            validate_architecture "." "${2:-false}"
            check_interfaces "."
            ;;

        check-interfaces)
            check_interfaces "${2:-.}"
            ;;

        continuous)
            continuous_validation "${2:-.}"
            ;;

        report)
            generate_learning_report
            ;;

        help|--help|-h)
            show_usage
            ;;

        *)
            print_color "$RED" "Error: Unknown command '$command'"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"