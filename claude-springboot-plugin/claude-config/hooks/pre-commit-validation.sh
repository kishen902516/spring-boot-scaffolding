#!/bin/bash

# Pre-Commit Validation Hook
# Runs quick validations before allowing commits
# Focuses on fast checks to maintain development flow

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "🔍 PRE-COMMIT VALIDATION"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SPRINGBOOT_CLI_PATH="${SPRINGBOOT_CLI_PATH:-/home/kishen90/java/springboot-cli}"

# Track validation status
VALIDATION_PASSED=true

# Function to check status
check_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        VALIDATION_PASSED=false
    fi
}

# 1. Check for compilation errors
echo "🔨 Checking compilation..."
if mvn compile -q > /dev/null 2>&1; then
    check_status 0 "Code compiles successfully"
else
    check_status 1 "Compilation failed"
    echo "   Run: mvn compile"
fi

# 2. Run fast unit tests (with timeout)
echo "🧪 Running fast unit tests..."
timeout 30s mvn test -Dtest="*Test" -DexcludedGroups="integration,slow,e2e" -q > /dev/null 2>&1
check_status $? "Fast unit tests passed"

# 3. Check for TODO/FIXME comments
echo "📝 Checking for unresolved TODOs..."
TODO_COUNT=$(grep -r "TODO\|FIXME" --include="*.java" src/main/java 2>/dev/null | wc -l || echo 0)
if [ "$TODO_COUNT" -eq 0 ]; then
    check_status 0 "No unresolved TODOs"
else
    echo -e "${YELLOW}⚠️  Found $TODO_COUNT TODO/FIXME comments${NC}"
fi

# 4. Architecture quick check
echo "🏗️ Quick architecture validation..."
if mvn test -Dtest="*ArchitectureTest" -q > /dev/null 2>&1; then
    check_status 0 "Architecture rules followed"
else
    check_status 1 "Architecture violations detected"
fi

# 5. Check for sensitive data
echo "🔒 Checking for sensitive data..."
SENSITIVE_PATTERNS="password=|api[_-]?key=|secret=|token=|private[_-]?key"
if grep -r -i -E "$SENSITIVE_PATTERNS" --include="*.java" --include="*.properties" --include="*.yml" --include="*.yaml" src/ 2>/dev/null | grep -v -E "password=\{|secret=\$|token=\$"; then
    check_status 1 "Possible sensitive data found"
    echo -e "${RED}   Remove hardcoded credentials!${NC}"
else
    check_status 0 "No hardcoded secrets detected"
fi

# 6. Check Java 21 features usage
echo "☕ Checking Java 21 patterns..."
RECORD_COUNT=$(find src/main/java -name "*.java" -exec grep -l "record " {} \; | wc -l)
if [ "$RECORD_COUNT" -gt 0 ]; then
    check_status 0 "Using Java 21 records ($RECORD_COUNT found)"
else
    echo -e "${YELLOW}⚠️  Consider using records for DTOs${NC}"
fi

# Final status
echo ""
if [ "$VALIDATION_PASSED" = true ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           ✅ PRE-COMMIT VALIDATION PASSED             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║           ❌ PRE-COMMIT VALIDATION FAILED             ║${NC}"
    echo -e "${RED}║                                                        ║${NC}"
    echo -e "${RED}║   Fix the issues above before committing              ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi