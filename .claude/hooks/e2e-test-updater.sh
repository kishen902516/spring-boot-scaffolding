#!/bin/bash

# E2E Test Updater Hook
# Analyzes new features and updates E2E test scenarios
# Runs after feature implementation to ensure E2E coverage

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "🔄 E2E TEST UPDATER"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Configuration
SPRINGBOOT_CLI_PATH="${SPRINGBOOT_CLI_PATH:-/home/kishen90/java/springboot-cli}"
PROJECT_ROOT="$(pwd)"
E2E_TEST_DIR="src/test/java/e2e"
OPENAPI_SPEC="src/main/resources/openapi.yaml"
PREVIOUS_SPEC=".e2e-updater/previous-openapi.yaml"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create tracking directory
mkdir -p .e2e-updater

echo "📍 Analyzing API changes..."
echo ""

# Function to extract endpoints from OpenAPI spec
extract_endpoints() {
    if [ -f "$1" ]; then
        grep -E "^\s+(\/[^:]+):$|^\s+(get|post|put|delete|patch):" "$1" | \
        awk '/^[[:space:]]+\// {endpoint=$1} /^[[:space:]]+(get|post|put|delete|patch):/ {print endpoint " " $1}' | \
        sed 's/:$//' | sort | uniq
    fi
}

# Check if OpenAPI spec exists
if [ ! -f "$OPENAPI_SPEC" ]; then
    echo -e "${YELLOW}⚠️  OpenAPI spec not found at $OPENAPI_SPEC${NC}"
    echo "   Skipping E2E test generation"
    exit 0
fi

# Extract current endpoints
CURRENT_ENDPOINTS=$(extract_endpoints "$OPENAPI_SPEC")

# Compare with previous version
if [ -f "$PREVIOUS_SPEC" ]; then
    PREVIOUS_ENDPOINTS=$(extract_endpoints "$PREVIOUS_SPEC")

    # Find new endpoints
    NEW_ENDPOINTS=$(comm -13 <(echo "$PREVIOUS_ENDPOINTS") <(echo "$CURRENT_ENDPOINTS"))

    if [ -z "$NEW_ENDPOINTS" ]; then
        echo -e "${GREEN}✅ No new endpoints detected${NC}"
        echo "   E2E tests are up to date"
        cp "$OPENAPI_SPEC" "$PREVIOUS_SPEC"
        exit 0
    fi

    echo -e "${BLUE}📝 New endpoints detected:${NC}"
    echo "$NEW_ENDPOINTS" | while IFS= read -r endpoint; do
        echo "   - $endpoint"
    done
    echo ""
else
    echo "   First run - establishing baseline"
    NEW_ENDPOINTS="$CURRENT_ENDPOINTS"
fi

# Create E2E test directory if it doesn't exist
mkdir -p "$E2E_TEST_DIR"

# Generate E2E test scenarios for new endpoints
echo "═══════════════════════════════════════════════════════════════"
echo "🧪 GENERATING E2E TEST SCENARIOS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Parse endpoints and generate test scenarios
echo "$NEW_ENDPOINTS" | while IFS=' ' read -r path method; do
    if [ -z "$path" ] || [ -z "$method" ]; then
        continue
    fi

    # Clean path for test name
    TEST_NAME=$(echo "$path" | sed 's/[{}]//g' | sed 's/\///g' | sed 's/-/_/g')
    METHOD_UPPER=$(echo "$method" | tr '[:lower:]' '[:upper:]')

    echo "Generating E2E test for: $METHOD_UPPER $path"

    # Determine entity from path
    ENTITY=$(echo "$path" | grep -oE '/([a-z]+)' | head -1 | sed 's/\///')

    # Generate E2E test file
    TEST_FILE="$E2E_TEST_DIR/${ENTITY^}E2ETest.java"

    # Check if test file exists, if not create it
    if [ ! -f "$TEST_FILE" ]; then
        cat > "$TEST_FILE" << 'EOF'
package e2e;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.testcontainers.junit.jupiter.Testcontainers;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
public class ENTITY_E2ETest {

    @LocalServerPort
    private int port;

    @BeforeEach
    void setUp() {
        RestAssured.port = port;
        RestAssured.basePath = "/api/v1";
    }

    // E2E test scenarios will be added here
}
EOF
        # Replace ENTITY placeholder
        sed -i "s/ENTITY_/${ENTITY^}/g" "$TEST_FILE"
    fi

    # Add test method for the endpoint (append to existing file)
    echo "" >> "$TEST_FILE.tmp"
    echo "    @Test" >> "$TEST_FILE.tmp"
    echo "    @DisplayName(\"E2E: $METHOD_UPPER $path\")" >> "$TEST_FILE.tmp"
    echo "    void should_${method}_${TEST_NAME}() {" >> "$TEST_FILE.tmp"

    case "$method" in
        "get")
            cat >> "$TEST_FILE.tmp" << EOF
        given()
            .contentType(ContentType.JSON)
        .when()
            .get("$path")
        .then()
            .statusCode(200)
            .body("data", is(notNullValue()));
EOF
            ;;
        "post")
            cat >> "$TEST_FILE.tmp" << EOF
        var requestBody = """
            {
                "name": "Test",
                "value": "test-value"
            }
            """;

        given()
            .contentType(ContentType.JSON)
            .body(requestBody)
        .when()
            .post("$path")
        .then()
            .statusCode(201)
            .header("Location", is(notNullValue()))
            .body("id", is(notNullValue()));
EOF
            ;;
        "put")
            cat >> "$TEST_FILE.tmp" << EOF
        var requestBody = """
            {
                "name": "Updated",
                "value": "updated-value"
            }
            """;

        given()
            .contentType(ContentType.JSON)
            .body(requestBody)
        .when()
            .put("$path")
        .then()
            .statusCode(200)
            .body("message", equalTo("Updated successfully"));
EOF
            ;;
        "delete")
            cat >> "$TEST_FILE.tmp" << EOF
        given()
            .contentType(ContentType.JSON)
        .when()
            .delete("$path")
        .then()
            .statusCode(204);
EOF
            ;;
    esac

    echo "    }" >> "$TEST_FILE.tmp"

    # Merge with existing file (avoiding duplicates)
    if ! grep -q "should_${method}_${TEST_NAME}" "$TEST_FILE"; then
        # Insert before the last closing brace
        sed -i '/^}$/d' "$TEST_FILE"
        cat "$TEST_FILE.tmp" >> "$TEST_FILE"
        echo "}" >> "$TEST_FILE"
        echo -e "${GREEN}✅ Generated test: should_${method}_${TEST_NAME}${NC}"
    else
        echo -e "${YELLOW}⚠️  Test already exists: should_${method}_${TEST_NAME}${NC}"
    fi

    rm -f "$TEST_FILE.tmp"
done

echo ""

# Generate comprehensive E2E flow tests
echo "═══════════════════════════════════════════════════════════════"
echo "🔄 GENERATING E2E FLOW TESTS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Analyze for common flows
FLOW_TEST_FILE="$E2E_TEST_DIR/ComprehensiveFlowE2ETest.java"

if [ ! -f "$FLOW_TEST_FILE" ]; then
    cat > "$FLOW_TEST_FILE" << 'EOF'
package e2e;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.*;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.testcontainers.junit.jupiter.Testcontainers;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class ComprehensiveFlowE2ETest {

    @LocalServerPort
    private int port;

    private static String resourceId;

    @BeforeEach
    void setUp() {
        RestAssured.port = port;
        RestAssured.basePath = "/api/v1";
    }

    @Test
    @Order(1)
    @DisplayName("Complete CRUD flow")
    void completeCrudFlow() {
        // CREATE
        resourceId = given()
            .contentType(ContentType.JSON)
            .body("""
                {
                    "name": "Test Resource",
                    "description": "E2E Test"
                }
                """)
        .when()
            .post("/resources")
        .then()
            .statusCode(201)
            .extract()
            .jsonPath()
            .getString("id");

        // READ
        given()
        .when()
            .get("/resources/" + resourceId)
        .then()
            .statusCode(200)
            .body("id", equalTo(resourceId))
            .body("name", equalTo("Test Resource"));

        // UPDATE
        given()
            .contentType(ContentType.JSON)
            .body("""
                {
                    "name": "Updated Resource",
                    "description": "Updated E2E Test"
                }
                """)
        .when()
            .put("/resources/" + resourceId)
        .then()
            .statusCode(200);

        // DELETE
        given()
        .when()
            .delete("/resources/" + resourceId)
        .then()
            .statusCode(204);

        // VERIFY DELETION
        given()
        .when()
            .get("/resources/" + resourceId)
        .then()
            .statusCode(404);
    }
}
EOF
    echo -e "${GREEN}✅ Generated comprehensive flow test${NC}"
fi

# Run the generated E2E tests
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🚀 RUNNING E2E TESTS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

if mvn test -Dtest="*E2ETest" > /tmp/e2e-test.log 2>&1; then
    echo -e "${GREEN}✅ E2E tests passed${NC}"
    grep -E "Tests run:" /tmp/e2e-test.log | tail -1
else
    echo -e "${YELLOW}⚠️  Some E2E tests failed${NC}"
    echo "   This is expected for newly generated tests"
    echo "   Please update the test data and assertions"
    echo "   Log: /tmp/e2e-test.log"
fi

# Save current OpenAPI spec for next comparison
cp "$OPENAPI_SPEC" "$PREVIOUS_SPEC"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "📊 E2E TEST COVERAGE REPORT"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Count E2E tests
E2E_COUNT=$(find "$E2E_TEST_DIR" -name "*E2ETest.java" -exec grep -c "@Test" {} \; | paste -sd+ | bc 2>/dev/null || echo "0")
ENDPOINT_COUNT=$(echo "$CURRENT_ENDPOINTS" | wc -l)

echo "   Total API endpoints: $ENDPOINT_COUNT"
echo "   Total E2E tests:     $E2E_COUNT"

if [ "$E2E_COUNT" -ge "$ENDPOINT_COUNT" ]; then
    echo -e "${GREEN}✅ Good E2E coverage${NC}"
else
    echo -e "${YELLOW}⚠️  Consider adding more E2E scenarios${NC}"
fi

echo ""
echo "💡 Next steps:"
echo "   1. Review generated E2E tests in $E2E_TEST_DIR"
echo "   2. Update test data for your specific use case"
echo "   3. Add business flow scenarios"
echo "   4. Run: mvn test -Dtest=\"*E2ETest\""

exit 0