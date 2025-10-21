#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

show_usage() {
    cat << EOF
Usage: ./springboot-cli.sh generate contract [OPTIONS]

Generate Pact contract tests

Options:
    --provider NAME     Generate provider tests for service NAME
    --consumer NAME     Generate consumer tests for service NAME
    --help              Show this help message

Examples:
    # Generate provider tests
    ./springboot-cli.sh generate contract --provider

    # Generate consumer tests for PaymentService
    ./springboot-cli.sh generate contract --consumer PaymentService

EOF
    exit 1
}

MODE=""
SERVICE_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --provider)
            MODE="provider"
            shift
            ;;
        --consumer)
            MODE="consumer"
            SERVICE_NAME="$2"
            shift 2
            ;;
        --help)
            show_usage
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            ;;
    esac
done

if [ -z "$MODE" ]; then
    print_error "Must specify either --provider or --consumer"
    show_usage
fi

if [ ! -f "pom.xml" ]; then
    print_error "Not in a Spring Boot project directory (pom.xml not found)"
    exit 1
fi

# Extract package from pom.xml (get project groupId, not parent groupId)
PACKAGE=$(grep "<groupId>" pom.xml | sed -n '2p' | sed 's/.*<groupId>\(.*\)<\/groupId>.*/\1/' | xargs)

print_info "Generating ${MODE} contract tests..."

CLI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [ "$MODE" = "provider" ]; then
    TEST_DIR="src/test/java/$(echo $PACKAGE | tr '.' '/')/contract/provider"
    mkdir -p "$TEST_DIR"

    TEMPLATE="$CLI_DIR/templates/tests/contract/ProviderContractTest.java.tmpl"
    OUTPUT="$TEST_DIR/ProviderContractTest.java"

    cp "$TEMPLATE" "$OUTPUT"
    sed -i "s/\${PACKAGE}/$PACKAGE/g" "$OUTPUT"

    print_success "Provider contract test created: $OUTPUT"
else
    if [ -z "$SERVICE_NAME" ]; then
        print_error "Consumer service name is required"
        show_usage
    fi

    TEST_DIR="src/test/java/$(echo $PACKAGE | tr '.' '/')/contract/consumer"
    mkdir -p "$TEST_DIR"

    TEMPLATE="$CLI_DIR/templates/tests/contract/ConsumerContractTest.java.tmpl"
    OUTPUT="$TEST_DIR/${SERVICE_NAME}ConsumerContractTest.java"

    cp "$TEMPLATE" "$OUTPUT"
    sed -i "s/\${PACKAGE}/$PACKAGE/g" "$OUTPUT"
    sed -i "s/\${EXTERNAL_SERVICE_NAME}/$SERVICE_NAME/g" "$OUTPUT"

    print_success "Consumer contract test created: $OUTPUT"
fi

print_info "Next steps:"
echo "  1. Add Pact dependencies to pom.xml"
echo "  2. Implement the contract test"
echo "  3. Run tests to generate/verify contracts"
