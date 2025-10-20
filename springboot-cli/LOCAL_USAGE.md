# Using Spring Boot CLI Without NPM Publish

This guide shows how to use the CLI locally without publishing to the npm registry.

## Method 1: Direct Bash Script (Simplest)

Just use the bash script directly:

```bash
# From anywhere
/home/kishen90/java/springboot-cli/bin/springboot-cli.sh --help

# Initialize a project
cd /tmp
/home/kishen90/java/springboot-cli/bin/springboot-cli.sh init \
  --name my-service \
  --package com.example

# Add to PATH for convenience
echo 'export PATH="/home/kishen90/java/springboot-cli/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Now use directly
springboot-cli.sh --help
```

## Method 2: Install from Local Directory

Install the package directly from the local directory:

```bash
# Install globally from local directory (may need sudo)
npm install -g /home/kishen90/java/springboot-cli

# Or without sudo, use npm prefix
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

npm install -g /home/kishen90/java/springboot-cli

# Now use anywhere
springboot-cli --help
cd /tmp
springboot-cli init --name test-service --package com.test
```

## Method 3: Install from Tarball

Use the packed tarball:

```bash
# Create the tarball (from springboot-cli directory)
cd /home/kishen90/java/springboot-cli
npm pack

# This creates: springboot-cli-generator-1.0.0.tgz

# Install globally from tarball
npm install -g ./springboot-cli-generator-1.0.0.tgz

# Or install to user directory
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

npm install -g /home/kishen90/java/springboot-cli/springboot-cli-generator-1.0.0.tgz

# Now use anywhere
springboot-cli --help
```

## Method 4: Use npx with Local Directory

Use npx to run directly from the local directory:

```bash
# Run with npx (no installation needed)
npx /home/kishen90/java/springboot-cli --help

# Initialize a project
cd /tmp
npx /home/kishen90/java/springboot-cli init --name my-service --package com.example

# Add entity
cd my-service
npx /home/kishen90/java/springboot-cli add entity --name Product
```

## Method 5: Use npx with Tarball

```bash
# Create tarball first
cd /home/kishen90/java/springboot-cli
npm pack

# Use with npx from any directory
cd /tmp
npx /home/kishen90/java/springboot-cli/springboot-cli-generator-1.0.0.tgz init --name test --package com.test
```

## Method 6: Share Tarball with Team

Share the tarball file with your team without npm publish:

```bash
# Create tarball
cd /home/kishen90/java/springboot-cli
npm pack

# Share springboot-cli-generator-1.0.0.tgz via:
# - File share
# - Git repository
# - Internal artifact repository
# - USB drive, etc.

# Team members install from tarball:
npm install -g ./springboot-cli-generator-1.0.0.tgz
```

## Method 7: Create Bash Alias

Create a convenient alias:

```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'alias springboot-cli="/home/kishen90/java/springboot-cli/bin/springboot-cli.sh"' >> ~/.bashrc
source ~/.bashrc

# Now use anywhere
springboot-cli --help
cd /tmp
springboot-cli init --name my-service --package com.example
```

## Method 8: Install to Project (Local Development)

Install as a dev dependency in a specific project:

```bash
# In your project directory
cd /path/to/your/project

# Install from local directory
npm install --save-dev /home/kishen90/java/springboot-cli

# Or from tarball
npm install --save-dev /home/kishen90/java/springboot-cli/springboot-cli-generator-1.0.0.tgz

# Add to package.json scripts
{
  "scripts": {
    "scaffold": "springboot-cli init",
    "add:entity": "springboot-cli add entity",
    "add:usecase": "springboot-cli add usecase"
  }
}

# Use via npm scripts
npm run scaffold -- --name my-service --package com.example
npm run add:entity -- --name Product
```

## Recommended Approaches

### For Personal Use:
**Option 1** (Simplest): Add to PATH
```bash
export PATH="/home/kishen90/java/springboot-cli/bin:$PATH"
springboot-cli.sh --help
```

**Option 2** (Most npm-like): Install globally from directory
```bash
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH
npm install -g /home/kishen90/java/springboot-cli
springboot-cli --help
```

### For Team Use:
**Option 1**: Share tarball + install instructions
```bash
# You create and share
npm pack
# Share springboot-cli-generator-1.0.0.tgz

# Team installs
npm install -g ./springboot-cli-generator-1.0.0.tgz
```

**Option 2**: Commit to Git and install from Git
```bash
# Team members install directly from Git
npm install -g git+https://github.com/yourusername/springboot-cli.git

# Or from specific branch/tag
npm install -g git+https://github.com/yourusername/springboot-cli.git#main
```

### For CI/CD:
```bash
# In CI pipeline, install from repository
npm install -g /path/to/springboot-cli

# Or from tarball in artifacts
npm install -g ./artifacts/springboot-cli-generator-1.0.0.tgz

# Use in pipeline
springboot-cli init --name $SERVICE_NAME --package $PACKAGE_NAME
```

## Troubleshooting

### Permission Denied (EACCES)

If you get permission errors with global install:

```bash
# Option 1: Use user directory
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Now install without sudo
npm install -g /home/kishen90/java/springboot-cli

# Option 2: Use sudo (not recommended)
sudo npm install -g /home/kishen90/java/springboot-cli
```

### Bash Not Found

```bash
# Check bash is installed
which bash

# On Windows, use WSL
wsl --install
```

### Command Not Found After Install

```bash
# Check where npm installs global packages
npm config get prefix

# Add to PATH
export PATH="$(npm config get prefix)/bin:$PATH"

# Make permanent
echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Changes Not Reflected

If you modify the CLI and changes don't show:

```bash
# Reinstall from directory
npm install -g /home/kishen90/java/springboot-cli --force

# Or recreate tarball and reinstall
cd /home/kishen90/java/springboot-cli
npm pack
npm install -g ./springboot-cli-generator-1.0.0.tgz --force
```

## Quick Start Guide

**Fastest way to get started:**

```bash
# Add alias (one time setup)
echo 'alias springboot-cli="/home/kishen90/java/springboot-cli/bin/springboot-cli.sh"' >> ~/.bashrc
source ~/.bashrc

# Use immediately
cd /tmp
springboot-cli init --name demo-service --package com.demo --database mongodb

cd demo-service
springboot-cli add entity --name Product
springboot-cli add usecase --name CreateProduct

mvn clean test
```

## Distribution Options Summary

| Method | Best For | Pros | Cons |
|--------|----------|------|------|
| Direct bash script | Personal dev | Simplest | No npm integration |
| Add to PATH | Personal dev | Easy access | System-specific |
| Install from directory | Local team | Easy updates | Requires local access |
| Install from tarball | Distribution | Portable | Manual updates |
| Install from Git | Team/OSS | Version control | Requires Git |
| Project dependency | Per-project | Isolated | Per-project install |
| npm publish | Public | Easy discovery | Requires npm account |

Choose the method that best fits your use case!
