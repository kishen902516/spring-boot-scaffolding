## Summary

<!-- Provide a brief summary of the changes in this PR -->

Implements: #{issue-number}

## Changes

<!-- Describe the changes made in this PR -->

### Domain Layer
-

### Application Layer
-

### Infrastructure Layer
-

### API Layer
-

## Type of Change

- [ ] 🎯 Feature (new functionality)
- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] 🔧 Refactoring (code improvement without changing functionality)
- [ ] 📚 Documentation update
- [ ] ⚡ Performance improvement
- [ ] 🧪 Test improvement

## Testing

### Test Coverage

- **Overall Coverage**: __%
- **Unit Tests**: __ passed
- **Integration Tests**: __ passed
- **E2E Tests**: __ passed
- **Architecture Tests**: ✅ Passed

### Test Strategy

<!-- Describe how the changes were tested -->

#### Unit Tests
```
Test files:
-
-
```

#### Integration Tests
```
Test files:
-
-
```

#### Manual Testing
<!-- If applicable, describe manual testing performed -->

- [ ] Tested locally
- [ ] Tested with Postman/curl
- [ ] Tested edge cases
- [ ] Tested error scenarios

## Architecture Validation

- [ ] ✅ Clean Architecture rules followed
- [ ] ✅ CQRS separation maintained
- [ ] ✅ Domain layer has no framework dependencies
- [ ] ✅ Dependencies point inward
- [ ] ✅ Port/Adapter pattern used correctly
- [ ] ✅ ArchUnit tests passing

```bash
# Validation command used
/springboot-validate --aspect all
```

## Code Quality

### Java 21 Features Used

- [ ] Records for DTOs/Commands/Queries
- [ ] Pattern matching
- [ ] Sealed classes for domain modeling
- [ ] Virtual threads for I/O operations
- [ ] Text blocks

### SOLID Principles

- [ ] Single Responsibility Principle
- [ ] Open/Closed Principle
- [ ] Liskov Substitution Principle
- [ ] Interface Segregation Principle
- [ ] Dependency Inversion Principle

### Code Style

- [ ] Google Java Style applied
- [ ] No checkstyle violations
- [ ] No SpotBugs warnings
- [ ] SonarLint clean

## TDD Compliance

- [ ] ✅ Tests written BEFORE implementation
- [ ] ✅ Followed Red-Green-Refactor cycle
- [ ] ✅ Test-first commit history visible

```
# Example commit order
1. Add failing test for User entity
2. Implement User entity to pass tests
3. Refactor User entity validation
4. Add failing test for CreateUserCommand
5. Implement CreateUserCommand handler
...
```

## Performance Impact

<!-- Describe any performance implications -->

- [ ] No performance impact
- [ ] Performance improved
- [ ] Performance tested with load tests
- [ ] Database query optimization performed

## Security Considerations

- [ ] No security implications
- [ ] Input validation added
- [ ] Output encoding applied
- [ ] No sensitive data exposed
- [ ] No hardcoded secrets
- [ ] OAuth2/JWT properly implemented

## Documentation

- [ ] Code comments added where necessary
- [ ] OpenAPI spec updated
- [ ] README updated (if needed)
- [ ] Architecture Decision Record (ADR) added (if applicable)
- [ ] Changelog updated

## Database Changes

- [ ] No database changes
- [ ] Migration scripts added
- [ ] Backwards compatible
- [ ] Rollback strategy documented

## Breaking Changes

- [ ] No breaking changes
- [ ] Breaking changes documented below

<!-- If breaking changes, describe them and migration path -->

## Deployment Notes

<!-- Any special deployment considerations -->

- [ ] No special deployment steps
- [ ] Environment variables needed: __
- [ ] Configuration changes required: __
- [ ] Database migration required: __

## Screenshots (if applicable)

<!-- Add screenshots for UI changes -->

## Checklist

### Code Implementation
- [ ] ✅ Tests written first (TDD)
- [ ] ✅ All tests passing
- [ ] ✅ Code coverage > 80%
- [ ] ✅ Architecture validation passed
- [ ] ✅ Clean Architecture maintained
- [ ] ✅ CQRS properly implemented
- [ ] ✅ Java 21 features used
- [ ] ✅ No framework dependencies in domain layer
- [ ] ✅ Code reviewed by self

### Quality Checks
- [ ] ✅ Compilation successful
- [ ] ✅ No linting errors
- [ ] ✅ No security vulnerabilities
- [ ] ✅ No code smells
- [ ] ✅ Documentation updated

### Git Hygiene
- [ ] ✅ Meaningful commit messages
- [ ] ✅ Conventional commits format used
- [ ] ✅ No merge conflicts
- [ ] ✅ Branch up to date with base

## Related Issues/PRs

Closes #{issue-number}

Related:
- #
- #

## Review Focus Areas

<!-- Highlight specific areas that need careful review -->

1.
2.
3.

## Reviewer Notes

<!-- Any additional context for reviewers -->

---

**Generated with Claude Code Spring Boot Plugin**

**Branch**: `feature/{issue-number}-{description}`
**Base**: `main`
**Assignee**: @{username}
**Labels**: feature, ready-for-review
