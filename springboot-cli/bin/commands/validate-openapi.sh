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
Usage: ./springboot-cli.sh validate openapi [OPTIONS]

Validate OpenAPI specification

Options:
    --spec PATH     Path to OpenAPI specification file (required)
    --help          Show this help message

Examples:
    ./springboot-cli.sh validate openapi --spec openapi/api-spec.yaml

EOF
    exit 1
}

SPEC_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --spec)
            SPEC_PATH="$2"
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

if [ -z "$SPEC_PATH" ]; then
    print_error "OpenAPI specification path is required"
    show_usage
fi

if [ ! -f "$SPEC_PATH" ]; then
    print_error "OpenAPI specification file not found: $SPEC_PATH"
    exit 1
fi

print_info "Validating OpenAPI specification: $SPEC_PATH"

# Check if openapi-generator-cli is available
if ! command -v openapi-generator-cli &> /dev/null; then
    print_error "OpenAPI Generator CLI not found"
    print_info "Install with: npm install -g @openapitools/openapi-generator-cli"
    exit 1
fi

# Validate the spec
openapi-generator-cli validate -i "$SPEC_PATH"

if [ $? -eq 0 ]; then
    print_success "OpenAPI specification is valid"
else
    print_error "OpenAPI specification validation failed"
    exit 1
fi
