#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: ./springboot-cli.sh assess camel

Analyzes the codebase to determine if Apache Camel integration would be beneficial.

Assessment criteria:
  - Number of external integrations
  - File/FTP operations
  - Data transformations
  - Messaging patterns
  - Content-based routing

Output:
  - Assessment score (0-100)
  - Recommendation (strongly recommended, consider, not recommended)
  - Identified patterns
  - Suggested Camel routes

EOF
    exit 1
}

# Parse arguments
if [ "$1" == "--help" ]; then
    show_usage
fi

# Check if we're in a project directory
if [ ! -f "pom.xml" ]; then
    print_error "Not in a Spring Boot project directory (pom.xml not found)"
    exit 1
fi

if [ ! -d "src" ]; then
    print_error "Source directory not found"
    exit 1
fi

print_info "Analyzing codebase for Camel integration patterns..."
echo ""

# Initialize score and reasons
score=0
reasons=()
patterns=()
suggestions=()

# 1. Check for external service integrations
print_info "Checking external service integrations..."
integration_count=$(grep -r -E "@FeignClient|RestTemplate|WebClient|RestClient" src/main/java 2>/dev/null | wc -l || echo "0")

if [ "$integration_count" -ge 5 ]; then
    score=$((score + 30))
    reasons+=("Multiple external integrations detected: $integration_count")
    patterns+=("Multiple REST clients")
    suggestions+=("Use Camel HTTP component for unified integration")
elif [ "$integration_count" -ge 3 ]; then
    score=$((score + 20))
    reasons+=("External integrations detected: $integration_count")
fi

# 2. Check for file operations
print_info "Checking file/FTP operations..."
file_ops=0

if grep -r -q "java\.nio\.file\|java\.io\.File\|Files\." src/main/java 2>/dev/null; then
    file_ops=$((file_ops + 1))
    patterns+=("File operations")
fi

if grep -r -q "apache\.commons\.net\.ftp\|FTPClient" src/main/java 2>/dev/null; then
    file_ops=$((file_ops + 1))
    patterns+=("FTP operations")
fi

if [ "$file_ops" -gt 0 ]; then
    score=$((score + 25))
    reasons+=("File/FTP operations detected")
    suggestions+=("Use Camel File/FTP components for file processing")
fi

# 3. Check for data transformations
print_info "Checking data transformations..."
transform_count=$(grep -r -E "ObjectMapper|XmlMapper|Jackson|Gson|@JsonProperty" src/main/java 2>/dev/null | wc -l || echo "0")

if [ "$transform_count" -ge 10 ]; then
    score=$((score + 20))
    reasons+=("Heavy data transformations: $transform_count occurrences")
    patterns+=("Data transformation")
    suggestions+=("Use Camel Jackson/JAXB components for transformations")
elif [ "$transform_count" -ge 5 ]; then
    score=$((score + 10))
    reasons+=("Data transformations detected: $transform_count occurrences")
fi

# 4. Check for messaging infrastructure
print_info "Checking messaging patterns..."
messaging=0

if grep -r -q "KafkaTemplate\|@KafkaListener\|spring-kafka" pom.xml src/ 2>/dev/null; then
    messaging=$((messaging + 1))
    patterns+=("Kafka messaging")
fi

if grep -r -q "RabbitTemplate\|@RabbitListener\|spring-rabbit" pom.xml src/ 2>/dev/null; then
    messaging=$((messaging + 1))
    patterns+=("RabbitMQ messaging")
fi

if grep -r -q "JmsTemplate\|@JmsListener\|spring-jms" pom.xml src/ 2>/dev/null; then
    messaging=$((messaging + 1))
    patterns+=("JMS messaging")
fi

if [ "$messaging" -gt 0 ]; then
    score=$((score + 15))
    reasons+=("Messaging infrastructure detected: $messaging types")
    suggestions+=("Use Camel messaging components for unified messaging")
fi

# 5. Check for routing/transformation logic
print_info "Checking routing and transformation logic..."
routing_count=$(grep -r -E "if.*contains|switch.*case|route.*to" src/main/java 2>/dev/null | wc -l || echo "0")

if [ "$routing_count" -ge 10 ]; then
    score=$((score + 10))
    reasons+=("Content-based routing patterns detected")
    patterns+=("Content-based routing")
    suggestions+=("Use Camel Content-Based Router EIP")
fi

# 6. Check for scheduled tasks
print_info "Checking scheduled tasks..."
if grep -r -q "@Scheduled\|@EnableScheduling" src/main/java 2>/dev/null; then
    score=$((score + 5))
    patterns+=("Scheduled tasks")
    suggestions+=("Use Camel Timer/Quartz components for scheduling")
fi

# 7. Check for batch processing
print_info "Checking batch processing..."
if grep -r -q "batch\|@EnableBatchProcessing\|spring-batch" pom.xml src/ 2>/dev/null; then
    score=$((score + 10))
    patterns+=("Batch processing")
    suggestions+=("Use Camel Batch component for batch processing")
fi

# Print results
echo ""
echo "═══════════════════════════════════════════════════"
echo "            Camel Assessment Results"
echo "═══════════════════════════════════════════════════"
echo ""

# Score
echo -e "${BLUE}Assessment Score: ${GREEN}${score}/100${NC}"
echo ""

# Recommendation
if [ "$score" -ge 60 ]; then
    print_success "STRONGLY RECOMMENDED"
    echo ""
    echo "Your application shows strong indicators for Apache Camel integration."
    echo "Camel will help you:"
    echo "  - Simplify integration code"
    echo "  - Use proven Enterprise Integration Patterns"
    echo "  - Reduce boilerplate code"
    echo "  - Improve maintainability"
elif [ "$score" -ge 30 ]; then
    print_warning "CONSIDER"
    echo ""
    echo "Your application has some integration patterns that could benefit from Camel."
    echo "Evaluate if Camel would simplify your specific use cases."
else
    print_info "NOT RECOMMENDED"
    echo ""
    echo "Your current stack is sufficient for your integration needs."
    echo "Adding Camel might introduce unnecessary complexity."
fi

echo ""

# Patterns detected
if [ ${#patterns[@]} -gt 0 ]; then
    echo "Detected Patterns:"
    for pattern in "${patterns[@]}"; do
        echo "  • $pattern"
    done
    echo ""
fi

# Reasons
if [ ${#reasons[@]} -gt 0 ]; then
    echo "Analysis Details:"
    for reason in "${reasons[@]}"; do
        echo "  • $reason"
    done
    echo ""
fi

# Suggestions
if [ ${#suggestions[@]} -gt 0 ] && [ "$score" -ge 30 ]; then
    echo "Suggested Camel Components:"
    for suggestion in "${suggestions[@]}"; do
        echo "  • $suggestion"
    done
    echo ""
fi

# Next steps
if [ "$score" -ge 60 ]; then
    echo "Next Steps:"
    echo "  1. Review Camel documentation: https://camel.apache.org/"
    echo "  2. Add Camel route with: ./springboot-cli.sh add camel-route"
    echo "  3. Start with simple routes and expand gradually"
elif [ "$score" -ge 30 ]; then
    echo "Next Steps:"
    echo "  1. Review specific use cases for Camel"
    echo "  2. Consider prototyping a simple Camel route"
    echo "  3. Compare with existing implementation"
fi

echo ""
echo "═══════════════════════════════════════════════════"

exit 0
