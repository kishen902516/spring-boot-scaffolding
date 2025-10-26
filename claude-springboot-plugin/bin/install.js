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

function showHelp() {
  log('\n📖 Claude Code Spring Boot Plugin Installer\n', 'blue');
  log('Usage:', 'yellow');
  log('  npx claude-springboot-install [directory] [options]\n', 'reset');
  log('Arguments:', 'yellow');
  log('  directory    Target directory (default: current directory)', 'reset');
  log('\nOptions:', 'yellow');
  log('  --force      Overwrite existing .claude directory', 'reset');
  log('  --help       Show this help message', 'reset');
  log('\nExamples:', 'yellow');
  log('  npx claude-springboot-install', 'blue');
  log('  npx claude-springboot-install /path/to/project', 'blue');
  log('  npx claude-springboot-install --force', 'blue');
  log('');
}

function install() {
  const args = process.argv.slice(2);

  // Check for help flag
  if (args.includes('--help') || args.includes('-h')) {
    showHelp();
    return;
  }

  // Parse arguments
  const force = args.includes('--force');
  const targetDirectory = args.find(arg => !arg.startsWith('--')) || process.cwd();

  log('\n🚀 Installing Claude Code Spring Boot Plugin...\n', 'blue');

  // Determine source directory (relative to this script)
  const sourceDir = path.join(__dirname, '..', 'claude-config');
  const targetDir = path.join(targetDirectory, '.claude');

  if (!fs.existsSync(sourceDir)) {
    log('✗ Source configuration not found', 'red');
    log(`  Expected at: ${sourceDir}`, 'red');
    return;
  }

  // Check if target directory exists
  if (!fs.existsSync(targetDirectory)) {
    log(`✗ Target directory does not exist: ${targetDirectory}`, 'red');
    return;
  }

  // Check if .claude already exists
  if (fs.existsSync(targetDir) && !force) {
    log('⚠ .claude directory already exists', 'yellow');
    log(`  Location: ${targetDir}`, 'yellow');
    log('\nOptions:', 'yellow');
    log('  1. Use --force to overwrite existing configuration', 'reset');
    log('  2. Manually backup and remove existing .claude directory', 'reset');
    log('\nExample:', 'blue');
    log('  npx claude-springboot-install --force', 'green');
    return;
  }

  // Backup existing directory if force is used
  if (fs.existsSync(targetDir) && force) {
    const backupDir = `${targetDir}.backup.${Date.now()}`;
    log(`📦 Backing up existing configuration to: ${backupDir}`, 'yellow');
    fs.renameSync(targetDir, backupDir);
  }

  try {
    // Copy all files
    log('📦 Copying configuration files...', 'blue');
    log(`  Source: ${sourceDir}`, 'reset');
    log(`  Target: ${targetDir}`, 'reset');
    copyRecursive(sourceDir, targetDir);

    // Make hook scripts executable
    const hooksDir = path.join(targetDir, 'hooks');
    if (fs.existsSync(hooksDir)) {
      log('\n🔧 Setting executable permissions on hooks...', 'blue');
      const hooks = fs.readdirSync(hooksDir).filter(f => f.endsWith('.sh'));
      hooks.forEach(file => {
        makeExecutable(path.join(hooksDir, file));
        log(`  ✓ ${file}`, 'green');
      });
    }

    log('\n✅ Installation complete!', 'green');

    log('\n📚 What was installed:', 'blue');
    log('  • Commands - 10 slash commands for Spring Boot generation', 'reset');
    log('  • Agents - 3 backend agents for development workflows', 'reset');
    log('  • Hooks - 3 automation scripts for validation', 'reset');
    log('  • Workflows - Feature development workflow', 'reset');
    log('  • Config - MCP server and plugin settings', 'reset');

    log('\n📖 Documentation:', 'blue');
    log(`  • README: ${path.join(targetDir, 'README.md')}`, 'reset');
    log(`  • Quick Start: ${path.join(targetDir, 'QUICKSTART.md')}`, 'reset');

    log('\n🔧 Prerequisites:', 'yellow');
    log('  1. Spring Boot CLI installed at /home/kishen90/java/springboot-cli', 'reset');
    log('  2. Java 21 or higher', 'reset');
    log('  3. Maven 3.9+', 'reset');
    log('  4. GitHub CLI (gh) - optional, for GitHub integration', 'reset');

    log('\n⚙️  Configuration:', 'yellow');
    log('  • Set SPRINGBOOT_CLI_PATH environment variable', 'reset');
    log('  • Configure GitHub token for MCP server (optional)', 'reset');
    log('  • Review and update .claude/config/mcp-servers.json', 'reset');

    log('\n🎯 Try your first command:', 'blue');
    log('  /springboot-init --name my-service --package com.example', 'green');

    log('\n🚀 Use agents for feature development:', 'blue');
    log('  @feature-developer: Implement user authentication', 'green');

  } catch (error) {
    log(`\n✗ Installation failed: ${error.message}`, 'red');
    log(`\n${error.stack}`, 'red');
    process.exit(1);
  }
}

// Run installation
install();
