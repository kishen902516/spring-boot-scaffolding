#!/bin/bash

# Agent Learning System
# Tracks violations, learns patterns, and updates agent behavior

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLI_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$CLI_DIR/data/learning"
VIOLATIONS_DB="$DATA_DIR/violations.sqlite"
PATTERNS_FILE="$DATA_DIR/patterns.json"
FEEDBACK_DIR="$DATA_DIR/feedback"
AGENT_PROMPTS_DIR="$CLI_DIR/../claude-springboot-plugin/claude-config/agents"

# Create directories
mkdir -p "$DATA_DIR" "$FEEDBACK_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Initialize SQLite database if not exists
init_database() {
    if [[ ! -f "$VIOLATIONS_DB" ]]; then
        sqlite3 "$VIOLATIONS_DB" << EOF
CREATE TABLE violations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    agent_name TEXT NOT NULL,
    session_id TEXT,
    violation_type TEXT NOT NULL,
    file_path TEXT,
    line_number INTEGER,
    severity TEXT,
    auto_fixed BOOLEAN,
    fix_applied TEXT,
    learning_applied BOOLEAN DEFAULT 0
);

CREATE TABLE patterns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pattern_type TEXT UNIQUE NOT NULL,
    first_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    occurrence_count INTEGER DEFAULT 1,
    auto_fix_success_rate REAL,
    recommended_action TEXT
);

CREATE TABLE agent_performance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_name TEXT NOT NULL,
    date DATE NOT NULL,
    violations_count INTEGER,
    auto_fixed_count INTEGER,
    learning_score REAL,
    UNIQUE(agent_name, date)
);

CREATE TABLE learning_feedback (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    agent_name TEXT NOT NULL,
    feedback_type TEXT,
    title TEXT,
    description TEXT,
    correct_pattern TEXT,
    incorrect_pattern TEXT,
    applied BOOLEAN DEFAULT 0
);
EOF
        echo -e "${GREEN}✓${NC} Database initialized"
    fi
}

# Record a violation
record_violation() {
    local agent_name="$1"
    local violation_type="$2"
    local file_path="$3"
    local severity="$4"
    local auto_fixed="$5"
    local session_id="${SESSION_ID:-$(date +%s)}"

    sqlite3 "$VIOLATIONS_DB" << EOF
INSERT INTO violations (agent_name, session_id, violation_type, file_path, severity, auto_fixed)
VALUES ('$agent_name', '$session_id', '$violation_type', '$file_path', '$severity', $auto_fixed);
EOF

    # Update pattern tracking
    update_pattern "$violation_type"
}

# Update pattern tracking
update_pattern() {
    local pattern_type="$1"

    sqlite3 "$VIOLATIONS_DB" << EOF
INSERT INTO patterns (pattern_type, occurrence_count)
VALUES ('$pattern_type', 1)
ON CONFLICT(pattern_type) DO UPDATE SET
    last_seen = CURRENT_TIMESTAMP,
    occurrence_count = occurrence_count + 1;
EOF
}

# Analyze patterns for an agent
analyze_agent_patterns() {
    local agent_name="${1:-all}"

    echo -e "${BLUE}═══ Pattern Analysis for Agent: $agent_name ═══${NC}"

    # Get most common violations
    local query="SELECT violation_type, COUNT(*) as count,
                        ROUND(AVG(auto_fixed) * 100, 2) as fix_rate
                 FROM violations"

    if [[ "$agent_name" != "all" ]]; then
        query="$query WHERE agent_name = '$agent_name'"
    fi

    query="$query GROUP BY violation_type ORDER BY count DESC LIMIT 10"

    echo -e "\n${CYAN}Most Common Violations:${NC}"
    sqlite3 -column -header "$VIOLATIONS_DB" "$query"

    # Get trend over time
    echo -e "\n${CYAN}Violation Trend (Last 7 Days):${NC}"
    sqlite3 -column -header "$VIOLATIONS_DB" << EOF
SELECT DATE(timestamp) as date,
       COUNT(*) as violations,
       SUM(auto_fixed) as auto_fixed
FROM violations
WHERE timestamp > datetime('now', '-7 days')
${agent_name != "all" ? "AND agent_name = '$agent_name'" : ""}
GROUP BY DATE(timestamp)
ORDER BY date;
EOF

    # Calculate learning score
    calculate_learning_score "$agent_name"
}

# Calculate learning score for agent
calculate_learning_score() {
    local agent_name="$1"

    # Get violations from last week vs this week
    local last_week=$(sqlite3 "$VIOLATIONS_DB" << EOF
SELECT COUNT(*) FROM violations
WHERE agent_name = '$agent_name'
AND timestamp BETWEEN datetime('now', '-14 days') AND datetime('now', '-7 days');
EOF
)

    local this_week=$(sqlite3 "$VIOLATIONS_DB" << EOF
SELECT COUNT(*) FROM violations
WHERE agent_name = '$agent_name'
AND timestamp > datetime('now', '-7 days');
EOF
)

    if [[ $last_week -gt 0 ]]; then
        local improvement=$(( (last_week - this_week) * 100 / last_week ))
        local learning_score=$((50 + improvement / 2))

        # Ensure score is between 0 and 100
        if [[ $learning_score -lt 0 ]]; then learning_score=0; fi
        if [[ $learning_score -gt 100 ]]; then learning_score=100; fi

        echo -e "\n${CYAN}Learning Score: ${NC}$learning_score/100"

        if [[ $improvement -gt 0 ]]; then
            echo -e "${GREEN}↑ ${improvement}% improvement from last week${NC}"
        else
            echo -e "${YELLOW}↓ ${improvement#-}% more violations than last week${NC}"
        fi

        # Store in database
        sqlite3 "$VIOLATIONS_DB" << EOF
INSERT OR REPLACE INTO agent_performance (agent_name, date, violations_count, learning_score)
VALUES ('$agent_name', DATE('now'), $this_week, $learning_score);
EOF
    else
        echo -e "\n${CYAN}Learning Score: ${NC}Insufficient data"
    fi
}

# Generate learning feedback
generate_learning_feedback() {
    local agent_name="$1"
    local output_file="$FEEDBACK_DIR/${agent_name}-feedback-$(date +%Y%m%d).md"

    echo -e "${BLUE}Generating learning feedback for $agent_name...${NC}"

    # Get top violations for feedback
    local violations=$(sqlite3 -list "$VIOLATIONS_DB" << EOF
SELECT violation_type, COUNT(*) as count
FROM violations
WHERE agent_name = '$agent_name'
AND learning_applied = 0
GROUP BY violation_type
ORDER BY count DESC
LIMIT 5;
EOF
)

    # Create feedback document
    cat > "$output_file" << EOF
# Learning Feedback for $agent_name
Generated: $(date -Iseconds)

## Summary
Agent: $agent_name
Analysis Period: Last 7 days

## Top Patterns to Address

EOF

    # Process each violation type
    IFS=$'\n'
    for violation in $violations; do
        local type=$(echo "$violation" | cut -d'|' -f1)
        local count=$(echo "$violation" | cut -d'|' -f2)

        generate_specific_feedback "$type" "$count" >> "$output_file"

        # Mark as learning applied
        sqlite3 "$VIOLATIONS_DB" << EOF
UPDATE violations
SET learning_applied = 1
WHERE agent_name = '$agent_name'
AND violation_type = '$type';
EOF
    done

    # Add recommendations
    cat >> "$output_file" << EOF

## Recommended Agent Prompt Updates

Based on the patterns observed, consider adding these rules to the agent prompt:

EOF

    generate_prompt_recommendations "$agent_name" >> "$output_file"

    echo -e "${GREEN}✓${NC} Feedback generated: $output_file"

    # Return the feedback file path
    echo "$output_file"
}

# Generate specific feedback for a violation type
generate_specific_feedback() {
    local violation_type="$1"
    local count="$2"

    cat << EOF

### $violation_type (Occurred $count times)

**What went wrong:**
EOF

    case "$violation_type" in
        "MISSING_INTERFACE")
            cat << EOF
Infrastructure components were created without implementing domain port interfaces.

**Why it matters:**
- Violates Dependency Inversion Principle
- Creates tight coupling between layers
- Makes testing difficult
- Breaks Clean Architecture

**Correct pattern:**
\`\`\`java
// 1. Create port in domain
public interface PaymentPort {
    Result process(Request req);
}

// 2. Implement in infrastructure
@Component
public class PaymentClient implements PaymentPort {
    @Override
    public Result process(Request req) { }
}
\`\`\`

**Prevention tip:**
Always create the port interface BEFORE implementing the infrastructure component.
EOF
            ;;

        "DOMAIN_ANNOTATION")
            cat << EOF
Spring/JPA annotations were found in domain entities.

**Why it matters:**
- Domain layer must be framework-agnostic
- Violates hexagonal architecture
- Couples business logic to infrastructure

**Correct pattern:**
\`\`\`java
// Domain: Pure Java
public class Order {
    private final UUID id;
    // No annotations!
}

// Infrastructure: JPA entity
@Entity
@Table(name = "orders")
public class OrderJpaEntity {
    @Id
    private UUID id;
}
\`\`\`

**Prevention tip:**
Domain entities should NEVER import Spring or JPA packages.
EOF
            ;;

        "BUSINESS_LOGIC_IN_WRONG_LAYER")
            cat << EOF
Business logic was found in controllers or repositories.

**Why it matters:**
- Violates Single Responsibility Principle
- Makes logic hard to test
- Couples business rules to infrastructure

**Correct pattern:**
\`\`\`java
// Use Case (correct location)
@Service
public class CreateOrderUseCase {
    public Order execute(Command cmd) {
        Order order = new Order(cmd);
        order.applyBusinessRules(); // Logic in domain
        return repository.save(order);
    }
}
\`\`\`

**Prevention tip:**
Controllers handle HTTP, repositories handle persistence. Business logic goes in use cases or domain.
EOF
            ;;

        *)
            echo "Pattern detected: $violation_type"
            echo "Frequency: $count occurrences"
            echo "Action: Review and update coding patterns"
            ;;
    esac
}

# Generate prompt recommendations
generate_prompt_recommendations() {
    local agent_name="$1"

    # Get most common violations
    local top_violations=$(sqlite3 -list "$VIOLATIONS_DB" << EOF
SELECT violation_type FROM violations
WHERE agent_name = '$agent_name'
GROUP BY violation_type
ORDER BY COUNT(*) DESC
LIMIT 3;
EOF
)

    local prompt_updates=""

    IFS=$'\n'
    for violation in $top_violations; do
        case "$violation" in
            "MISSING_INTERFACE")
                prompt_updates="${prompt_updates}
1. **MANDATORY**: Every infrastructure component MUST implement a domain port interface
   - Create interface in domain/port/outbound/ FIRST
   - Then implement in infrastructure/adapter/"
                ;;
            "DOMAIN_ANNOTATION")
                prompt_updates="${prompt_updates}
2. **FORBIDDEN**: NEVER use @Entity, @Table, @Component in domain layer
   - Domain entities must be pure Java objects
   - Create separate JPA entities in infrastructure/adapter/persistence/entity/"
                ;;
            "BUSINESS_LOGIC_IN_WRONG_LAYER")
                prompt_updates="${prompt_updates}
3. **RULE**: Business logic ONLY in domain entities and use cases
   - Controllers: HTTP handling only
   - Repositories: Persistence only
   - Use Cases: Orchestration and business rules"
                ;;
        esac
    done

    echo "$prompt_updates"

    # Also suggest updating the agent configuration
    echo "

## Suggested Configuration Update

Add to: $AGENT_PROMPTS_DIR/${agent_name}.md

\`\`\`markdown
## Additional Rules Based on Learning

$prompt_updates
\`\`\`
"
}

# Update agent prompt automatically
update_agent_prompt() {
    local agent_name="$1"
    local prompt_file="$AGENT_PROMPTS_DIR/${agent_name}.md"

    if [[ ! -f "$prompt_file" ]]; then
        echo -e "${YELLOW}⚠${NC} Agent prompt file not found: $prompt_file"
        return 1
    fi

    echo -e "${BLUE}Updating agent prompt based on learning...${NC}"

    # Generate recommendations
    local recommendations=$(generate_prompt_recommendations "$agent_name")

    # Check if learning section exists
    if ! grep -q "## Learning-Based Rules" "$prompt_file"; then
        # Add learning section
        cat >> "$prompt_file" << EOF

## Learning-Based Rules
*Auto-generated based on violation patterns*

$recommendations

*Last updated: $(date -Iseconds)*
EOF
        echo -e "${GREEN}✓${NC} Added learning section to agent prompt"
    else
        echo -e "${YELLOW}⚠${NC} Learning section already exists. Manual update required."
    fi
}

# Show learning dashboard
show_dashboard() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              AGENT LEARNING SYSTEM DASHBOARD                  ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"

    # Overall statistics
    echo -e "\n${CYAN}═══ Overall Statistics ═══${NC}"
    sqlite3 -column -header "$VIOLATIONS_DB" << EOF
SELECT
    COUNT(*) as total_violations,
    SUM(auto_fixed) as auto_fixed,
    ROUND(AVG(auto_fixed) * 100, 2) as auto_fix_rate,
    COUNT(DISTINCT agent_name) as active_agents
FROM violations
WHERE timestamp > datetime('now', '-30 days');
EOF

    # Per-agent performance
    echo -e "\n${CYAN}═══ Agent Performance (Last 7 Days) ═══${NC}"
    sqlite3 -column -header "$VIOLATIONS_DB" << EOF
SELECT
    agent_name,
    COUNT(*) as violations,
    SUM(auto_fixed) as fixed,
    ROUND(AVG(auto_fixed) * 100, 2) as fix_rate
FROM violations
WHERE timestamp > datetime('now', '-7 days')
GROUP BY agent_name
ORDER BY violations DESC;
EOF

    # Top violation patterns
    echo -e "\n${CYAN}═══ Top Violation Patterns ═══${NC}"
    sqlite3 -column -header "$VIOLATIONS_DB" << EOF
SELECT
    violation_type,
    occurrence_count as total,
    DATE(last_seen) as last_seen,
    ROUND(auto_fix_success_rate, 2) as fix_rate
FROM patterns
ORDER BY occurrence_count DESC
LIMIT 10;
EOF

    # Learning trends
    echo -e "\n${CYAN}═══ Learning Trend (Daily) ═══${NC}"
    sqlite3 -column -header "$VIOLATIONS_DB" << EOF
SELECT
    DATE(timestamp) as date,
    COUNT(*) as violations,
    ROUND(AVG(auto_fixed) * 100, 2) as fix_rate
FROM violations
WHERE timestamp > datetime('now', '-7 days')
GROUP BY DATE(timestamp)
ORDER BY date DESC;
EOF
}

# Interactive menu
show_menu() {
    echo -e "\n${BLUE}Agent Learning System${NC}"
    echo "1. Show Dashboard"
    echo "2. Analyze Agent Patterns"
    echo "3. Generate Learning Feedback"
    echo "4. Update Agent Prompt"
    echo "5. Record Violation (Manual)"
    echo "6. Export Learning Data"
    echo "0. Exit"
    echo -n "Choose option: "
}

# Export learning data
export_data() {
    local export_file="$DATA_DIR/learning-export-$(date +%Y%m%d).json"

    echo -e "${BLUE}Exporting learning data...${NC}"

    # Create JSON export
    cat > "$export_file" << EOF
{
  "export_date": "$(date -Iseconds)",
  "violations": [
EOF

    # Export violations
    sqlite3 -list "$VIOLATIONS_DB" "
SELECT id, timestamp, agent_name, violation_type, file_path, severity, auto_fixed
FROM violations
ORDER BY timestamp DESC
LIMIT 1000;" | while IFS='|' read -r id timestamp agent type file severity fixed; do
        echo "    {\"id\": $id, \"timestamp\": \"$timestamp\", \"agent\": \"$agent\", \"type\": \"$type\", \"file\": \"$file\", \"severity\": \"$severity\", \"auto_fixed\": $fixed},"
    done >> "$export_file"

    # Close JSON
    echo "  ]," >> "$export_file"
    echo "  \"patterns\": [" >> "$export_file"

    # Export patterns
    sqlite3 -list "$VIOLATIONS_DB" "
SELECT pattern_type, occurrence_count, auto_fix_success_rate
FROM patterns
ORDER BY occurrence_count DESC;" | while IFS='|' read -r type count rate; do
        echo "    {\"type\": \"$type\", \"count\": $count, \"fix_rate\": $rate},"
    done >> "$export_file"

    echo "  ]" >> "$export_file"
    echo "}" >> "$export_file"

    echo -e "${GREEN}✓${NC} Data exported to: $export_file"
}

# Main function
main() {
    # Initialize database
    init_database

    case "${1:-menu}" in
        record)
            # Record a violation (called by orchestrator)
            record_violation "$2" "$3" "$4" "$5" "$6"
            ;;

        analyze)
            # Analyze patterns for agent
            analyze_agent_patterns "${2:-all}"
            ;;

        feedback)
            # Generate learning feedback
            generate_learning_feedback "${2:-feature-developer}"
            ;;

        update-prompt)
            # Update agent prompt
            update_agent_prompt "${2:-feature-developer}"
            ;;

        dashboard)
            # Show dashboard
            show_dashboard
            ;;

        export)
            # Export data
            export_data
            ;;

        menu)
            # Interactive menu
            while true; do
                show_menu
                read -r choice

                case $choice in
                    1) show_dashboard ;;
                    2)
                        echo -n "Enter agent name (or 'all'): "
                        read -r agent
                        analyze_agent_patterns "$agent"
                        ;;
                    3)
                        echo -n "Enter agent name: "
                        read -r agent
                        generate_learning_feedback "$agent"
                        ;;
                    4)
                        echo -n "Enter agent name: "
                        read -r agent
                        update_agent_prompt "$agent"
                        ;;
                    5)
                        echo -n "Agent name: "
                        read -r agent
                        echo -n "Violation type: "
                        read -r vtype
                        echo -n "File path: "
                        read -r file
                        echo -n "Severity (CRITICAL/HIGH/MEDIUM/LOW): "
                        read -r severity
                        echo -n "Auto-fixed? (1/0): "
                        read -r fixed
                        record_violation "$agent" "$vtype" "$file" "$severity" "$fixed"
                        echo -e "${GREEN}✓${NC} Violation recorded"
                        ;;
                    6) export_data ;;
                    0) exit 0 ;;
                    *) echo -e "${RED}Invalid option${NC}" ;;
                esac

                echo -e "\nPress Enter to continue..."
                read -r
            done
            ;;

        help|--help)
            echo "Usage: $0 [command] [options]"
            echo ""
            echo "Commands:"
            echo "  record <agent> <type> <file> <severity> <fixed>  - Record violation"
            echo "  analyze [agent]                                   - Analyze patterns"
            echo "  feedback [agent]                                  - Generate feedback"
            echo "  update-prompt [agent]                             - Update agent prompt"
            echo "  dashboard                                         - Show dashboard"
            echo "  export                                            - Export data"
            echo "  menu                                              - Interactive menu"
            ;;

        *)
            echo -e "${RED}Unknown command: $1${NC}"
            echo "Use '$0 help' for usage"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"