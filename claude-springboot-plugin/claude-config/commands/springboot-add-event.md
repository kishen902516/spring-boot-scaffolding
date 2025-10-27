# Add Domain Event

Add a domain event for event-driven architecture and event sourcing patterns.

## Usage
```
/springboot-add-event --name <event-name> --attributes <attribute-list> [--aggregate <aggregate-name>]
```

## Parameters
- `name`: Event name (PascalCase, e.g., OrderCreated)
- `attributes`: Event attributes (name:type format)
- `aggregate`: Related aggregate (optional)

## Example
```
/springboot-add-event --name OrderCreated \
  --attributes "orderId:UUID,customerId:UUID,totalAmount:BigDecimal,createdAt:Instant" \
  --aggregate Order
```

## Execution

```bash
cd ${PROJECT_ROOT}
springboot-cli add event \
  --name ${name} \
  --package ${package}.domain.event \
  --attributes "${attributes}"
```

Generated components:
- Domain event as Java record
- Event metadata (timestamp, aggregate ID, version)
- Event publisher port interface
- Event handler interface
- Event store integration (if event sourcing enabled)
- Kafka/RabbitMQ adapter (if messaging enabled)