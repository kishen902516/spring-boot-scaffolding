# Spring Boot CLI Claude Code Plugin

A comprehensive Claude Code plugin for generating production-ready Spring Boot microservices with Clean Architecture, CQRS, TDD, and Java 21 best practices.

## 🚀 Features

- **Test-Driven Development (TDD)** - Enforces test-first development approach
- **Clean Architecture** - Maintains strict architectural boundaries
- **CQRS Pattern** - Separates commands and queries
- **Java 21 Features** - Records, pattern matching, virtual threads, sealed classes
- **GitHub Integration** - Automated PR creation, issue tracking, project boards
- **Comprehensive Testing** - Unit, integration, architecture, and E2E tests
- **Automated Validation** - Architecture, coverage, style checks via hooks

## 📋 Prerequisites

1. **Spring Boot CLI** installed at `/home/kishen90/java/springboot-cli`
2. **Java 21** or higher
3. **Maven 3.9+**
4. **Docker** (for Testcontainers)
5. **GitHub CLI** (`gh`) installed and configured
6. **Claude Code CLI** installed

## 🔧 Installation

### 1. Clone the Spring Boot CLI Repository

```bash
cd /home/kishen90/java
git clone <your-springboot-cli-repo> springboot-cli
```

### 2. Install the Claude Code Plugin

The plugin is already installed in this repository at `.claude/`. To use it in other projects:

```bash
# Copy plugin to your project
cp -r /home/kishen90/java/.claude /path/to/your/project/

# Make hooks executable
chmod +x /path/to/your/project/.claude/hooks/*.sh
```

### 3. Configure GitHub MCP Server

Install the GitHub MCP server globally:

```bash
npm install -g @modelcontextprotocol/server-github
```

Set up your GitHub token:

```bash
export GITHUB_TOKEN="your-github-personal-access-token"
```

Add to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
export GITHUB_TOKEN="your-github-personal-access-token"
export SPRINGBOOT_CLI_PATH="/home/kishen90/java/springboot-cli"
```

### 4. Configure Claude Code

In Claude Code, enable the plugin by opening settings and adding the MCP server configuration:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### 5. Set Up Git Hooks (Optional)

To enable pre-commit validation:

```bash
cd /path/to/your/project
ln -s .claude/hooks/pre-commit-validation.sh .git/hooks/pre-commit
```

## 🎯 Usage

### Quick Start

1. **Initialize a new Spring Boot project:**

```
/springboot-init --name user-service --package com.example.users --database mongodb --features oauth2,resilience
```

2. **Start feature development with TDD:**

```
@feature-developer: Implement user registration with email verification
```

The agent will:
- Create GitHub issue and branch
- Guide you through TDD implementation
- Use slash commands to generate code
- Validate architecture at each step
- Create PR when complete

### Available Slash Commands

#### Project Management
- `/springboot-init` - Initialize new Spring Boot project
- `/springboot-validate` - Validate architecture/coverage/style
- `/springboot-assess` - Assess if Camel integration is needed

#### Domain Layer
- `/springboot-add-entity` - Add domain entity
- `/springboot-add-aggregate` - Add aggregate root
- `/springboot-add-event` - Add domain event

#### Application Layer
- `/springboot-add-usecase` - Add command/query handler

#### Infrastructure Layer
- `/springboot-add-repository` - Add repository implementation
- `/springboot-add-client` - Add external REST client

#### API Layer
- `/springboot-generate-api` - Generate from OpenAPI spec

#### Testing
- `/springboot-generate-tests` - Generate test suites

### Backend Agents

#### 1. Feature Developer (`@feature-developer`)

Main development agent that implements features using TDD:

```
@feature-developer: Create a product catalog with search functionality
```

The agent will:
1. Analyze requirements
2. Create GitHub issue and branch
3. Write tests first (RED)
4. Generate implementation (GREEN)
5. Refactor and optimize (REFACTOR)
6. Create PR when complete

#### 2. Test Engineer (`@test-engineer`)

Specialized in testing strategies:

```
@test-engineer: Improve test coverage for the order module
```

#### 3. Architecture Guardian (`@architecture-guardian`)

Ensures architectural integrity:

```
@architecture-guardian: Review the current architecture for violations
```

### Hooks

Hooks run automatically at different stages:

1. **Pre-Commit** (`pre-commit-validation.sh`)
   - Compilation check
   - Fast unit tests
   - Architecture validation
   - Security scan

2. **Post-Feature** (`post-feature-complete.sh`)
   - Full test suite
   - Coverage validation
   - Style checks
   - Test pyramid validation

3. **E2E Test Updater** (`e2e-test-updater.sh`)
   - Analyzes new endpoints
   - Generates E2E test scenarios
   - Updates test coverage

## 🏗️ Architecture

The plugin enforces Clean Architecture with CQRS:

```
┌─────────────────────────────────────┐
│           API Layer                 │  ← Controllers, OpenAPI
├─────────────────────────────────────┤
│      Infrastructure Layer           │  ← Adapters, Spring Config
├─────────────────────────────────────┤
│       Application Layer              │  ← Use Cases, CQRS Handlers
├─────────────────────────────────────┤
│         Domain Layer                 │  ← Entities, Value Objects
│    (NO Framework Dependencies!)     │
└─────────────────────────────────────┘

Dependencies flow inward only (↓)
```

### Key Principles

1. **Domain Purity**: Domain layer has ZERO framework dependencies
2. **CQRS Separation**: Commands modify, Queries read - never mix
3. **Port & Adapter**: All external interactions through interfaces
4. **Test Pyramid**: 75% unit, 20% integration, 5% E2E tests
5. **Java 21 Features**: Records for DTOs, pattern matching, virtual threads

## 📝 Example Workflow

### Creating a New Feature

1. **Start with the agent:**

```
@feature-developer: Implement order processing with payment integration
```

2. **Agent creates GitHub issue and branch**

3. **TDD Cycle begins:**

```java
// 1. Agent writes test first
@Test
void should_process_order_with_payment() {
    // Test implementation
}

// 2. Agent generates entity
/springboot-add-entity --name Order --attributes "id:UUID,customerId:UUID,amount:BigDecimal"

// 3. Agent implements business logic
// 4. Test passes (GREEN)
// 5. Refactor for quality
```

4. **Validation:**

```bash
/springboot-validate --aspect all
```

5. **PR Creation:**

The agent creates a PR with:
- Comprehensive description
- Test results
- Coverage report
- Architecture validation

## 🧪 Testing

### Run Tests Locally

```bash
# All tests
mvn test

# Unit tests only
mvn test -Dtest="*Test"

# Integration tests
mvn test -Dtest="*IntegrationTest"

# Architecture tests
mvn test -Dtest="*ArchitectureTest"

# E2E tests
mvn test -Dtest="*E2ETest"
```

### Check Coverage

```bash
mvn jacoco:report
# Report at: target/site/jacoco/index.html
```

## 🔍 Validation

### Manual Validation

```bash
# Architecture
/springboot-validate --aspect architecture

# Coverage
/springboot-validate --aspect coverage

# Style
/springboot-validate --aspect style

# All aspects
/springboot-validate --aspect all
```

### Automated Validation

Hooks automatically validate:
- Pre-commit: Fast checks
- Post-feature: Comprehensive validation
- PR creation: Full test suite

## 🎨 Java 21 Best Practices

The plugin enforces modern Java patterns:

### Records for DTOs

```java
public record CreateOrderCommand(
    UUID customerId,
    List<OrderItem> items,
    PaymentMethod paymentMethod
) {
    // Validation in compact constructor
    public CreateOrderCommand {
        Objects.requireNonNull(customerId);
        Objects.requireNonNull(items);
        if (items.isEmpty()) {
            throw new IllegalArgumentException("Order must have items");
        }
    }
}
```

### Pattern Matching

```java
public void handle(Command command) {
    switch (command) {
        case CreateOrderCommand(var customerId, var items, var payment) ->
            createOrder(customerId, items, payment);
        case UpdateOrderCommand(var orderId, var updates) ->
            updateOrder(orderId, updates);
        case null ->
            throw new IllegalArgumentException("Command cannot be null");
    }
}
```

### Virtual Threads

```java
@Service
public class OrderService {
    private final ExecutorService executor =
        Executors.newVirtualThreadPerTaskExecutor();

    public CompletableFuture<Order> processAsync(Order order) {
        return CompletableFuture.supplyAsync(
            () -> processOrder(order),
            executor
        );
    }
}
```

## 📊 GitHub Integration

### Project Boards

The plugin automatically:
- Creates project boards for each service
- Tracks feature progress
- Updates task status
- Links PRs to issues

### PR Workflow

1. Agent creates feature branch
2. Implements with TDD
3. Creates PR with template
4. Links to issue
5. Updates project board

## 🐛 Troubleshooting

### Common Issues

1. **Spring Boot CLI not found**
   ```bash
   export SPRINGBOOT_CLI_PATH="/path/to/springboot-cli"
   ```

2. **GitHub token not set**
   ```bash
   export GITHUB_TOKEN="your-token"
   ```

3. **Tests failing**
   - Check test logs in `/tmp/`
   - Verify Docker is running (for Testcontainers)
   - Check database connections

4. **Architecture violations**
   ```bash
   /springboot-validate --aspect architecture
   ```
   Review violations and fix dependency issues

5. **Low coverage**
   - Generate report: `mvn jacoco:report`
   - Add missing test scenarios
   - Focus on domain and application layers

### Debug Mode

Enable verbose output:

```bash
export CLAUDE_PLUGIN_DEBUG=true
```

## 📚 Documentation

### Generated Documentation

The plugin generates:
- API documentation (OpenAPI/Swagger)
- Architecture diagrams
- Test coverage reports
- Code quality reports

### Additional Resources

- [Spring Boot CLI Documentation](./springboot-cli/README.md)
- [Clean Architecture Guide](./springboot-cli/docs/clean-architecture.md)
- [CQRS Pattern Guide](./springboot-cli/docs/cqrs.md)
- [TDD Best Practices](./springboot-cli/docs/tdd.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Follow TDD approach
4. Ensure all validations pass
5. Create PR with comprehensive description

## 📄 License

This plugin is part of the Spring Boot CLI project and follows the same license.

## 🆘 Support

For issues or questions:
1. Check troubleshooting section
2. Review logs in `/tmp/`
3. Create issue in GitHub repository
4. Contact the development team

## 🎯 Quick Reference

### Essential Commands

```bash
# Initialize project
/springboot-init --name my-service --package com.example --database mongodb --features oauth2

# Add entity
/springboot-add-entity --name User --attributes "id:UUID,email:String,name:String"

# Add use case
/springboot-add-usecase --type command --name CreateUser --entity User --operation create

# Validate
/springboot-validate --aspect all

# Generate tests
/springboot-generate-tests --type all --scope feature
```

### Agent Commands

```
@feature-developer: [Implement feature description]
@test-engineer: [Improve test coverage]
@architecture-guardian: [Review architecture]
```

### Validation Checklist

- [ ] TDD: Tests written first
- [ ] Coverage > 80%
- [ ] Architecture validation passed
- [ ] CQRS properly separated
- [ ] Java 21 features used
- [ ] No domain contamination
- [ ] All tests passing
- [ ] Documentation updated

---

**Happy Coding with Clean Architecture, CQRS, and TDD! 🚀**