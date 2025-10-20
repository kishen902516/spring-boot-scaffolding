# NPM Installation Guide

This guide explains how to install, use, and publish the Spring Boot CLI as an npm package.

## Installation

### Using npx (Recommended for trying it out)

```bash
# Run without installing
npx @springboot-cli/generator init --name my-service --package com.example

# Run any command
npx @springboot-cli/generator add entity --name Product
```

### Global Installation

```bash
# Install globally
npm install -g @springboot-cli/generator

# Now use directly
springboot-cli init --name my-service --package com.example
springboot-cli add entity --name Product
```

### Local Installation

```bash
# Install in your project
npm install @springboot-cli/generator

# Use via npx
npx springboot-cli init --name my-service --package com.example

# Or add to package.json scripts
{
  "scripts": {
    "generate": "springboot-cli"
  }
}
```

## Usage Examples

### Initialize a new Spring Boot project

```bash
springboot-cli init \
  --name product-service \
  --package com.company.product \
  --database mongodb \
  --features oauth2,eventsourcing-lite
```

### Add components to your project

```bash
# Add an entity
springboot-cli add entity --name Product

# Add a repository
springboot-cli add repository --name ProductRepository

# Add a use case
springboot-cli add usecase --name CreateProduct

# Add external client
springboot-cli add client --name InventoryClient
```

### Generate code from OpenAPI

```bash
springboot-cli generate api --spec openapi.yaml
```

### Validate architecture

```bash
springboot-cli validate architecture
springboot-cli validate coverage
```

### Assess Camel integration need

```bash
springboot-cli assess camel
```

## System Requirements

- **Node.js**: 14.0.0 or higher
- **Bash**: Required (automatically checked)
- **Java**: 21 or higher (for generated projects)
- **Maven**: 3.9+ (for generated projects)
- **OS**: Linux or macOS (Windows via WSL)

## Local Development & Testing

### Test locally before publishing

```bash
# Navigate to the springboot-cli directory
cd /home/kishen90/java/springboot-cli

# Create a global symlink
npm link

# Now test the command
springboot-cli --help

# Test in a temp directory
cd /tmp
springboot-cli init --name test-service --package com.test

# Unlink when done testing
npm unlink -g @springboot-cli/generator
```

### Test the package without global install

```bash
# In the springboot-cli directory
node bin/cli.js --help
node bin/cli.js init --name test --package com.test
```

## Publishing to npm

### Prerequisites

1. Create an npm account at https://www.npmjs.com
2. Login to npm:
   ```bash
   npm login
   ```

### Before Publishing

1. **Update package.json metadata:**
   - Change `author` field
   - Update `repository` URL
   - Verify `version` number
   - Update package name if needed (must be unique on npm)

2. **Test the package:**
   ```bash
   npm link
   springboot-cli --help
   ```

3. **Check what will be published:**
   ```bash
   npm pack --dry-run
   ```

### Publishing Steps

```bash
# Navigate to springboot-cli directory
cd /home/kishen90/java/springboot-cli

# Ensure you're logged in
npm whoami

# Publish (first time - public)
npm publish --access public

# For scoped packages (@yourorg/package)
npm publish --access public

# For subsequent updates
# 1. Update version in package.json
npm version patch  # or minor, or major
npm publish
```

### Version Management

```bash
# Patch release (1.0.0 -> 1.0.1) - bug fixes
npm version patch

# Minor release (1.0.0 -> 1.1.0) - new features
npm version minor

# Major release (1.0.0 -> 2.0.0) - breaking changes
npm version major

# Then publish
npm publish
```

## Troubleshooting

### Permission Errors

If you get permission errors during installation:

```bash
# The postinstall script sets execute permissions automatically
# But if needed, you can manually fix:
chmod +x node_modules/@springboot-cli/generator/bin/*.sh
chmod +x node_modules/@springboot-cli/generator/bin/cli.js
```

### Bash Not Found

The CLI requires bash. On Windows, use WSL:

```bash
# Install WSL and run from within WSL
wsl
npm install -g @springboot-cli/generator
```

### Command Not Found After Global Install

```bash
# Check npm global bin path is in PATH
npm config get prefix

# Add to PATH if needed (Linux/Mac)
export PATH="$(npm config get prefix)/bin:$PATH"

# Add to ~/.bashrc or ~/.zshrc to make permanent
echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> ~/.bashrc
```

## Package Information

- **Package Name**: `@springboot-cli/generator`
- **Registry**: https://www.npmjs.com
- **Binary Command**: `springboot-cli`
- **Current Version**: See `package.json`

## Additional Resources

- [Main README](./README.md) - CLI usage and features
- [Implementation Summary](./IMPLEMENTATION_SUMMARY.md) - Development status
- [LLM Usage Guide](./docs/llm-usage.md) - Using with AI assistants
- [Application Insights Queries](./docs/app-insights-queries.md) - Observability queries

## Contributing

If you're contributing to this package:

1. Test locally with `npm link`
2. Update version in `package.json`
3. Update this documentation if needed
4. Test installation flow
5. Publish with `npm publish`

## License

MIT - See LICENSE file for details
