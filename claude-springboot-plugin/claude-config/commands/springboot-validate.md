# Validate Architecture and Code Quality

Run comprehensive validation checks for architecture, coverage, and code style.

## Usage
```
/springboot-validate --aspect <architecture|coverage|style|all> [--rules <custom-rules>]
```

## Parameters
- `aspect`: Validation aspect to check
- `rules`: Custom validation rules (optional)

## Examples

### Architecture Validation
```
/springboot-validate --aspect architecture --rules "clean-architecture,cqrs-separation,no-domain-contamination"
```

### Coverage Validation
```
/springboot-validate --aspect coverage --minimum 80 --exclude "config,dto"
```

### Style Validation
```
/springboot-validate --aspect style --standard google-java-format
```

### Complete Validation
```
/springboot-validate --aspect all
```

## Execution

```bash
cd ${PROJECT_ROOT}
springboot-cli validate ${aspect}
```

Validation checks:
- **Architecture**: Layer dependencies, Clean Architecture rules, CQRS separation
- **Coverage**: Unit test coverage (min 80%), test pyramid distribution
- **Style**: Google Java Style, Checkstyle rules, SpotBugs analysis
- **All**: Runs all validation aspects sequentially

Reports generated in `target/validation-reports/`