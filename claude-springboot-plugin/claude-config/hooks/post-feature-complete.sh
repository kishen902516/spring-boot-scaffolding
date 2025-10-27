#!/bin/bash

# Post-Feature-Complete Hook
# Runs comprehensive test suite after feature implementation
# This hook ensures all quality gates are met before PR creation

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "🔍 POST-FEATURE VALIDATION SUITE"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Get Spring Boot CLI path
SPRINGBOOT_CLI_PATH="${SPRINGBOOT_CLI_PATH:-/home/kishen90/java/springboot-cli}"
PROJECT_ROOT="$(pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

# Track overall status
OVERALL_STATUS=0

echo "📍 Project: ${PROJECT_ROOT}"
echo "📍 Spring Boot CLI: ${SPRINGBOOT_CLI_PATH}"
echo ""

# 1. Unit Tests
echo "═══════════════════════════════════════════════════════════════"
echo "🧪 RUNNING UNIT TESTS"
echo "═══════════════════════════════════════════════════════════════"
if mvn test -Dtest="*Test" -DexcludedGroups="integration,e2e" > /tmp/unit-test.log 2>&1; then
    print_status 0 "Unit tests passed"
    echo "   $(grep -E "Tests run:" /tmp/unit-test.log | tail -1)"
else
    print_status 1 "Unit tests failed"
    echo "   See /tmp/unit-test.log for details"
    OVERALL_STATUS=1
fi
echo ""

# 2. Integration Tests
echo "═══════════════════════════════════════════════════════════════"
echo "🔗 RUNNING INTEGRATION TESTS"
echo "═══════════════════════════════════════════════════════════════"
if mvn test -Dtest="*IntegrationTest" > /tmp/integration-test.log 2>&1; then
    print_status 0 "Integration tests passed"
    echo "   $(grep -E "Tests run:" /tmp/integration-test.log | tail -1)"
else
    print_status 1 "Integration tests failed"
    echo "   See /tmp/integration-test.log for details"
    OVERALL_STATUS=1
fi
echo ""

# 3. Architecture Tests
echo "═══════════════════════════════════════════════════════════════"
echo "🏗️ RUNNING ARCHITECTURE TESTS"
echo "═══════════════════════════════════════════════════════════════"
if mvn test -Dtest="*ArchitectureTest" > /tmp/architecture-test.log 2>&1; then
    print_status 0 "Architecture tests passed"
    echo "   ✓ Clean Architecture verified"
    echo "   ✓ CQRS separation maintained"
    echo "   ✓ Domain layer pure"
else
    print_status 1 "Architecture violations detected"
    echo "   See /tmp/architecture-test.log for violations"
    OVERALL_STATUS=1
fi
echo ""

# 4. Code Coverage
echo "═══════════════════════════════════════════════════════════════"
echo "📊 CHECKING CODE COVERAGE"
echo "═══════════════════════════════════════════════════════════════"
mvn jacoco:report > /tmp/coverage.log 2>&1

if [ -f target/site/jacoco/index.html ]; then
    # Extract coverage percentage
    COVERAGE=$(grep -oP 'Total[^%]*\K[0-9]+' target/site/jacoco/index.html | head -1)

    if [ -z "$COVERAGE" ]; then
        COVERAGE=0
    fi

    echo "   Overall Coverage: ${COVERAGE}%"

    if [ "$COVERAGE" -ge 80 ]; then
        print_status 0 "Coverage meets minimum (80%)"
    else
        print_status 1 "Coverage below minimum (80%)"
        echo -e "${YELLOW}   Warning: Coverage is ${COVERAGE}%, should be at least 80%${NC}"
        OVERALL_STATUS=1
    fi
else
    echo -e "${YELLOW}⚠️  Could not generate coverage report${NC}"
fi
echo ""

# 5. Style Check
echo "═══════════════════════════════════════════════════════════════"
echo "🎨 RUNNING STYLE CHECKS"
echo "═══════════════════════════════════════════════════════════════"
if mvn checkstyle:check > /tmp/checkstyle.log 2>&1; then
    print_status 0 "Checkstyle passed"
else
    print_status 1 "Checkstyle violations found"
    echo "   See /tmp/checkstyle.log for details"
    OVERALL_STATUS=1
fi
echo ""

# 6. Spring Boot CLI Validation
echo "═══════════════════════════════════════════════════════════════"
echo "🔧 RUNNING SPRING BOOT CLI VALIDATION"
echo "═══════════════════════════════════════════════════════════════"
if [ -x "${SPRINGBOOT_CLI_PATH}/bin/springboot-cli.sh" ]; then
    # Run architecture validation
    if ${SPRINGBOOT_CLI_PATH}/bin/springboot-cli.sh validate architecture > /tmp/cli-validation.log 2>&1; then
        print_status 0 "CLI architecture validation passed"
    else
        print_status 1 "CLI architecture validation failed"
        echo "   See /tmp/cli-validation.log for details"
        OVERALL_STATUS=1
    fi
else
    echo -e "${YELLOW}⚠️  Spring Boot CLI not found at ${SPRINGBOOT_CLI_PATH}${NC}"
fi
echo ""

# 7. Test Pyramid Distribution
echo "═══════════════════════════════════════════════════════════════"
echo "📐 VALIDATING TEST PYRAMID"
echo "═══════════════════════════════════════════════════════════════"

# Count test files
UNIT_TESTS=$(find src/test -name "*Test.java" -not -name "*IntegrationTest.java" -not -name "*E2ETest.java" | wc -l)
INTEGRATION_TESTS=$(find src/test -name "*IntegrationTest.java" | wc -l)
E2E_TESTS=$(find src/test -name "*E2ETest.java" | wc -l)
TOTAL_TESTS=$((UNIT_TESTS + INTEGRATION_TESTS + E2E_TESTS))

if [ $TOTAL_TESTS -gt 0 ]; then
    UNIT_PERCENT=$((UNIT_TESTS * 100 / TOTAL_TESTS))
    INTEGRATION_PERCENT=$((INTEGRATION_TESTS * 100 / TOTAL_TESTS))
    E2E_PERCENT=$((E2E_TESTS * 100 / TOTAL_TESTS))

    echo "   Unit Tests:        ${UNIT_TESTS} (${UNIT_PERCENT}%)"
    echo "   Integration Tests: ${INTEGRATION_TESTS} (${INTEGRATION_PERCENT}%)"
    echo "   E2E Tests:        ${E2E_TESTS} (${E2E_PERCENT}%)"

    if [ $UNIT_PERCENT -ge 60 ]; then
        print_status 0 "Test pyramid distribution acceptable"
    else
        print_status 1 "Test pyramid inverted (too few unit tests)"
        echo -e "${YELLOW}   Target: 75% unit, 20% integration, 5% E2E${NC}"
        OVERALL_STATUS=1
    fi
else
    echo -e "${YELLOW}⚠️  No tests found${NC}"
fi
echo ""

# 8. Security Check (if OWASP dependency check is configured)
echo "═══════════════════════════════════════════════════════════════"
echo "🔒 RUNNING SECURITY CHECKS"
echo "═══════════════════════════════════════════════════════════════"
if mvn dependency-check:check > /tmp/security.log 2>&1; then
    print_status 0 "No security vulnerabilities found"
else
    echo -e "${YELLOW}⚠️  Security check not configured or failed${NC}"
    echo "   Consider adding OWASP Dependency Check"
fi
echo ""

# 9. Final Summary
echo "═══════════════════════════════════════════════════════════════"
echo "📋 VALIDATION SUMMARY"
echo "═══════════════════════════════════════════════════════════════"

if [ $OVERALL_STATUS -eq 0 ]; then
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║           ✅ ALL VALIDATIONS PASSED! ✅               ║"
    echo "║                                                        ║"
    echo "║   Your feature is ready for Pull Request creation     ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
else
    echo -e "${RED}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║           ❌ VALIDATION FAILURES DETECTED ❌          ║"
    echo "║                                                        ║"
    echo "║   Please fix the issues before creating a PR          ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo "📝 Review the following logs for details:"
    echo "   - Unit tests:        /tmp/unit-test.log"
    echo "   - Integration tests: /tmp/integration-test.log"
    echo "   - Architecture:      /tmp/architecture-test.log"
    echo "   - Coverage:          target/site/jacoco/index.html"
    echo "   - Checkstyle:        /tmp/checkstyle.log"
fi

exit $OVERALL_STATUS