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
Usage: ./springboot-cli.sh generate openapi [OPTIONS]

Generate API interfaces and DTOs from OpenAPI specification

Options:
    --spec PATH         Path to OpenAPI specification file (required)
    --update            Update existing generated code (optional)
    --help              Show this help message

Examples:
    # Initial generation
    ./springboot-cli.sh generate openapi --spec openapi/api-spec.yaml

    # Update existing generated code
    ./springboot-cli.sh generate openapi --spec openapi/api-spec.yaml --update

EOF
    exit 1
}

# Parse arguments
SPEC_PATH=""
UPDATE_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --spec)
            SPEC_PATH="$2"
            shift 2
            ;;
        --update)
            UPDATE_MODE=true
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

# Validate required arguments
if [ -z "$SPEC_PATH" ]; then
    print_error "OpenAPI specification path is required"
    show_usage
fi

# Check if spec file exists
if [ ! -f "$SPEC_PATH" ]; then
    print_error "OpenAPI specification file not found: $SPEC_PATH"
    exit 1
fi

# Check if we're in a project directory
if [ ! -f "pom.xml" ]; then
    print_error "Not in a Spring Boot project directory (pom.xml not found)"
    exit 1
fi

# Extract package information from pom.xml (get project groupId, not parent groupId)
PACKAGE=$(grep "<groupId>" pom.xml | sed -n '2p' | sed 's/.*<groupId>\(.*\)<\/groupId>.*/\1/' | xargs)
ARTIFACT_ID=$(grep -oP '<artifactId>\K[^<]+' pom.xml | head -1)

if [ -z "$PACKAGE" ] || [ -z "$ARTIFACT_ID" ]; then
    print_error "Could not extract package information from pom.xml"
    exit 1
fi

print_info "Generating OpenAPI code from: $SPEC_PATH"
print_info "Package: $PACKAGE"
print_info "Artifact ID: $ARTIFACT_ID"

# Check if OpenAPI Generator CLI is available
if ! command -v openapi-generator-cli &> /dev/null; then
    print_error "OpenAPI Generator CLI not found"
    print_info "Installing OpenAPI Generator CLI via npm..."

    if ! command -v npm &> /dev/null; then
        print_error "npm is required to install openapi-generator-cli"
        print_info "Please install Node.js and npm, or install openapi-generator-cli manually"
        print_info "See: https://openapi-generator.tech/docs/installation"
        exit 1
    fi

    npm install -g @openapitools/openapi-generator-cli

    if [ $? -ne 0 ]; then
        print_error "Failed to install OpenAPI Generator CLI"
        exit 1
    fi

    print_success "OpenAPI Generator CLI installed successfully"
fi

# Create temporary config file
TEMP_CONFIG=$(mktemp)
trap "rm -f $TEMP_CONFIG" EXIT

# Get the CLI directory (parent of bin/commands)
CLI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_TEMPLATE="$CLI_DIR/generators/openapi-generator/config.yaml"

# Substitute variables in config
sed -e "s/\${PACKAGE}/$PACKAGE/g" \
    -e "s/\${GROUP_ID}/$PACKAGE/g" \
    -e "s/\${ARTIFACT_ID}/$ARTIFACT_ID/g" \
    "$CONFIG_TEMPLATE" > "$TEMP_CONFIG"

# Backup existing generated files if in update mode
if [ "$UPDATE_MODE" = true ]; then
    print_info "Backing up existing generated files..."

    BACKUP_DIR=".openapi-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # Backup generated files
    if [ -d "src/main/java/$(echo $PACKAGE | tr '.' '/')/api" ]; then
        cp -r "src/main/java/$(echo $PACKAGE | tr '.' '/')/api" "$BACKUP_DIR/"
        print_success "Backup created in $BACKUP_DIR"
    fi
fi

# Generate code
print_info "Generating code..."

openapi-generator-cli generate \
    -i "$SPEC_PATH" \
    -g spring \
    -c "$TEMP_CONFIG" \
    --skip-validate-spec \
    --enable-post-process-file

if [ $? -ne 0 ]; then
    print_error "Code generation failed"
    exit 1
fi

print_success "OpenAPI code generated successfully"

# Create OpenApiConfig if it doesn't exist
OPENAPI_CONFIG_DIR="src/main/java/$(echo $PACKAGE | tr '.' '/')/infrastructure/config"
OPENAPI_CONFIG_FILE="$OPENAPI_CONFIG_DIR/OpenApiConfig.java"

if [ ! -f "$OPENAPI_CONFIG_FILE" ]; then
    print_info "Creating OpenApiConfig..."

    mkdir -p "$OPENAPI_CONFIG_DIR"

    cat > "$OPENAPI_CONFIG_FILE" << 'JAVA_EOF'
package ${PACKAGE}.infrastructure.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

  @Value("${spring.application.name}")
  private String applicationName;

  @Bean
  public OpenAPI customOpenAPI() {
    return new OpenAPI()
        .info(
            new Info()
                .title(applicationName + " API")
                .version("1.0.0")
                .description("API documentation for " + applicationName)
                .contact(
                    new Contact()
                        .name("API Support")
                        .email("support@example.com"))
                .license(
                    new License()
                        .name("Apache 2.0")
                        .url("https://www.apache.org/licenses/LICENSE-2.0")))
        .servers(
            List.of(
                new Server().url("http://localhost:8080").description("Local server"),
                new Server().url("https://api.example.com").description("Production server")));
  }
}
JAVA_EOF

    # Replace package placeholder
    sed -i "s/\${PACKAGE}/$PACKAGE/g" "$OPENAPI_CONFIG_FILE"

    print_success "OpenApiConfig created"
fi

# Format generated code if google-java-format is available
if command -v google-java-format &> /dev/null; then
    print_info "Formatting generated code..."
    find src/main/java/$(echo $PACKAGE | tr '.' '/')/api -name "*.java" -exec google-java-format -i {} \;
    print_success "Code formatted"
fi

# Print summary
print_success "Code generation complete!"
echo ""
print_info "Generated files:"
echo "  - API Controllers: src/main/java/$(echo $PACKAGE | tr '.' '/')/api/controller/"
echo "  - DTOs: src/main/java/$(echo $PACKAGE | tr '.' '/')/api/dto/"
echo ""
print_info "Next steps:"
echo "  1. Implement the generated API interfaces in your controllers"
echo "  2. Map DTOs to domain models using mappers"
echo "  3. Connect controllers to use cases"
echo ""
print_info "View API documentation at: http://localhost:8080/swagger-ui.html"
