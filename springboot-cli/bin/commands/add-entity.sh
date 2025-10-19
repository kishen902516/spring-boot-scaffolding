#!/bin/bash

# Spring Boot CLI - Add Entity Command
# Add a new domain entity to an existing Spring Boot project

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
ENTITY_NAME=""
FIELDS=""

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --name)
                ENTITY_NAME="$2"
                shift 2
                ;;
            --fields)
                FIELDS="$2"
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
Usage: springboot-cli.sh add entity [OPTIONS]

Add a new domain entity to an existing Spring Boot project.

Options:
    --name <name>      Entity name (required, e.g., Product)
    --fields <fields>  Comma-separated fields with types (required)
                       Format: "name:type,name:type,..."
                       Types: String, Integer, Long, Double, BigDecimal,
                              Boolean, UUID, LocalDateTime, Instant
    --help, -h         Show this help message

Examples:
    # Add a simple entity
    springboot-cli.sh add entity --name Product \\
        --fields "id:UUID,name:String,price:BigDecimal,description:String"

    # Add an entity with various field types
    springboot-cli.sh add entity --name Customer \\
        --fields "id:UUID,firstName:String,lastName:String,email:String,age:Integer,active:Boolean,createdAt:Instant"
EOF
}

# Validate inputs
validate_inputs() {
    if [ -z "$ENTITY_NAME" ]; then
        log_error "Entity name is required (--name)"
        exit 1
    fi

    if [ -z "$FIELDS" ]; then
        log_error "Fields are required (--fields)"
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

# Parse fields into arrays
parse_fields() {
    IFS=',' read -ra FIELD_ARRAY <<< "$FIELDS"
    FIELD_NAMES=()
    FIELD_TYPES=()
    FIELD_IMPORTS=()

    for field in "${FIELD_ARRAY[@]}"; do
        IFS=':' read -r name type <<< "$field"

        # Trim whitespace
        name=$(echo "$name" | xargs)
        type=$(echo "$type" | xargs)

        if [ -z "$name" ] || [ -z "$type" ]; then
            log_error "Invalid field format: $field (expected name:type)"
            exit 1
        fi

        FIELD_NAMES+=("$name")
        FIELD_TYPES+=("$type")

        # Determine imports needed
        case $type in
            UUID)
                FIELD_IMPORTS+=("java.util.UUID")
                ;;
            BigDecimal)
                FIELD_IMPORTS+=("java.math.BigDecimal")
                ;;
            LocalDateTime)
                FIELD_IMPORTS+=("java.time.LocalDateTime")
                ;;
            Instant)
                FIELD_IMPORTS+=("java.time.Instant")
                ;;
            List)
                FIELD_IMPORTS+=("java.util.List")
                ;;
            Set)
                FIELD_IMPORTS+=("java.util.Set")
                ;;
            Map)
                FIELD_IMPORTS+=("java.util.Map")
                ;;
        esac
    done

    # Remove duplicates from imports
    UNIQUE_IMPORTS=($(printf "%s\n" "${FIELD_IMPORTS[@]}" | sort -u))
}

# Generate entity class
generate_entity() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')
    local entity_path="src/main/java/$package_path/domain/model/entity/${ENTITY_NAME}.java"

    log_info "Generating entity: $entity_path"

    mkdir -p "$(dirname "$entity_path")"

    # Start building the entity file
    cat > "$entity_path" << EOF
package ${package_name}.domain.model.entity;

EOF

    # Add imports
    for import in "${UNIQUE_IMPORTS[@]}"; do
        echo "import $import;" >> "$entity_path"
    done

    if [ ${#UNIQUE_IMPORTS[@]} -gt 0 ]; then
        echo "" >> "$entity_path"
    fi

    cat >> "$entity_path" << EOF
/**
 * ${ENTITY_NAME} domain entity
 * This entity represents a ${ENTITY_NAME} in the domain model
 */
public class ${ENTITY_NAME} {

EOF

    # Add fields
    for i in "${!FIELD_NAMES[@]}"; do
        echo "    private ${FIELD_TYPES[$i]} ${FIELD_NAMES[$i]};" >> "$entity_path"
    done

    echo "" >> "$entity_path"

    # Add private constructor
    cat >> "$entity_path" << EOF
    /**
     * Private constructor for builder pattern
     */
    private ${ENTITY_NAME}() {
    }

EOF

    # Generate getters
    for i in "${!FIELD_NAMES[@]}"; do
        local getter_name="get$(echo ${FIELD_NAMES[$i]} | sed 's/\b\(.\)/\u\1/')"
        if [ "${FIELD_TYPES[$i]}" = "Boolean" ] || [ "${FIELD_TYPES[$i]}" = "boolean" ]; then
            getter_name="is$(echo ${FIELD_NAMES[$i]} | sed 's/\b\(.\)/\u\1/')"
        fi

        cat >> "$entity_path" << EOF
    public ${FIELD_TYPES[$i]} ${getter_name}() {
        return ${FIELD_NAMES[$i]};
    }

EOF
    done

    # Add Builder class
    cat >> "$entity_path" << EOF
    /**
     * Builder for ${ENTITY_NAME}
     */
    public static class Builder {
        private final ${ENTITY_NAME} ${ENTITY_NAME,,};

        public Builder() {
            this.${ENTITY_NAME,,} = new ${ENTITY_NAME}();
        }

EOF

    # Add builder methods
    for i in "${!FIELD_NAMES[@]}"; do
        cat >> "$entity_path" << EOF
        public Builder ${FIELD_NAMES[$i]}(${FIELD_TYPES[$i]} ${FIELD_NAMES[$i]}) {
            this.${ENTITY_NAME,,}.${FIELD_NAMES[$i]} = ${FIELD_NAMES[$i]};
            return this;
        }

EOF
    done

    # Add build method with validation
    cat >> "$entity_path" << EOF
        public ${ENTITY_NAME} build() {
            validate();
            return ${ENTITY_NAME,,};
        }

        private void validate() {
            // TODO: Add validation logic
EOF

    # Add basic validation for required fields
    for i in "${!FIELD_NAMES[@]}"; do
        if [ "${FIELD_TYPES[$i]}" = "String" ]; then
            cat >> "$entity_path" << EOF
            if (${ENTITY_NAME,,}.${FIELD_NAMES[$i]} == null || ${ENTITY_NAME,,}.${FIELD_NAMES[$i]}.isBlank()) {
                throw new IllegalArgumentException("${FIELD_NAMES[$i]} cannot be null or empty");
            }
EOF
        elif [[ ! "${FIELD_TYPES[$i]}" =~ ^(int|long|double|float|boolean|char|byte|short)$ ]]; then
            # For non-primitive object types
            cat >> "$entity_path" << EOF
            if (${ENTITY_NAME,,}.${FIELD_NAMES[$i]} == null) {
                throw new IllegalArgumentException("${FIELD_NAMES[$i]} cannot be null");
            }
EOF
        fi
    done

    cat >> "$entity_path" << EOF
        }
    }

    /**
     * Static factory method for builder
     */
    public static Builder builder() {
        return new Builder();
    }

    @Override
    public String toString() {
        return "${ENTITY_NAME}{" +
EOF

    # Add toString fields
    for i in "${!FIELD_NAMES[@]}"; do
        if [ $i -eq 0 ]; then
            echo "                \"${FIELD_NAMES[$i]}=\" + ${FIELD_NAMES[$i]} +" >> "$entity_path"
        else
            echo "                \", ${FIELD_NAMES[$i]}=\" + ${FIELD_NAMES[$i]} +" >> "$entity_path"
        fi
    done

    cat >> "$entity_path" << EOF
                '}';
    }
}
EOF

    log_success "Generated entity class"
}

# Generate unit test
generate_unit_test() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')
    local test_path="src/test/java/$package_path/unit/domain/${ENTITY_NAME}Test.java"

    log_info "Generating unit test: $test_path"

    mkdir -p "$(dirname "$test_path")"

    cat > "$test_path" << EOF
package ${package_name}.unit.domain;

import ${package_name}.domain.model.entity.${ENTITY_NAME};
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

EOF

    # Add test imports
    for import in "${UNIQUE_IMPORTS[@]}"; do
        echo "import $import;" >> "$test_path"
    done

    cat >> "$test_path" << EOF

import static org.assertj.core.api.Assertions.*;

/**
 * Unit tests for ${ENTITY_NAME} entity
 */
@DisplayName("${ENTITY_NAME} Entity Tests")
class ${ENTITY_NAME}Test {

    @Test
    @DisplayName("Should create ${ENTITY_NAME} with valid data")
    void shouldCreate${ENTITY_NAME}WithValidData() {
        // Given
EOF

    # Generate test data
    for i in "${!FIELD_NAMES[@]}"; do
        local test_value=""
        case ${FIELD_TYPES[$i]} in
            String)
                test_value="\"test-${FIELD_NAMES[$i]}\""
                ;;
            Integer|int)
                test_value="42"
                ;;
            Long|long)
                test_value="123L"
                ;;
            Double|double)
                test_value="99.99"
                ;;
            BigDecimal)
                test_value="new BigDecimal(\"99.99\")"
                ;;
            Boolean|boolean)
                test_value="true"
                ;;
            UUID)
                test_value="UUID.randomUUID()"
                ;;
            LocalDateTime)
                test_value="LocalDateTime.now()"
                ;;
            Instant)
                test_value="Instant.now()"
                ;;
            *)
                test_value="null // TODO: Set appropriate value"
                ;;
        esac
        echo "        ${FIELD_TYPES[$i]} ${FIELD_NAMES[$i]} = ${test_value};" >> "$test_path"
    done

    cat >> "$test_path" << EOF

        // When
        ${ENTITY_NAME} ${ENTITY_NAME,,} = ${ENTITY_NAME}.builder()
EOF

    # Add builder calls
    for i in "${!FIELD_NAMES[@]}"; do
        echo "                .${FIELD_NAMES[$i]}(${FIELD_NAMES[$i]})" >> "$test_path"
    done

    cat >> "$test_path" << EOF
                .build();

        // Then
        assertThat(${ENTITY_NAME,,}).isNotNull();
EOF

    # Add assertions
    for i in "${!FIELD_NAMES[@]}"; do
        local getter_name="get$(echo ${FIELD_NAMES[$i]} | sed 's/\b\(.\)/\u\1/')"
        if [ "${FIELD_TYPES[$i]}" = "Boolean" ] || [ "${FIELD_TYPES[$i]}" = "boolean" ]; then
            getter_name="is$(echo ${FIELD_NAMES[$i]} | sed 's/\b\(.\)/\u\1/')"
        fi
        echo "        assertThat(${ENTITY_NAME,,}.${getter_name}()).isEqualTo(${FIELD_NAMES[$i]});" >> "$test_path"
    done

    cat >> "$test_path" << EOF
    }

    @Test
    @DisplayName("Should throw exception when required field is null")
    void shouldThrowExceptionWhenRequiredFieldIsNull() {
        // Given/When/Then
        assertThatThrownBy(() ->
            ${ENTITY_NAME}.builder()
EOF

    # Set first field to null for test
    if [ ${#FIELD_NAMES[@]} -gt 0 ]; then
        for i in "${!FIELD_NAMES[@]}"; do
            if [ $i -eq 0 ]; then
                echo "                    .${FIELD_NAMES[$i]}(null)" >> "$test_path"
            else
                # Generate valid values for other fields
                local test_value=""
                case ${FIELD_TYPES[$i]} in
                    String)
                        test_value="\"valid\""
                        ;;
                    Integer|int)
                        test_value="1"
                        ;;
                    Long|long)
                        test_value="1L"
                        ;;
                    UUID)
                        test_value="UUID.randomUUID()"
                        ;;
                    *)
                        test_value="null"
                        ;;
                esac
                if [[ ! "${FIELD_TYPES[$i]}" =~ ^(int|long|double|float|boolean|char|byte|short)$ ]]; then
                    echo "                    .${FIELD_NAMES[$i]}(${test_value})" >> "$test_path"
                fi
            fi
        done
    fi

    cat >> "$test_path" << EOF
                    .build()
        )
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("cannot be null");
    }

    @Test
    @DisplayName("Should have correct toString representation")
    void shouldHaveCorrectToStringRepresentation() {
        // Given
        ${ENTITY_NAME} ${ENTITY_NAME,,} = ${ENTITY_NAME}.builder()
EOF

    # Add simple builder calls for toString test
    for i in "${!FIELD_NAMES[@]}"; do
        local test_value=""
        case ${FIELD_TYPES[$i]} in
            String)
                test_value="\"value${i}\""
                ;;
            Integer|int|Long|long)
                test_value="${i}"
                ;;
            Boolean|boolean)
                test_value="true"
                ;;
            UUID)
                test_value="UUID.randomUUID()"
                ;;
            *)
                test_value="null"
                ;;
        esac
        echo "                .${FIELD_NAMES[$i]}(${test_value})" >> "$test_path"
    done

    cat >> "$test_path" << EOF
                .build();

        // When
        String toString = ${ENTITY_NAME,,}.toString();

        // Then
        assertThat(toString).contains("${ENTITY_NAME}");
EOF

    for name in "${FIELD_NAMES[@]}"; do
        echo "        assertThat(toString).contains(\"${name}=\");" >> "$test_path"
    done

    cat >> "$test_path" << EOF
    }
}
EOF

    log_success "Generated unit test"
}

# Main execution
main() {
    parse_arguments "$@"
    validate_inputs

    log_info "Adding entity: $ENTITY_NAME"

    PACKAGE_NAME=$(get_package_name)
    log_info "Package name: $PACKAGE_NAME"

    # Parse fields
    parse_fields

    # Generate files
    generate_entity "$PACKAGE_NAME"
    generate_unit_test "$PACKAGE_NAME"

    log_success "✓ Entity added successfully!"
    echo ""
    log_info "Generated files:"
    echo "  - Entity: domain/model/entity/${ENTITY_NAME}.java"
    echo "  - Unit test: test/.../unit/domain/${ENTITY_NAME}Test.java"
    echo ""
    echo "Next steps:"
    echo "  1. Review and customize the validation logic"
    echo "  2. Add business methods as needed"
    echo "  3. Run: mvn test"
}

# Run main
main "$@"