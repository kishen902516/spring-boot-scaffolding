# Claude Agent Quick Start - Architecture Orchestration

## 🚀 For Claude Agents: Start Using This Immediately

### 1. Quick Validation (Use This Now!)

When you write Java code, run this command to validate and auto-fix:

```bash
orchestrator.sh validate --fix
```

This will:
- ✅ Fix missing interfaces automatically
- ✅ Move Spring annotations from domain to infrastructure
- ✅ Create use cases for misplaced business logic
- ✅ Generate mappers between layers

### 2. Available Slash Commands

You can use these slash commands directly:

- **`/validate-arch`** - Run architecture validation with auto-fix
- **`/develop-feature`** - Start monitored feature development

Example:
```
User: Create a payment service

Claude: I'll create the payment service with architecture validation.

/validate-arch

[After writing code...]

Let me validate the architecture:
/validate-arch
```

### 3. When Writing Code, Follow This Pattern

#### Step 1: Write code (may have violations)
```java
// You might write this initially (with violation):
@Component
public class PaymentClient {
    public Result processPayment(Request req) {
        // implementation
    }
}
```

#### Step 2: Run validation
```bash
orchestrator.sh validate --fix
```

#### Step 3: Auto-fixes applied
```java
// Orchestrator creates this:
// domain/port/outbound/PaymentPort.java
public interface PaymentPort {
    Result processPayment(Request req);
}

// And updates your class:
@Component
public class PaymentClient implements PaymentPort {
    @Override
    public Result processPayment(Request req) {
        // implementation
    }
}
```

### 4. Common Scenarios

#### Scenario A: Creating a New Service
```bash
# 1. Start continuous monitoring
orchestrator.sh continuous . &

# 2. Write your service code
# 3. Violations are auto-fixed in real-time
# 4. Stop monitoring when done
kill $(cat /tmp/orchestrator-monitor.pid)
```

#### Scenario B: Adding a Repository
```java
// 1. Write repository (may violate initially)
@Repository
public class OrderRepositoryImpl {
    // implementation without interface
}

// 2. Run validation
orchestrator.sh validate --fix

// 3. Auto-creates OrderRepository interface in domain/port
// 4. Updates OrderRepositoryImpl to implement it
```

#### Scenario C: Domain Entity with JPA
```java
// 1. You might write:
@Entity
public class Product {
    @Id
    private UUID id;
}

// 2. Run validation
orchestrator.sh validate --fix

// 3. Auto-fixes:
// - Removes @Entity from domain
// - Creates ProductJpaEntity in infrastructure
// - Creates ProductMapper
```

### 5. Learning from Violations

After each session, check what you can improve:

```bash
# View learning report
orchestrator.sh report

# Or use the learning system directly
/home/kishen90/java/springboot-cli/bin/agent-learning-system.sh dashboard
```

### 6. Integration in Your Workflow

When responding to user requests:

```markdown
User: Create a user authentication service

Claude: I'll create a user authentication service with automatic architecture compliance.

First, let me start the orchestration monitor:
```bash
orchestrator.sh continuous . &
```

Now I'll create the service components...

[Write code...]

Let me validate the architecture:
```bash
orchestrator.sh validate --fix
```

✅ Architecture validated and auto-fixed:
- Created UserPort interface for UserClient
- Moved JPA annotations from User to UserJpaEntity
- Created UserMapper for conversion

The service is ready with clean architecture!
```

### 7. Key Rules Enforced Automatically

| Rule | Auto-Fix Applied |
|------|-----------------|
| Missing interface | Creates port, updates implementation |
| @Entity in domain | Moves to infrastructure JPA entity |
| Business logic in controller | Creates use case |
| Mutable value object | Removes setters, adds final |
| Wrong dependency direction | Inverts to use interfaces |

### 8. Emergency Commands

If something goes wrong:

```bash
# Check validation logs
cat /tmp/architecture-validation-*.log

# Reset learning data
rm -rf /home/kishen90/java/springboot-cli/data/learning/*

# Manual validation without fixes
/home/kishen90/java/springboot-cli/bin/commands/validate-architecture.sh
```

### 9. Best Practices for Claude Agents

1. **Always validate after generating code**
   - Even if you think it's correct
   - Auto-fixes ensure compliance

2. **Use continuous monitoring for long tasks**
   - Start at beginning of feature
   - Stop when complete

3. **Review learning feedback**
   - Helps you improve patterns
   - Reduces future violations

4. **Commit after validation**
   - Only commit validated code
   - Include validation results in commit message

### 10. Example Full Session

```bash
# 1. Start feature
echo "Starting payment integration feature..."

# 2. Enable monitoring
orchestrator.sh continuous . &

# 3. Create components
cat > PaymentClient.java << 'EOF'
@Component
public class PaymentClient {
    public PaymentResponse process(PaymentRequest req) {
        // Call external API
    }
}
EOF

# 4. Auto-fix triggers
echo "Violation detected and fixed: PaymentClient missing interface"

# 5. Validate final state
orchestrator.sh validate

# 6. Review learning
orchestrator.sh report

# 7. Commit
git add .
git commit -m "feat: payment integration with clean architecture

- PaymentClient implements PaymentPort
- Architecture validation passed
- No violations remaining"
```

## 🎯 Remember

**The orchestrator is your safety net!** Write code naturally, and let it fix violations automatically. This ensures:
- ✅ Clean Architecture compliance
- ✅ Consistent patterns
- ✅ Learning from mistakes
- ✅ High-quality code

Start using `/validate-arch` in your responses now!