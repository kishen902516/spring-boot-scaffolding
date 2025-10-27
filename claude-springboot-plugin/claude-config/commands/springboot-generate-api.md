# Generate API from OpenAPI

Generate REST controllers and DTOs from OpenAPI specification following API-first development.

## Usage
```
/springboot-generate-api --spec <spec-file> [--controllers <controller-names>]
```

## Parameters
- `spec`: Path to OpenAPI specification file
- `controllers`: Specific controllers to generate (optional, comma-separated)

## Example
```
/springboot-generate-api --spec src/main/resources/openapi.yaml --controllers ProductController,OrderController
```

## Process
1. Define OpenAPI spec with endpoints, schemas, and responses
2. Execute:

```bash
cd ${PROJECT_ROOT}
springboot-cli generate api \
  --spec ${spec} \
  --package ${package}.api \
  --controllers "${controllers}"
```

Generated components:
- Controller interfaces from OpenAPI
- Request/Response DTOs as Java records
- Validation annotations
- Controller implementations
- API documentation
- Example requests/responses