# Publishing Guide

This document explains how to publish the Claude Code Spring Boot Plugin to npm.

## Prerequisites

1. **npm account** - Create one at https://www.npmjs.com/signup
2. **npm CLI** - Should be installed with Node.js
3. **Authentication** - Login to npm via CLI

## Setup

### 1. Create npm Account (if needed)

```bash
# Visit https://www.npmjs.com/signup to create account
```

### 2. Login to npm

```bash
npm login
# Enter your username, password, and email
# You may need 2FA code
```

### 3. Verify Login

```bash
npm whoami
# Should display your npm username
```

## Publishing Steps

### Option 1: Publish to Public npm Registry

```bash
cd /home/kishen90/java/claude-springboot-plugin

# Test the package
npm pack
npm publish --dry-run

# Publish for real
npm publish --access public
```

**Note**: The package name `@claude-code/springboot-plugin` uses a scoped namespace. You may need to:
- Own the `@claude-code` organization on npm, OR
- Change the package name in `package.json` to something like `@your-username/springboot-plugin` or `claude-springboot-plugin` (without scope)

### Option 2: Publish with Different Name

If you don't own `@claude-code` namespace:

```bash
# Edit package.json and change name to:
# "name": "@YOUR-USERNAME/springboot-plugin"
# or
# "name": "claude-springboot-plugin"

npm publish --access public
```

### Option 3: Publish to Private Registry

```bash
# For private package (requires paid npm account)
npm publish
```

## Version Management

### Update Version

```bash
# Patch release (1.0.0 -> 1.0.1)
npm version patch

# Minor release (1.0.0 -> 1.1.0)
npm version minor

# Major release (1.0.0 -> 2.0.0)
npm version major

# Then publish
npm publish --access public
```

## Publishing Checklist

Before publishing, ensure:

- [ ] `package.json` has correct name, version, and metadata
- [ ] `README.md` is complete and accurate
- [ ] `LICENSE` file is present
- [ ] `.npmignore` excludes unnecessary files
- [ ] All files in `files` array in package.json exist
- [ ] Test installation locally: `npm pack && npm install <tarball>`
- [ ] Test CLI command: `claude-springboot-install --help`
- [ ] Repository URL is correct (update to your GitHub repo)
- [ ] Author information is correct

## Post-Publishing

### 1. Verify Package

```bash
# Check on npm
open https://www.npmjs.com/package/@claude-code/springboot-plugin
# (or your chosen package name)

# Try installing
npm install -g @claude-code/springboot-plugin
```

### 2. Test Installation

```bash
# In a test directory
mkdir /tmp/test-npm-install
cd /tmp/test-npm-install
npm init -y

# Test different installation methods
npm install @claude-code/springboot-plugin
npx claude-springboot-install
```

### 3. Update Documentation

Update repository README with actual installation command:

```bash
npm install -g @claude-code/springboot-plugin
```

## Alternative Distribution Methods

If you prefer not to publish to npm registry:

### Method 1: GitHub Package Registry

```bash
# Update package.json
{
  "name": "@YOUR-GITHUB-USERNAME/springboot-plugin",
  "publishConfig": {
    "registry": "https://npm.pkg.github.com"
  }
}

# Login to GitHub Packages
npm login --scope=@YOUR-GITHUB-USERNAME --registry=https://npm.pkg.github.com

# Publish
npm publish
```

Users install with:
```bash
npm install @YOUR-GITHUB-USERNAME/springboot-plugin --registry=https://npm.pkg.github.com
```

### Method 2: Git Repository Installation

Users can install directly from Git:

```bash
npm install git+https://github.com/YOUR-USERNAME/claude-springboot-plugin.git
```

### Method 3: Tarball Distribution

Share the `.tgz` file directly:

```bash
npm pack
# Share claude-code-springboot-plugin-1.0.0.tgz

# Users install with:
npm install /path/to/claude-code-springboot-plugin-1.0.0.tgz
```

### Method 4: Local File System

For local use only:

```bash
# In the package directory
npm link

# In project directory
npm link @claude-code/springboot-plugin
```

## Troubleshooting

### Error: 403 Forbidden

**Problem**: You don't have permission to publish under `@claude-code` scope.

**Solution**: Either:
1. Change package name in `package.json` to use your username or no scope
2. Create/join the `@claude-code` organization on npm

### Error: Package already exists

**Problem**: Package name is taken.

**Solution**: Choose a different package name:
- `@your-username/springboot-plugin`
- `your-username-springboot-plugin`
- `claude-springboot-config-plugin`

### Error: Authentication required

**Problem**: Not logged in to npm.

**Solution**: Run `npm login` and enter credentials.

## Recommended Package Names

If `@claude-code/springboot-plugin` is not available:

1. `@your-npm-username/springboot-plugin`
2. `claude-springboot-config`
3. `springboot-claude-plugin`
4. `your-username-claude-springboot`

## CI/CD Publishing (Optional)

For automated publishing with GitHub Actions:

```yaml
# .github/workflows/publish.yml
name: Publish Package

on:
  release:
    types: [created]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '18'
          registry-url: 'https://registry.npmjs.org'
      - run: npm install
      - run: npm publish --access public
        env:
          NODE_AUTH_TOKEN: ${{secrets.NPM_TOKEN}}
```

## Security

### npm Token

If using CI/CD:

1. Generate npm token: https://www.npmjs.com/settings/YOUR-USERNAME/tokens
2. Add as GitHub secret: `NPM_TOKEN`

### 2FA

Enable 2FA on your npm account for security:
https://www.npmjs.com/settings/YOUR-USERNAME/tfa

## Support

For npm publishing issues:
- npm Documentation: https://docs.npmjs.com/
- npm Support: https://www.npmjs.com/support

## Next Steps

After successful publishing:

1. ✅ Update main repository README with installation instructions
2. ✅ Create GitHub release
3. ✅ Share on social media / developer communities
4. ✅ Create demo video or tutorial
5. ✅ Write blog post about the plugin

---

**Ready to publish?** Follow the steps above and share your Claude Code plugin with the community! 🚀
