#!/bin/bash

# Spring Boot CLI - Add Use Case Command
# Add a new use case to an existing Spring Boot project

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Variables
USECASE_NAME=""
AGGREGATE_NAME=""

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --name)
                USECASE_NAME="$2"
                shift 2
                ;;
            --aggregate)
                AGGREGATE_NAME="$2"
                shift 2
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Show usage
show_usage() {
    cat << EOF
Usage: springboot-cli.sh add usecase [OPTIONS]

Add a new use case to an existing Spring Boot project.

Options:
    --name <name>         Use case name (required, e.g., ProcessOrder)
    --aggregate <name>    Aggregate name (required, e.g., Order)
    --help, -h            Show this help message

Examples:
    # Add a simple use case
    springboot-cli.sh add usecase --name ProcessOrder --aggregate Order

    # Add another use case
    springboot-cli.sh add usecase --name UpdateInventory --aggregate Product
EOF
}

# Validate inputs
validate_inputs() {
    if [ -z "$USECASE_NAME" ]; then
        log_error "Use case name is required (--name)"
        exit 1
    fi

    if [ -z "$AGGREGATE_NAME" ]; then
        log_error "Aggregate name is required (--aggregate)"
        exit 1
    fi

    # Check if in a Spring Boot project
    if [ ! -f "pom.xml" ]; then
        log_error "Not in a Spring Boot project directory (pom.xml not found)"
        exit 1
    fi
}

# Extract package name from pom.xml
get_package_name() {
    # Skip parent groupId and get the project groupId
    local package_name=$(grep "<groupId>" pom.xml | sed -n '2p' | sed 's/.*<groupId>\(.*\)<\/groupId>.*/\1/' | xargs)
    if [ -z "$package_name" ]; then
        log_error "Could not determine package name from pom.xml"
        exit 1
    fi
    echo "$package_name"
}

# Generate use case interface
generate_usecase_interface() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')
    local interface_path="src/main/java/$package_path/domain/port/input/${USECASE_NAME}UseCase.java"

    log_info "Generating use case interface: $interface_path"

    mkdir -p "$(dirname "$interface_path")"

    cat > "$interface_path" << EOF
package ${package_name}.domain.port.input;

/**
 * Use case interface for ${USECASE_NAME}
 * This interface defines the contract for the ${USECASE_NAME} use case
 */
public interface ${USECASE_NAME}UseCase {

    /**
     * Execute the ${USECASE_NAME} use case
     *
     * @param command The command containing input data
     * @return The result of the use case execution
     */
    ${AGGREGATE_NAME} execute(${USECASE_NAME}Command command);

    /**
     * Command object for ${USECASE_NAME} use case
     */
    record ${USECASE_NAME}Command(
        // TODO: Add command fields
        String exampleField
    ) {
        public ${USECASE_NAME}Command {
            // Validation logic
            if (exampleField == null || exampleField.isBlank()) {
                throw new IllegalArgumentException("Example field cannot be null or empty");
            }
        }
    }
}
EOF

    log_success "Generated use case interface"
}

# Generate use case implementation
generate_usecase_implementation() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')
    local impl_path="src/main/java/$package_path/application/usecase/${USECASE_NAME}UseCaseImpl.java"

    log_info "Generating use case implementation: $impl_path"

    mkdir -p "$(dirname "$impl_path")"

    cat > "$impl_path" << EOF
package ${package_name}.application.usecase;

import ${package_name}.domain.port.input.${USECASE_NAME}UseCase;
import ${package_name}.domain.port.output.${AGGREGATE_NAME}Repository;
import ${package_name}.domain.model.aggregate.${AGGREGATE_NAME};
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Implementation of ${USECASE_NAME} use case
 */
@Service
@Transactional
public class ${USECASE_NAME}UseCaseImpl implements ${USECASE_NAME}UseCase {

    private static final Logger logger = LoggerFactory.getLogger(${USECASE_NAME}UseCaseImpl.class);

    private final ${AGGREGATE_NAME}Repository ${AGGREGATE_NAME,,}Repository;

    public ${USECASE_NAME}UseCaseImpl(${AGGREGATE_NAME}Repository ${AGGREGATE_NAME,,}Repository) {
        this.${AGGREGATE_NAME,,}Repository = ${AGGREGATE_NAME,,}Repository;
    }

    @Override
    public ${AGGREGATE_NAME} execute(${USECASE_NAME}Command command) {
        logger.info("Executing ${USECASE_NAME} use case with command: {}", command);

        // TODO: Implement business logic
        // 1. Validate command
        // 2. Load aggregate from repository if needed
        // 3. Execute business operations
        // 4. Save aggregate
        // 5. Publish domain events if needed

        // Example implementation:
        ${AGGREGATE_NAME} ${AGGREGATE_NAME,,} = new ${AGGREGATE_NAME}();
        // Apply business logic...

        ${AGGREGATE_NAME} saved = ${AGGREGATE_NAME,,}Repository.save(${AGGREGATE_NAME,,});

        logger.info("Successfully executed ${USECASE_NAME} use case for aggregate: {}", saved.getId());
        return saved;
    }
}
EOF

    log_success "Generated use case implementation"
}

# Generate unit test
generate_unit_test() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')
    local test_path="src/test/java/$package_path/unit/application/${USECASE_NAME}UseCaseTest.java"

    log_info "Generating unit test: $test_path"

    mkdir -p "$(dirname "$test_path")"

    cat > "$test_path" << EOF
package ${package_name}.unit.application;

import ${package_name}.application.usecase.${USECASE_NAME}UseCaseImpl;
import ${package_name}.domain.port.input.${USECASE_NAME}UseCase;
import ${package_name}.domain.port.input.${USECASE_NAME}UseCase.${USECASE_NAME}Command;
import ${package_name}.domain.port.output.${AGGREGATE_NAME}Repository;
import ${package_name}.domain.model.aggregate.${AGGREGATE_NAME};
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit tests for ${USECASE_NAME}UseCase
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("${USECASE_NAME} Use Case Tests")
class ${USECASE_NAME}UseCaseTest {

    @Mock
    private ${AGGREGATE_NAME}Repository ${AGGREGATE_NAME,,}Repository;

    private ${USECASE_NAME}UseCaseImpl useCase;

    @BeforeEach
    void setUp() {
        useCase = new ${USECASE_NAME}UseCaseImpl(${AGGREGATE_NAME,,}Repository);
    }

    @Test
    @DisplayName("Should execute ${USECASE_NAME} successfully")
    void shouldExecute${USECASE_NAME}Successfully() {
        // Given
        ${USECASE_NAME}Command command = new ${USECASE_NAME}Command("test-value");
        ${AGGREGATE_NAME} expected${AGGREGATE_NAME} = new ${AGGREGATE_NAME}();
        // Set up expected aggregate...

        when(${AGGREGATE_NAME,,}Repository.save(any(${AGGREGATE_NAME}.class)))
            .thenReturn(expected${AGGREGATE_NAME});

        // When
        ${AGGREGATE_NAME} result = useCase.execute(command);

        // Then
        assertThat(result).isNotNull();
        assertThat(result).isEqualTo(expected${AGGREGATE_NAME});
        verify(${AGGREGATE_NAME,,}Repository, times(1)).save(any(${AGGREGATE_NAME}.class));
    }

    @Test
    @DisplayName("Should throw exception when command is invalid")
    void shouldThrowExceptionWhenCommandIsInvalid() {
        // Given/When/Then
        assertThatThrownBy(() -> new ${USECASE_NAME}Command(null))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("cannot be null");
    }

    @Test
    @DisplayName("Should handle repository exception")
    void shouldHandleRepositoryException() {
        // Given
        ${USECASE_NAME}Command command = new ${USECASE_NAME}Command("test-value");

        when(${AGGREGATE_NAME,,}Repository.save(any(${AGGREGATE_NAME}.class)))
            .thenThrow(new RuntimeException("Database error"));

        // When/Then
        assertThatThrownBy(() -> useCase.execute(command))
            .isInstanceOf(RuntimeException.class)
            .hasMessageContaining("Database error");
    }
}
EOF

    log_success "Generated unit test"
}

# Create placeholder aggregate and repository if they don't exist
create_placeholders() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')

    # Create aggregate if it doesn't exist
    local aggregate_path="src/main/java/$package_path/domain/model/aggregate/${AGGREGATE_NAME}.java"
    if [ ! -f "$aggregate_path" ]; then
        log_info "Creating placeholder aggregate: $aggregate_path"
        mkdir -p "$(dirname "$aggregate_path")"

        cat > "$aggregate_path" << EOF
package ${package_name}.domain.model.aggregate;

import java.util.UUID;

/**
 * ${AGGREGATE_NAME} aggregate root
 * TODO: Implement aggregate logic
 */
public class ${AGGREGATE_NAME} {

    private UUID id;
    private String status;

    public ${AGGREGATE_NAME}() {
        this.id = UUID.randomUUID();
        this.status = "CREATED";
    }

    public UUID getId() {
        return id;
    }

    public String getStatus() {
        return status;
    }

    // TODO: Add business methods
}
EOF
        log_success "Created placeholder aggregate"
    fi

    # Create repository interface if it doesn't exist
    local repo_path="src/main/java/$package_path/domain/port/output/${AGGREGATE_NAME}Repository.java"
    if [ ! -f "$repo_path" ]; then
        log_info "Creating placeholder repository interface: $repo_path"
        mkdir -p "$(dirname "$repo_path")"

        cat > "$repo_path" << EOF
package ${package_name}.domain.port.output;

import ${package_name}.domain.model.aggregate.${AGGREGATE_NAME};
import java.util.UUID;
import java.util.Optional;

/**
 * Repository interface for ${AGGREGATE_NAME} aggregate
 */
public interface ${AGGREGATE_NAME}Repository {

    ${AGGREGATE_NAME} save(${AGGREGATE_NAME} ${AGGREGATE_NAME,,});

    Optional<${AGGREGATE_NAME}> findById(UUID id);

    void deleteById(UUID id);

    // TODO: Add other repository methods as needed
}
EOF
        log_success "Created placeholder repository interface"
    fi
}

# Main execution
main() {
    parse_arguments "$@"
    validate_inputs

    log_info "Adding use case: $USECASE_NAME for aggregate: $AGGREGATE_NAME"

    PACKAGE_NAME=$(get_package_name)
    log_info "Package name: $PACKAGE_NAME"

    # Create placeholders if needed
    create_placeholders "$PACKAGE_NAME"

    # Generate files
    generate_usecase_interface "$PACKAGE_NAME"
    generate_usecase_implementation "$PACKAGE_NAME"
    generate_unit_test "$PACKAGE_NAME"

    log_success "✓ Use case added successfully!"
    echo ""
    log_info "Generated files:"
    echo "  - Use case interface: domain/port/input/${USECASE_NAME}UseCase.java"
    echo "  - Implementation: application/usecase/${USECASE_NAME}UseCaseImpl.java"
    echo "  - Unit test: test/.../unit/application/${USECASE_NAME}UseCaseTest.java"
    echo ""
    echo "Next steps:"
    echo "  1. Implement the business logic in ${USECASE_NAME}UseCaseImpl"
    echo "  2. Update the command object with actual fields"
    echo "  3. Complete the unit tests"
    echo "  4. Run: mvn test"
}

# Run main
main "$@"