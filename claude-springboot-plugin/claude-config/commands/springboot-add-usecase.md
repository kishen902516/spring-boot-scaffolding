# Add CQRS Use Case

Add a command or query handler following CQRS pattern with Clean Architecture.

## Usage
```
/springboot-add-usecase --type <command|query> --name <usecase-name> --entity <entity> --operation <operation-type>
```

## Parameters
- `type`: Use case type (command|query)
- `name`: Use case name (e.g., CreateOrderUseCase)
- `entity`: Related entity name
- `operation`: Operation type (create|update|delete|get|list|search)

## Examples

### Command (Write Side)
```
/springboot-add-usecase --type command --name CreateProduct --entity Product --operation create
```

### Query (Read Side)
```
/springboot-add-usecase --type query --name GetProductById --entity Product --operation get
```

## TDD Implementation
1. Write failing test for use case
2. Execute command generation:

```bash
cd ${PROJECT_ROOT}
springboot-cli add usecase \
  --type ${type} \
  --name ${name}UseCase \
  --package ${package}.application.usecase \
  --entity ${entity} \
  --operation ${operation}
```

Generated structure:
- Command/Query object (Java record)
- Handler with port dependencies
- Result object (Java record)
- Transaction management (for commands)
- Read model projection (for queries)