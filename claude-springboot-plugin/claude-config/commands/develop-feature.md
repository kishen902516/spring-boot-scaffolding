# Develop Feature with Orchestrated Architecture Validation

Start feature development with automatic architecture compliance monitoring and correction.

## What this command does

1. **Starts** orchestrated feature development
2. **Monitors** code changes in real-time
3. **Validates** architecture compliance continuously
4. **Auto-fixes** violations as you code
5. **Provides** learning feedback

## Get feature details from user

First, ask the user for feature details:
- Feature name (e.g., "user-authentication")
- Feature description (e.g., "Add JWT-based authentication")

## Start orchestrated development

```bash
# Get feature details
echo "🚀 Starting Orchestrated Feature Development"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Set agent context
export AGENT_NAME="feature-developer"

# Ask for feature details if not provided
read -p "Enter feature name (kebab-case): " FEATURE_NAME
read -p "Enter feature description: " FEATURE_DESC

# Start orchestrated development
echo ""
echo "📋 Feature: $FEATURE_NAME"
echo "📝 Description: $FEATURE_DESC"
echo ""

# Initial validation
echo "🔍 Running initial architecture check..."
orchestrator.sh validate

# Start continuous monitoring in background
echo ""
echo "👁️ Starting continuous architecture monitoring..."
orchestrator.sh continuous . &
MONITOR_PID=$!

echo "✅ Monitoring started (PID: $MONITOR_PID)"
echo ""
echo "📝 Development Guidelines:"
echo "  1. Write tests first (TDD)"
echo "  2. Implement features incrementally"
echo "  3. Architecture violations will be auto-fixed"
echo "  4. Review learning feedback after each fix"
echo ""
echo "🛠️ Available commands during development:"
echo "  - validate-arch: Run validation manually"
echo "  - kill $MONITOR_PID: Stop monitoring"
echo ""

# Store monitor PID for later
echo $MONITOR_PID > /tmp/orchestrator-monitor.pid

echo "Ready to start coding! The orchestrator is watching for violations."
```

## Development workflow

1. **Write test first** (TDD)
2. **Implement code** - orchestrator monitors
3. **Auto-fix applied** when violations detected
4. **Review changes** with `git diff`
5. **Continue development** with learned patterns

## Stop monitoring

```bash
# Read the stored PID
if [ -f /tmp/orchestrator-monitor.pid ]; then
    MONITOR_PID=$(cat /tmp/orchestrator-monitor.pid)
    echo "🛑 Stopping orchestration monitor (PID: $MONITOR_PID)..."
    kill $MONITOR_PID 2>/dev/null
    rm /tmp/orchestrator-monitor.pid

    # Run final validation
    echo ""
    echo "🔍 Running final validation..."
    orchestrator.sh validate --fix

    # Show learning report
    echo ""
    echo "📊 Session Learning Report:"
    orchestrator.sh report
else
    echo "No orchestration monitor running"
fi
```

## Example session

```
🚀 Starting Orchestrated Feature Development
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Enter feature name: payment-integration
Enter feature description: Add Stripe payment processing

📋 Feature: payment-integration
📝 Description: Add Stripe payment processing

🔍 Running initial architecture check...
✅ No violations found

👁️ Starting continuous architecture monitoring...
✅ Monitoring started (PID: 12345)

Ready to start coding! The orchestrator is watching for violations.

[During development...]
⚠️ Violation detected: PaymentClient missing interface
🔧 Auto-fixing...
✅ Created PaymentPort interface
✅ Updated PaymentClient to implement PaymentPort

📚 Learning: Always implement port interfaces for infrastructure components
```

## Integration with TDD workflow

1. **Write failing test**
   ```java
   @Test
   void should_process_payment() {
       // Test for payment processing
   }
   ```

2. **Generate implementation** (may violate initially)
   ```bash
   /springboot-add-client --name PaymentClient
   ```

3. **Orchestrator auto-fixes** violations
   - Creates missing interface
   - Updates implementation

4. **Test passes** with clean architecture

## Best practices

- Keep monitor running during entire feature
- Review auto-fixes to learn patterns
- Check learning report regularly
- Commit after each successful validation