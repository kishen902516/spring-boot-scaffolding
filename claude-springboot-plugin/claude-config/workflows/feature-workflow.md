# Feature Development Workflow

This workflow guides the complete feature implementation process from requirement to deployment using TDD and Clean Architecture.

## Workflow Steps

### 1. Requirements Analysis
- Analyze user story/requirement
- Identify domain entities and aggregates
- Define commands and queries (CQRS)
- List external dependencies

### 2. GitHub Setup
Using GitHub MCP:
```bash
# Create issue
gh issue create --title "Feature: {name}" --body "{description}" --label "feature"

# Create feature branch
git checkout -b feature/{issue-number}-{feature-name}

# Create/update project board
gh project item-add {project-id} --issue {issue-number}
```

### 3. TDD Implementation

#### Phase 1: RED (Write Failing Tests)

**Domain Layer:**
1. Write entity tests
2. Write aggregate tests
3. Write value object tests
4. Write domain event tests

**Application Layer:**
1. Write command handler tests
2. Write query handler tests
3. Write mapper tests

**Infrastructure Layer:**
1. Write repository tests
2. Write client tests
3. Write adapter tests

**API Layer:**
1. Write controller tests
2. Write integration tests

#### Phase 2: GREEN (Implement Minimum Code)

Use slash commands to generate implementation:
```bash
# Domain
/springboot-add-entity --name {Entity} --attributes "{attributes}"
/springboot-add-aggregate --name {Aggregate} --attributes "{attributes}" --events "{events}"

# Application
/springboot-add-usecase --type command --name {Name} --entity {Entity} --operation {op}
/springboot-add-usecase --type query --name {Name} --entity {Entity} --operation {op}

# Infrastructure
/springboot-add-repository --name {Name} --entity {Entity} --database {db}
/springboot-add-client --name {Name} --base-url {url} --resilience "{patterns}"

# API
/springboot-generate-api --spec openapi.yaml --controllers {controllers}
```

#### Phase 3: REFACTOR (Improve Quality)

1. Apply Java 21 features (records, pattern matching)
2. Ensure Clean Architecture
3. Verify CQRS separation
4. Run validations

### 4. Validation

Run comprehensive validations:
```bash
# Architecture validation
/springboot-validate --aspect architecture

# Coverage check
/springboot-validate --aspect coverage

# Style check
/springboot-validate --aspect style

# Run all validations
/springboot-validate --aspect all
```

### 5. E2E Testing

Generate and run E2E tests:
```bash
# Generate E2E tests
/springboot-generate-tests --type e2e --feature "{feature-name}"

# Run E2E tests
mvn test -Dtest="*E2ETest"
```

### 6. Documentation

Update documentation:
1. Update OpenAPI specification
2. Update README with feature description
3. Add architecture decision records (ADRs)
4. Update changelog

### 7. Pull Request

Create PR using GitHub MCP:
```bash
# Commit changes
git add .
git commit -m "feat: {feature description}"

# Push to remote
git push -u origin feature/{issue-number}-{feature-name}

# Create PR
gh pr create \
  --title "Feature: {name}" \
  --body "{description}" \
  --assignee @me \
  --label "feature" \
  --milestone "{milestone}"

# Link PR to issue
gh pr edit {pr-number} --body "Closes #{issue-number}"
```

### 8. Code Review

Address review feedback:
1. Fix any architecture violations
2. Improve test coverage
3. Refactor based on feedback
4. Update documentation

### 9. Merge and Deploy

After approval:
```bash
# Merge PR
gh pr merge {pr-number} --squash --delete-branch

# Update project board
gh project item-edit --id {item-id} --field Status --value Done

# Tag release (if needed)
git tag -a v{version} -m "Release {version}"
git push origin v{version}
```

## Checklist

Before marking feature as complete:

- [ ] All tests written first (TDD)
- [ ] All tests passing (unit, integration, E2E)
- [ ] Code coverage > 80%
- [ ] Architecture validation passed
- [ ] CQRS properly implemented
- [ ] Java 21 features used
- [ ] No domain contamination
- [ ] Documentation updated
- [ ] PR approved and merged
- [ ] Project board updated

## Common Commands Reference

### Testing
```bash
mvn test                          # Run all tests
mvn test -Dtest="*Test"          # Run unit tests
mvn test -Dtest="*IntegrationTest" # Run integration tests
mvn test -Dtest="*E2ETest"       # Run E2E tests
mvn test -Dtest="*ArchitectureTest" # Run architecture tests
```

### Coverage
```bash
mvn jacoco:report                 # Generate coverage report
mvn jacoco:check                  # Check coverage thresholds
```

### Validation
```bash
mvn checkstyle:check              # Check code style
mvn spotbugs:check                # Check for bugs
mvn dependency-check:check        # Check for vulnerabilities
```

## Troubleshooting

### Test Failures
1. Check test output for specific failures
2. Verify test data and mocks
3. Check for timing issues in integration tests
4. Ensure Testcontainers are running

### Architecture Violations
1. Run `/springboot-validate --aspect architecture`
2. Check dependency directions
3. Verify no framework dependencies in domain
4. Ensure CQRS separation

### Coverage Issues
1. Generate coverage report: `mvn jacoco:report`
2. Identify uncovered code in `target/site/jacoco/index.html`
3. Add missing test scenarios
4. Focus on domain and application layers