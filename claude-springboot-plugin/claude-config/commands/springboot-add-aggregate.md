# Add Aggregate Root

Add an aggregate root with business logic, invariants, and domain events.

## Usage
```
/springboot-add-aggregate --name <aggregate-name> --attributes <attributes> --events <event-list>
```

## Parameters
- `name`: Aggregate name (PascalCase)
- `attributes`: Aggregate attributes (name:type format)
- `events`: Domain events this aggregate can raise

## Example
```
/springboot-add-aggregate --name Order \
  --attributes "id:UUID,customerId:UUID,items:List<OrderItem>,status:OrderStatus,totalAmount:BigDecimal" \
  --events "OrderCreated,OrderItemAdded,OrderCompleted,OrderCancelled"
```

## TDD Implementation
1. Write failing test for aggregate behavior
2. Execute:

```bash
cd ${PROJECT_ROOT}
springboot-cli add aggregate \
  --name ${name} \
  --package ${package}.domain.model \
  --attributes "${attributes}" \
  --events "${events}"
```

Generated components:
- Aggregate root with identity
- Business methods with invariant checks
- Domain event raising
- State transitions
- Factory methods (static, no 'new')
- Private setters, public getters
- Builder pattern for complex construction