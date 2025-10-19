# Spring Boot Standardization CLI 🚀

A comprehensive CLI tool for standardizing Spring Boot API development with Clean Architecture, API-First development, and production-ready features out of the box.

## ✨ Features

- **Clean Architecture** - Domain-driven design with clear separation of concerns
- **API-First Development** - OpenAPI 3.1 specification-driven development
- **Google Java Style** - Automatic code formatting and quality checks
- **Test Pyramid Strategy** - Unit, integration, contract, and architecture tests
- **Azure Application Insights** - Full observability (traces, metrics, logs)
- **Resilience Patterns** - Circuit breaker, retry, rate limiter with Resilience4j
- **Security Built-in** - OAuth2 + JWT authentication
- **Event Sourcing Options** - Full event sourcing or lightweight event-driven
- **Java 21** - Virtual Threads and modern JDK features
- **Database Support** - MS SQL Server and MongoDB

## 📋 Prerequisites

- Java 21 or higher
- Maven 3.9 or higher
- Bash shell (Linux/Mac/WSL)
- Git

## 🚀 Quick Start

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-org/springboot-cli.git
cd springboot-cli
```

2. Make the CLI executable:
```bash
chmod +x bin/springboot-cli.sh
chmod +x bin/commands/*.sh
```

3. Add to PATH (optional):
```bash
export PATH="$PATH:$(pwd)/bin"
```

### Basic Usage

#### Initialize a New Project

```bash
# Create a Spring Boot project with MS SQL
./bin/springboot-cli.sh init \
  --name my-service \
  --package com.company.myservice \
  --database mssql

# With MongoDB and OAuth2
./bin/springboot-cli.sh init \
  --name my-service \
  --package com.company.myservice \
  --database mongodb \
  --features oauth2

# With OpenAPI specification
./bin/springboot-cli.sh init \
  --name my-service \
  --package com.company.myservice \
  --openapi ./api-spec.yaml \
  --features oauth2,eventsourcing-lite
```

#### Add Components

```bash
# Add a use case
./bin/springboot-cli.sh add usecase \
  --name ProcessOrder \
  --aggregate Order

# Add a domain entity
./bin/springboot-cli.sh add entity \
  --name Product \
  --fields "id:UUID,name:String,price:BigDecimal,stock:Integer"

# Add a repository
./bin/springboot-cli.sh add repository \
  --entity Product \
  --type jpa
```

#### Validate Architecture

```bash
# Run architecture validation
./bin/springboot-cli.sh validate architecture

# Generate and run architecture tests
./bin/springboot-cli.sh validate architecture --generate-test
```

## 📁 Generated Project Structure

```
my-service/
├── src/
│   ├── main/
│   │   ├── java/com/company/myservice/
│   │   │   ├── domain/                    # Enterprise Business Rules
│   │   │   │   ├── model/
│   │   │   │   │   ├── aggregate/         # Aggregate roots
│   │   │   │   │   ├── entity/            # Domain entities
│   │   │   │   │   └── valueobject/       # Value objects
│   │   │   │   ├── event/                 # Domain events
│   │   │   │   ├── exception/             # Domain exceptions
│   │   │   │   └── port/                  # Ports (interfaces)
│   │   │   │       ├── input/             # Use case interfaces
│   │   │   │       └── output/            # Repository interfaces
│   │   │   ├── application/               # Application Business Rules
│   │   │   │   ├── usecase/               # Use case implementations
│   │   │   │   ├── service/               # Application services
│   │   │   │   └── eventhandler/          # Event handlers
│   │   │   ├── infrastructure/            # Frameworks & Drivers
│   │   │   │   ├── adapter/
│   │   │   │   │   ├── persistence/       # Database implementations
│   │   │   │   │   ├── messaging/         # Message queues
│   │   │   │   │   ├── client/            # External API clients
│   │   │   │   │   └── observability/     # Telemetry
│   │   │   │   ├── config/                # Spring configurations
│   │   │   │   └── exception/             # Exception handling
│   │   │   └── api/                       # Interface Adapters
│   │   │       ├── controller/            # REST controllers
│   │   │       ├── dto/                   # Data transfer objects
│   │   │       └── mapper/                # DTO mappers
│   │   └── resources/
│   │       ├── application.yml            # Main configuration
│   │       ├── application-dev.yml        # Development profile
│   │       └── db/migration/              # Database migrations
│   └── test/
│       └── java/com/company/myservice/
│           ├── unit/                      # Unit tests (75%)
│           ├── integration/               # Integration tests (20%)
│           ├── contract/                  # Contract tests (5%)
│           └── architecture/              # Architecture tests
├── pom.xml                                # Maven configuration
├── Dockerfile                             # Container configuration
└── README.md                              # Project documentation
```

## 🏗️ Clean Architecture Principles

The CLI enforces Clean Architecture with the following rules:

### Dependency Rule
- Dependencies point only inward toward higher-level policies
- Domain layer has NO framework dependencies
- Application layer depends only on Domain
- Infrastructure implements Domain ports
- API layer adapts between external and internal representations

### Layer Responsibilities

| Layer | Responsibility | Dependencies |
|-------|---------------|--------------|
| **Domain** | Business rules, entities, events | None |
| **Application** | Use cases, application services | Domain only |
| **Infrastructure** | Database, external APIs, frameworks | Domain, Application |
| **API** | Controllers, DTOs, REST endpoints | All layers |

## 🧪 Testing Strategy

### Test Pyramid Distribution

- **Unit Tests (75%)**: Fast, isolated tests for business logic
- **Integration Tests (20%)**: Database, API, and external service tests
- **Contract Tests (5%)**: Provider/consumer contract validation

### Running Tests

```bash
# Run all tests
mvn test

# Run only unit tests
mvn test -Dtest="*Test"

# Run integration tests
mvn test -Dtest="*IntegrationTest"

# Run architecture tests
mvn test -Dtest="*ArchitectureTest"

# Check code coverage
mvn test jacoco:report
# Report: target/site/jacoco/index.html

# Run mutation tests
mvn test-compile org.pitest:pitest-maven:mutationCoverage
# Report: target/pit-reports/index.html
```

## 🔍 Observability

### Application Insights Configuration

Set the connection string:
```bash
export APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=...;IngestionEndpoint=..."
```

### Features
- Automatic request/response tracking
- Dependency tracking
- Custom events and metrics
- Distributed tracing
- Performance counters
- Structured logging

### Custom Telemetry Example

```java
@Service
public class OrderService {
    private final TelemetryService telemetry;

    public Order processOrder(CreateOrderCommand command) {
        // Track custom event
        telemetry.trackEvent("OrderProcessed",
            Map.of("customerId", command.customerId()),
            Map.of("orderValue", command.totalAmount())
        );

        // Track custom metric
        telemetry.trackMetric("order.value", command.totalAmount());

        return order;
    }
}
```

## 🛡️ Security

### OAuth2 + JWT Configuration

The generated projects include:
- OAuth2 resource server configuration
- JWT token validation
- Role-based access control
- Method-level security
- CORS configuration

### Configuration

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${OAUTH2_ISSUER_URI}
          jwk-set-uri: ${OAUTH2_JWK_SET_URI}
```

## 💪 Resilience Patterns

### Circuit Breaker
```java
@CircuitBreaker(name = "paymentService", fallbackMethod = "paymentFallback")
public PaymentResponse processPayment(PaymentRequest request) {
    return paymentClient.charge(request);
}
```

### Retry
```java
@Retry(name = "paymentService")
public PaymentResponse processPayment(PaymentRequest request) {
    return paymentClient.charge(request);
}
```

### Rate Limiter
```java
@RateLimiter(name = "publicApi")
public List<Product> getProducts() {
    return productRepository.findAll();
}
```

## 🏃 Running Applications

### Development Mode

```bash
# With H2 in-memory database (quick start)
mvn spring-boot:run -Dspring-boot.run.profiles=h2

# With local database
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# With debug
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

### Docker

```bash
# Build image
docker build -t my-service:1.0.0 .

# Run container
docker run -p 8080:8080 \
  -e APPLICATIONINSIGHTS_CONNECTION_STRING="..." \
  -e DB_PASSWORD="..." \
  my-service:1.0.0
```

## 📖 Commands Reference

### init
Initialize a new Spring Boot project.

**Options:**
- `--name` (required): Service name (kebab-case)
- `--package` (required): Java package
- `--database`: Database type (mssql|mongodb, default: mssql)
- `--openapi`: Path to OpenAPI spec
- `--features`: Comma-separated features
- `--docker-available`: Docker availability

### add usecase
Add a new use case.

**Options:**
- `--name` (required): Use case name
- `--aggregate` (required): Aggregate name

### add entity
Add a new domain entity.

**Options:**
- `--name` (required): Entity name
- `--fields` (required): Comma-separated fields with types

### add repository
Add a repository for an entity.

**Options:**
- `--entity` (required): Entity name
- `--type`: Repository type (jpa|mongo, auto-detected)

### validate architecture
Validate Clean Architecture rules.

**Options:**
- `--generate-test`: Generate ArchUnit test file

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact the development team
- Check the documentation

## 🚧 Roadmap

- [ ] GraphQL support
- [ ] WebFlux (reactive) support
- [ ] gRPC integration
- [ ] Kubernetes manifests generation
- [ ] CI/CD pipeline templates
- [ ] Multi-module project support
- [ ] Service mesh integration

---

Built with ❤️ for standardized Spring Boot development