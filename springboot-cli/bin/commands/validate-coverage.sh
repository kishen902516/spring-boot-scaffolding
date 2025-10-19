#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
Usage: ./springboot-cli.sh validate coverage [OPTIONS]

Validate test coverage using JaCoCo and mutation testing with PIT

Options:
    --threshold PCT     Minimum coverage threshold (default: 80)
    --mutation          Run mutation testing with PIT (optional)
    --help              Show this help message

Examples:
    # Validate with default 80% threshold
    ./springboot-cli.sh validate coverage

    # Validate with custom threshold
    ./springboot-cli.sh validate coverage --threshold 90

    # Include mutation testing
    ./springboot-cli.sh validate coverage --mutation

EOF
    exit 1
}

THRESHOLD=80
RUN_MUTATION=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --threshold)
            THRESHOLD="$2"
            shift 2
            ;;
        --mutation)
            RUN_MUTATION=true
            shift
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

if [ ! -f "pom.xml" ]; then
    print_error "Not in a Spring Boot project directory (pom.xml not found)"
    exit 1
fi

print_info "Running test coverage analysis..."
print_info "Coverage threshold: ${THRESHOLD}%"

# Run tests with coverage
mvn clean test jacoco:report

if [ $? -ne 0 ]; then
    print_error "Tests failed"
    exit 1
fi

print_success "Tests completed successfully"

# Check if JaCoCo report exists
JACOCO_REPORT="target/site/jacoco/index.html"
if [ ! -f "$JACOCO_REPORT" ]; then
    print_error "JaCoCo report not found. Ensure jacoco-maven-plugin is configured."
    exit 1
fi

print_success "Coverage report generated: $JACOCO_REPORT"

# Parse coverage from JaCoCo CSV
JACOCO_CSV="target/site/jacoco/jacoco.csv"
if [ -f "$JACOCO_CSV" ]; then
    COVERAGE=$(awk -F',' 'NR>1 {missed+=$4; covered+=$5} END {if(missed+covered>0) print int(covered/(missed+covered)*100)}' "$JACOCO_CSV")

    echo ""
    print_info "Coverage: ${COVERAGE}%"

    if [ "$COVERAGE" -lt "$THRESHOLD" ]; then
        print_error "Coverage ${COVERAGE}% is below threshold ${THRESHOLD}%"
        exit 1
    else
        print_success "Coverage meets threshold"
    fi
fi

# Run mutation testing if requested
if [ "$RUN_MUTATION" = true ]; then
    print_info "Running mutation testing with PIT..."

    mvn test-compile org.pitest:pitest-maven:mutationCoverage

    if [ $? -eq 0 ]; then
        print_success "Mutation testing complete"
        print_info "Report: target/pit-reports/index.html"
    else
        print_error "Mutation testing failed"
        exit 1
    fi
fi

print_success "Coverage validation complete!"
