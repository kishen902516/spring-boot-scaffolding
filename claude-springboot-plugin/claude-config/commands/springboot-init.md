# Initialize Spring Boot Project

Initialize a new Spring Boot project with Clean Architecture, CQRS, and enterprise features.

## Usage
```
/springboot-init --name <service-name> --package <base-package> --database <db-type> --features <feature-list>
```

## Parameters
- `name`: Service name (e.g., order-service)
- `package`: Base Java package (e.g., com.company.service)
- `database`: Database type (mssql|mongodb)
- `features`: Comma-separated features (oauth2,eventsourcing,camel,resilience)

## Example
```
/springboot-init --name user-service --package com.example.users --database mongodb --features oauth2,resilience
```

Execute the Spring Boot CLI init command:
```bash
${SPRINGBOOT_CLI_PATH}/bin/springboot-cli.sh init \
  --name ${name} \
  --package ${package} \
  --database ${database} \
  --features ${features} \
  --java-version 21 \
  --spring-boot-version 3.3.0
```

After initialization:
1. Set up GitHub repository
2. Create initial project board
3. Configure Application Insights
4. Run architecture validation
5. Generate initial test suite