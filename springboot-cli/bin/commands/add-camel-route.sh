#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: ./springboot-cli.sh add camel-route [OPTIONS]

Add Apache Camel route to the project

Options:
    --name NAME         Route name (required, PascalCase)
    --pattern PATTERN   Route pattern (optional)
                        - file-to-queue: File processing to message queue
                        - rest-to-rest: REST API integration
                        - content-based: Content-based routing
                        - custom: Empty template for custom route
    --help              Show this help message

Examples:
    # Add file-to-queue route
    ./springboot-cli.sh add camel-route --name OrderFileProcessor --pattern file-to-queue

    # Add custom route
    ./springboot-cli.sh add camel-route --name CustomRoute --pattern custom

EOF
    exit 1
}

# Parse arguments
ROUTE_NAME=""
PATTERN="custom"

while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            ROUTE_NAME="$2"
            shift 2
            ;;
        --pattern)
            PATTERN="$2"
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

# Validate required arguments
if [ -z "$ROUTE_NAME" ]; then
    print_error "Route name is required"
    show_usage
fi

# Validate pattern
case $PATTERN in
    file-to-queue|rest-to-rest|content-based|custom)
        ;;
    *)
        print_error "Invalid pattern: $PATTERN"
        echo "Valid patterns: file-to-queue, rest-to-rest, content-based, custom"
        exit 1
        ;;
esac

# Check if we're in a project directory
if [ ! -f "pom.xml" ]; then
    print_error "Not in a Spring Boot project directory (pom.xml not found)"
    exit 1
fi

# Extract package from pom.xml (get project groupId, not parent groupId)
PACKAGE=$(grep "<groupId>" pom.xml | sed -n '2p' | sed 's/.*<groupId>\(.*\)<\/groupId>.*/\1/' | xargs)

if [ -z "$PACKAGE" ]; then
    print_error "Could not extract package from pom.xml"
    exit 1
fi

# Create directory structure
CAMEL_DIR="src/main/java/$(echo $PACKAGE | tr '.' '/')/infrastructure/adapter/camel"
mkdir -p "$CAMEL_DIR"

# Route file path
ROUTE_FILE="$CAMEL_DIR/${ROUTE_NAME}Route.java"

if [ -f "$ROUTE_FILE" ]; then
    print_error "Route already exists: $ROUTE_FILE"
    exit 1
fi

print_info "Creating Camel route: $ROUTE_NAME"
print_info "Pattern: $PATTERN"
print_info "Package: $PACKAGE"

# Get CLI directory
CLI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Select template based on pattern
case $PATTERN in
    file-to-queue)
        TEMPLATE="$CLI_DIR/templates/camel/routes/FileToQueueRoute.java.tmpl"
        ;;
    rest-to-rest)
        TEMPLATE="$CLI_DIR/templates/camel/routes/RestToRestRoute.java.tmpl"
        ;;
    content-based)
        TEMPLATE="$CLI_DIR/templates/camel/routes/ContentBasedRoute.java.tmpl"
        ;;
    custom)
        # Create custom template
        cat > "$ROUTE_FILE" << 'JAVA_EOF'
package ${PACKAGE}.infrastructure.adapter.camel;

import org.apache.camel.LoggingLevel;
import org.apache.camel.builder.RouteBuilder;
import org.springframework.stereotype.Component;

/**
 * ${ROUTE_NAME} Camel route.
 *
 * <p>TODO: Describe route purpose and flow
 *
 * <p>Enterprise Integration Patterns used:
 * - TODO: List patterns
 */
@Component
public class ${ROUTE_NAME}Route extends RouteBuilder {

  @Override
  public void configure() throws Exception {
    // TODO: Configure route
    from("direct:${ROUTE_NAME_LOWER}")
        .routeId("${ROUTE_NAME_LOWER}")
        .log(LoggingLevel.INFO, "Processing message: ${body}")
        // Add route logic here
        .log(LoggingLevel.INFO, "Processing complete");
  }
}
JAVA_EOF
        # Substitute variables
        ROUTE_NAME_LOWER=$(echo "$ROUTE_NAME" | sed 's/\([A-Z]\)/-\L\1/g' | sed 's/^-//')
        sed -i "s/\${PACKAGE}/$PACKAGE/g" "$ROUTE_FILE"
        sed -i "s/\${ROUTE_NAME}/$ROUTE_NAME/g" "$ROUTE_FILE"
        sed -i "s/\${ROUTE_NAME_LOWER}/$ROUTE_NAME_LOWER/g" "$ROUTE_FILE"

        print_success "Custom Camel route created: $ROUTE_FILE"
        echo ""
        print_info "Next steps:"
        echo "  1. Edit $ROUTE_FILE to implement your route logic"
        echo "  2. Add Camel dependencies to pom.xml if not already present"
        echo "  3. Configure Camel properties in application.yml"
        echo "  4. Test your route"
        exit 0
        ;;
esac

# Copy and substitute template
if [ -f "$TEMPLATE" ]; then
    cp "$TEMPLATE" "$ROUTE_FILE"

    # Substitute variables
    sed -i "s/\${PACKAGE}/$PACKAGE/g" "$ROUTE_FILE"
    sed -i "s/\${ROUTE_NAME}/$ROUTE_NAME/g" "$ROUTE_FILE"

    print_success "Camel route created: $ROUTE_FILE"
else
    print_error "Template not found: $TEMPLATE"
    exit 1
fi

# Create CamelConfig if it doesn't exist
CONFIG_DIR="src/main/java/$(echo $PACKAGE | tr '.' '/')/infrastructure/config"
CONFIG_FILE="$CONFIG_DIR/CamelConfig.java"

if [ ! -f "$CONFIG_FILE" ]; then
    print_info "Creating CamelConfig..."
    mkdir -p "$CONFIG_DIR"

    CAMEL_CONFIG_TEMPLATE="$CLI_DIR/templates/camel/CamelConfig.java.tmpl"
    if [ -f "$CAMEL_CONFIG_TEMPLATE" ]; then
        cp "$CAMEL_CONFIG_TEMPLATE" "$CONFIG_FILE"
        sed -i "s/\${PACKAGE}/$PACKAGE/g" "$CONFIG_FILE"
        print_success "CamelConfig created"
    fi
fi

# Print next steps
echo ""
print_info "Next steps:"
echo "  1. Add Camel dependencies to pom.xml if not already present:"
echo "     - camel-spring-boot-starter"
echo "     - Pattern-specific components (camel-file, camel-kafka, etc.)"
echo "  2. Configure Camel properties in application.yml"
echo "  3. Review and customize the route in: $ROUTE_FILE"
echo "  4. Test your route"
echo ""
print_info "Camel documentation: https://camel.apache.org/"
