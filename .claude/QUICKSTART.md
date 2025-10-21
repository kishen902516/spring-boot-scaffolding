# Quick Start Guide - Spring Boot CLI Claude Code Plugin

## 🚀 5-Minute Setup

### 1. Set Environment Variables

```bash
export GITHUB_TOKEN="your-github-token"
export SPRINGBOOT_CLI_PATH="/home/kishen90/java/springboot-cli"
```

### 2. Test the Plugin

```bash
# Navigate to your project directory
cd /home/kishen90/java

# Test a slash command in Claude Code
/springboot-validate --aspect all
```

## 🎯 Your First Feature with TDD

### Step 1: Initialize a New Project

In Claude Code, type:

```
/springboot-init --name product-service --package com.example.products --database mongodb --features oauth2,resilience
```

### Step 2: Implement Your First Feature

Tell the feature developer agent:

```
@feature-developer: Create a product management system with the following:
- Product entity with id, name, description, price, and quantity
- Create, update, delete, and get operations
- Search products by name
- MongoDB repository
```

The agent will:
1. ✅ Create GitHub issue and branch
2. ✅ Write tests first (TDD)
3. ✅ Generate implementation using slash commands
4. ✅ Validate architecture
5. ✅ Create pull request

## 📝 Common Scenarios

### Scenario 1: Add a New Entity

```
@feature-developer: Add a Category entity with id, name, and description. Products should belong to categories.
```

### Scenario 2: Add External Integration

```
@feature-developer: Integrate with a payment service at https://payment.api.com with circuit breaker and retry patterns
```

### Scenario 3: Add Event-Driven Features

```
@feature-developer: When an order is placed, publish an OrderPlaced event that triggers inventory update and email notification
```

## 🧪 Testing Your Implementation

### Quick Test Run

```bash
# Unit tests (fast feedback)
mvn test -Dtest="*Test" -DexcludedGroups="integration,e2e"

# Full validation
.claude/hooks/post-feature-complete.sh
```

### Check Coverage

```bash
mvn jacoco:report
open target/site/jacoco/index.html
```

## ✅ Validation Checklist

Before completing a feature:

```bash
# 1. Architecture check
/springboot-validate --aspect architecture

# 2. Coverage check (must be >80%)
/springboot-validate --aspect coverage

# 3. Style check
/springboot-validate --aspect style
```

## 🎨 Java 21 Pattern Examples

### Use Records for DTOs

```java
// The plugin generates this automatically
public record ProductDTO(
    UUID id,
    String name,
    String description,
    BigDecimal price,
    Integer quantity
) {}
```

### CQRS Commands and Queries

```java
// Command (modifies state)
public record CreateProductCommand(
    String name,
    String description,
    BigDecimal price,
    Integer quantity
) {}

// Query (reads state)
public record GetProductByIdQuery(UUID productId) {}
```

## 🔥 Pro Tips

### 1. Let the Agent Drive TDD

Don't write implementation first! Tell the agent what you want, and it will:
- Write the test
- Run it (RED)
- Generate implementation (GREEN)
- Refactor (REFACTOR)

### 2. Use Architecture Guardian for Reviews

```
@architecture-guardian: Review my current implementation for Clean Architecture violations
```

### 3. Leverage Test Engineer for Coverage

```
@test-engineer: Analyze the product module and improve test coverage to 90%
```

### 4. Batch Operations

You can chain multiple operations:

```
@feature-developer:
1. Add User entity with authentication
2. Add Role entity with permissions
3. Create user registration flow with email verification
4. Add OAuth2 integration
```

## 🚨 Common Gotchas

### Domain Contamination

❌ **Wrong**: Adding Spring annotations to domain entities
```java
@Entity  // ❌ NO!
public class Product {
    @Id  // ❌ NO!
    private UUID id;
}
```

✅ **Right**: Keep domain pure
```java
public class Product {
    private final UUID id;  // ✅ Pure Java
}
```

### Mixed Commands and Queries

❌ **Wrong**: Command returning data
```java
public ProductDTO createProduct(CreateProductCommand cmd) {
    // Creates AND returns - violates CQRS
}
```

✅ **Right**: Separate operations
```java
// Command - only modifies
public void createProduct(CreateProductCommand cmd) { }

// Query - only reads
public ProductDTO getProduct(GetProductByIdQuery query) { }
```

## 🎯 Next Steps

1. **Explore slash commands**: Type `/springboot-` in Claude Code to see all options
2. **Try different agents**: Each agent has specialized capabilities
3. **Review generated code**: Check `.claude/agents/` for agent behaviors
4. **Customize hooks**: Modify `.claude/hooks/` for your workflow
5. **Read the full README**: `.claude/README.md` for comprehensive documentation

## 💡 Need Help?

- Check logs: `/tmp/` directory contains detailed logs
- Validate setup: `/springboot-validate --aspect all`
- Review architecture: `@architecture-guardian: analyze my project`
- Improve tests: `@test-engineer: review test coverage`

---

**You're ready to build production-ready Spring Boot microservices with TDD! 🚀**