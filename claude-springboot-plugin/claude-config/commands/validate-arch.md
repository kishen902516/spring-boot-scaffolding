# Validate and Auto-Fix Architecture Violations

Run the architecture orchestration system to detect and automatically fix Clean Architecture violations.

## What this command does

1. **Scans** all Java files for architecture violations
2. **Auto-fixes** common issues:
   - Missing port interface implementations
   - Spring/JPA annotations in domain layer
   - Business logic in wrong layers
   - Mutable value objects
3. **Provides** learning feedback about what was fixed
4. **Reports** remaining issues that need manual intervention

## Execute the validation

```bash
echo "🔍 Starting architecture validation and auto-fix..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Run orchestrator validation with auto-fix
/home/kishen90/java/springboot-cli/bin/orchestrator.sh validate --fix

# Check if auto-fixes were applied
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Architecture validation complete!"

    # Show what changed
    echo ""
    echo "📝 Changes made by auto-fix:"
    git diff --stat 2>/dev/null || echo "No git repository detected"

    # Check for remaining violations
    echo ""
    echo "🔍 Running final validation..."
    /validate-architecture.sh || {
        echo "⚠️  Some architecture rules still need attention"
    }
else
    echo "❌ Validation failed. Please check the errors above."
fi

# Generate learning report
echo ""
echo "📊 Learning Report:"
/home/kishen90/java/springboot-cli/bin/orchestrator.sh report
```

## Common fixes applied automatically

### 1. Missing Interface Implementation
- **Creates** port interface in `domain/port/outbound/`
- **Updates** infrastructure class to implement interface
- **Adds** @Override annotations

### 2. Spring Annotations in Domain
- **Removes** @Entity, @Table, @Component from domain
- **Creates** JPA entity in `infrastructure/adapter/persistence/entity/`
- **Generates** mapper for conversion

### 3. Business Logic in Wrong Layer
- **Creates** use case in `application/usecase/`
- **Moves** logic from controller/repository
- **Updates** references to use the use case

## What to do after validation

1. **Review changes**: Check the auto-fixes with `git diff`
2. **Test**: Run tests to ensure fixes didn't break functionality
3. **Commit**: If satisfied, commit the fixes
4. **Learn**: Review the learning report to avoid future violations

## Example output

```
🔍 Starting architecture validation and auto-fix...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Scanning project...
Found 3 violations:
  ❌ PaymentClient missing interface
  ❌ Order has JPA annotations in domain
  ❌ OrderController contains business logic

Applying auto-fixes...
  ✅ Created PaymentPort interface
  ✅ Updated PaymentClient to implement PaymentPort
  ✅ Moved Order JPA annotations to OrderJpaEntity
  ✅ Created OrderMapper
  ✅ Created CreateOrderUseCase for business logic

✅ All violations fixed successfully!

📝 Changes made:
  5 files changed, 127 insertions(+), 23 deletions(-)

📊 Learning Report:
  Total violations fixed: 3
  Most common: Missing interface (1)
  Improvement: 50% fewer violations than last session
```