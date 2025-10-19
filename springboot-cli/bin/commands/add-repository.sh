#!/bin/bash

# Spring Boot CLI - Add Repository Command
# Add a new repository for an entity to an existing Spring Boot project

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
REPOSITORY_TYPE=""

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --entity)
                ENTITY_NAME="$2"
                shift 2
                ;;
            --type)
                REPOSITORY_TYPE="$2"
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
Usage: springboot-cli.sh add repository [OPTIONS]

Add a new repository for an entity to an existing Spring Boot project.

Options:
    --entity <name>    Entity name (required, e.g., Product)
    --type <type>      Repository type: jpa or mongo (optional, auto-detected from pom.xml)
    --help, -h         Show this help message

Examples:
    # Add a JPA repository
    springboot-cli.sh add repository --entity Product --type jpa

    # Add a MongoDB repository
    springboot-cli.sh add repository --entity Product --type mongo

    # Auto-detect repository type from project
    springboot-cli.sh add repository --entity Product
EOF
}

# Validate inputs
validate_inputs() {
    if [ -z "$ENTITY_NAME" ]; then
        log_error "Entity name is required (--entity)"
        exit 1
    fi

    # Check if in a Spring Boot project
    if [ ! -f "pom.xml" ]; then
        log_error "Not in a Spring Boot project directory (pom.xml not found)"
        exit 1
    fi

    # Auto-detect repository type if not specified
    if [ -z "$REPOSITORY_TYPE" ]; then
        if grep -q "spring-boot-starter-data-mongodb" pom.xml; then
            REPOSITORY_TYPE="mongo"
            log_info "Auto-detected MongoDB repository type"
        else
            REPOSITORY_TYPE="jpa"
            log_info "Auto-detected JPA repository type"
        fi
    fi

    if [[ "$REPOSITORY_TYPE" != "jpa" && "$REPOSITORY_TYPE" != "mongo" ]]; then
        log_error "Repository type must be either 'jpa' or 'mongo'"
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

# Generate repository interface (domain port)
generate_repository_interface() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')
    local interface_path="src/main/java/$package_path/domain/port/output/${ENTITY_NAME}Repository.java"

    log_info "Generating repository interface: $interface_path"

    mkdir -p "$(dirname "$interface_path")"

    cat > "$interface_path" << EOF
package ${package_name}.domain.port.output;

import ${package_name}.domain.model.entity.${ENTITY_NAME};
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository interface for ${ENTITY_NAME} entity
 * This is a port in the hexagonal architecture
 */
public interface ${ENTITY_NAME}Repository {

    /**
     * Save or update an entity
     *
     * @param ${ENTITY_NAME,,} the entity to save
     * @return the saved entity
     */
    ${ENTITY_NAME} save(${ENTITY_NAME} ${ENTITY_NAME,,});

    /**
     * Find an entity by ID
     *
     * @param id the entity ID
     * @return an Optional containing the entity if found
     */
    Optional<${ENTITY_NAME}> findById(UUID id);

    /**
     * Find all entities
     *
     * @return list of all entities
     */
    List<${ENTITY_NAME}> findAll();

    /**
     * Check if an entity exists by ID
     *
     * @param id the entity ID
     * @return true if exists, false otherwise
     */
    boolean existsById(UUID id);

    /**
     * Delete an entity by ID
     *
     * @param id the entity ID
     */
    void deleteById(UUID id);

    /**
     * Delete all entities
     */
    void deleteAll();

    /**
     * Count all entities
     *
     * @return the total count of entities
     */
    long count();
}
EOF

    log_success "Generated repository interface"
}

# Generate JPA implementation
generate_jpa_implementation() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')

    # Generate JPA Entity
    local entity_path="src/main/java/$package_path/infrastructure/adapter/persistence/mssql/entity/${ENTITY_NAME}Entity.java"
    log_info "Generating JPA entity: $entity_path"

    mkdir -p "$(dirname "$entity_path")"

    cat > "$entity_path" << EOF
package ${package_name}.infrastructure.adapter.persistence.mssql.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import java.util.UUID;
import java.time.Instant;

/**
 * JPA Entity for ${ENTITY_NAME}
 */
@Entity
@Table(name = "${ENTITY_NAME,,}s")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ${ENTITY_NAME}Entity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false)
    private UUID id;

    // TODO: Add entity fields matching the domain entity
    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description")
    private String description;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = Instant.now();
        updatedAt = Instant.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = Instant.now();
    }
}
EOF

    # Generate Spring Data JPA Repository
    local jpa_repo_path="src/main/java/$package_path/infrastructure/adapter/persistence/mssql/repository/Jpa${ENTITY_NAME}Repository.java"
    log_info "Generating Spring Data JPA repository: $jpa_repo_path"

    mkdir -p "$(dirname "$jpa_repo_path")"

    cat > "$jpa_repo_path" << EOF
package ${package_name}.infrastructure.adapter.persistence.mssql.repository;

import ${package_name}.infrastructure.adapter.persistence.mssql.entity.${ENTITY_NAME}Entity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.UUID;
import java.util.Optional;

/**
 * Spring Data JPA Repository for ${ENTITY_NAME}Entity
 */
@Repository
public interface Jpa${ENTITY_NAME}Repository extends JpaRepository<${ENTITY_NAME}Entity, UUID> {

    // Add custom query methods as needed
    Optional<${ENTITY_NAME}Entity> findByName(String name);

    @Query("SELECT e FROM ${ENTITY_NAME}Entity e WHERE e.name LIKE %:keyword%")
    List<${ENTITY_NAME}Entity> searchByKeyword(String keyword);
}
EOF

    # Generate Repository Adapter
    local adapter_path="src/main/java/$package_path/infrastructure/adapter/persistence/mssql/adapter/${ENTITY_NAME}RepositoryAdapter.java"
    log_info "Generating repository adapter: $adapter_path"

    mkdir -p "$(dirname "$adapter_path")"

    cat > "$adapter_path" << EOF
package ${package_name}.infrastructure.adapter.persistence.mssql.adapter;

import ${package_name}.domain.model.entity.${ENTITY_NAME};
import ${package_name}.domain.port.output.${ENTITY_NAME}Repository;
import ${package_name}.infrastructure.adapter.persistence.mssql.entity.${ENTITY_NAME}Entity;
import ${package_name}.infrastructure.adapter.persistence.mssql.repository.Jpa${ENTITY_NAME}Repository;
import ${package_name}.infrastructure.adapter.persistence.mssql.mapper.${ENTITY_NAME}EntityMapper;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Adapter implementation of ${ENTITY_NAME}Repository using JPA
 */
@Component
@Transactional
public class ${ENTITY_NAME}RepositoryAdapter implements ${ENTITY_NAME}Repository {

    private final Jpa${ENTITY_NAME}Repository jpaRepository;
    private final ${ENTITY_NAME}EntityMapper mapper;

    public ${ENTITY_NAME}RepositoryAdapter(Jpa${ENTITY_NAME}Repository jpaRepository,
                                           ${ENTITY_NAME}EntityMapper mapper) {
        this.jpaRepository = jpaRepository;
        this.mapper = mapper;
    }

    @Override
    public ${ENTITY_NAME} save(${ENTITY_NAME} ${ENTITY_NAME,,}) {
        ${ENTITY_NAME}Entity entity = mapper.toEntity(${ENTITY_NAME,,});
        ${ENTITY_NAME}Entity saved = jpaRepository.save(entity);
        return mapper.toDomain(saved);
    }

    @Override
    public Optional<${ENTITY_NAME}> findById(UUID id) {
        return jpaRepository.findById(id)
                .map(mapper::toDomain);
    }

    @Override
    public List<${ENTITY_NAME}> findAll() {
        return jpaRepository.findAll()
                .stream()
                .map(mapper::toDomain)
                .collect(Collectors.toList());
    }

    @Override
    public boolean existsById(UUID id) {
        return jpaRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        jpaRepository.deleteById(id);
    }

    @Override
    public void deleteAll() {
        jpaRepository.deleteAll();
    }

    @Override
    public long count() {
        return jpaRepository.count();
    }
}
EOF

    # Generate Mapper
    local mapper_path="src/main/java/$package_path/infrastructure/adapter/persistence/mssql/mapper/${ENTITY_NAME}EntityMapper.java"
    log_info "Generating entity mapper: $mapper_path"

    mkdir -p "$(dirname "$mapper_path")"

    cat > "$mapper_path" << EOF
package ${package_name}.infrastructure.adapter.persistence.mssql.mapper;

import ${package_name}.domain.model.entity.${ENTITY_NAME};
import ${package_name}.infrastructure.adapter.persistence.mssql.entity.${ENTITY_NAME}Entity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

/**
 * MapStruct mapper for converting between ${ENTITY_NAME} and ${ENTITY_NAME}Entity
 */
@Mapper(componentModel = "spring")
public interface ${ENTITY_NAME}EntityMapper {

    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    ${ENTITY_NAME}Entity toEntity(${ENTITY_NAME} domain);

    ${ENTITY_NAME} toDomain(${ENTITY_NAME}Entity entity);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateEntity(@MappingTarget ${ENTITY_NAME}Entity entity, ${ENTITY_NAME} domain);
}
EOF

    log_success "Generated JPA implementation files"
}

# Generate MongoDB implementation
generate_mongo_implementation() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')

    # Generate MongoDB Document
    local document_path="src/main/java/$package_path/infrastructure/adapter/persistence/mongodb/document/${ENTITY_NAME}Document.java"
    log_info "Generating MongoDB document: $document_path"

    mkdir -p "$(dirname "$document_path")"

    cat > "$document_path" << EOF
package ${package_name}.infrastructure.adapter.persistence.mongodb.document;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.index.Indexed;
import java.util.UUID;
import java.time.Instant;

/**
 * MongoDB Document for ${ENTITY_NAME}
 */
@Document(collection = "${ENTITY_NAME,,}s")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ${ENTITY_NAME}Document {

    @Id
    private String id;

    private UUID businessId;

    // TODO: Add document fields matching the domain entity
    @Indexed
    private String name;

    private String description;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}
EOF

    # Generate Spring Data MongoDB Repository
    local mongo_repo_path="src/main/java/$package_path/infrastructure/adapter/persistence/mongodb/repository/Mongo${ENTITY_NAME}Repository.java"
    log_info "Generating Spring Data MongoDB repository: $mongo_repo_path"

    mkdir -p "$(dirname "$mongo_repo_path")"

    cat > "$mongo_repo_path" << EOF
package ${package_name}.infrastructure.adapter.persistence.mongodb.repository;

import ${package_name}.infrastructure.adapter.persistence.mongodb.document.${ENTITY_NAME}Document;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.UUID;
import java.util.Optional;
import java.util.List;

/**
 * Spring Data MongoDB Repository for ${ENTITY_NAME}Document
 */
@Repository
public interface Mongo${ENTITY_NAME}Repository extends MongoRepository<${ENTITY_NAME}Document, String> {

    Optional<${ENTITY_NAME}Document> findByBusinessId(UUID businessId);

    Optional<${ENTITY_NAME}Document> findByName(String name);

    @Query("{'name': {'\$regex': ?0, '\$options': 'i'}}")
    List<${ENTITY_NAME}Document> searchByKeyword(String keyword);

    void deleteByBusinessId(UUID businessId);

    boolean existsByBusinessId(UUID businessId);
}
EOF

    # Generate Repository Adapter
    local adapter_path="src/main/java/$package_path/infrastructure/adapter/persistence/mongodb/adapter/${ENTITY_NAME}RepositoryAdapter.java"
    log_info "Generating MongoDB repository adapter: $adapter_path"

    mkdir -p "$(dirname "$adapter_path")"

    cat > "$adapter_path" << EOF
package ${package_name}.infrastructure.adapter.persistence.mongodb.adapter;

import ${package_name}.domain.model.entity.${ENTITY_NAME};
import ${package_name}.domain.port.output.${ENTITY_NAME}Repository;
import ${package_name}.infrastructure.adapter.persistence.mongodb.document.${ENTITY_NAME}Document;
import ${package_name}.infrastructure.adapter.persistence.mongodb.repository.Mongo${ENTITY_NAME}Repository;
import ${package_name}.infrastructure.adapter.persistence.mongodb.mapper.${ENTITY_NAME}DocumentMapper;
import org.springframework.stereotype.Component;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Adapter implementation of ${ENTITY_NAME}Repository using MongoDB
 */
@Component
public class ${ENTITY_NAME}RepositoryAdapter implements ${ENTITY_NAME}Repository {

    private final Mongo${ENTITY_NAME}Repository mongoRepository;
    private final ${ENTITY_NAME}DocumentMapper mapper;

    public ${ENTITY_NAME}RepositoryAdapter(Mongo${ENTITY_NAME}Repository mongoRepository,
                                          ${ENTITY_NAME}DocumentMapper mapper) {
        this.mongoRepository = mongoRepository;
        this.mapper = mapper;
    }

    @Override
    public ${ENTITY_NAME} save(${ENTITY_NAME} ${ENTITY_NAME,,}) {
        ${ENTITY_NAME}Document document = mapper.toDocument(${ENTITY_NAME,,});
        ${ENTITY_NAME}Document saved = mongoRepository.save(document);
        return mapper.toDomain(saved);
    }

    @Override
    public Optional<${ENTITY_NAME}> findById(UUID id) {
        return mongoRepository.findByBusinessId(id)
                .map(mapper::toDomain);
    }

    @Override
    public List<${ENTITY_NAME}> findAll() {
        return mongoRepository.findAll()
                .stream()
                .map(mapper::toDomain)
                .collect(Collectors.toList());
    }

    @Override
    public boolean existsById(UUID id) {
        return mongoRepository.existsByBusinessId(id);
    }

    @Override
    public void deleteById(UUID id) {
        mongoRepository.deleteByBusinessId(id);
    }

    @Override
    public void deleteAll() {
        mongoRepository.deleteAll();
    }

    @Override
    public long count() {
        return mongoRepository.count();
    }
}
EOF

    # Generate Mapper
    local mapper_path="src/main/java/$package_path/infrastructure/adapter/persistence/mongodb/mapper/${ENTITY_NAME}DocumentMapper.java"
    log_info "Generating document mapper: $mapper_path"

    mkdir -p "$(dirname "$mapper_path")"

    cat > "$mapper_path" << EOF
package ${package_name}.infrastructure.adapter.persistence.mongodb.mapper;

import ${package_name}.domain.model.entity.${ENTITY_NAME};
import ${package_name}.infrastructure.adapter.persistence.mongodb.document.${ENTITY_NAME}Document;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import java.util.UUID;

/**
 * MapStruct mapper for converting between ${ENTITY_NAME} and ${ENTITY_NAME}Document
 */
@Mapper(componentModel = "spring")
public interface ${ENTITY_NAME}DocumentMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(source = "id", target = "businessId")
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    ${ENTITY_NAME}Document toDocument(${ENTITY_NAME} domain);

    @Mapping(source = "businessId", target = "id")
    ${ENTITY_NAME} toDomain(${ENTITY_NAME}Document document);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "businessId", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateDocument(@MappingTarget ${ENTITY_NAME}Document document, ${ENTITY_NAME} domain);

    default String mapUUIDToString(UUID uuid) {
        return uuid != null ? uuid.toString() : null;
    }

    default UUID mapStringToUUID(String str) {
        return str != null ? UUID.fromString(str) : null;
    }
}
EOF

    log_success "Generated MongoDB implementation files"
}

# Generate integration test
generate_integration_test() {
    local package_name=$1
    local package_path=$(echo "$package_name" | tr '.' '/')
    local test_path="src/test/java/$package_path/integration/persistence/${ENTITY_NAME}RepositoryIntegrationTest.java"

    log_info "Generating integration test: $test_path"

    mkdir -p "$(dirname "$test_path")"

    if [ "$REPOSITORY_TYPE" = "jpa" ]; then
        cat > "$test_path" << EOF
package ${package_name}.integration.persistence;

import ${package_name}.domain.model.entity.${ENTITY_NAME};
import ${package_name}.domain.port.output.${ENTITY_NAME}Repository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;

/**
 * Integration tests for ${ENTITY_NAME}Repository with JPA
 */
@DataJpaTest
@Testcontainers
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ActiveProfiles("test")
@DisplayName("${ENTITY_NAME} Repository Integration Tests")
class ${ENTITY_NAME}RepositoryIntegrationTest {

    @Autowired
    private ${ENTITY_NAME}Repository repository;

    @BeforeEach
    void setUp() {
        repository.deleteAll();
    }

    @Test
    @DisplayName("Should save and retrieve ${ENTITY_NAME}")
    void shouldSaveAndRetrieve${ENTITY_NAME}() {
        // Given
        ${ENTITY_NAME} ${ENTITY_NAME,,} = create${ENTITY_NAME}();

        // When
        ${ENTITY_NAME} saved = repository.save(${ENTITY_NAME,,});
        Optional<${ENTITY_NAME}> found = repository.findById(saved.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getId()).isEqualTo(saved.getId());
    }

    @Test
    @DisplayName("Should find all ${ENTITY_NAME}s")
    void shouldFindAll${ENTITY_NAME}s() {
        // Given
        ${ENTITY_NAME} entity1 = create${ENTITY_NAME}();
        ${ENTITY_NAME} entity2 = create${ENTITY_NAME}();
        repository.save(entity1);
        repository.save(entity2);

        // When
        List<${ENTITY_NAME}> all = repository.findAll();

        // Then
        assertThat(all).hasSize(2);
    }

    @Test
    @DisplayName("Should delete ${ENTITY_NAME} by ID")
    void shouldDelete${ENTITY_NAME}ById() {
        // Given
        ${ENTITY_NAME} ${ENTITY_NAME,,} = create${ENTITY_NAME}();
        ${ENTITY_NAME} saved = repository.save(${ENTITY_NAME,,});

        // When
        repository.deleteById(saved.getId());
        Optional<${ENTITY_NAME}> found = repository.findById(saved.getId());

        // Then
        assertThat(found).isEmpty();
    }

    @Test
    @DisplayName("Should count ${ENTITY_NAME}s")
    void shouldCount${ENTITY_NAME}s() {
        // Given
        repository.save(create${ENTITY_NAME}());
        repository.save(create${ENTITY_NAME}());

        // When
        long count = repository.count();

        // Then
        assertThat(count).isEqualTo(2);
    }

    private ${ENTITY_NAME} create${ENTITY_NAME}() {
        return ${ENTITY_NAME}.builder()
                // TODO: Set appropriate test values
                .id(UUID.randomUUID())
                .name("Test ${ENTITY_NAME}")
                .description("Test Description")
                .build();
    }
}
EOF
    else
        cat > "$test_path" << EOF
package ${package_name}.integration.persistence;

import ${package_name}.domain.model.entity.${ENTITY_NAME};
import ${package_name}.domain.port.output.${ENTITY_NAME}Repository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.data.mongo.DataMongoTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;

/**
 * Integration tests for ${ENTITY_NAME}Repository with MongoDB
 */
@DataMongoTest
@Testcontainers
@ActiveProfiles("test")
@DisplayName("${ENTITY_NAME} Repository Integration Tests")
class ${ENTITY_NAME}RepositoryIntegrationTest {

    @Autowired
    private ${ENTITY_NAME}Repository repository;

    @BeforeEach
    void setUp() {
        repository.deleteAll();
    }

    @Test
    @DisplayName("Should save and retrieve ${ENTITY_NAME}")
    void shouldSaveAndRetrieve${ENTITY_NAME}() {
        // Given
        ${ENTITY_NAME} ${ENTITY_NAME,,} = create${ENTITY_NAME}();

        // When
        ${ENTITY_NAME} saved = repository.save(${ENTITY_NAME,,});
        Optional<${ENTITY_NAME}> found = repository.findById(saved.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getId()).isEqualTo(saved.getId());
    }

    @Test
    @DisplayName("Should find all ${ENTITY_NAME}s")
    void shouldFindAll${ENTITY_NAME}s() {
        // Given
        ${ENTITY_NAME} entity1 = create${ENTITY_NAME}();
        ${ENTITY_NAME} entity2 = create${ENTITY_NAME}();
        repository.save(entity1);
        repository.save(entity2);

        // When
        List<${ENTITY_NAME}> all = repository.findAll();

        // Then
        assertThat(all).hasSize(2);
    }

    @Test
    @DisplayName("Should delete ${ENTITY_NAME} by ID")
    void shouldDelete${ENTITY_NAME}ById() {
        // Given
        ${ENTITY_NAME} ${ENTITY_NAME,,} = create${ENTITY_NAME}();
        ${ENTITY_NAME} saved = repository.save(${ENTITY_NAME,,});

        // When
        repository.deleteById(saved.getId());
        Optional<${ENTITY_NAME}> found = repository.findById(saved.getId());

        // Then
        assertThat(found).isEmpty();
    }

    @Test
    @DisplayName("Should count ${ENTITY_NAME}s")
    void shouldCount${ENTITY_NAME}s() {
        // Given
        repository.save(create${ENTITY_NAME}());
        repository.save(create${ENTITY_NAME}());

        // When
        long count = repository.count();

        // Then
        assertThat(count).isEqualTo(2);
    }

    private ${ENTITY_NAME} create${ENTITY_NAME}() {
        return ${ENTITY_NAME}.builder()
                // TODO: Set appropriate test values
                .id(UUID.randomUUID())
                .name("Test ${ENTITY_NAME}")
                .description("Test Description")
                .build();
    }
}
EOF
    fi

    log_success "Generated integration test"
}

# Main execution
main() {
    parse_arguments "$@"
    validate_inputs

    log_info "Adding repository for entity: $ENTITY_NAME"
    log_info "Repository type: $REPOSITORY_TYPE"

    PACKAGE_NAME=$(get_package_name)
    log_info "Package name: $PACKAGE_NAME"

    # Generate repository interface
    generate_repository_interface "$PACKAGE_NAME"

    # Generate implementation based on type
    if [ "$REPOSITORY_TYPE" = "jpa" ]; then
        generate_jpa_implementation "$PACKAGE_NAME"
    else
        generate_mongo_implementation "$PACKAGE_NAME"
    fi

    # Generate integration test
    generate_integration_test "$PACKAGE_NAME"

    log_success "✓ Repository added successfully!"
    echo ""
    log_info "Generated files:"
    echo "  - Repository interface: domain/port/output/${ENTITY_NAME}Repository.java"

    if [ "$REPOSITORY_TYPE" = "jpa" ]; then
        echo "  - JPA Entity: infrastructure/.../mssql/entity/${ENTITY_NAME}Entity.java"
        echo "  - JPA Repository: infrastructure/.../mssql/repository/Jpa${ENTITY_NAME}Repository.java"
        echo "  - Repository Adapter: infrastructure/.../mssql/adapter/${ENTITY_NAME}RepositoryAdapter.java"
        echo "  - Entity Mapper: infrastructure/.../mssql/mapper/${ENTITY_NAME}EntityMapper.java"
    else
        echo "  - MongoDB Document: infrastructure/.../mongodb/document/${ENTITY_NAME}Document.java"
        echo "  - MongoDB Repository: infrastructure/.../mongodb/repository/Mongo${ENTITY_NAME}Repository.java"
        echo "  - Repository Adapter: infrastructure/.../mongodb/adapter/${ENTITY_NAME}RepositoryAdapter.java"
        echo "  - Document Mapper: infrastructure/.../mongodb/mapper/${ENTITY_NAME}DocumentMapper.java"
    fi

    echo "  - Integration test: test/.../integration/persistence/${ENTITY_NAME}RepositoryIntegrationTest.java"
    echo ""
    echo "Next steps:"
    echo "  1. Update the entity/document fields to match your domain model"
    echo "  2. Customize the mapper implementation"
    echo "  3. Add custom query methods as needed"
    echo "  4. Run: mvn test"
}

# Run main
main "$@"