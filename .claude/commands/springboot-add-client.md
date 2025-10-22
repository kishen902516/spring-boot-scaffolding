# Add External Client

Add an external REST client with resilience patterns (Circuit Breaker, Retry, Rate Limiter).

## Usage
```
/springboot-add-client --name <client-name> --base-url <url> --resilience <patterns> [--timeout <ms>]
```

## Parameters
- `name`: Client name (e.g., PaymentServiceClient)
- `base-url`: Base URL or property placeholder
- `resilience`: Comma-separated patterns (circuit-breaker,retry,rate-limiter,bulkhead)
- `timeout`: Timeout in milliseconds (default: 5000)

## Example
```
/springboot-add-client --name PaymentServiceClient \
  --base-url "${payment.service.url}" \
  --resilience "circuit-breaker,retry,rate-limiter" \
  --timeout 3000
```

## TDD Implementation
1. Write failing client test with WireMock
2. Execute:

```bash
cd ${PROJECT_ROOT}
${SPRINGBOOT_CLI_PATH}/bin/springboot-cli.sh add client \
  --name ${name} \
  --package ${package}.infrastructure.client \
  --base-url "${base_url}" \
  --resilience "${resilience}" \
  --timeout ${timeout}
```

Generated components:
- Port interface in domain/application layer
- WebClient/RestClient implementation
- Resilience4j configuration
- Fallback methods
- WireMock test setup
- Virtual thread support for async calls