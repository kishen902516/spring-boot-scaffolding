# Feature Development Workflow

This workflow guides the complete feature implementation process from requirement to deployment using TDD and Clean Architecture.

## Prerequisites

### 0. Project Structure Check

**MANDATORY PREREQUISITE:**
Before proceeding with feature development, verify that a Spring Boot project structure exists.

**Check for Project Structure:**
```bash
# Look for Maven project indicators
ls pom.xml
ls src/main/java

# Look for Spring Boot indicators
grep -r "@SpringBootApplication" src/main/java 2>/dev/null
```

**If NO Spring Boot/Maven project exists:**

⚠️ **YOU MUST INITIALIZE THE PROJECT FIRST** ⚠️

Run the initialization command:
```bash
/springboot-init --name <service-name> --package <base-package> --database <db-type> --features <feature-list>
```

See: `/home/kishen90/java/claude-springboot-plugin/claude-config/commands/springboot-init.md`

**Example:**
```bash
/springboot-init --name user-service --package com.example.users --database mongodb --features oauth2,resilience
```

**Validation After Init:**
- ✅ pom.xml exists
- ✅ src/main/java directory structure created
- ✅ Spring Boot application class present
- ✅ Clean Architecture layers (domain, application, infrastructure, api) created
- ✅ Build succeeds: `mvn clean install`

**ONLY PROCEED with feature development after project initialization is complete.**

---

## Workflow Steps

### 1. Requirements Analysis
- Analyze user story/requirement
- Identify domain entities and aggregates
- Define commands and queries (CQRS)
- List external dependencies

### 2. GitHub Setup (Using GitHub MCP)

**PREREQUISITE CHECK:**
Ensure GitHub MCP is configured. Run: `/github-setup-check`

**Check/Create GitHub Project:**

**Step 1: Check for Existing Project**
```bash
# Check if a project exists with the repository/service name
gh project list --owner @me --limit 100 | grep -i "$(basename $(pwd))"

# Or check organization projects
gh project list --owner {org-name} --limit 100 | grep -i "$(basename $(pwd))"
```

**Step 2: Create GitHub Project if Not Exists**
```bash
# Get the project/service name from current directory or pom.xml
PROJECT_NAME=$(basename $(pwd))

# Create GitHub project with the same name as the service
gh project create --owner @me --title "$PROJECT_NAME" --description "Project board for $PROJECT_NAME development"

# Or for organization
gh project create --owner {org-name} --title "$PROJECT_NAME" --description "Project board for $PROJECT_NAME development"

# Create standard columns (TODO, In Progress, In Review, Done)
PROJECT_ID=$(gh project list --owner @me --limit 1 --format json | jq -r '.[0].id')

# Add columns to project
gh project field-create $PROJECT_ID --name "Status" --data-type "single-select" \
  --single-select-options "TODO,In Progress,In Review,Done"

# Set TODO as default status
gh project field-update $PROJECT_ID --name "Status" --default-value "TODO"
```

**Working with One Ticket at a Time:**
```
IMPORTANT: Only one issue should be in "In Progress" status at any time.
Before moving a new issue to "In Progress", ensure all other issues are in TODO, In Review, or Done.
```

**Create GitHub Issue via MCP:**
```
@feature-developer will use GitHub MCP to:
- Create issue with title, description, labels
- Add acceptance criteria
- Assign to user
- Add to project board with "TODO" status (default)
- Check no other issues are "In Progress" before starting
```

**Start Working on Issue:**
```bash
# Check for any issues currently in progress
gh project item-list $PROJECT_ID --format json | jq '.items[] | select(.status == "In Progress")'

# If no issues in progress, move current issue to "In Progress"
gh project item-edit --id {item-id} --field Status --value "In Progress"

# If an issue is already in progress, complete it first or move it back to TODO
```

**Create Feature Branch via MCP:**
```
Branch naming: feature/{issue-number}-{feature-name}
Base branch: main (or configured default)
```

**Update Project Board via MCP:**
```
Move issue from "TODO" → "In Progress" (only one at a time)
Add status comment on issue
```

**Manual Alternative (if needed):**
```bash
# If MCP unavailable, use git directly
git checkout -b feature/{issue-number}-{feature-name}
git push -u origin feature/{issue-number}-{feature-name}
```

**Validation:**
- ✅ GitHub project exists with same name as service
- ✅ Project has TODO, In Progress, In Review, Done columns
- ✅ Only one issue in "In Progress" status
- ✅ Issue created and assigned with TODO status
- ✅ Branch created from latest main
- ✅ Project board updated correctly
- ✅ Issue number captured for PR linking

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

### 7. Pull Request (Using GitHub MCP)

**Commit Changes:**
```bash
git add .
git commit -m "feat: {feature description}

Implements feature #{issue-number}

- Changes summary
- Tests added with >80% coverage
- Architecture validation passed

Closes #{issue-number}"

git push -u origin feature/{issue-number}-{feature-name}
```

**Create PR via GitHub MCP:**
```
@feature-developer will use GitHub MCP to:
- Create pull request with PR template
- Title: "feat: {Feature name}"
- Body: Auto-filled from template (.claude/config/PULL_REQUEST_TEMPLATE.md)
  - Summary of changes
  - Test coverage report
  - Architecture validation results
  - Checklist (pre-filled)
- Base: main
- Head: feature/{issue-number}-{feature-name}
- Labels: feature, ready-for-review
- Assignee: Current user
- Link: Closes #{issue-number}
```

**Update Project Board via MCP:**
```
Move issue from "In Progress" → "In Review"
Add comment: "PR #{pr-number} created"
Note: After moving to "In Review", the "In Progress" slot is now free for the next TODO item
```

**Manual Alternative:**
```bash
# If MCP unavailable
gh pr create \
  --title "feat: {name}" \
  --body "Closes #{issue-number}" \
  --assignee @me \
  --label "feature"
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

# Update project board - move from "In Review" → "Done"
gh project item-edit --id {item-id} --field Status --value Done

# After moving to Done, pick the next TODO item if available
echo "Issue completed! Ready to pick next TODO item from the project board."

# Check for next TODO items
gh project item-list $PROJECT_ID --format json | jq '.items[] | select(.status == "TODO") | {id, title}'

# Tag release (if needed)
git tag -a v{version} -m "Release {version}"
git push origin v{version}
```

**Workflow Cycle:**
```
TODO → In Progress (only 1 at a time) → In Review → Done → Pick next TODO
```

## Checklist

Before starting feature development:

- [ ] **Project structure exists** (if not, run `/springboot-init`)
- [ ] pom.xml and Maven structure verified
- [ ] Spring Boot application class present

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