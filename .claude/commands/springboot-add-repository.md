# Add Repository

Add a repository implementation following the port/adapter pattern with Spring Data.

## Usage
```
/springboot-add-repository --name <repository-name> --entity <entity> --database <db-type> [--custom-methods <methods>]
```

## Parameters
- `name`: Repository name (e.g., ProductRepository)
- `entity`: Domain entity name
- `database`: Database type (mssql|mongodb)
- `custom-methods`: Custom query methods (optional, format: methodName:returnType)

## Example
```
/springboot-add-repository --name ProductRepository --entity Product --database mongodb \
  --custom-methods "findByName:Optional<Product>,existsBySku:boolean,findByPriceRange:List<Product>"
```

## TDD Implementation
1. Write failing repository test with Testcontainers
2. Execute:

```bash
cd ${PROJECT_ROOT}
${SPRINGBOOT_CLI_PATH}/bin/springboot-cli.sh add repository \
  --name ${name} \
  --package ${package}.infrastructure.persistence \
  --entity ${entity} \
  --database ${database} \
  --custom-methods "${custom_methods}"
```

Generated components:
- Port interface in domain layer
- Adapter implementation in infrastructure
- Spring Data repository
- Entity mapper (domain ↔ persistence)
- Custom query implementations
- Testcontainers test setup