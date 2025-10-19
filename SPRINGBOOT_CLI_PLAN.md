# Spring Boot Standardization CLI - Comprehensive Design Plan

## Executive Summary

A CLI tool for standardizing Spring Boot API development with:
- **Clean Architecture** (domain-driven design, separation of concerns)
- **API-First Development** (OpenAPI 3.1 specification-driven)
- **Google Java Style** (formatting and code quality)
- **Test Pyramid Strategy** (unit, integration, contract, mutation, architecture tests)
- **Azure Application Insights** (observability - traces, metrics, logs)
- **Resilience Patterns** (circuit breaker, retry, rate limiter with Resilience4j)
- **Security Built-in** (OAuth2 + JWT)
- **Event Sourcing Options** (full event sourcing or lightweight event-driven)
- **Optional Camel Integration** (intelligent assessment-based inclusion)
- **Java 21** (Virtual Threads, modern JDK features)
- **LLM-Friendly** (structured for both developers and AI assistants)

---

## 1. CLI Architecture

### Implementation Approach
- **PowerShell + Bash Scripts** for maximum compatibility
- **Template-based generation** for consistency
- **OpenAPI Generator integration** for spec-first development
- **Maven-based** build tool (standardized, enterprise-ready)

### CLI Directory Structure

```
springboot-cli/
├── bin/
│   ├── springboot-cli.sh              # Main bash entry point
│   ├── springboot-cli.ps1             # Main PowerShell entry point
│   └── commands/                      # Individual command scripts
│       ├── init.sh / init.ps1         # Initialize new project
│       ├── add-usecase.sh / .ps1      # Add use case
│       ├── add-entity.sh / .ps1       # Add domain entity
│       ├── add-repository.sh / .ps1   # Add repository
│       ├── add-client.sh / .ps1       # Add external client
│       ├── add-camel.sh / .ps1        # Add Camel route
│       ├── generate-openapi.sh / .ps1 # Generate from OpenAPI
│       ├── generate-contract.sh / .ps1# Generate contracts
│       ├── validate-arch.sh / .ps1    # Validate architecture
│       ├── validate-coverage.sh / .ps1# Validate test coverage
│       └── assess-camel.sh / .ps1     # Assess Camel need
├── templates/                         # Project templates
│   ├── base/                          # Base Spring Boot project
│   │   ├── pom-mssql.xml             # MS SQL variant
│   │   └── pom-mongodb.xml           # MongoDB variant
│   ├── layers/                        # Clean architecture layers
│   │   ├── domain/                   # Domain layer templates
│   │   ├── application/              # Application layer templates
│   │   ├── infrastructure/           # Infrastructure layer templates
│   │   └── api/                      # API layer templates
│   ├── security/                      # OAuth2/JWT templates
│   │   ├── SecurityConfig.java.tmpl
│   │   └── JwtAuthenticationFilter.java.tmpl
│   ├── observability/                 # App Insights templates
│   │   ├── ObservabilityConfig.java.tmpl
│   │   └── TelemetryService.java.tmpl
│   ├── eventsourcing/                # Event sourcing templates
│   │   ├── full/                     # Full event sourcing
│   │   └── lite/                     # Lightweight event-driven
│   └── camel/                         # Optional Camel templates
│       └── routes/                    # Route templates
├── generators/                        # Code generators
│   └── openapi-generator/            # OpenAPI configuration
├── config/                            # Configuration templates
│   ├── checkstyle-google.xml
│   ├── application.yml.tmpl
│   ├── application-dev.yml.tmpl
│   ├── application-prod.yml.tmpl
│   ├── application-test.yml.tmpl
│   ├── logback-spring.xml.tmpl
│   └── Dockerfile.tmpl
└── docs/                              # Documentation
    ├── README.md                      # CLI usage
    ├── ARCHITECTURE.md                # Architecture decisions
    └── llm-prompts.md                # LLM usage guide
```

---

## 2. CLI Commands

### Command: `init` - Initialize New Project

**Usage:**
```bash
./springboot-cli.sh init \
  --name my-service \
  --package com.company.myservice \
  --database mssql|mongodb \
  --openapi path/to/api-spec.yaml \
  --features oauth2,eventsourcing-full|eventsourcing-lite \
  --camel-assessment \
  --docker-available false
```

**Parameters:**
- `--name`: Service name (kebab-case)
- `--package`: Java package (e.g., com.company.service)
- `--database`: Database type (mssql | mongodb)
- `--openapi`: Path to OpenAPI 3.1 specification
- `--features`: Comma-separated features (oauth2, eventsourcing-full, eventsourcing-lite)
- `--camel-assessment`: Run Camel assessment (optional)
- `--docker-available`: Docker availability (true | false)

**Generated Output:**
- Complete Spring Boot project structure
- Clean Architecture layers (domain, application, infrastructure, api)
- OpenAPI-generated controllers and DTOs
- Database-specific configuration (MS SQL or MongoDB)
- Security configuration (if oauth2 feature enabled)
- Observability configuration (Application Insights)
- Resilience configuration (Resilience4j)
- Test infrastructure (all test types)
- Dockerfile (for future use)
- Documentation (README, architecture docs)

### Command: `add` - Add Components

#### Add Use Case
```bash
./springboot-cli.sh add usecase \
  --name ProcessOrder \
  --aggregate Order
```

Generates:
- Use case interface in `domain/port/input/`
- Use case implementation in `application/usecase/`
- Unit test skeleton

#### Add Entity
```bash
./springboot-cli.sh add entity \
  --name Product \
  --fields "id:UUID,name:String,price:BigDecimal,description:String"
```

Generates:
- Domain entity in `domain/model/entity/`
- Builder pattern implementation
- Validation logic
- Unit tests

#### Add Repository
```bash
./springboot-cli.sh add repository \
  --entity Product \
  --type jpa|mongo
```

Generates:
- Repository interface in `domain/port/output/`
- Repository implementation in `infrastructure/adapter/persistence/`
- Database entity/document mapping
- Integration test with Testcontainers (or embedded DB)

#### Add External Client
```bash
./springboot-cli.sh add client \
  --name PaymentService \
  --spec payment-api.yaml \
  --circuit-breaker \
  --retry
```

Generates:
- Client interface in `domain/port/output/`
- Client implementation in `infrastructure/adapter/client/`
- Resilience4j configuration
- Circuit breaker and retry patterns
- Mock server tests

#### Add Camel Route
```bash
./springboot-cli.sh add camel-route \
  --name FileToQueue \
  --pattern file-to-messaging \
  --from file:///input \
  --to kafka:orders
```

Generates:
- Camel route in `infrastructure/adapter/camel/`
- Route configuration
- Route tests

### Command: `generate` - Code Generation

#### Generate from OpenAPI
```bash
./springboot-cli.sh generate openapi \
  --spec api-spec.yaml \
  --update
```

Actions:
- Regenerates API interfaces and DTOs
- Updates OpenAPI configuration
- Preserves manual implementations

#### Generate Contract Tests
```bash
./springboot-cli.sh generate contracts \
  --provider \
  --consumer consumer-service-name
```

Generates:
- Pact contract tests (provider or consumer)
- Contract verification tests

### Command: `validate` - Validation

#### Validate Architecture
```bash
./springboot-cli.sh validate architecture
```

Checks:
- Clean Architecture rules (ArchUnit)
- Layer dependencies
- Naming conventions
- Package structure

#### Validate Coverage
```bash
./springboot-cli.sh validate coverage \
  --threshold 80
```

Checks:
- Code coverage (JaCoCo)
- Mutation coverage (PIT)
- Test pyramid distribution

#### Validate OpenAPI
```bash
./springboot-cli.sh validate openapi \
  --spec api-spec.yaml
```

Checks:
- OpenAPI spec validity
- Spec compliance with standards
- Breaking changes detection

### Command: `assess` - Camel Assessment

```bash
./springboot-cli.sh assess camel
```

Analyzes:
- Number of external integrations
- File/FTP operations
- Data transformations
- Messaging patterns
- Content-based routing

Outputs:
- Assessment score (0-100)
- Recommendation (strongly recommended, consider, not recommended)
- Identified patterns
- Suggested Camel routes

---

## 3. Generated Project Structure

### Complete Directory Layout

```
my-service/
├── pom.xml                                    # Maven configuration
├── Dockerfile                                 # Multi-stage build (Java 21)
├── .editorconfig                              # Google Java Style
├── checkstyle.xml                             # Google Java Style rules
├── README.md                                  # Setup and usage guide
├── openapi/
│   └── api-spec.yaml                          # OpenAPI 3.1 specification
├── src/main/java/com/company/myservice/
│   ├── domain/                                # Enterprise Business Rules Layer
│   │   ├── model/
│   │   │   ├── aggregate/                     # Aggregate roots (DDD)
│   │   │   │   └── Order.java
│   │   │   ├── entity/                        # Domain entities
│   │   │   │   ├── Product.java
│   │   │   │   └── OrderItem.java
│   │   │   └── valueobject/                   # Value objects (immutable)
│   │   │       ├── Money.java
│   │   │       └── Address.java
│   │   ├── event/                             # Domain events
│   │   │   ├── OrderCreatedEvent.java
│   │   │   └── OrderCompletedEvent.java
│   │   ├── exception/                         # Domain exceptions
│   │   │   ├── OrderNotFoundException.java
│   │   │   └── InvalidOrderStateException.java
│   │   └── port/                              # Ports (interfaces)
│   │       ├── input/                         # Use case interfaces (driving)
│   │       │   ├── ProcessOrderUseCase.java
│   │       │   └── GetOrderUseCase.java
│   │       └── output/                        # Repository/service interfaces (driven)
│   │           ├── OrderRepository.java
│   │           ├── ProductRepository.java
│   │           └── PaymentServicePort.java
│   ├── application/                           # Application Business Rules Layer
│   │   ├── usecase/                           # Use case implementations
│   │   │   ├── ProcessOrderUseCaseImpl.java
│   │   │   └── GetOrderUseCaseImpl.java
│   │   ├── service/                           # Application services
│   │   │   └── OrderValidationService.java
│   │   ├── eventhandler/                      # Event handlers
│   │   │   └── OrderEventHandler.java
│   │   └── dto/                               # Internal DTOs (if needed)
│   ├── infrastructure/                        # Frameworks & Drivers Layer
│   │   ├── adapter/
│   │   │   ├── persistence/
│   │   │   │   ├── mssql/                     # MS SQL implementation
│   │   │   │   │   ├── entity/                # JPA entities
│   │   │   │   │   │   ├── OrderEntity.java
│   │   │   │   │   │   └── ProductEntity.java
│   │   │   │   │   ├── repository/            # JPA repositories
│   │   │   │   │   │   ├── JpaOrderRepository.java
│   │   │   │   │   │   └── JpaProductRepository.java
│   │   │   │   │   ├── adapter/               # Port implementations
│   │   │   │   │   │   ├── OrderRepositoryAdapter.java
│   │   │   │   │   │   └── ProductRepositoryAdapter.java
│   │   │   │   │   └── mapper/                # Entity <-> Domain mapper
│   │   │   │   │       └── OrderEntityMapper.java
│   │   │   │   ├── mongodb/                   # MongoDB implementation
│   │   │   │   │   ├── document/              # MongoDB documents
│   │   │   │   │   │   └── OrderDocument.java
│   │   │   │   │   ├── repository/            # Mongo repositories
│   │   │   │   │   │   └── MongoOrderRepository.java
│   │   │   │   │   ├── adapter/               # Port implementations
│   │   │   │   │   │   └── OrderRepositoryAdapter.java
│   │   │   │   │   └── mapper/                # Document <-> Domain mapper
│   │   │   │   │       └── OrderDocumentMapper.java
│   │   │   │   └── eventstore/                # Event store (if full event sourcing)
│   │   │   │       ├── EventStoreRepository.java
│   │   │   │       └── EventEntity.java
│   │   │   ├── messaging/                     # Message producers/consumers
│   │   │   │   ├── kafka/
│   │   │   │   │   ├── OrderEventProducer.java
│   │   │   │   │   └── OrderEventConsumer.java
│   │   │   │   └── config/
│   │   │   │       └── KafkaConfig.java
│   │   │   ├── client/                        # External API clients
│   │   │   │   ├── PaymentServiceClient.java
│   │   │   │   ├── InventoryServiceClient.java
│   │   │   │   └── config/
│   │   │   │       └── RestClientConfig.java
│   │   │   ├── camel/                         # Camel routes (optional)
│   │   │   │   ├── FileProcessingRoute.java
│   │   │   │   └── config/
│   │   │   │       └── CamelConfig.java
│   │   │   └── observability/                 # Telemetry service
│   │   │       └── TelemetryService.java
│   │   ├── config/                            # Spring configurations
│   │   │   ├── SecurityConfig.java            # OAuth2 + JWT
│   │   │   ├── ObservabilityConfig.java       # Application Insights
│   │   │   ├── ResilienceConfig.java          # Resilience4j
│   │   │   ├── DatabaseConfig.java            # MS SQL or MongoDB
│   │   │   ├── EventSourcingConfig.java       # Event sourcing (if enabled)
│   │   │   └── OpenApiConfig.java             # Springdoc OpenAPI
│   │   └── exception/                         # Exception handling
│   │       ├── GlobalExceptionHandler.java    # @RestControllerAdvice
│   │       └── ErrorResponse.java             # Error DTO
│   └── api/                                   # Interface Adapters Layer (REST)
│       ├── controller/                        # Generated from OpenAPI
│       │   ├── OrderApiController.java        # Implements generated interface
│       │   └── ProductApiController.java
│       ├── dto/                               # Generated from OpenAPI
│       │   ├── OrderDto.java
│       │   └── CreateOrderRequestDto.java
│       └── mapper/                            # API DTO <-> Domain mapper
│           ├── OrderDtoMapper.java
│           └── ProductDtoMapper.java
├── src/main/resources/
│   ├── application.yml                        # Main configuration
│   ├── application-dev.yml                    # Development profile
│   ├── application-h2.yml                     # H2 embedded database profile
│   ├── application-prod.yml                   # Production profile
│   ├── application-test.yml                   # Test profile
│   ├── logback-spring.xml                     # Structured logging config
│   ├── db/migration/                          # Flyway migrations (if MS SQL)
│   │   ├── V1__create_orders_table.sql
│   │   └── V2__create_products_table.sql
│   └── db/changelog/                          # Mongock changelogs (if MongoDB)
│       └── changelog-1.0.xml
├── src/test/java/com/company/myservice/
│   ├── unit/                                  # Unit Tests (75% of tests)
│   │   ├── domain/                            # Domain model tests
│   │   │   ├── OrderTest.java
│   │   │   └── ProductTest.java
│   │   ├── application/                       # Use case tests
│   │   │   ├── ProcessOrderUseCaseTest.java
│   │   │   └── GetOrderUseCaseTest.java
│   │   └── infrastructure/                    # Mapper tests
│   │       └── OrderEntityMapperTest.java
│   ├── integration/                           # Integration Tests (20%)
│   │   ├── api/                               # REST API tests
│   │   │   └── OrderApiIntegrationTest.java   # REST Assured tests
│   │   ├── persistence/                       # Repository tests
│   │   │   └── OrderRepositoryIntegrationTest.java  # Testcontainers or embedded
│   │   └── client/                            # External client tests
│   │       └── PaymentServiceClientTest.java  # WireMock tests
│   ├── contract/                              # Contract Tests (5%)
│   │   ├── provider/                          # Pact provider tests
│   │   │   └── OrderApiProviderTest.java
│   │   └── consumer/                          # Pact consumer tests
│   │       └── PaymentServiceConsumerTest.java
│   └── architecture/                          # Architecture Tests
│       └── ArchitectureTest.java              # ArchUnit rules
├── src/test/resources/
│   ├── contracts/                             # Pact contract files
│   │   └── payment-service-contract.json
│   ├── application-test.yml                   # Test configuration
│   └── logback-test.xml                       # Test logging config
└── docs/
    ├── README.md                              # Project documentation
    ├── ARCHITECTURE.md                        # Architecture decisions
    ├── API.md                                 # API usage guide
    ├── OBSERVABILITY.md                       # App Insights guide
    ├── DEVELOPER_GUIDE.md                     # Development guidelines
    ├── llm-usage.md                           # LLM-friendly prompts
    └── queries.md                             # Application Insights KQL queries
```

---

## 4. Technology Stack

### Core Framework
- **Java 21** (LTS, Virtual Threads)
- **Spring Boot 3.3+** (Spring Framework 6.x)
- **Maven 3.9+** (Build tool)

### API Specification
- **OpenAPI 3.1.0** (API-first design)
- **OpenAPI Generator 7.x** (Code generation)
- **Springdoc OpenAPI 2.x** (Runtime spec, Swagger UI)

### Database Options

#### MS SQL Server
- `spring-boot-starter-data-jpa`
- `mssql-jdbc` (Microsoft JDBC Driver)
- `flyway-core` + `flyway-sqlserver` (Migrations)
- `hibernate-core` 6.x (JPA implementation)

#### MongoDB
- `spring-boot-starter-data-mongodb`
- `mongodb-driver-sync`
- `mongock-springboot` + `mongock-mongodb-springdata-v4-driver` (Migrations)

#### Development/Testing
- `h2` (In-memory SQL database for quick dev)
- `de.flapdoodle.embed.mongo` (Embedded MongoDB for tests)

### Security
- `spring-boot-starter-security`
- `spring-boot-starter-oauth2-resource-server` (OAuth2)
- `spring-security-oauth2-jose` (JWT validation)
- `java-jwt` (Auth0 JWT library)

### Observability (Application Insights)
- `applicationinsights-spring-boot-starter` 3.5.1
- `applicationinsights-core`
- `spring-boot-starter-actuator` (Health checks)
- `logstash-logback-encoder` 7.4 (Structured JSON logging)

### Resilience (Resilience4j)
- `resilience4j-spring-boot3`
- `resilience4j-circuitbreaker`
- `resilience4j-retry`
- `resilience4j-ratelimiter`
- `resilience4j-bulkhead`
- `resilience4j-timelimiter`

### Testing

#### Unit Testing
- `junit-jupiter` 5.10+ (JUnit 5)
- `mockito-core` 5.x (Mocking)
- `assertj-core` 3.x (Fluent assertions)

#### Integration Testing
- `spring-boot-starter-test`
- `rest-assured` 5.x (API testing)
- `testcontainers-mssqlserver` or `testcontainers-mongodb`
- `wiremock` (External service mocking)

#### Contract Testing
- `pact-jvm-consumer-junit5`
- `pact-jvm-provider-junit5`

#### Architecture Testing
- `archunit-junit5` (Architecture rules)

#### Coverage & Mutation
- `jacoco-maven-plugin` (Code coverage)
- `pitest-maven` (Mutation testing)

### Code Quality
- `google-java-format` (Auto-formatting)
- `maven-checkstyle-plugin` with Google Java Style
- `spotbugs-maven-plugin` (Static analysis)
- `maven-enforcer-plugin` (Dependency enforcement)

### Event Sourcing

#### Full Event Sourcing
- Custom event store implementation
- Spring Data (for event persistence)
- Jackson (event serialization/deserialization)

#### Lightweight Event-Driven
- `spring-modulith-events`
- `spring-modulith-events-jdbc` or `spring-modulith-events-mongodb`

### Camel Integration (Optional)
- `camel-spring-boot-starter` 4.x
- `camel-openapi-java`
- Pattern-specific components:
  - `camel-file` (File operations)
  - `camel-ftp` (FTP operations)
  - `camel-kafka` (Kafka integration)
  - `camel-http` (HTTP operations)
  - `camel-jackson` (JSON transformation)

---

## 5. Database Configuration

### MS SQL Server

**Dependencies:**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>com.microsoft.sqlserver</groupId>
    <artifactId>mssql-jdbc</artifactId>
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
```

**Configuration (application-dev.yml):**
```yaml
spring:
  datasource:
    url: jdbc:sqlserver://localhost:1433;databaseName=myservice;encrypt=false
    username: sa
    password: ${DB_PASSWORD}
    driver-class-name: com.microsoft.sqlserver.jdbc.SQLServerDriver
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
  flyway:
    enabled: true
    baseline-on-migrate: true
```

**Migration Example (V1__create_orders_table.sql):**
```sql
CREATE TABLE orders (
    id UNIQUEIDENTIFIER PRIMARY KEY,
    customer_id UNIQUEIDENTIFIER NOT NULL,
    total_amount DECIMAL(19,4) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at DATETIME2 NOT NULL,
    updated_at DATETIME2 NOT NULL
);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
```

### MongoDB

**Dependencies:**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
<dependency>
    <groupId>io.mongock</groupId>
    <artifactId>mongock-springboot</artifactId>
</dependency>
<dependency>
    <groupId>io.mongock</groupId>
    <artifactId>mongock-mongodb-springdata-v4-driver</artifactId>
</dependency>
<dependency>
    <groupId>de.flapdoodle.embed</groupId>
    <artifactId>de.flapdoodle.embed.mongo</artifactId>
    <scope>test</scope>
</dependency>
```

**Configuration (application-dev.yml):**
```yaml
spring:
  data:
    mongodb:
      uri: mongodb://localhost:27017/myservice
      auto-index-creation: true
mongock:
  change-logs-scan-package: com.company.myservice.infrastructure.adapter.persistence.mongodb.changelog
```

**Migration Example (DatabaseChangeLog.java):**
```java
@ChangeUnit(id = "create-orders-collection", order = "1")
public class CreateOrdersCollectionChangeLog {

    @Execution
    public void createOrdersCollection(MongoDatabase mongoDatabase) {
        mongoDatabase.createCollection("orders");

        // Create indexes
        mongoDatabase.getCollection("orders")
            .createIndex(Indexes.ascending("customerId"));
    }
}
```

---

## 6. Observability - Application Insights

### Configuration

**Dependencies:**
```xml
<dependency>
    <groupId>com.microsoft.azure</groupId>
    <artifactId>applicationinsights-spring-boot-starter</artifactId>
    <version>3.5.1</version>
</dependency>
<dependency>
    <groupId>com.microsoft.azure</groupId>
    <artifactId>applicationinsights-core</artifactId>
    <version>3.5.1</version>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>7.4</version>
</dependency>
```

**Configuration (application.yml):**
```yaml
azure:
  application-insights:
    enabled: true
    connection-string: ${APPLICATIONINSIGHTS_CONNECTION_STRING}
    web:
      enable-W3C-distributed-tracing: true
    customDimensions:
      environment: ${SPRING_PROFILES_ACTIVE:local}
      service: ${spring.application.name}
    sampling:
      percentage: 100  # Adjust for production
    performance-counters:
      enabled: true
    heartbeat:
      enabled: true
      interval: 900

management:
  endpoints:
    web:
      exposure:
        include: health,info
  endpoint:
    health:
      show-details: when-authorized
      probes:
        enabled: true
```

### Telemetry Features

**Automatic Instrumentation:**
- HTTP requests (duration, status codes, URLs)
- Database queries (SQL, MongoDB)
- External HTTP calls (dependencies)
- Exceptions (stack traces, context)
- Performance counters (CPU, memory, GC)

**Custom Telemetry:**
- Custom events (business events)
- Custom metrics (business metrics)
- Custom traces (debugging)
- Dependency tracking (external services)
- Exception tracking (with context)

**TelemetryService Usage:**
```java
// Track business event
telemetry.trackEvent("OrderProcessed",
    Map.of("customerId", customerId, "status", "completed"),
    Map.of("orderValue", 99.99, "itemCount", 3.0)
);

// Track custom metric
telemetry.trackMetric("order.value", 99.99,
    Map.of("status", "completed")
);

// Track dependency
telemetry.trackDependency("PaymentService", "charge", durationMs, success);

// Track exception
telemetry.trackException(exception,
    Map.of("orderId", orderId),
    SeverityLevel.Error
);
```

### Structured Logging

**Logback Configuration (logback-spring.xml):**
- JSON format logging
- Correlation IDs (trace ID, span ID)
- MDC (Mapped Diagnostic Context) support
- Application Insights appender

**Log Pattern:**
```
timestamp: 2025-10-19T10:30:45.123Z
level: INFO
logger: com.company.myservice.application.usecase.ProcessOrderUseCase
message: Processing order for customer: 123
traceId: abc123...
spanId: def456...
application: my-service
environment: production
```

### Monitoring & Alerting

**Azure Portal Views:**
- **Live Metrics**: Real-time monitoring
- **Application Map**: Service dependencies visualization
- **Performance**: Request duration, dependencies
- **Failures**: Exception tracking
- **Metrics**: Custom metrics visualization
- **Logs**: KQL query interface

**Sample KQL Queries:**
```kusto
// Request performance (P95)
requests
| where timestamp > ago(1h)
| summarize percentile(duration, 95) by operation_Name

// Custom business events
customEvents
| where name == "OrderProcessed"
| extend orderValue = todouble(customMeasurements.orderValue)
| summarize count(), avg(orderValue), sum(orderValue) by bin(timestamp, 1h)

// Dependency failures
dependencies
| where success == false
| summarize count() by name, resultCode
```

---

## 7. Security - OAuth2 + JWT

### Configuration

**Dependencies:**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>
```

**Configuration (application.yml):**
```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${OAUTH2_ISSUER_URI}
          jwk-set-uri: ${OAUTH2_JWK_SET_URI}
```

**SecurityConfig.java:**
```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/health", "/actuator/info").permitAll()
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter()))
            )
            .csrf(csrf -> csrf.disable())  // For stateless APIs
            .cors(cors -> cors.configurationSource(corsConfigurationSource()));

        return http.build();
    }

    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter() {
        JwtGrantedAuthoritiesConverter grantedAuthoritiesConverter =
            new JwtGrantedAuthoritiesConverter();
        grantedAuthoritiesConverter.setAuthoritiesClaimName("roles");
        grantedAuthoritiesConverter.setAuthorityPrefix("ROLE_");

        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(grantedAuthoritiesConverter);
        return converter;
    }
}
```

### Security Features
- JWT token validation
- Role-based access control (RBAC)
- Method-level security (@PreAuthorize, @Secured)
- CORS configuration
- Security headers
- CSRF protection (configurable)

---

## 8. Resilience - Resilience4j

### Configuration

**Dependencies:**
```xml
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot3</artifactId>
</dependency>
```

**Configuration (application.yml):**
```yaml
resilience4j:
  circuitbreaker:
    instances:
      paymentService:
        sliding-window-size: 10
        failure-rate-threshold: 50
        wait-duration-in-open-state: 10s
        permitted-number-of-calls-in-half-open-state: 3
        automatic-transition-from-open-to-half-open-enabled: true

  retry:
    instances:
      paymentService:
        max-attempts: 3
        wait-duration: 1s
        exponential-backoff-multiplier: 2
        retry-exceptions:
          - java.net.ConnectException
          - java.io.IOException

  ratelimiter:
    instances:
      publicApi:
        limit-for-period: 100
        limit-refresh-period: 1s
        timeout-duration: 0s

  bulkhead:
    instances:
      heavyOperation:
        max-concurrent-calls: 10
        max-wait-duration: 100ms
```

### Resilience Patterns

**Circuit Breaker:**
```java
@CircuitBreaker(name = "paymentService", fallbackMethod = "paymentFallback")
public PaymentResponse processPayment(PaymentRequest request) {
    return paymentClient.charge(request);
}

private PaymentResponse paymentFallback(PaymentRequest request, Exception ex) {
    telemetry.trackEvent("PaymentServiceFallback", Map.of("reason", ex.getMessage()), null);
    return PaymentResponse.failed("Service unavailable");
}
```

**Retry:**
```java
@Retry(name = "paymentService")
public PaymentResponse processPayment(PaymentRequest request) {
    return paymentClient.charge(request);
}
```

**Rate Limiter:**
```java
@RateLimiter(name = "publicApi")
public List<Product> getProducts() {
    return productRepository.findAll();
}
```

**Bulkhead:**
```java
@Bulkhead(name = "heavyOperation")
public Report generateReport() {
    return reportService.generate();
}
```

**Combined Patterns:**
```java
@CircuitBreaker(name = "paymentService", fallbackMethod = "paymentFallback")
@Retry(name = "paymentService")
@RateLimiter(name = "paymentService")
public PaymentResponse processPayment(PaymentRequest request) {
    // Combines circuit breaker, retry, and rate limiting
}
```

---

## 9. Testing Strategy - Test Pyramid

### Test Distribution
```
           /\
          /  \        Contract Tests (5%)
         /____\       - Provider verification (Pact)
        /      \      - Consumer contracts
       /________\
      /          \    Integration Tests (20%)
     /            \   - API tests (REST Assured)
    /              \  - Repository tests (Testcontainers/Embedded)
   /________________\ - Client tests (WireMock)
  /                  \
 /____________________\ Unit Tests (75%)
                        - Domain logic
                        - Use cases
                        - Mappers
```

### Unit Tests (75%)

**Target:** Domain logic, use cases, mappers

**Tools:**
- JUnit 5 (Jupiter)
- Mockito (mocking)
- AssertJ (assertions)

**Example:**
```java
@ExtendWith(MockitoExtension.class)
class ProcessOrderUseCaseTest {

    @Mock
    private OrderRepository orderRepository;

    @Mock
    private TelemetryService telemetry;

    @InjectMocks
    private ProcessOrderUseCaseImpl useCase;

    @Test
    void shouldProcessOrderSuccessfully() {
        // Given
        CreateOrderCommand command = new CreateOrderCommand(customerId, items);
        Order expectedOrder = Order.create(customerId, items);
        when(orderRepository.save(any(Order.class))).thenReturn(expectedOrder);

        // When
        Order result = useCase.execute(command);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getStatus()).isEqualTo(OrderStatus.CREATED);
        verify(orderRepository).save(any(Order.class));
        verify(telemetry).trackEvent(eq("OrderProcessed"), any(), any());
    }
}
```

### Integration Tests (20%)

**Target:** API endpoints, repository layer, external clients

**Tools:**
- Spring Boot Test
- REST Assured (API testing)
- Testcontainers (database containers) or Embedded databases
- WireMock (external service mocking)

**API Test Example:**
```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class OrderApiIntegrationTest {

    @LocalServerPort
    private int port;

    @Test
    void shouldCreateOrder() {
        given()
            .port(port)
            .contentType(ContentType.JSON)
            .body("""
                {
                  "customerId": "123e4567-e89b-12d3-a456-426614174000",
                  "items": [
                    {"productId": "prod-1", "quantity": 2}
                  ]
                }
                """)
        .when()
            .post("/api/orders")
        .then()
            .statusCode(201)
            .body("id", notNullValue())
            .body("status", equalTo("CREATED"));
    }
}
```

**Repository Test Example (with embedded DB):**
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
class OrderRepositoryIntegrationTest {

    @Autowired
    private JpaOrderRepository repository;

    @Test
    void shouldSaveAndRetrieveOrder() {
        OrderEntity order = new OrderEntity();
        order.setCustomerId(UUID.randomUUID());
        order.setStatus("CREATED");

        OrderEntity saved = repository.save(order);

        assertThat(saved.getId()).isNotNull();
        assertThat(repository.findById(saved.getId())).isPresent();
    }
}
```

### Contract Tests (5%)

**Target:** Provider-consumer contracts

**Tools:**
- Pact JVM

**Provider Test Example:**
```java
@Provider("order-service")
@PactBroker(host = "pact-broker.example.com", port = "443")
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class OrderApiProviderTest {

    @LocalServerPort
    private int port;

    @TestTemplate
    @ExtendWith(PactVerificationInvocationContextProvider.class)
    void pactVerificationTest(PactVerificationContext context) {
        context.verifyInteraction();
    }

    @BeforeEach
    void setup(PactVerificationContext context) {
        context.setTarget(new HttpTestTarget("localhost", port));
    }

    @State("an order exists")
    void orderExists() {
        // Setup state
    }
}
```

**Consumer Test Example:**
```java
@ExtendWith(PactConsumerTestExt.class)
@PactTestFor(providerName = "payment-service")
class PaymentServiceConsumerTest {

    @Pact(consumer = "order-service")
    public RequestResponsePact createPact(PactDslWithProvider builder) {
        return builder
            .given("payment can be processed")
            .uponReceiving("a payment request")
                .path("/api/payments")
                .method("POST")
            .willRespondWith()
                .status(200)
                .body(new PactDslJsonBody()
                    .stringType("transactionId")
                    .stringType("status", "SUCCESS"))
            .toPact();
    }

    @Test
    void shouldProcessPayment(MockServer mockServer) {
        // Test consumer using mock server
    }
}
```

### Architecture Tests

**Target:** Clean architecture rules enforcement

**Tools:**
- ArchUnit

**Example:**
```java
@AnalyzeClasses(packages = "com.company.myservice")
public class ArchitectureTest {

    @ArchTest
    static final ArchRule domain_should_not_depend_on_infrastructure =
        noClasses()
            .that().resideInAPackage("..domain..")
            .should().dependOnClassesThat()
            .resideInAnyPackage("..infrastructure..", "..api..");

    @ArchTest
    static final ArchRule use_cases_should_be_in_application_layer =
        classes()
            .that().haveSimpleNameEndingWith("UseCase")
            .should().resideInAPackage("..application.usecase..");

    @ArchTest
    static final ArchRule repositories_should_be_interfaces_in_domain =
        classes()
            .that().haveSimpleNameEndingWith("Repository")
            .and().resideInAPackage("..domain.port.output..")
            .should().beInterfaces();
}
```

### Mutation Testing

**Tool:** PIT (Pitest)

**Configuration:**
```xml
<plugin>
    <groupId>org.pitest</groupId>
    <artifactId>pitest-maven</artifactId>
    <configuration>
        <targetClasses>
            <param>com.company.myservice.*</param>
        </targetClasses>
        <targetTests>
            <param>com.company.myservice.*</param>
        </targetTests>
        <mutationThreshold>80</mutationThreshold>
        <coverageThreshold>80</coverageThreshold>
    </configuration>
</plugin>
```

**Run:**
```bash
mvn test-compile org.pitest:pitest-maven:mutationCoverage
# Report: target/pit-reports/index.html
```

### Code Coverage

**Tool:** JaCoCo

**Configuration:**
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <executions>
        <execution>
            <id>check</id>
            <goals><goal>check</goal></goals>
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
```

**Run:**
```bash
mvn clean test jacoco:report
# Report: target/site/jacoco/index.html
```

---

## 10. Event Sourcing Options

### Full Event Sourcing

**When to use:**
- Audit trail requirements
- Temporal queries (state at any point in time)
- Event replay needed
- Complex domain with state transitions

**Components:**
- Event Store (custom implementation)
- Aggregate Root base class
- Event replay mechanism
- Snapshot support
- Separate read models (CQRS)
- Projection handlers
- Event upcasting (versioning)

**Example Structure:**
```java
// Aggregate Root
public abstract class AggregateRoot {
    private UUID id;
    private long version;
    private List<DomainEvent> uncommittedEvents = new ArrayList<>();

    protected void applyEvent(DomainEvent event) {
        uncommittedEvents.add(event);
        apply(event);
        version++;
    }

    protected abstract void apply(DomainEvent event);

    public List<DomainEvent> getUncommittedEvents() {
        return uncommittedEvents;
    }
}

// Order Aggregate
public class Order extends AggregateRoot {
    private OrderStatus status;

    public static Order create(UUID customerId, List<OrderItem> items) {
        Order order = new Order();
        order.applyEvent(new OrderCreatedEvent(UUID.randomUUID(), customerId, items));
        return order;
    }

    @Override
    protected void apply(DomainEvent event) {
        if (event instanceof OrderCreatedEvent e) {
            this.status = OrderStatus.CREATED;
        } else if (event instanceof OrderCompletedEvent e) {
            this.status = OrderStatus.COMPLETED;
        }
    }
}

// Event Store
public interface EventStore {
    void save(UUID aggregateId, List<DomainEvent> events, long expectedVersion);
    List<DomainEvent> getEvents(UUID aggregateId);
}
```

### Lightweight Event-Driven Architecture

**When to use:**
- Simple event notification
- Eventual consistency
- Decoupled components
- No complex event replay needed

**Components:**
- Spring Modulith Events
- Event handlers (@EventListener)
- Outbox pattern (for reliability)
- Simple event bus

**Example Structure:**
```java
// Domain Event
public record OrderCreatedEvent(
    UUID orderId,
    UUID customerId,
    BigDecimal totalAmount,
    Instant createdAt
) implements DomainEvent {}

// Publishing Events
@Service
public class OrderService {
    private final ApplicationEventPublisher eventPublisher;

    public Order createOrder(CreateOrderCommand command) {
        Order order = Order.create(command.customerId(), command.items());
        orderRepository.save(order);

        // Publish event
        eventPublisher.publishEvent(new OrderCreatedEvent(
            order.getId(),
            order.getCustomerId(),
            order.getTotalAmount(),
            Instant.now()
        ));

        return order;
    }
}

// Handling Events
@Component
public class OrderEventHandler {

    @EventListener
    @Transactional
    public void handleOrderCreated(OrderCreatedEvent event) {
        // Send notification
        // Update read model
        // Trigger downstream processes
    }
}
```

**Spring Modulith Configuration:**
```xml
<dependency>
    <groupId>org.springframework.modulith</groupId>
    <artifactId>spring-modulith-events-jdbc</artifactId>
</dependency>
```

---

## 11. Camel Integration (Optional)

### Assessment Logic

The CLI will analyze the codebase and provide a recommendation score (0-100):

**Scoring Criteria:**
- Multiple external integrations (≥3): +30 points
- File/FTP operations detected: +25 points
- Complex data transformations (≥5): +20 points
- Messaging infrastructure (Kafka, RabbitMQ): +15 points
- Content-based routing patterns (≥3): +10 points

**Recommendation Levels:**
- **60-100**: Strongly recommended
- **30-59**: Consider (evaluate complexity)
- **0-29**: Not recommended

### Assessment Script Example

```bash
#!/bin/bash
# assess-camel.sh

score=0
reasons=()

# Check integrations
integration_count=$(grep -rE "@FeignClient|RestTemplate|WebClient" src/ | wc -l)
if [ $integration_count -ge 3 ]; then
    score=$((score + 30))
    reasons+=("Multiple external integrations: $integration_count")
fi

# Check file operations
if grep -rq "java.nio.file\|apache.commons.net.ftp" src/; then
    score=$((score + 25))
    reasons+=("File/FTP operations detected")
fi

# Check transformations
transform_count=$(grep -rE "ObjectMapper|XmlMapper" src/ | wc -l)
if [ $transform_count -ge 5 ]; then
    score=$((score + 20))
    reasons+=("Data transformations: $transform_count")
fi

# Check messaging
if grep -rq "KafkaTemplate|RabbitTemplate|JmsTemplate" src/; then
    score=$((score + 15))
    reasons+=("Messaging infrastructure detected")
fi

# Output recommendation
echo "=== Camel Assessment ==="
echo "Score: $score/100"
echo ""

if [ $score -ge 60 ]; then
    echo "✓ STRONGLY RECOMMENDED"
    echo "Suggested patterns:"
    echo "  - Content-Based Router"
    echo "  - Message Translator"
    echo "  - Enterprise Integration Patterns"
elif [ $score -ge 30 ]; then
    echo "⚠ CONSIDER"
    echo "Evaluate if Camel simplifies your integrations"
else
    echo "✗ NOT RECOMMENDED"
    echo "Current stack is sufficient"
fi

echo ""
echo "Reasons:"
printf '%s\n' "${reasons[@]}"
```

### Camel Route Templates

**File to Messaging Route:**
```java
@Component
public class FileToQueueRoute extends RouteBuilder {

    @Override
    public void configure() throws Exception {
        from("file:///input?delete=true&moveFailed=error")
            .routeId("file-to-queue")
            .log("Processing file: ${header.CamelFileName}")
            .unmarshal().json(JsonLibrary.Jackson, Order.class)
            .to("kafka:orders-topic")
            .log("File processed successfully");

        onException(Exception.class)
            .handled(true)
            .log(LoggingLevel.ERROR, "Error processing file: ${exception.message}")
            .to("file:///error");
    }
}
```

---

## 12. Clean Architecture Principles

### Dependency Rule

**The Dependency Rule:**
> Source code dependencies must point only inward, toward higher-level policies.

```
┌─────────────────────────────────────────────────┐
│                  API Layer                      │  ← REST Controllers, DTOs
│  (Interface Adapters - External Interface)     │
└────────────────┬────────────────────────────────┘
                 │ depends on ↓
┌────────────────▼────────────────────────────────┐
│            Infrastructure Layer                 │  ← Repositories, Clients
│  (Frameworks & Drivers - Implementation)       │
└────────────────┬────────────────────────────────┘
                 │ implements ↓
┌────────────────▼────────────────────────────────┐
│            Application Layer                    │  ← Use Cases, Services
│  (Application Business Rules)                  │
└────────────────┬────────────────────────────────┘
                 │ depends on ↓
┌────────────────▼────────────────────────────────┐
│              Domain Layer                       │  ← Entities, Ports
│  (Enterprise Business Rules - Core)            │  ← NO FRAMEWORK DEPENDENCIES
└─────────────────────────────────────────────────┘
```

### Layer Responsibilities

**Domain Layer (Enterprise Business Rules):**
- Core business entities
- Domain events
- Business rules and invariants
- Port interfaces (use case inputs, repository outputs)
- **NO dependencies** on frameworks or outer layers

**Application Layer (Application Business Rules):**
- Use case implementations
- Application services
- Event handlers
- Orchestration logic
- Depends only on Domain layer

**Infrastructure Layer (Frameworks & Drivers):**
- Database implementations (JPA, MongoDB)
- External API clients
- Messaging adapters
- Framework configurations
- Implements ports from Domain layer

**API Layer (Interface Adapters):**
- REST controllers
- API DTOs
- Request/response mappers
- Generated from OpenAPI specification

### SOLID Principles

**Single Responsibility Principle (SRP):**
- Each class has one reason to change
- Use cases are separated (ProcessOrderUseCase, GetOrderUseCase)
- Mappers are dedicated to transformation

**Open/Closed Principle (OCP):**
- Open for extension, closed for modification
- Strategy pattern for payment methods
- Plugin architecture for Camel routes

**Liskov Substitution Principle (LSP):**
- Proper interface contracts
- Repository implementations are interchangeable
- Database can be switched without changing business logic

**Interface Segregation Principle (ISP):**
- Granular port interfaces
- Clients don't depend on methods they don't use
- Separate input and output ports

**Dependency Inversion Principle (DIP):**
- High-level modules don't depend on low-level modules
- Both depend on abstractions (ports)
- Domain defines interfaces, Infrastructure implements

### Design Patterns

**Implemented Patterns:**
- **Port & Adapter** (Hexagonal Architecture)
- **Repository Pattern** (Data access abstraction)
- **Factory Pattern** (Entity creation)
- **Builder Pattern** (Complex object construction)
- **Strategy Pattern** (Pluggable algorithms)
- **Observer Pattern** (Event handling)
- **Circuit Breaker Pattern** (Resilience)
- **Retry Pattern** (Fault tolerance)

---

## 13. Code Quality Standards

### Google Java Style

**Configuration Files:**
- `checkstyle.xml` (Google Java Style)
- `.editorconfig` (Editor configuration)
- Google Java Format plugin

**Key Rules:**
- 2 spaces for indentation
- 100 character line limit
- Block indentation: +2 spaces
- No wildcard imports
- Consistent ordering (static imports first)

**Maven Plugins:**
```xml
<!-- Auto-format -->
<plugin>
    <groupId>com.spotify.fmt</groupId>
    <artifactId>fmt-maven-plugin</artifactId>
    <executions>
        <execution>
            <goals><goal>format</goal></goals>
        </execution>
    </executions>
</plugin>

<!-- Style check -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <configuration>
        <configLocation>checkstyle.xml</configLocation>
        <failOnViolation>true</failOnViolation>
    </configuration>
</plugin>
```

**Commands:**
```bash
# Format code
mvn fmt:format

# Check style
mvn checkstyle:check
```

### Clean Code Principles

**Naming Conventions:**
- Use cases: `{Verb}{Noun}UseCase` (ProcessOrderUseCase)
- Entities: `{Noun}` (Order, Product)
- Repositories: `{Entity}Repository` interface, `{DB}{Entity}RepositoryAdapter` implementation
- DTOs: `{Entity}Dto` or `{Action}{Entity}RequestDto`
- Mappers: `{Source}To{Target}Mapper`

**Method Guidelines:**
- Maximum 20 lines per method
- Single responsibility
- Clear, descriptive names
- No magic numbers (use constants)
- Comprehensive Javadoc for public APIs

**Class Guidelines:**
- Maximum 300 lines per class
- Single responsibility
- Immutable where possible (Java records for DTOs)
- Final fields for dependencies

### Static Analysis

**Tools:**
- SpotBugs (bug detection)
- Error Prone (compile-time checks)
- Checkstyle (style enforcement)

---

## 14. REST API Conventions

### Resource-Based URLs

```
GET    /api/orders              # List orders
GET    /api/orders/{id}         # Get specific order
POST   /api/orders              # Create order
PUT    /api/orders/{id}         # Full update
PATCH  /api/orders/{id}         # Partial update
DELETE /api/orders/{id}         # Delete order

GET    /api/orders/{id}/items   # Get order items (nested resource)
```

### HTTP Status Codes

**Success (2xx):**
- 200 OK (GET, PUT, PATCH)
- 201 Created (POST)
- 204 No Content (DELETE)

**Client Errors (4xx):**
- 400 Bad Request (validation error)
- 401 Unauthorized (missing/invalid token)
- 403 Forbidden (insufficient permissions)
- 404 Not Found (resource doesn't exist)
- 409 Conflict (business rule violation)
- 422 Unprocessable Entity (semantic errors)

**Server Errors (5xx):**
- 500 Internal Server Error
- 502 Bad Gateway (upstream service error)
- 503 Service Unavailable (circuit breaker open)

### Response Format

**Success Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "customerId": "cust-123",
  "items": [
    {
      "productId": "prod-1",
      "quantity": 2,
      "price": 29.99
    }
  ],
  "totalAmount": 59.98,
  "status": "CREATED",
  "createdAt": "2025-10-19T10:30:00Z"
}
```

**Error Response:**
```json
{
  "timestamp": "2025-10-19T10:30:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "path": "/api/orders",
  "errors": [
    {
      "field": "items",
      "message": "must not be empty"
    }
  ],
  "traceId": "abc123..."
}
```

### Pagination

```
GET /api/orders?page=0&size=20&sort=createdAt,desc

Response:
{
  "content": [...],
  "page": {
    "number": 0,
    "size": 20,
    "totalElements": 150,
    "totalPages": 8
  }
}
```

### Filtering & Searching

```
GET /api/orders?status=COMPLETED&customerId=123
GET /api/products?search=laptop&category=electronics
```

### Versioning

**URI Versioning (Default):**
```
GET /api/v1/orders
GET /api/v2/orders
```

**Header Versioning (Alternative):**
```
GET /api/orders
Accept: application/vnd.myservice.v1+json
```

---

## 15. LLM-Friendly Features

### Structured Documentation

**docs/llm-usage.md:**
- Common prompts for tasks
- Command examples with explanations
- Workflow examples (end-to-end scenarios)
- Conventions and naming rules
- Error troubleshooting

### Example Prompts

**Initialize Service:**
```
Create a new Spring Boot service called "inventory-service" with:
- Package: com.company.inventory
- Database: MongoDB
- OpenAPI spec: ./specs/inventory-api.yaml
- Features: OAuth2, lightweight event-driven

Command:
./springboot-cli.sh init --name inventory-service --package com.company.inventory --database mongodb --openapi ./specs/inventory-api.yaml --features oauth2,eventsourcing-lite
```

**Add Feature:**
```
Add a "Track Inventory" use case:
1. Create use case: TrackInventory
2. Create entity: InventoryItem with fields (id, productId, quantity, location, lastUpdated)
3. Create repository for InventoryItem
4. Add unit tests

Commands:
./springboot-cli.sh add usecase --name TrackInventory --aggregate InventoryItem
./springboot-cli.sh add entity --name InventoryItem --fields "id:UUID,productId:UUID,quantity:Integer,location:String,lastUpdated:Instant"
./springboot-cli.sh add repository --entity InventoryItem
```

### Clear Conventions

**Package Structure Rules:**
- Domain: NO Spring/framework imports
- Application: Depends only on domain and standard Java
- Infrastructure: Implements domain ports
- API: Maps between API DTOs and domain

**Testing Rules:**
- Unit tests: Mock all dependencies
- Integration tests: Use Testcontainers or embedded databases
- Always use AssertJ for assertions
- Follow Given-When-Then structure

### Validation Feedback

CLI provides clear, actionable error messages:

```
❌ Architecture Violation Detected:
   Class: com.company.myservice.domain.model.Order
   Issue: Domain layer depends on org.springframework.stereotype.Component

   Fix: Remove Spring annotations from domain layer.
   Domain classes should be pure Java with no framework dependencies.

   See: docs/ARCHITECTURE.md#domain-layer
```

---

## 16. Running Applications (No Docker)

### Local Development

**Using Maven:**
```bash
# Standard run
mvn spring-boot:run

# With specific profile
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# With environment variables
DB_PASSWORD=secret mvn spring-boot:run

# With JVM arguments
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xmx512m"

# With debug
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

### Database Options (No Docker)

**Option 1: H2 In-Memory (Quick Start)**
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=h2
# Data is lost on restart
```

**Option 2: Cloud Databases**
- Azure SQL Database
- MongoDB Atlas (free tier)
- AWS RDS

**Option 3: Local Installation**
- SQL Server Express (Windows/Linux)
- MongoDB Community Edition

### Configuration Profiles

**Development (application-dev.yml):**
- Connection to local or cloud database
- Application Insights enabled (optional)
- Debug logging
- Full sampling

**H2 Profile (application-h2.yml):**
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;MODE=MSSQLServer
    driver-class-name: org.h2.Driver
  h2:
    console:
      enabled: true
      path: /h2-console
```

**Test Profile (application-test.yml):**
- Embedded databases
- Application Insights disabled
- Minimal logging

**Production (application-prod.yml):**
- Production database connection
- Application Insights enabled with optimized sampling
- Warn-level logging

---

## 17. Deployment

### Dockerfile (Multi-Stage Build)

```dockerfile
# Build stage
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Create non-root user
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy JAR
COPY --from=build /app/target/*.jar app.jar

# Expose ports
EXPOSE 8080

# Enable virtual threads
ENV SPRING_THREADS_VIRTUAL_ENABLED=true

ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Build & Run (when Docker available):**
```bash
docker build -t my-service:1.0.0 .
docker run -p 8080:8080 \
  -e APPLICATIONINSIGHTS_CONNECTION_STRING="..." \
  -e DB_PASSWORD="..." \
  my-service:1.0.0
```

---

## 18. Implementation Roadmap

### ✅ Implementation Status

**✅ IMPLEMENTATION COMPLETE - All Core Features Implemented!**

**Completed Features:**
- ✅ CLI Foundation with bash scripts
- ✅ Clean Architecture project generation
- ✅ `init` command for new projects
- ✅ `add usecase` command
- ✅ `add entity` command
- ✅ `add repository` command (JPA/MongoDB)
- ✅ `add client` command with resilience patterns
- ✅ `add camel-route` command
- ✅ `generate openapi` command (OpenAPI Generator integration)
- ✅ `generate contract` command (Pact tests)
- ✅ `validate architecture` command with ArchUnit
- ✅ `validate coverage` command (JaCoCo + PIT)
- ✅ `validate openapi` command
- ✅ `assess camel` command
- ✅ Full event sourcing templates (AggregateRoot, EventStore, etc.)
- ✅ Lightweight event-driven templates (Spring Modulith)
- ✅ OAuth2/JWT security templates (complete)
- ✅ Application Insights observability templates (complete)
- ✅ Resilience4j templates with all patterns
- ✅ Comprehensive test infrastructure (unit, integration, contract, architecture)
- ✅ Camel integration templates (3 route patterns)
- ✅ LLM usage guide with prompts
- ✅ Application Insights KQL query library (30+ queries)
- ✅ Comprehensive documentation
- ✅ Maven-based build configuration

**Partially Completed:**
- ⚠️ PowerShell scripts (bash only implemented - skipped per request)

**Not Yet Implemented (Future Enhancements):**
- ❌ Docker/Kubernetes support
- ❌ Service mesh integration
- ❌ CI/CD pipeline templates
- ❌ GraphQL/gRPC support

### Phase 1: CLI Foundation (Week 1)
- [x] Create CLI directory structure
- [x] Implement bash/PowerShell script framework
- [x] Create base project templates
- [x] Implement `init` command
- [x] Test project generation

### Phase 2: Clean Architecture Templates (Week 2)
- [x] Create domain layer templates
- [x] Create application layer templates
- [x] Create infrastructure layer templates (MS SQL)
- [x] Create infrastructure layer templates (MongoDB)
- [x] Create API layer templates
- [x] Implement layer-specific code generators

### Phase 3: OpenAPI Integration (Week 2) ✅ COMPLETED
- [x] Configure OpenAPI Generator
- [x] Create OpenAPI templates
- [x] Implement `generate openapi` command
- [x] Test spec-first generation
- [x] Create sample OpenAPI specs

### Phase 4: Observability & Resilience (Week 3) ✅ COMPLETED
- [x] Create Application Insights configuration templates
- [x] Implement TelemetryService
- [x] Create Resilience4j configuration templates
- [x] Implement resilience pattern examples
- [x] Create observability documentation

### Phase 5: Security & Testing (Week 3) ✅ COMPLETED
- [x] Create OAuth2/JWT configuration templates
- [x] Implement security examples
- [x] Create test infrastructure templates
- [x] Implement test generators (unit, integration, contract)
- [x] Configure mutation and coverage tools

### Phase 6: Event Sourcing (Week 4) ✅ COMPLETED
- [x] Create full event sourcing templates
- [x] Create lightweight event-driven templates
- [x] Implement event store example
- [x] Create event handler templates
- [x] Document event sourcing patterns

### Phase 7: Camel Integration (Week 4) ✅ COMPLETED
- [x] Implement Camel assessment script
- [x] Create Camel route templates
- [x] Implement `add camel-route` command
- [x] Create Camel integration examples
- [x] Document EIP patterns

### Phase 8: Add Commands (Week 5) ✅ COMPLETED
- [x] Implement `add usecase` command
- [x] Implement `add entity` command
- [x] Implement `add repository` command
- [x] Implement `add client` command
- [x] Test all add commands

### Phase 9: Validation (Week 5) ✅ COMPLETED
- [x] Implement `validate architecture` command
- [x] Implement `validate coverage` command
- [x] Implement `validate openapi` command
- [x] Create ArchUnit rule templates
- [x] Test validation commands

### Phase 10: Documentation & Polish (Week 6) ✅ COMPLETED
- [x] Create comprehensive README templates
- [x] Create architecture documentation
- [x] Create LLM usage guide with prompts
- [x] Create troubleshooting guide
- [x] Create Application Insights query templates
- [x] Final testing and bug fixes

### Total Estimated Time: 6 weeks

**✅ IMPLEMENTATION COMPLETED: 2025-10-19**

All phases (1-10) have been successfully implemented. The CLI is production-ready with:
- 13 bash command scripts
- 50+ templates and configurations
- Complete documentation (README, LLM guide, KQL queries, architecture docs)
- Full feature coverage from the original plan

See `IMPLEMENTATION_SUMMARY.md` for detailed implementation report.

---

## 19. Success Criteria

### For Developers
- ✅ Generate production-ready Spring Boot service in < 5 minutes
- ✅ Clean Architecture enforced automatically
- ✅ Comprehensive test coverage (>80%) out of the box
- ✅ Observable from day one (Application Insights)
- ✅ Resilient by default (circuit breaker, retry)
- ✅ Secure by default (OAuth2 + JWT)
- ✅ API-first development workflow
- ✅ Clear documentation and examples

### For LLMs
- ✅ Structured, predictable command interface
- ✅ Clear conventions and naming rules
- ✅ Comprehensive prompt examples
- ✅ Actionable error messages
- ✅ Consistent project structure
- ✅ Well-documented patterns

### For Organizations
- ✅ Standardized Spring Boot services
- ✅ Reduced time-to-production
- ✅ Consistent code quality
- ✅ Maintainable, extensible architecture
- ✅ Production-ready observability
- ✅ Built-in security best practices

---

## 20. Future Enhancements

- Service mesh integration (Istio, Linkerd)
- Kubernetes manifests generation
- Helm chart templates
- CI/CD pipeline templates (GitHub Actions, GitLab CI)
- GraphQL API support
- WebFlux (reactive) support
- gRPC integration
- Multi-module project support
- Database migration tooling
- Performance testing templates (Gatling, JMeter)
- API versioning strategies
- Blue-green deployment support

---

## Appendix A: Key Technologies Summary

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Core** | Java | 21 | Programming language |
| | Spring Boot | 3.3+ | Application framework |
| | Maven | 3.9+ | Build tool |
| **API** | OpenAPI | 3.1.0 | API specification |
| | OpenAPI Generator | 7.x | Code generation |
| | Springdoc | 2.x | API documentation |
| **Database (SQL)** | MS SQL Server | 2022+ | Relational database |
| | Spring Data JPA | 3.3+ | Data access |
| | Flyway | Latest | Schema migrations |
| **Database (NoSQL)** | MongoDB | 7.x | Document database |
| | Spring Data MongoDB | 3.3+ | Data access |
| | Mongock | Latest | Schema migrations |
| **Security** | Spring Security | 6.x | Security framework |
| | OAuth2 Resource Server | - | OAuth2 support |
| | JWT | - | Token validation |
| **Observability** | Application Insights | 3.5.1 | Full observability |
| | Spring Actuator | - | Health checks |
| | Logstash Encoder | 7.4 | Structured logging |
| **Resilience** | Resilience4j | 2.2.0 | Resilience patterns |
| **Testing** | JUnit | 5.10+ | Unit testing |
| | Mockito | 5.x | Mocking |
| | Testcontainers | Latest | Integration testing |
| | Pact JVM | Latest | Contract testing |
| | ArchUnit | Latest | Architecture testing |
| | PIT | Latest | Mutation testing |
| **Quality** | Google Java Format | Latest | Code formatting |
| | Checkstyle | Latest | Style enforcement |
| | SpotBugs | Latest | Static analysis |
| **Integration (Opt)** | Apache Camel | 4.x | Integration patterns |

---

## Appendix B: Contact & Support

- **Documentation**: See generated `docs/` folder
- **Issues**: Track in project repository
- **Updates**: Check CLI version for latest features
- **Community**: Share patterns and templates

---

**End of Plan Document**
