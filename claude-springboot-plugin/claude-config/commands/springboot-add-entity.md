# Add Domain Entity

Add a new domain entity following DDD principles with Java 21 records when appropriate.

## Usage
```
/springboot-add-entity --name <entity-name> --attributes <attribute-list> [--aggregate <aggregate-name>]
```

## Parameters
- `name`: Entity name (PascalCase)
- `attributes`: Comma-separated attributes (name:type format)
- `aggregate`: Parent aggregate (optional)

## Example
```
/springboot-add-entity --name Product --attributes "id:UUID,name:String,price:BigDecimal,quantity:Integer"
```

## TDD Process
1. First write failing test in `src/test/java/.../domain/model/${Entity}Test.java`
2. Then execute:

```bash
cd ${PROJECT_ROOT}
springboot-cli add entity \
  --name ${name} \
  --package ${package}.domain.model \
  --attributes "${attributes}"
```

The command will generate:
- Domain entity with invariants
- Builder pattern (composition over inheritance)
- Value objects as records
- Domain validation
- Equals/hashCode based on domain identity