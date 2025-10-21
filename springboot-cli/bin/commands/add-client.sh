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
Usage: ./springboot-cli.sh add client [OPTIONS]

Add external service client with resilience patterns

Options:
    --name NAME             Client name (required, PascalCase, e.g., PaymentService)
    --circuit-breaker       Enable circuit breaker pattern (optional)
    --retry                 Enable retry pattern (optional)
    --rate-limit            Enable rate limiting (optional)
    --help                  Show this help message

Examples:
    # Simple client
    ./springboot-cli.sh add client --name PaymentService

    # Client with full resilience
    ./springboot-cli.sh add client --name PaymentService --circuit-breaker --retry --rate-limit

EOF
    exit 1
}

# Parse arguments
CLIENT_NAME=""
CIRCUIT_BREAKER=false
RETRY=false
RATE_LIMIT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            CLIENT_NAME="$2"
            shift 2
            ;;
        --circuit-breaker)
            CIRCUIT_BREAKER=true
            shift
            ;;
        --retry)
            RETRY=true
            shift
            ;;
        --rate-limit)
            RATE_LIMIT=true
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
if [ -z "$CLIENT_NAME" ]; then
    print_error "Client name is required"
    show_usage
fi

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

print_info "Creating external service client: $CLIENT_NAME"
print_info "Package: $PACKAGE"
print_info "Circuit Breaker: $CIRCUIT_BREAKER"
print_info "Retry: $RETRY"
print_info "Rate Limit: $RATE_LIMIT"

# Create directory structure
PORT_DIR="src/main/java/$(echo $PACKAGE | tr '.' '/')/domain/port/output"
CLIENT_DIR="src/main/java/$(echo $PACKAGE | tr '.' '/')/infrastructure/adapter/client"
CONFIG_DIR="src/main/java/$(echo $PACKAGE | tr '.' '/')/infrastructure/config"

mkdir -p "$PORT_DIR"
mkdir -p "$CLIENT_DIR"
mkdir -p "$CONFIG_DIR"

# Create port interface
PORT_FILE="$PORT_DIR/${CLIENT_NAME}Port.java"

if [ -f "$PORT_FILE" ]; then
    print_error "Port interface already exists: $PORT_FILE"
    exit 1
fi

print_info "Creating port interface..."

cat > "$PORT_FILE" << JAVA_EOF
package ${PACKAGE}.domain.port.output;

/**
 * Port interface for ${CLIENT_NAME} external service.
 *
 * <p>Defines the contract for ${CLIENT_NAME} operations.
 * Implementations must handle:
 * - Network failures
 * - Timeouts
 * - Rate limiting
 * - Error responses
 */
public interface ${CLIENT_NAME}Port {

  /**
   * Example method - replace with actual operations.
   *
   * @param request the request data
   * @return the response data
   * @throws ServiceUnavailableException if service is unavailable
   */
  String callService(String request);

  // TODO: Add actual service methods
}
JAVA_EOF

sed -i "s/\${PACKAGE}/$PACKAGE/g" "$PORT_FILE"
sed -i "s/\${CLIENT_NAME}/$CLIENT_NAME/g" "$PORT_FILE"

print_success "Port interface created: $PORT_FILE"

# Create client implementation
CLIENT_FILE="$CLIENT_DIR/${CLIENT_NAME}Client.java"

if [ -f "$CLIENT_FILE" ]; then
    print_error "Client already exists: $CLIENT_FILE"
    exit 1
fi

print_info "Creating client implementation..."

# Build annotations based on resilience options
ANNOTATIONS=""
IMPORT_ANNOTATIONS=""

if [ "$CIRCUIT_BREAKER" = true ]; then
    ANNOTATIONS="$ANNOTATIONS  @CircuitBreaker(name = \"${CLIENT_NAME_LOWER}\", fallbackMethod = \"fallback\")\n"
    IMPORT_ANNOTATIONS="$IMPORT_ANNOTATIONS\nimport io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;"
fi

if [ "$RETRY" = true ]; then
    ANNOTATIONS="$ANNOTATIONS  @Retry(name = \"${CLIENT_NAME_LOWER}\")\n"
    IMPORT_ANNOTATIONS="$IMPORT_ANNOTATIONS\nimport io.github.resilience4j.retry.annotation.Retry;"
fi

if [ "$RATE_LIMIT" = true ]; then
    ANNOTATIONS="$ANNOTATIONS  @RateLimiter(name = \"${CLIENT_NAME_LOWER}\")\n"
    IMPORT_ANNOTATIONS="$IMPORT_ANNOTATIONS\nimport io.github.resilience4j.ratelimiter.annotation.RateLimiter;"
fi

CLIENT_NAME_LOWER=$(echo "$CLIENT_NAME" | sed 's/\([A-Z]\)/-\L\1/g' | sed 's/^-//' | tr '-' '_')

cat > "$CLIENT_FILE" << 'JAVA_EOF'
package ${PACKAGE}.infrastructure.adapter.client;

import ${PACKAGE}.domain.port.output.${CLIENT_NAME}Port;
import ${PACKAGE}.infrastructure.adapter.observability.TelemetryService;${IMPORT_ANNOTATIONS}
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

/**
 * Client for ${CLIENT_NAME} external service.
 *
 * <p>Implements resilience patterns:${RESILIENCE_FEATURES}
 * - Dependency tracking (Application Insights)
 * - Structured logging
 */
@Component
public class ${CLIENT_NAME}Client implements ${CLIENT_NAME}Port {

  private static final Logger logger = LoggerFactory.getLogger(${CLIENT_NAME}Client.class);

  private final RestTemplate restTemplate;
  private final TelemetryService telemetry;

  @Value("${${CLIENT_NAME_LOWER}.url:http://localhost:8080}")
  private String serviceUrl;

  public ${CLIENT_NAME}Client(RestTemplate restTemplate, TelemetryService telemetry) {
    this.restTemplate = restTemplate;
    this.telemetry = telemetry;
  }

${ANNOTATIONS}  @Override
  public String callService(String request) {
    logger.info("Calling ${CLIENT_NAME} with request: {}", request);
    long startTime = System.currentTimeMillis();

    try {
      String response = restTemplate.postForObject(
          serviceUrl + "/api/endpoint",
          request,
          String.class);

      long duration = System.currentTimeMillis() - startTime;
      telemetry.trackDependency("${CLIENT_NAME}", "POST /api/endpoint", duration, true);

      logger.info("${CLIENT_NAME} call successful");
      return response;

    } catch (Exception e) {
      long duration = System.currentTimeMillis() - startTime;
      telemetry.trackDependency("${CLIENT_NAME}", "POST /api/endpoint", duration, false);
      telemetry.trackException(e, Map.of("service", "${CLIENT_NAME}"));

      logger.error("${CLIENT_NAME} call failed", e);
      throw e;
    }
  }
${FALLBACK_METHOD}
  // TODO: Add actual service methods
}
JAVA_EOF

# Build resilience features text
RESILIENCE_FEATURES=""
if [ "$CIRCUIT_BREAKER" = true ]; then
    RESILIENCE_FEATURES="$RESILIENCE_FEATURES\n * - Circuit breaker (prevents cascading failures)"
fi
if [ "$RETRY" = true ]; then
    RESILIENCE_FEATURES="$RESILIENCE_FEATURES\n * - Retry with exponential backoff"
fi
if [ "$RATE_LIMIT" = true ]; then
    RESILIENCE_FEATURES="$RESILIENCE_FEATURES\n * - Rate limiting (prevents overwhelming service)"
fi

# Add fallback method if circuit breaker is enabled
FALLBACK_METHOD=""
if [ "$CIRCUIT_BREAKER" = true ]; then
    FALLBACK_METHOD="\n  private String fallback(String request, Exception ex) {\n    logger.warn(\"${CLIENT_NAME} fallback triggered\", ex);\n    telemetry.trackEvent(\"${CLIENT_NAME}Fallback\",\n        Map.of(\"reason\", ex.getClass().getSimpleName()));\n    throw new RuntimeException(\"Service temporarily unavailable\", ex);\n  }\n"
fi

# Substitute variables
sed -i "s/\${PACKAGE}/$PACKAGE/g" "$CLIENT_FILE"
sed -i "s/\${CLIENT_NAME}/$CLIENT_NAME/g" "$CLIENT_FILE"
sed -i "s/\${CLIENT_NAME_LOWER}/$CLIENT_NAME_LOWER/g" "$CLIENT_FILE"
sed -i "s|\${IMPORT_ANNOTATIONS}|$IMPORT_ANNOTATIONS|g" "$CLIENT_FILE"
sed -i "s|\${ANNOTATIONS}|$ANNOTATIONS|g" "$CLIENT_FILE"
sed -i "s|\${RESILIENCE_FEATURES}|$RESILIENCE_FEATURES|g" "$CLIENT_FILE"
sed -i "s|\${FALLBACK_METHOD}|$FALLBACK_METHOD|g" "$CLIENT_FILE"

print_success "Client implementation created: $CLIENT_FILE"

# Create RestClientConfig if it doesn't exist
REST_CONFIG_FILE="$CONFIG_DIR/RestClientConfig.java"

if [ ! -f "$REST_CONFIG_FILE" ]; then
    print_info "Creating RestClientConfig..."

    cat > "$REST_CONFIG_FILE" << 'JAVA_EOF'
package ${PACKAGE}.infrastructure.config;

import java.time.Duration;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

/**
 * Configuration for REST clients.
 */
@Configuration
public class RestClientConfig {

  @Bean
  public RestTemplate restTemplate(RestTemplateBuilder builder) {
    return builder
        .setConnectTimeout(Duration.ofSeconds(5))
        .setReadTimeout(Duration.ofSeconds(10))
        .build();
  }
}
JAVA_EOF

    sed -i "s/\${PACKAGE}/$PACKAGE/g" "$REST_CONFIG_FILE"
    print_success "RestClientConfig created"
fi

# Print summary
echo ""
print_success "External service client created successfully!"
echo ""
print_info "Created files:"
echo "  - Port interface: $PORT_FILE"
echo "  - Client implementation: $CLIENT_FILE"
echo "  - REST config: $REST_CONFIG_FILE"
echo ""
print_info "Next steps:"
echo "  1. Update the port interface with actual methods"
echo "  2. Implement the actual service calls in the client"
echo "  3. Configure service URL in application.yml:"
echo "     ${CLIENT_NAME_LOWER}.url: https://api.example.com"

if [ "$CIRCUIT_BREAKER" = true ] || [ "$RETRY" = true ] || [ "$RATE_LIMIT" = true ]; then
    echo "  4. Configure Resilience4j in application.yml (see templates/infrastructure/resilience4j.yml)"
fi

echo "  5. Add client to your use cases via dependency injection"
