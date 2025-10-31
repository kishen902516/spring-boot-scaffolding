# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains **Spring Boot Standardization CLI** - a comprehensive CLI tool for generating production-ready Spring Boot microservices with Clean Architecture, API-first development, and enterprise-grade observability.

**Key Characteristics:**
- Bash-based CLI tool (13 commands)
- Template-driven code generation (50+ templates)
- Clean Architecture enforcement
- Java 21 + Spring Boot 3.3+
- Azure Application Insights observability
- OAuth2/JWT security built-in

## CLI Command Structure

The main entry point is `springboot-cli/bin/springboot-cli.sh` which delegates to command scripts in `bin/commands/`:

```bash
# Main commands
./bin/springboot-cli.sh init              # Initialize new project
./bin/springboot-cli.sh add <component>   # Add components
./bin/springboot-cli.sh generate <type>   # Generate code
./bin/springboot-cli.sh validate <aspect> # Validate architecture/coverage
./bin/springboot-cli.sh assess camel      # Assess Camel integration need
```

## Testing the CLI

```bash
# Quick test - create a sample project
cd /tmp
/home/kishen90/java/springboot-cli/bin/springboot-cli.sh init \
  --name test-service \
  --package com.test \
  --database mongodb \
  --features oauth2

# Run tests
cd test-service
mvn clean test

# Validate architecture
/home/kishen90/java/springboot-cli/bin/springboot-cli.sh validate architecture
```

## Architecture Principles

### Clean Architecture Layers (Dependency Flow: Inward Only)

```
API Layer (REST)
    ↓ depends on
Infrastructure Layer (Adapters)
    ↓ implements
Application Layer (Use Cases)
    ↓ depends on
Domain Layer (Core) ← NO FRAMEWORK DEPENDENCIES
```

**Critical Rules:**
1. Domain layer has ZERO Spring/framework dependencies
2. Infrastructure implements domain port interfaces
3. All dependencies point inward toward domain
4. Use cases orchestrate domain logic, never contain it

### Generated Project Structure

```
my-service/
├── src/main/java/com/company/myservice/
│   ├── domain/                    # Pure business logic
│   │   ├── model/                 # Entities, aggregates, value objects
│   │   ├── event/                 # Domain events
│   │   └── port/                  # Interfaces (input/output)
│   ├── application/               # Use cases, orchestration
│   │   ├── usecase/               # Use case implementations
│   │   └── eventhandler/          # Event handlers
│   ├── infrastructure/            # Framework adapters
│   │   ├── adapter/
│   │   │   ├── persistence/       # JPA/MongoDB implementations
│   │   │   ├── client/            # External API clients
│   │   │   └── messaging/         # Kafka/messaging
│   │   └── config/                # Spring configurations
│   └── api/                       # REST controllers (OpenAPI-generated)
```

## Template System

Templates are in `springboot-cli/templates/` and use variable substitution:

**Common Variables:**
- `${PACKAGE}` - Java package (e.g., com.company.service)
- `${PACKAGE_PATH}` - Package as path (e.g., com/company/service)
- `${SERVICE_NAME}` - Service name (e.g., my-service)
- `${ENTITY}` - Entity name (e.g., Order)
- `${AGGREGATE}` - Aggregate name (e.g., Order)

**Template Categories:**
- `base/` - Maven POM files, Dockerfile, OpenAPI spec
- `layers/` - Clean architecture layer templates
- `security/` - OAuth2/JWT templates
- `observability/` - Application Insights, logging
- `infrastructure/` - Resilience4j patterns
- `eventsourcing/` - Full event sourcing + lightweight event-driven
- `camel/` - Apache Camel integration routes
- `tests/` - Unit, integration, contract, architecture tests

## Key Technologies

| Component | Technology | Configuration |
|-----------|-----------|---------------|
| Build | Maven 3.9+ | `templates/base/pom-*.xml` |
| Database | MS SQL / MongoDB | Auto-configured via `--database` flag |
| Security | OAuth2 + JWT | `templates/security/` |
| Observability | Azure Application Insights 3.5.1 | `templates/observability/` |
| Resilience | Resilience4j (CB, Retry, Rate Limit) | `templates/infrastructure/` |
| API-First | OpenAPI 3.1 + Generator | `generators/openapi-generator/` |
| Testing | JUnit 5, Mockito, Testcontainers, Pact, ArchUnit | `templates/tests/` |

## Common Development Commands

### Adding New Command Scripts

```bash
# Create new command script
cd springboot-cli/bin/commands
touch add-new-feature.sh
chmod +x add-new-feature.sh

# Add to main CLI switch statement in bin/springboot-cli.sh
# Follow pattern of existing commands
```

### Creating New Templates

```bash
# Add template file with .tmpl extension
cd springboot-cli/templates/
# Use ${VARIABLE} syntax for substitution
# Test with: sed "s/\${PACKAGE}/com.test/g" template.tmpl
```

### Testing Template Substitution

```bash
# Verify variable substitution works
sed -e "s/\${PACKAGE}/com.test/g" \
    -e "s/\${ENTITY}/Product/g" \
    templates/layers/domain/Entity.java.tmpl
```

## Observability - Application Insights

Generated projects include full observability via Azure Application Insights:

**Automatic Tracking:**
- HTTP requests (duration, status codes)
- Database queries (SQL/MongoDB)
- External dependencies
- Exceptions with context
- Performance counters

**Custom Telemetry:**
```java
// Generated TelemetryService allows:
telemetry.trackEvent("OrderProcessed", properties, metrics);
telemetry.trackMetric("order.value", value);
telemetry.trackException(exception, properties, severity);
```

**KQL Queries:**
See `springboot-cli/docs/app-insights-queries.md` for 30+ pre-built queries for monitoring performance, failures, and business metrics.

## Testing Strategy

Generated projects follow the test pyramid (enforced by templates):

- **75% Unit Tests** - Fast, isolated, no framework
  - Domain logic tests
  - Use case tests with mocks
  - Mapper tests

- **20% Integration Tests** - With Testcontainers/embedded DBs
  - API tests (REST Assured)
  - Repository tests (Testcontainers)
  - External client tests (WireMock)

- **5% Contract Tests** - Pact provider/consumer
  - API contract verification
  - External service contracts

- **Architecture Tests** - ArchUnit for Clean Architecture enforcement

```bash
# Run all tests
mvn test

# Run only unit tests
mvn test -Dtest="*Test"

# Run integration tests
mvn test -Dtest="*IntegrationTest"

# Check coverage (JaCoCo)
mvn test jacoco:report
# Report: target/site/jacoco/index.html

# Run mutation tests (PIT)
mvn test-compile org.pitest:pitest-maven:mutationCoverage
# Report: target/pit-reports/index.html
```

## Event Sourcing Options

CLI generates two event patterns:

1. **Full Event Sourcing** (`--features eventsourcing-full`)
   - Custom EventStore implementation
   - AggregateRoot base class
   - Event replay capability
   - Snapshots support

2. **Lightweight Event-Driven** (`--features eventsourcing-lite`)
   - Spring Modulith Events
   - Simple publish/subscribe
   - Outbox pattern for reliability

## Camel Integration

The CLI includes intelligent Camel assessment:

```bash
# Assess if Camel is needed
./bin/springboot-cli.sh assess camel

# Scoring (0-100):
# 60-100: Strongly recommended (multiple integrations, file ops, transformations)
# 30-59:  Consider (moderate complexity)
# 0-29:   Not recommended
```

**Route Templates:**
- File-to-Queue (file system to messaging)
- REST-to-REST (API orchestration)
- Content-Based Router (conditional routing)

## LLM Usage

See `springboot-cli/docs/llm-usage.md` for comprehensive prompts and examples.

**Example LLM Prompt:**
```
Create a Product inventory service with:
- Entity: Product (id:UUID, sku:String, name:String, price:BigDecimal, quantity:Integer)
- Use Cases: CreateProduct, UpdateQuantity, GetProduct
- Database: MongoDB
- Security: OAuth2
- Repository with custom SKU lookup

Generate the CLI commands needed.
```

## Critical Implementation Notes

1. **Domain Layer Purity:** Domain layer templates have ZERO Spring annotations. Any framework coupling is in Infrastructure layer.

2. **Port & Adapter Pattern:** All external interactions (DB, APIs) go through domain-defined port interfaces implemented in Infrastructure.

3. **OpenAPI-First:** API layer is generated from OpenAPI specs via OpenAPI Generator. Controllers implement generated interfaces.

4. **Resilience by Default:** All external clients get Circuit Breaker, Retry, and Rate Limiter configurations.

5. **Observability by Default:** Every generated project includes Application Insights with structured logging and custom telemetry.

## Git Workflow

```bash
# Current branch (as of commit bd7e179)
git branch  # add-skills

# Recent commits
# bd7e179 - Fixed the spring boot cli initializer issue
# e83cd09 - clean up
# bbffac4 - delete .calude folder
# d8e1e87 - feat(plugin) : added plugin feature
```

## Extending the CLI

### Adding a New "add" Command

1. Create `bin/commands/add-newfeature.sh`
2. Add to `bin/springboot-cli.sh` switch statement under `add` case
3. Create templates in `templates/layers/` or `templates/infrastructure/`
4. Use existing commands as reference (e.g., `add-entity.sh`)

### Adding New Templates

1. Place in appropriate `templates/` subdirectory
2. Use `${VARIABLE}` syntax for substitution
3. Use `.tmpl` extension
4. Reference in command scripts using `$TEMPLATES_DIR`

## Documentation Files

- `springboot-cli/README.md` - User-facing CLI documentation
- `springboot-cli/IMPLEMENTATION_SUMMARY.md` - Implementation status
- `springboot-cli/docs/llm-usage.md` - LLM prompts and examples
- `springboot-cli/docs/app-insights-queries.md` - KQL query library
- `SPRINGBOOT_CLI_PLAN.md` - Original design specification

## Common Pitfalls

1. **Don't add Spring annotations to domain templates** - Domain layer must remain framework-agnostic
2. **Always use port interfaces** - Never directly implement Spring Data repositories in domain
3. **Template variables case-sensitive** - ${PACKAGE} vs ${package}
4. **Test all substitutions** - Variable replacement can fail silently
5. **Maintain clean architecture** - ArchUnit tests will fail if dependencies are wrong

## Success Criteria

Generated projects must:
- ✅ Build successfully with `mvn clean install`
- ✅ Pass architecture tests (ArchUnit)
- ✅ Achieve >80% code coverage
- ✅ Have working Application Insights integration
- ✅ Have functional OAuth2 security (if enabled)
- ✅ Follow Google Java Style