# Claude Agent Integration Guide for Orchestration Workflow

## Overview

This guide explains how Claude agents (AI assistants) integrate with the automated orchestration workflow to enforce Clean Architecture and DDD principles. The system ensures that code written by feature agents automatically passes through architecture validation and correction.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     CLAUDE INTERFACE                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                  ORCHESTRATION LAYER                         │
│  • Pre-commit hooks  • Validation scripts  • Auto-fix rules │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                    AGENT ECOSYSTEM                           │
│  • Feature Agent  • Architecture Agent  • Test Agent         │
└──────────────────────────────────────────────────────────────┘
```

## 1. Agent Configuration

### Feature Developer Agent Configuration

Create or update: `/home/kishen90/java/claude-springboot-plugin/claude-config/agents/feature-developer.md`

```markdown
# Feature Developer Agent

You are a Feature Developer Agent working within an orchestrated architecture validation system.

## CRITICAL RULES - MUST FOLLOW

1. **ALWAYS implement domain port interfaces** when creating infrastructure components:
   - Clients must implement corresponding Port interfaces
   - Repositories must implement Repository interfaces
   - Adapters must implement Port interfaces

2. **NEVER add Spring/JPA annotations to domain layer**:
   - Domain entities must be pure Java objects
   - Create separate JPA entities in infrastructure/adapter/persistence/entity
   - Use mappers to convert between domain and JPA entities

3. **NEVER put business logic in controllers or repositories**:
   - Controllers only handle HTTP concerns
   - Business logic goes in use cases (application layer)
   - Repositories only handle persistence

## BEFORE COMMITTING CODE

Always run architecture validation:
```bash
/home/kishen90/java/springboot-cli/bin/orchestrator.sh validate --fix
```

## WHEN CREATING NEW FEATURES

1. Write the feature code
2. Run validation: `orchestrator.sh validate`
3. Apply auto-fixes if suggested
4. Review and test the changes
5. Commit only after validation passes

## EXAMPLE PATTERNS TO FOLLOW

### Creating a Client (CORRECT WAY):

```java
// 1. First, create port interface in domain
package com.example.domain.port.outbound;

public interface PaymentPort {
    PaymentResult processPayment(PaymentRequest request);
}

// 2. Then, implement in infrastructure
package com.example.infrastructure.adapter.client;

@Component
public class PaymentClient implements PaymentPort {
    @Override
    public PaymentResult processPayment(PaymentRequest request) {
        // implementation
    }
}
```

### Creating an Entity (CORRECT WAY):

```java
// 1. Pure domain entity
package com.example.domain.model;

public class Order {
    private final UUID id;
    private final BigDecimal amount;

    // business methods, no annotations
}

// 2. JPA entity in infrastructure
package com.example.infrastructure.adapter.persistence.entity;

@Entity
@Table(name = "orders")
public class OrderJpaEntity {
    @Id
    private UUID id;
    private BigDecimal amount;
}

// 3. Mapper to convert
@Component
public class OrderMapper {
    public Order toDomain(OrderJpaEntity entity) { ... }
    public OrderJpaEntity toEntity(Order domain) { ... }
}
```
```
```

### System Prompt Integration

Add to Claude's system prompt or configuration:

```markdown
## Architecture Orchestration Integration

You have access to an automated architecture validation system. When writing code:

1. After creating or modifying Java files, run:
   ```bash
   /home/kishen90/java/springboot-cli/bin/orchestrator.sh validate --fix
   ```

2. The system will:
   - Detect architecture violations
   - Auto-fix common issues
   - Provide learning feedback

3. Review auto-fixes before proceeding

4. If manual fixes are needed, the system will guide you

## Available Orchestration Commands

- `orchestrator.sh validate` - Check architecture compliance
- `orchestrator.sh validate --fix` - Auto-fix violations
- `orchestrator.sh report` - View learning report
- `auto-fix-violations.sh` - Direct auto-fix tool

## Validation Triggers

The system automatically validates when:
- Pre-commit hooks run
- You explicitly call validation
- CI/CD pipeline executes
```

## 2. Slash Commands for Claude

### Create Architecture Validation Slash Command

Create: `/home/kishen90/java/claude-springboot-plugin/.claude/commands/validate-arch.md`

```markdown
# validate-arch

Run architecture validation and auto-fix violations.

## Execute validation

```bash
echo "🔍 Starting architecture validation..."
/home/kishen90/java/springboot-cli/bin/orchestrator.sh validate --fix

# Check if fixes were applied
if [ -f /tmp/architecture-validation-*.log ]; then
    echo "📊 Validation complete. Reviewing changes..."
    git diff --stat
fi
```

## Review what was fixed

After validation, explain to the user:
1. What violations were found
2. What was auto-fixed
3. What needs manual intervention

## Common fixes you'll see

- Missing interface implementations → Auto-created
- Spring annotations in domain → Moved to infrastructure
- Business logic in wrong layer → Use cases created
```

### Create Feature Development Slash Command

Create: `/home/kishen90/java/claude-springboot-plugin/.claude/commands/develop-feature.md`

```markdown
# develop-feature

Develop a feature with automatic architecture compliance.

## Development workflow

1. Understand the feature requirements
2. Write the implementation
3. Run architecture validation automatically
4. Apply fixes if needed
5. Test the implementation
6. Commit with confidence

## Trigger orchestrated development

```bash
# Set agent context
export AGENT_NAME="feature-developer"

# Start orchestrated feature development
/home/kishen90/java/springboot-cli/bin/orchestrator.sh orchestrate \
    "${FEATURE_NAME}" \
    "${FEATURE_DESCRIPTION}"
```

## Auto-validation steps

The orchestration will:
1. Let you develop the feature
2. Validate architecture compliance
3. Auto-fix violations
4. Generate tests
5. Provide final validation
```

## 3. Hook Configuration

### Pre-execution Hook

Create: `/home/kishen90/java/claude-springboot-plugin/claude-config/hooks/pre-code-execution.sh`

```bash
#!/bin/bash

# Pre-execution hook for architecture validation
# Runs before code is executed to ensure compliance

# Check if Java files were created/modified
if git diff --cached --name-only | grep -q "\.java$"; then
    echo "🔍 Java files detected. Running architecture pre-validation..."

    # Quick validation (non-blocking)
    timeout 5 /home/kishen90/java/springboot-cli/bin/orchestrator.sh validate || {
        echo "⚠️ Quick validation found potential issues. Will run full validation after."
    }
fi

# Continue with execution
exit 0
```

### Post-execution Hook

Create: `/home/kishen90/java/claude-springboot-plugin/claude-config/hooks/post-code-execution.sh`

```bash
#!/bin/bash

# Post-execution hook for architecture validation
# Runs after code changes to fix violations

# Check if Java files were created/modified
JAVA_FILES=$(find . -name "*.java" -newer /tmp/.last_validation 2>/dev/null | head -5)

if [ -n "$JAVA_FILES" ]; then
    echo "🔧 Running post-execution architecture validation..."

    # Run validation with auto-fix
    /home/kishen90/java/springboot-cli/bin/orchestrator.sh validate --fix

    # Update timestamp
    touch /tmp/.last_validation

    # Show summary
    echo "✅ Architecture validation complete"
fi

exit 0
```

## 4. Agent Communication Templates

### Feature Agent → Orchestrator

When the feature agent completes code:

```python
# Python example for agent integration
import subprocess
import json

def notify_orchestrator(feature_name, files_created):
    """Notify orchestrator about completed feature"""

    notification = {
        "agent": "feature-developer",
        "action": "code_complete",
        "feature": feature_name,
        "files": files_created,
        "ready_for_validation": True
    }

    # Write notification
    with open("/tmp/agent_notification.json", "w") as f:
        json.dump(notification, f)

    # Trigger validation
    result = subprocess.run([
        "/home/kishen90/java/springboot-cli/bin/orchestrator.sh",
        "validate",
        "--fix"
    ], capture_output=True, text=True)

    return result.returncode == 0
```

### Orchestrator → Feature Agent (Feedback)

The orchestrator provides feedback that agents should incorporate:

```python
def process_orchestrator_feedback():
    """Process learning feedback from orchestrator"""

    feedback_file = "/home/kishen90/java/springboot-cli/data/orchestrator/last_feedback.json"

    if os.path.exists(feedback_file):
        with open(feedback_file) as f:
            feedback = json.load(f)

        if feedback["violations_found"] > 0:
            print(f"📚 Learning from {feedback['violations_found']} violations:")

            for learning_point in feedback["learning_points"]:
                print(f"  • {learning_point}")

            # Update agent knowledge
            update_agent_knowledge(feedback["learning_points"])
```

## 5. Practical Usage Examples

### Example 1: Feature Agent Creating a New Service

```bash
# Claude agent receives request
User: "Create a payment processing service with Stripe integration"

# Agent response with orchestration
Claude: "I'll create a payment processing service with automatic architecture compliance checking."

# Step 1: Create the service
echo "Creating payment service structure..."

# Step 2: Write the code
cat > src/main/java/com/example/infrastructure/adapter/client/StripePaymentClient.java << 'EOF'
package com.example.infrastructure.adapter.client;

import org.springframework.stereotype.Component;

@Component
public class StripePaymentClient {
    // Initial implementation without interface (violation!)
    public PaymentResult processPayment(PaymentRequest request) {
        // Stripe API integration
    }
}
EOF

# Step 3: Run orchestration validation
echo "🔍 Validating architecture compliance..."
/home/kishen90/java/springboot-cli/bin/orchestrator.sh validate --fix

# Step 4: Review auto-fixes
echo "✅ Auto-fixes applied:"
echo "  - Created PaymentPort interface in domain/port/outbound/"
echo "  - Updated StripePaymentClient to implement PaymentPort"
echo "  - Added @Override annotations"

# Step 5: Show the corrected code
echo "The payment client now properly implements the port interface!"
```

### Example 2: Handling Validation Failures

```bash
# When validation fails
Claude: "I detected architecture violations. Let me fix them automatically..."

# Run auto-fix
/home/kishen90/java/springboot-cli/bin/commands/auto-fix-violations.sh .

# Check results
if [ $? -eq 0 ]; then
    echo "✅ All violations fixed automatically!"
else
    echo "⚠️ Some violations need manual intervention:"
    echo "  - Complex business logic needs to be moved to use case"
    echo "  - Circular dependency detected between modules"
    echo ""
    echo "Would you like me to help fix these manually?"
fi
```

### Example 3: Continuous Validation During Development

```bash
# Start continuous monitoring
Claude: "I'll enable continuous architecture monitoring while developing this feature."

# Launch monitoring in background
/home/kishen90/java/springboot-cli/bin/orchestrator.sh continuous . &
MONITOR_PID=$!

# Develop the feature
echo "Developing feature with real-time validation..."

# ... write code ...

# Stop monitoring
kill $MONITOR_PID

# Final validation
/home/kishen90/java/springboot-cli/bin/orchestrator.sh validate --fix
```

## 6. Learning Feedback Integration

### Automatic Learning from Violations

```bash
# Check learning report
/home/kishen90/java/springboot-cli/bin/orchestrator.sh report

# Example output processing
VIOLATIONS=$(grep -c "MISSING_INTERFACE" /home/kishen90/java/springboot-cli/data/orchestrator/learning.log)

if [ $VIOLATIONS -gt 5 ]; then
    echo "📚 Pattern detected: Frequently missing interface implementations"
    echo "🎯 Updating my approach to always create interfaces first"
fi
```

### Incorporating Feedback into Agent Behavior

```python
# Python script for agent learning
def update_agent_behavior():
    """Update agent behavior based on violation patterns"""

    violations = analyze_violation_patterns()

    if violations["missing_interface"] > threshold:
        # Update agent prompt
        agent_rules.append(
            "ALWAYS create port interface before implementing client"
        )

    if violations["domain_annotations"] > threshold:
        agent_rules.append(
            "NEVER use @Entity or @Component in domain layer"
        )

    save_updated_rules(agent_rules)
```

## 7. CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/architecture-validation.yml
name: Architecture Validation

on:
  pull_request:
    paths:
      - '**.java'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Set up orchestrator
        run: |
          chmod +x /home/kishen90/java/springboot-cli/bin/orchestrator.sh
          chmod +x /home/kishen90/java/springboot-cli/bin/commands/*.sh

      - name: Run architecture validation
        run: |
          export AGENT_NAME="ci-validator"
          /home/kishen90/java/springboot-cli/bin/orchestrator.sh validate --fix

      - name: Comment on PR
        if: failure()
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '❌ Architecture violations detected. Please run `orchestrator.sh validate --fix` locally.'
            })
```

## 8. Troubleshooting

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Validation fails silently | Check logs in `/tmp/architecture-validation-*.log` |
| Auto-fix doesn't work | Ensure write permissions on source files |
| Interface not created | Check if domain/port directory exists |
| Learning not working | Verify `learning.log` is being written |

### Debug Mode

```bash
# Enable debug mode for detailed output
export ORCHESTRATOR_DEBUG=true
/home/kishen90/java/springboot-cli/bin/orchestrator.sh validate --fix
```

## 9. Best Practices for Claude Agents

1. **Always validate before committing**
   ```bash
   orchestrator.sh validate --fix && git commit
   ```

2. **Review auto-fixes before accepting**
   ```bash
   git diff  # Review changes
   git add -p  # Selectively stage fixes
   ```

3. **Learn from patterns**
   ```bash
   orchestrator.sh report  # Check violation patterns
   ```

4. **Use continuous monitoring for long tasks**
   ```bash
   orchestrator.sh continuous . &
   ```

5. **Integrate with IDE**
   - Configure as external tool
   - Bind to keyboard shortcut
   - Run on save

## 10. Quick Reference Card

```bash
# Validate only
orchestrator.sh validate

# Validate and auto-fix
orchestrator.sh validate --fix

# Start orchestrated feature
orchestrator.sh orchestrate "feature-name" "description"

# Continuous monitoring
orchestrator.sh continuous .

# View learning report
orchestrator.sh report

# Direct auto-fix
auto-fix-violations.sh .

# Run specific validation
validate-architecture.sh
validate-coverage.sh
```

## Conclusion

By following this integration guide, Claude agents will:
- Automatically enforce Clean Architecture
- Learn from violations to improve over time
- Provide consistent, high-quality code
- Reduce manual architecture reviews
- Maintain architectural integrity throughout development

The orchestration system acts as a safety net, ensuring that even if agents make mistakes, the architecture remains clean and maintainable.