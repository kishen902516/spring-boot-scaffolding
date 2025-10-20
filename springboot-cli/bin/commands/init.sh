#!/bin/bash

# Spring Boot CLI - Init Command
# Initialize a new Spring Boot project with Clean Architecture

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Default values
PROJECT_NAME=""
PACKAGE_NAME=""
DATABASE="mssql"
OPENAPI_SPEC=""
FEATURES=""
CAMEL_ASSESSMENT="false"
DOCKER_AVAILABLE="false"

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --name)
                PROJECT_NAME="$2"
                shift 2
                ;;
            --package)
                PACKAGE_NAME="$2"
                shift 2
                ;;
            --database)
                DATABASE="$2"
                shift 2
                ;;
            --openapi)
                OPENAPI_SPEC="$2"
                shift 2
                ;;
            --features)
                FEATURES="$2"
                shift 2
                ;;
            --camel-assessment)
                CAMEL_ASSESSMENT="true"
                shift
                ;;
            --docker-available)
                DOCKER_AVAILABLE="$2"
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
Usage: springboot-cli.sh init [OPTIONS]

Initialize a new Spring Boot project with Clean Architecture.

Options:
    --name <name>               Service name (required, kebab-case)
    --package <package>         Java package (required, e.g., com.company.myservice)
    --database <type>           Database type: mssql or mongodb (default: mssql)
    --openapi <path>            Path to OpenAPI 3.1 specification
    --features <features>       Comma-separated features: oauth2,eventsourcing-full,eventsourcing-lite
    --camel-assessment          Run Camel integration assessment
    --docker-available <bool>   Docker availability: true or false (default: false)
    --help, -h                  Show this help message

Examples:
    # Basic initialization with MS SQL
    springboot-cli.sh init --name my-service --package com.company.myservice

    # With MongoDB and OAuth2
    springboot-cli.sh init --name my-service --package com.company.myservice \\
        --database mongodb --features oauth2

    # With OpenAPI spec and full event sourcing
    springboot-cli.sh init --name my-service --package com.company.myservice \\
        --openapi ./api-spec.yaml --features oauth2,eventsourcing-full
EOF
}

# Validate inputs
validate_inputs() {
    if [ -z "$PROJECT_NAME" ]; then
        log_error "Project name is required (--name)"
        exit 1
    fi

    if [ -z "$PACKAGE_NAME" ]; then
        log_error "Package name is required (--package)"
        exit 1
    fi

    # Validate project name (kebab-case)
    if ! [[ "$PROJECT_NAME" =~ ^[a-z][a-z0-9-]*[a-z0-9]$ ]]; then
        log_error "Project name must be in kebab-case (e.g., my-service)"
        exit 1
    fi

    # Validate package name
    if ! [[ "$PACKAGE_NAME" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)*$ ]]; then
        log_error "Invalid package name format (e.g., com.company.myservice)"
        exit 1
    fi

    # Validate database type
    if [[ "$DATABASE" != "mssql" && "$DATABASE" != "mongodb" ]]; then
        log_error "Database must be either 'mssql' or 'mongodb'"
        exit 1
    fi

    # Check if project directory already exists
    if [ -d "$PROJECT_NAME" ]; then
        log_error "Directory '$PROJECT_NAME' already exists"
        exit 1
    fi

    # Validate OpenAPI spec if provided
    if [ -n "$OPENAPI_SPEC" ] && [ ! -f "$OPENAPI_SPEC" ]; then
        log_error "OpenAPI spec file not found: $OPENAPI_SPEC"
        exit 1
    fi
}

# Create project structure
create_project_structure() {
    log_info "Creating project structure for: $PROJECT_NAME"

    # Convert package name to directory path
    PACKAGE_PATH=$(echo "$PACKAGE_NAME" | tr '.' '/')

    # Create base directories
    mkdir -p "$PROJECT_NAME"/{src/{main/{java/"$PACKAGE_PATH",resources/{db/{migration,changelog},config}},test/{java/"$PACKAGE_PATH",resources}},docs,openapi}

    # Create clean architecture directories
    mkdir -p "$PROJECT_NAME/src/main/java/$PACKAGE_PATH"/{domain/{model/{aggregate,entity,valueobject},event,exception,port/{input,output}},application/{usecase,service,eventhandler,dto},infrastructure/{adapter/{persistence/{mssql,mongodb},messaging,client,observability},config,exception},api/{controller,dto,mapper}}

    # Create test directories
    mkdir -p "$PROJECT_NAME/src/test/java/$PACKAGE_PATH"/{unit/{domain,application,infrastructure},integration/{api,persistence,client},contract/{provider,consumer},architecture}

    log_success "Project structure created"
}

# Generate pom.xml
generate_pom() {
    log_info "Generating pom.xml for $DATABASE database"

    local POM_TEMPLATE
    if [ "$DATABASE" = "mssql" ]; then
        POM_TEMPLATE="$TEMPLATES_DIR/base/pom-mssql.xml"
    else
        POM_TEMPLATE="$TEMPLATES_DIR/base/pom-mongodb.xml"
    fi

    # Create pom.xml with substitutions
    cat > "$PROJECT_NAME/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.3.0</version>
        <relativePath/>
    </parent>

    <groupId>__PACKAGE_NAME__</groupId>
    <artifactId>__PROJECT_NAME__</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>__PROJECT_NAME__</name>
    <description>Spring Boot service with Clean Architecture</description>

    <properties>
        <java.version>21</java.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <spring-cloud.version>2023.0.0</spring-cloud.version>
        <resilience4j.version>2.2.0</resilience4j.version>
        <applicationinsights.version>3.7.5</applicationinsights.version>
        <testcontainers.version>1.19.3</testcontainers.version>
        <archunit.version>1.2.1</archunit.version>
        <pact.version>4.6.3</pact.version>
        <pitest.version>1.15.3</pitest.version>
        <openapi-generator.version>7.1.0</openapi-generator.version>
        <springdoc-openapi.version>2.3.0</springdoc-openapi.version>
    </properties>

    <dependencies>
        <!-- Spring Boot Core -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

EOF

    # Add database-specific dependencies
    if [ "$DATABASE" = "mssql" ]; then
        cat >> "$PROJECT_NAME/pom.xml" << 'EOF'
        <!-- MS SQL Database -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>com.microsoft.sqlserver</groupId>
            <artifactId>mssql-jdbc</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-sqlserver</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>

EOF
    else
        cat >> "$PROJECT_NAME/pom.xml" << 'EOF'
        <!-- MongoDB Database -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-mongodb</artifactId>
        </dependency>
        <dependency>
            <groupId>io.mongock</groupId>
            <artifactId>mongock-springboot-v3</artifactId>
            <version>5.3.4</version>
        </dependency>
        <dependency>
            <groupId>io.mongock</groupId>
            <artifactId>mongodb-springdata-v4-driver</artifactId>
            <version>5.3.4</version>
        </dependency>

EOF
    fi

    # Add common dependencies
    cat >> "$PROJECT_NAME/pom.xml" << 'EOF'
        <!-- Security -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
        </dependency>

        <!-- Observability -->
        <dependency>
            <groupId>com.microsoft.azure</groupId>
            <artifactId>applicationinsights-core</artifactId>
            <version>${applicationinsights.version}</version>
        </dependency>
        <dependency>
            <groupId>net.logstash.logback</groupId>
            <artifactId>logstash-logback-encoder</artifactId>
            <version>7.4</version>
        </dependency>

        <!-- Resilience -->
        <dependency>
            <groupId>io.github.resilience4j</groupId>
            <artifactId>resilience4j-spring-boot3</artifactId>
            <version>${resilience4j.version}</version>
        </dependency>
        <dependency>
            <groupId>io.github.resilience4j</groupId>
            <artifactId>resilience4j-circuitbreaker</artifactId>
            <version>${resilience4j.version}</version>
        </dependency>

        <!-- OpenAPI -->
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
            <version>${springdoc-openapi.version}</version>
        </dependency>

        <!-- Utilities -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.mapstruct</groupId>
            <artifactId>mapstruct</artifactId>
            <version>1.5.5.Final</version>
        </dependency>
        <dependency>
            <groupId>org.mapstruct</groupId>
            <artifactId>mapstruct-processor</artifactId>
            <version>1.5.5.Final</version>
            <scope>provided</scope>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>io.rest-assured</groupId>
            <artifactId>rest-assured</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>testcontainers</artifactId>
            <version>${testcontainers.version}</version>
            <scope>test</scope>
        </dependency>
EOF

    # Add database-specific test dependencies
    if [ "$DATABASE" = "mssql" ]; then
        cat >> "$PROJECT_NAME/pom.xml" << 'EOF'
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>mssqlserver</artifactId>
            <version>${testcontainers.version}</version>
            <scope>test</scope>
        </dependency>
EOF
    else
        cat >> "$PROJECT_NAME/pom.xml" << 'EOF'
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>mongodb</artifactId>
            <version>${testcontainers.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>de.flapdoodle.embed</groupId>
            <artifactId>de.flapdoodle.embed.mongo</artifactId>
            <version>4.9.3</version>
            <scope>test</scope>
        </dependency>
EOF
    fi

    # Add remaining test dependencies and close
    cat >> "$PROJECT_NAME/pom.xml" << 'EOF'
        <dependency>
            <groupId>com.github.tomakehurst</groupId>
            <artifactId>wiremock-jre8-standalone</artifactId>
            <version>3.0.1</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>com.tngtech.archunit</groupId>
            <artifactId>archunit-junit5</artifactId>
            <version>${archunit.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>au.com.dius.pact.consumer</groupId>
            <artifactId>junit5</artifactId>
            <version>${pact.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>au.com.dius.pact.provider</groupId>
            <artifactId>junit5</artifactId>
            <version>${pact.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>

            <!-- Code Quality -->
            <plugin>
                <groupId>com.spotify.fmt</groupId>
                <artifactId>fmt-maven-plugin</artifactId>
                <version>2.21.1</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>format</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-checkstyle-plugin</artifactId>
                <version>3.3.1</version>
                <configuration>
                    <configLocation>checkstyle.xml</configLocation>
                    <consoleOutput>true</consoleOutput>
                    <failsOnError>true</failsOnError>
                </configuration>
                <executions>
                    <execution>
                        <id>validate</id>
                        <phase>validate</phase>
                        <goals>
                            <goal>check</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>

            <!-- Testing -->
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.11</version>
                <executions>
                    <execution>
                        <id>prepare-agent</id>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>test</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>check</id>
                        <goals>
                            <goal>check</goal>
                        </goals>
                        <configuration>
                            <rules>
                                <rule>
                                    <element>BUNDLE</element>
                                    <limits>
                                        <limit>
                                            <counter>LINE</counter>
                                            <value>COVEREDRATIO</value>
                                            <minimum>0.80</minimum>
                                        </limit>
                                    </limits>
                                </rule>
                            </rules>
                        </configuration>
                    </execution>
                </executions>
            </plugin>

            <plugin>
                <groupId>org.pitest</groupId>
                <artifactId>pitest-maven</artifactId>
                <version>${pitest.version}</version>
                <configuration>
                    <targetClasses>
                        <param>__PACKAGE_NAME__.*</param>
                    </targetClasses>
                    <targetTests>
                        <param>__PACKAGE_NAME__.*</param>
                    </targetTests>
                    <mutationThreshold>80</mutationThreshold>
                    <coverageThreshold>80</coverageThreshold>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

    # Replace placeholders
    sed -i "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$PROJECT_NAME/pom.xml"
    sed -i "s/__PACKAGE_NAME__/$PACKAGE_NAME/g" "$PROJECT_NAME/pom.xml"

    log_success "Generated pom.xml"
}

# Generate application files
generate_application_files() {
    log_info "Generating application files"

    # Generate main application class
    PACKAGE_PATH=$(echo "$PACKAGE_NAME" | tr '.' '/')
    CLASSNAME=$(echo "$PROJECT_NAME" | sed 's/-//g' | sed 's/\b\(.\)/\u\1/g')

    cat > "$PROJECT_NAME/src/main/java/$PACKAGE_PATH/${CLASSNAME}Application.java" << EOF
package $PACKAGE_NAME;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ${CLASSNAME}Application {

    public static void main(String[] args) {
        SpringApplication.run(${CLASSNAME}Application.class, args);
    }
}
EOF

    # Generate application.yml
    cat > "$PROJECT_NAME/src/main/resources/application.yml" << 'EOF'
spring:
  application:
    name: __PROJECT_NAME__
  profiles:
    active: dev
  threads:
    virtual:
      enabled: true

server:
  port: 8080
  error:
    include-message: always
    include-binding-errors: always

# Azure Application Insights
azure:
  application-insights:
    enabled: true
    connection-string: ${APPLICATIONINSIGHTS_CONNECTION_STRING:}
    web:
      enable-W3C-distributed-tracing: true
    customDimensions:
      environment: ${SPRING_PROFILES_ACTIVE:local}
      service: ${spring.application.name}
    sampling:
      percentage: 100
    performance-counters:
      enabled: true
    heartbeat:
      enabled: true
      interval: 900

# Actuator
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: when-authorized
      probes:
        enabled: true
  metrics:
    export:
      azure:
        enabled: true

# OpenAPI Documentation
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html
    enabled: true

# Logging
logging:
  level:
    root: INFO
    __PACKAGE_NAME__: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
EOF

    # Replace placeholders
    sed -i "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$PROJECT_NAME/src/main/resources/application.yml"
    sed -i "s/__PACKAGE_NAME__/$PACKAGE_NAME/g" "$PROJECT_NAME/src/main/resources/application.yml"

    # Generate application-dev.yml
    if [ "$DATABASE" = "mssql" ]; then
        cat > "$PROJECT_NAME/src/main/resources/application-dev.yml" << 'EOF'
spring:
  datasource:
    url: jdbc:sqlserver://localhost:1433;databaseName=__PROJECT_NAME__;encrypt=false
    username: sa
    password: ${DB_PASSWORD:Password123!}
    driver-class-name: com.microsoft.sqlserver.jdbc.SQLServerDriver
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
    properties:
      hibernate:
        format_sql: true
  flyway:
    enabled: true
    baseline-on-migrate: true
    locations: classpath:db/migration

logging:
  level:
    root: INFO
    __PACKAGE_NAME__: DEBUG
    org.springframework.web: DEBUG
    org.hibernate.SQL: DEBUG
EOF
    else
        cat > "$PROJECT_NAME/src/main/resources/application-dev.yml" << 'EOF'
spring:
  data:
    mongodb:
      uri: mongodb://localhost:27017/__PROJECT_NAME__
      auto-index-creation: true

mongock:
  enabled: true
  change-logs-scan-package: __PACKAGE_NAME__.infrastructure.adapter.persistence.mongodb.changelog

logging:
  level:
    root: INFO
    __PACKAGE_NAME__: DEBUG
    org.springframework.web: DEBUG
    org.springframework.data.mongodb: DEBUG
EOF
    fi

    # Replace placeholders
    sed -i "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$PROJECT_NAME/src/main/resources/application-dev.yml"
    sed -i "s/__PACKAGE_NAME__/$PACKAGE_NAME/g" "$PROJECT_NAME/src/main/resources/application-dev.yml"

    # Generate application-h2.yml for quick development
    cat > "$PROJECT_NAME/src/main/resources/application-h2.yml" << 'EOF'
spring:
  datasource:
    url: jdbc:h2:mem:testdb;MODE=MSSQLServer;DB_CLOSE_ON_EXIT=FALSE
    driver-class-name: org.h2.Driver
    username: sa
    password:
  h2:
    console:
      enabled: true
      path: /h2-console
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
  flyway:
    enabled: false

azure:
  application-insights:
    enabled: false
EOF

    log_success "Generated application configuration files"
}

# Generate .gitignore
generate_gitignore() {
    cat > "$PROJECT_NAME/.gitignore" << 'EOF'
# Compiled class files
*.class

# Log files
*.log

# BlueJ files
*.ctxt

# Mobile Tools for Java (J2ME)
.mtj.tmp/

# Package Files
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar

# virtual machine crash logs
hs_err_pid*
replay_pid*

# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties
.mvn/wrapper/maven-wrapper.jar

# IDE files
.idea/
*.iws
*.iml
*.ipr
.vscode/
.project
.classpath
.settings/

# OS files
.DS_Store
Thumbs.db

# Application specific
application-local.yml
application-secrets.yml
*.env
.env.*
EOF

    log_success "Generated .gitignore"
}

# Generate checkstyle.xml
generate_checkstyle() {
    log_info "Generating checkstyle.xml"

    if [ -f "$TEMPLATES_DIR/base/checkstyle.xml" ]; then
        cp "$TEMPLATES_DIR/base/checkstyle.xml" "$PROJECT_NAME/checkstyle.xml"
        log_success "Generated checkstyle.xml"
    else
        log_warning "checkstyle.xml template not found, skipping"
    fi
}

# Main execution
main() {
    parse_arguments "$@"
    validate_inputs

    log_info "Initializing Spring Boot project: $PROJECT_NAME"
    log_info "Package: $PACKAGE_NAME"
    log_info "Database: $DATABASE"

    create_project_structure
    generate_pom
    generate_application_files
    generate_gitignore
    generate_checkstyle

    # If OpenAPI spec provided, copy it
    if [ -n "$OPENAPI_SPEC" ]; then
        log_info "Copying OpenAPI specification"
        cp "$OPENAPI_SPEC" "$PROJECT_NAME/openapi/api-spec.yaml"
        log_success "OpenAPI spec copied"
    fi

    # Run Camel assessment if requested
    if [ "$CAMEL_ASSESSMENT" = "true" ]; then
        log_info "Running Camel integration assessment..."
        # This would call the assess-camel.sh script
        # For now, just show a placeholder message
        log_info "Camel assessment will be available in the next version"
    fi

    log_success "✓ Project initialized successfully!"
    echo ""
    log_info "Next steps:"
    echo "  1. cd $PROJECT_NAME"
    echo "  2. mvn clean compile"
    echo "  3. mvn spring-boot:run -Dspring-boot.run.profiles=h2"
    echo ""
    echo "For more commands, run: springboot-cli.sh help"
}

# Run main
main "$@"