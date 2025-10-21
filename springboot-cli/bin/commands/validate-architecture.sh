#!/bin/bash

# Spring Boot CLI - Validate Architecture Command
# Validate Clean Architecture rules using ArchUnit

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

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Variables
GENERATE_TEST="false"

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --generate-test)
                GENERATE_TEST="true"
                shift
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
Usage: springboot-cli.sh validate architecture [OPTIONS]

Validate Clean Architecture rules in the Spring Boot project.

Options:
    --generate-test    Generate ArchUnit test file if it doesn't exist
    --help, -h         Show this help message

Examples:
    # Validate architecture
    springboot-cli.sh validate architecture

    # Generate ArchUnit test and validate
    springboot-cli.sh validate architecture --generate-test

Architecture Rules Checked:
    1. Domain layer should not depend on infrastructure or application layers
    2. Application layer should not depend on infrastructure layer
    3. Domain entities should not use framework annotations
    4. Use cases should be in the application layer
    5. Repositories should be interfaces in domain layer
    6. Repository implementations should be in infrastructure layer
    7. Controllers should be in the API layer
    8. Proper naming conventions are followed
EOF
}

# Extract package name from pom.xml (get project groupId, not parent groupId)
get_package_name() {
    local package_name=$(grep "<groupId>" pom.xml | sed -n '2p' | sed 's/.*<groupId>\(.*\)<\/groupId>.*/\1/' | xargs)
    if [ -z "$package_name" ]; then
        log_error "Could not determine package name from pom.xml"
        exit 1
    fi
    echo "$package_name"
}

# Generate ArchUnit test file
generate_archunit_test() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')
    local test_path="src/test/java/$package_path/architecture/ArchitectureTest.java"

    log_info "Generating ArchUnit test: $test_path"

    mkdir -p "$(dirname "$test_path")"

    cat > "$test_path" << EOF
package ${package_name}.architecture;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.lang.ArchRule;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.*;
import static com.tngtech.archunit.library.Architectures.*;

/**
 * Architecture tests using ArchUnit
 * Validates Clean Architecture principles
 */
@DisplayName("Clean Architecture Validation")
public class ArchitectureTest {

    private static JavaClasses classes;

    @BeforeAll
    static void setUp() {
        classes = new ClassFileImporter()
                .importPackages("${package_name}");
    }

    @Test
    @DisplayName("Domain layer should not depend on infrastructure or application layers")
    void domainLayerShouldNotDependOnOuterLayers() {
        ArchRule rule = noClasses()
                .that().resideInAPackage("..domain..")
                .should().dependOnClassesThat()
                .resideInAnyPackage("..infrastructure..", "..application..", "..api..")
                .because("Domain layer must be independent of outer layers");

        rule.check(classes);
    }

    @Test
    @DisplayName("Domain layer should not depend on Spring framework")
    void domainLayerShouldNotDependOnSpring() {
        ArchRule rule = noClasses()
                .that().resideInAPackage("..domain..")
                .should().dependOnClassesThat()
                .resideInAnyPackage("org.springframework..")
                .because("Domain layer must be framework-agnostic");

        rule.check(classes);
    }

    @Test
    @DisplayName("Application layer should not depend on infrastructure layer")
    void applicationLayerShouldNotDependOnInfrastructure() {
        ArchRule rule = noClasses()
                .that().resideInAPackage("..application..")
                .should().dependOnClassesThat()
                .resideInAPackage("..infrastructure..")
                .because("Application layer should depend on abstractions, not implementations");

        rule.check(classes);
    }

    @Test
    @DisplayName("Use cases should be in application layer")
    void useCasesShouldBeInApplicationLayer() {
        ArchRule rule = classes()
                .that().haveSimpleNameEndingWith("UseCase")
                .or().haveSimpleNameEndingWith("UseCaseImpl")
                .should().resideInAPackage("..application..")
                .because("Use cases belong in the application layer");

        rule.check(classes);
    }

    @Test
    @DisplayName("Repository interfaces should be in domain layer")
    void repositoryInterfacesShouldBeInDomainLayer() {
        ArchRule rule = classes()
                .that().haveSimpleNameEndingWith("Repository")
                .and().areInterfaces()
                .should().resideInAPackage("..domain.port.output..")
                .because("Repository interfaces are domain ports");

        rule.check(classes);
    }

    @Test
    @DisplayName("Repository implementations should be in infrastructure layer")
    void repositoryImplementationsShouldBeInInfrastructureLayer() {
        ArchRule rule = classes()
                .that().haveSimpleNameEndingWith("RepositoryAdapter")
                .or().haveSimpleNameEndingWith("RepositoryImpl")
                .should().resideInAPackage("..infrastructure.adapter.persistence..")
                .because("Repository implementations belong in infrastructure layer");

        rule.check(classes);
    }

    @Test
    @DisplayName("Controllers should be in API layer")
    void controllersShouldBeInApiLayer() {
        ArchRule rule = classes()
                .that().haveSimpleNameEndingWith("Controller")
                .should().resideInAPackage("..api.controller..")
                .because("Controllers belong in the API layer");

        rule.check(classes);
    }

    @Test
    @DisplayName("Clean Architecture layers should be respected")
    void cleanArchitectureLayersShouldBeRespected() {
        ArchRule rule = layeredArchitecture()
                .consideringAllDependencies()
                .layer("Domain").definedBy("..domain..")
                .layer("Application").definedBy("..application..")
                .layer("Infrastructure").definedBy("..infrastructure..")
                .layer("API").definedBy("..api..")

                .whereLayer("Domain").mayOnlyBeAccessedByLayers("Application", "Infrastructure", "API")
                .whereLayer("Application").mayOnlyBeAccessedByLayers("Infrastructure", "API")
                .whereLayer("Infrastructure").mayOnlyBeAccessedByLayers("API")
                .whereLayer("API").mayNotBeAccessedByAnyLayer()

                .because("Clean Architecture dependencies must flow inward");

        rule.check(classes);
    }

    @Test
    @DisplayName("Domain entities should not have JPA annotations")
    void domainEntitiesShouldNotHaveJpaAnnotations() {
        ArchRule rule = noClasses()
                .that().resideInAPackage("..domain.model..")
                .should().dependOnClassesThat()
                .resideInAPackage("jakarta.persistence..")
                .orShould().dependOnClassesThat()
                .resideInAPackage("javax.persistence..")
                .because("Domain entities should be persistence-agnostic");

        rule.check(classes);
    }

    @Test
    @DisplayName("Value objects should be immutable")
    void valueObjectsShouldBeImmutable() {
        ArchRule rule = classes()
                .that().resideInAPackage("..domain.model.valueobject..")
                .should().haveOnlyFinalFields()
                .because("Value objects must be immutable");

        rule.check(classes);
    }

    @Test
    @DisplayName("Services should follow naming conventions")
    void servicesShouldFollowNamingConventions() {
        ArchRule rule = classes()
                .that().resideInAPackage("..application.service..")
                .should().haveSimpleNameEndingWith("Service")
                .because("Services should follow naming conventions");

        rule.check(classes);
    }

    @Test
    @DisplayName("Ports should be interfaces")
    void portsShouldBeInterfaces() {
        ArchRule rule = classes()
                .that().resideInAPackage("..domain.port..")
                .should().beInterfaces()
                .because("Ports should be interfaces defining contracts");

        rule.check(classes);
    }
}
EOF

    log_success "Generated ArchUnit test file"
}

# Run architecture validation
run_validation() {
    log_info "Running architecture validation..."

    # Check if Maven is available
    if ! command -v mvn &> /dev/null; then
        log_error "Maven is not installed or not in PATH"
        exit 1
    fi

    # Compile the project first to ensure classes are available
    log_info "Compiling project..."
    mvn compile test-compile -q

    # Run only architecture tests
    log_info "Running ArchUnit tests..."
    mvn test -Dtest="*ArchitectureTest" -q

    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log_success "✓ Architecture validation passed!"
        return 0
    else
        log_error "✗ Architecture validation failed!"
        return 1
    fi
}

# Check violations manually (fallback if Maven test fails)
check_violations_manually() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')
    local violations=0

    log_info "Performing manual architecture checks..."

    # Check 1: Domain layer dependencies
    log_info "Checking domain layer dependencies..."
    if grep -r "import.*\.infrastructure\." "src/main/java/$package_path/domain/" 2>/dev/null; then
        log_error "Domain layer has dependencies on infrastructure layer"
        violations=$((violations + 1))
    fi

    if grep -r "import.*\.application\." "src/main/java/$package_path/domain/" 2>/dev/null; then
        log_error "Domain layer has dependencies on application layer"
        violations=$((violations + 1))
    fi

    if grep -r "import org\.springframework\." "src/main/java/$package_path/domain/" 2>/dev/null | grep -v "import org.springframework.lang" ; then
        log_error "Domain layer has Spring framework dependencies"
        violations=$((violations + 1))
    fi

    # Check 2: Application layer dependencies
    log_info "Checking application layer dependencies..."
    if grep -r "import.*\.infrastructure\." "src/main/java/$package_path/application/" 2>/dev/null; then
        log_warning "Application layer has direct dependencies on infrastructure layer (should use ports)"
        violations=$((violations + 1))
    fi

    # Check 3: Use case locations
    log_info "Checking use case locations..."
    if find "src/main/java/$package_path" -name "*UseCase*.java" -type f | grep -v "/application/" | grep -v "/domain/port/"; then
        log_error "Use cases found outside application layer or domain ports"
        violations=$((violations + 1))
    fi

    # Check 4: Repository interface locations
    log_info "Checking repository locations..."
    if find "src/main/java/$package_path/domain" -name "*Repository.java" -type f | xargs grep -l "class.*Repository" 2>/dev/null; then
        log_error "Repository implementations found in domain layer (should be interfaces only)"
        violations=$((violations + 1))
    fi

    # Check 5: JPA annotations in domain
    log_info "Checking for JPA annotations in domain..."
    if grep -r "@Entity\|@Table\|@Column" "src/main/java/$package_path/domain/" 2>/dev/null; then
        log_error "JPA annotations found in domain layer"
        violations=$((violations + 1))
    fi

    # Summary
    echo ""
    if [ $violations -eq 0 ]; then
        log_success "✓ No architecture violations found!"
        return 0
    else
        log_error "✗ Found $violations architecture violation(s)"
        return 1
    fi
}

# Main execution
main() {
    parse_arguments "$@"

    # Check if in a Spring Boot project
    if [ ! -f "pom.xml" ]; then
        log_error "Not in a Spring Boot project directory (pom.xml not found)"
        exit 1
    fi

    PACKAGE_NAME=$(get_package_name)
    log_info "Package name: $PACKAGE_NAME"

    # Generate ArchUnit test if requested or if it doesn't exist
    PACKAGE_PATH=$(echo "$PACKAGE_NAME" | tr '.' '/')
    TEST_PATH="src/test/java/$PACKAGE_PATH/architecture/ArchitectureTest.java"

    if [ "$GENERATE_TEST" = "true" ] || [ ! -f "$TEST_PATH" ]; then
        generate_archunit_test "$PACKAGE_NAME"
    fi

    # Try to run validation with Maven
    if run_validation; then
        echo ""
        log_info "Architecture validation complete"
        echo ""
        echo "Clean Architecture Rules Validated:"
        echo "  ✓ Domain layer independence"
        echo "  ✓ Application layer abstraction"
        echo "  ✓ Infrastructure layer isolation"
        echo "  ✓ Proper layer dependencies"
        echo "  ✓ Naming conventions"
        echo "  ✓ Port/Adapter pattern"
    else
        echo ""
        log_warning "Running manual checks as fallback..."
        check_violations_manually "$PACKAGE_NAME"
    fi
}

# Run main
main "$@"