# Generate Test Suites

Generate comprehensive test suites following the test pyramid (75% unit, 20% integration, 5% E2E).

## Usage
```
/springboot-generate-tests --type <unit|integration|architecture|e2e|all> --scope <entity|usecase|api|all>
```

## Parameters
- `type`: Test type to generate
- `scope`: Scope of test generation

## Examples

### Unit Tests
```
/springboot-generate-tests --type unit --scope entity --coverage-target 90
```

### Integration Tests
```
/springboot-generate-tests --type integration --scope repository --use-testcontainers true
```

### Architecture Tests
```
/springboot-generate-tests --type architecture --rules "clean-architecture,dependency-direction"
```

### E2E Tests
```
/springboot-generate-tests --type e2e --feature "user-registration"
```

## TDD Note
⚠️ In TDD, tests are written FIRST. Use this command only for:
- Generating missing test coverage after refactoring
- Creating architecture validation tests
- Generating E2E tests after feature completion

## Execution

```bash
cd ${PROJECT_ROOT}
springboot-cli generate tests \
  --type ${type} \
  --scope ${scope} \
  --output src/test/java
```

Generated test types:
- **Unit**: Pure logic tests, no Spring context
- **Integration**: With Spring context, Testcontainers, WireMock
- **Architecture**: ArchUnit rules for Clean Architecture
- **E2E**: REST Assured, full application context