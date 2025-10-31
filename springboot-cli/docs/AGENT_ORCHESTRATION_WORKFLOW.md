# Agent Orchestration Workflow for Clean Architecture Enforcement

## Overview

This document defines the automated orchestration between Feature Developer Agents and Architecture Validation Agents to ensure strict adherence to Clean Architecture and Domain-Driven Design principles.

## Problem Statement

Feature agents often bypass clean architecture principles by:
- Removing interface extensions when implementing clients
- Adding Spring annotations to domain entities
- Creating direct dependencies between layers
- Implementing business logic in infrastructure layer
- Skipping port/adapter pattern

## Orchestration Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION CONTROLLER                  │
│                   (orchestrator.sh)                          │
└──────────────────┬──────────────────────────┬───────────────┘
                   │                          │
         ┌─────────▼──────────┐     ┌────────▼──────────┐
         │  FEATURE AGENT     │     │ ARCHITECTURE AGENT │
         │  (writes code)     │     │  (validates code)  │
         └─────────┬──────────┘     └────────┬──────────┘
                   │                          │
         ┌─────────▼──────────────────────────▼──────────┐
         │           VALIDATION PIPELINE                  │
         │  1. Syntax Check                              │
         │  2. Architecture Rules (ArchUnit)             │
         │  3. Pattern Detection                         │
         │  4. Auto-Correction                          │
         │  5. Feedback Loop                            │
         └───────────────────────────────────────────────┘
```

## Workflow Stages

### Stage 1: Feature Development
```yaml
trigger: Feature request or user story
agent: feature-developer
outputs:
  - New code files
  - Modified existing files
  - Test files
validation_checkpoint: true
```

### Stage 2: Pre-Validation
```yaml
trigger: Code written by feature agent
validations:
  - Compilation check
  - Import analysis
  - Package structure verification
timeout: 30s
fail_fast: true
```

### Stage 3: Architecture Validation
```yaml
trigger: Pre-validation success
agent: architecture-guardian
checks:
  - Domain layer purity
  - Port/Adapter pattern adherence
  - Dependency direction
  - Interface implementation
  - Clean architecture rules
auto_fix: true
```

### Stage 4: Auto-Correction
```yaml
trigger: Architecture violations detected
corrections:
  - Add missing interface extensions
  - Remove Spring annotations from domain
  - Move misplaced classes
  - Fix dependency directions
  - Extract interfaces to ports
feedback_to_feature_agent: true
```

### Stage 5: Final Validation
```yaml
trigger: Auto-correction complete
validations:
  - ArchUnit tests
  - Coverage check (80% minimum)
  - Contract tests
  - Integration tests
approval_required: false
```

## Common Violation Patterns and Fixes

### 1. Missing Interface Extension in Clients

**Violation:**
```java
// Infrastructure layer - INCORRECT
@Component
public class ExternalServiceClient {
    // Missing: implements ExternalServicePort
}
```

**Auto-Fix:**
```java
// Infrastructure layer - CORRECTED
@Component
public class ExternalServiceClient implements ExternalServicePort {
    // Implements domain port interface
}
```

### 2. Spring Annotations in Domain

**Violation:**
```java
// Domain layer - INCORRECT
@Entity
@Table(name = "orders")
public class Order {
    @Id
    private UUID id;
}
```

**Auto-Fix:**
```java
// Domain layer - CORRECTED
public class Order {
    private UUID id;
    // Pure domain object, no framework dependencies
}

// Infrastructure layer - JPA Entity
@Entity
@Table(name = "orders")
public class OrderJpaEntity {
    @Id
    private UUID id;
    // JPA-specific implementation
}
```

### 3. Business Logic in Infrastructure

**Violation:**
```java
// Infrastructure layer - INCORRECT
@Repository
public class OrderRepositoryImpl {
    public Order createOrder(OrderRequest request) {
        // Business logic here - WRONG!
        if (request.getAmount() > 10000) {
            request.setStatus("REQUIRES_APPROVAL");
        }
        return save(order);
    }
}
```

**Auto-Fix:**
```java
// Domain layer - Use Case
public class CreateOrderUseCase {
    public Order execute(OrderRequest request) {
        // Business logic belongs here
        if (request.getAmount() > 10000) {
            request.setStatus("REQUIRES_APPROVAL");
        }
        return orderPort.save(order);
    }
}

// Infrastructure layer - Repository
@Repository
public class OrderRepositoryImpl implements OrderPort {
    public Order save(Order order) {
        // Only persistence logic
        return mapper.toDomain(repository.save(mapper.toEntity(order)));
    }
}
```

## Validation Rules Configuration

```yaml
architecture_rules:
  domain_layer:
    - no_framework_dependencies: true
    - no_spring_annotations: true
    - immutable_value_objects: true
    - rich_domain_models: true

  application_layer:
    - use_cases_only: true
    - orchestration_only: true
    - no_business_logic: false  # Can orchestrate domain logic

  infrastructure_layer:
    - implements_ports: mandatory
    - adapter_pattern: mandatory
    - framework_specific: allowed

  api_layer:
    - rest_controllers_only: true
    - thin_controllers: true
    - delegates_to_usecases: mandatory

dependency_rules:
  - from: "api"
    to: ["application", "domain"]
    allowed: true

  - from: "application"
    to: ["domain"]
    allowed: true

  - from: "infrastructure"
    to: ["domain", "application"]
    allowed: true

  - from: "domain"
    to: ["api", "application", "infrastructure"]
    allowed: false  # Domain depends on nothing

interface_rules:
  ports:
    location: "domain.port"
    naming: ".*Port$"

  adapters:
    location: "infrastructure.adapter"
    must_implement_port: true
    naming: ".*Adapter$|.*RepositoryImpl$|.*Client$"
```

## Agent Communication Protocol

### Feature Agent → Orchestrator
```json
{
  "agent": "feature-developer",
  "action": "code_complete",
  "files": [
    "src/main/java/com/example/infrastructure/client/PaymentClient.java",
    "src/test/java/com/example/PaymentClientTest.java"
  ],
  "feature": "payment-integration",
  "ready_for_validation": true
}
```

### Orchestrator → Architecture Agent
```json
{
  "action": "validate",
  "files": [
    "src/main/java/com/example/infrastructure/client/PaymentClient.java"
  ],
  "rules": ["interface_implementation", "clean_architecture"],
  "auto_fix": true,
  "report_violations": true
}
```

### Architecture Agent → Orchestrator
```json
{
  "validation_result": "failed",
  "violations": [
    {
      "file": "PaymentClient.java",
      "line": 10,
      "rule": "missing_interface_implementation",
      "severity": "HIGH",
      "fix_available": true,
      "fix_applied": true
    }
  ],
  "fixes_applied": 1,
  "recommendation": "Review auto-fixes and re-run tests"
}
```

### Orchestrator → Feature Agent (Feedback)
```json
{
  "feedback": "architecture_violations_fixed",
  "violations_found": 1,
  "auto_fixed": 1,
  "learning_points": [
    "Always implement domain port interfaces in infrastructure clients",
    "Reference: Clean Architecture principle - dependency inversion"
  ],
  "next_action": "continue"
}
```

## Integration Points

### 1. Git Hooks
```bash
# .git/hooks/pre-commit
#!/bin/bash
/path/to/orchestrator.sh validate --stage pre-commit
```

### 2. CI/CD Pipeline
```yaml
# .github/workflows/architecture-validation.yml
- name: Orchestrated Validation
  run: |
    ./bin/orchestrator.sh validate --full
    ./bin/orchestrator.sh report --format json > validation-report.json
```

### 3. IDE Integration
```json
// .vscode/tasks.json
{
  "label": "Validate Architecture",
  "type": "shell",
  "command": "./bin/orchestrator.sh",
  "args": ["validate", "--file", "${file}"],
  "problemMatcher": "$tsc"
}
```

## Metrics and Monitoring

### Key Metrics
- **Violation Rate**: Number of violations per 100 lines of code
- **Auto-Fix Success Rate**: Percentage of violations auto-corrected
- **Agent Learning Rate**: Reduction in violations over time
- **Validation Time**: Average time for full validation cycle

### Dashboard Components
```yaml
metrics:
  daily_violations:
    query: "COUNT(violations) GROUP BY date, agent"

  common_violations:
    query: "TOP(10) violations BY type"

  fix_effectiveness:
    query: "COUNT(auto_fixed) / COUNT(total_violations)"

  agent_performance:
    query: "AVG(violations) BY agent OVER time"
```

## Continuous Learning

### Feedback Loop Implementation
1. **Collect Violations**: Store all violations in a learning database
2. **Pattern Recognition**: Identify recurring violations by agent
3. **Update Agent Prompts**: Enhance agent instructions with common pitfalls
4. **Measure Improvement**: Track violation reduction over time

### Learning Database Schema
```sql
CREATE TABLE agent_violations (
    id UUID PRIMARY KEY,
    agent_name VARCHAR(50),
    violation_type VARCHAR(100),
    file_path VARCHAR(255),
    line_number INT,
    original_code TEXT,
    fixed_code TEXT,
    fix_applied BOOLEAN,
    timestamp TIMESTAMP,
    learning_applied BOOLEAN DEFAULT FALSE
);

CREATE TABLE agent_improvements (
    agent_name VARCHAR(50),
    violation_type VARCHAR(100),
    occurrences_before INT,
    occurrences_after INT,
    improvement_percentage DECIMAL(5,2),
    prompt_updated BOOLEAN,
    update_date DATE
);
```

## Implementation Checklist

- [ ] Create orchestrator.sh main script
- [ ] Implement validation pipeline
- [ ] Create auto-correction rules engine
- [ ] Set up agent communication protocol
- [ ] Integrate with existing validation tools
- [ ] Create learning database
- [ ] Set up metrics collection
- [ ] Create monitoring dashboard
- [ ] Write comprehensive tests
- [ ] Document agent prompts updates

## Success Criteria

1. **Zero Manual Fixes**: 95% of architecture violations auto-corrected
2. **Learning Curve**: 50% reduction in violations within 30 days
3. **Performance**: Full validation cycle under 60 seconds
4. **Coverage**: 100% of Clean Architecture rules validated
5. **Adoption**: All feature development uses orchestration

## References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design by Eric Evans](https://domainlanguage.com/ddd/)
- [ArchUnit Documentation](https://www.archunit.org/)
- [Spring Boot CLI Documentation](../README.md)