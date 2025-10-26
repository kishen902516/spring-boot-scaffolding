#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  red: '\x1b[31m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function copyRecursive(src, dest) {
  const exists = fs.existsSync(src);
  const stats = exists && fs.statSync(src);
  const isDirectory = exists && stats.isDirectory();

  if (isDirectory) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }
    fs.readdirSync(src).forEach(childItemName => {
      copyRecursive(
        path.join(src, childItemName),
        path.join(dest, childItemName)
      );
    });
  } else {
    fs.copyFileSync(src, dest);
  }
}

function makeExecutable(filePath) {
  try {
    fs.chmodSync(filePath, '755');
  } catch (err) {
    // Silently fail on Windows or if permissions can't be changed
  }
}

function install() {
  log('\n🚀 Installing Claude Code Spring Boot Plugin...\n', 'blue');

  // Determine installation directory
  // When installed as dependency, install in project root
  // When installed globally, skip auto-install (user will use CLI command)
  const cwd = process.cwd();
  const targetDir = path.join(cwd, '.claude');

  // Check if we're in a global installation
  const isGlobal = __dirname.includes('/lib/node_modules') ||
                   __dirname.includes('\\node_modules\\') &&
                   !cwd.includes('node_modules');

  if (isGlobal) {
    log('✓ Installed globally', 'green');
    log('\nTo install in your project, run:', 'yellow');
    log('  npx claude-springboot-install', 'blue');
    log('\nOr in a specific directory:', 'yellow');
    log('  npx claude-springboot-install /path/to/project', 'blue');
    return;
  }

  // Local installation - install into project .claude directory
  const sourceDir = path.join(__dirname, 'claude-config');

  if (!fs.existsSync(sourceDir)) {
    log('✗ Source configuration not found', 'red');
    return;
  }

  // Check if .claude already exists
  if (fs.existsSync(targetDir)) {
    log('⚠ .claude directory already exists', 'yellow');
    log('Skipping installation to avoid overwriting existing configuration', 'yellow');
    log('\nTo manually install, run:', 'yellow');
    log('  npx claude-springboot-install --force', 'blue');
    return;
  }

  try {
    // Copy all files
    log('📦 Copying configuration files...', 'blue');
    copyRecursive(sourceDir, targetDir);

    // Make hook scripts executable
    const hooksDir = path.join(targetDir, 'hooks');
    if (fs.existsSync(hooksDir)) {
      log('🔧 Setting executable permissions on hooks...', 'blue');
      fs.readdirSync(hooksDir).forEach(file => {
        if (file.endsWith('.sh')) {
          makeExecutable(path.join(hooksDir, file));
        }
      });
    }

    log('\n✓ Installation complete!', 'green');
    log('\n📚 What was installed:', 'blue');
    log('  • Commands - Slash commands for Spring Boot generation', 'reset');
    log('  • Agents - Backend agents for feature development', 'reset');
    log('  • Hooks - Automation scripts for validation', 'reset');
    log('  • Workflows - Feature development workflows', 'reset');
    log('  • Config - MCP server and plugin settings', 'reset');

    log('\n📖 Next steps:', 'yellow');
    log('  1. Review .claude/README.md for full documentation', 'reset');
    log('  2. Check .claude/QUICKSTART.md for quick start guide', 'reset');
    log('  3. Configure GitHub token if using GitHub integration', 'reset');
    log('  4. Install Spring Boot CLI at /home/kishen90/java/springboot-cli', 'reset');

    log('\n🎯 Try your first command:', 'blue');
    log('  /springboot-init --name my-service --package com.example', 'green');

  } catch (error) {
    log(`\n✗ Installation failed: ${error.message}`, 'red');
    process.exit(1);
  }
}

// Run installation
if (require.main === module) {
  install();
}

module.exports = { install, copyRecursive, makeExecutable };
