#!/usr/bin/env node

/**
 * Post-install script for Spring Boot CLI with Orchestration
 * Sets up permissions, initializes databases, and configures the environment
 */

const fs = require('fs');
const path = require('path');
const { execSync, spawn } = require('child_process');
const chalk = require('chalk').default || require('chalk');
const ora = require('ora');

// Determine if we're in global or local install
const isGlobal = process.env.npm_config_global === 'true' ||
                process.argv.includes('-g') ||
                __dirname.includes('node_modules');

const projectRoot = path.resolve(__dirname, '..');

console.log(chalk.blue('\n╔═══════════════════════════════════════════════════════════════╗'));
console.log(chalk.blue('║     Spring Boot CLI - Post Installation Setup                 ║'));
console.log(chalk.blue('╚═══════════════════════════════════════════════════════════════╝\n'));

// Helper function to set executable permissions
function makeExecutable(filePath) {
  try {
    fs.chmodSync(filePath, '755');
    return true;
  } catch (e) {
    // Windows doesn't need chmod
    if (process.platform === 'win32') {
      return true;
    }
    console.warn(chalk.yellow(`⚠ Could not set permissions for ${path.basename(filePath)}`));
    return false;
  }
}

// Helper function to check if a command exists
function commandExists(cmd) {
  try {
    execSync(`which ${cmd}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

// Step 1: Set executable permissions
async function setPermissions() {
  const spinner = ora('Setting executable permissions...').start();

  const scriptsToMakeExecutable = [
    path.join(projectRoot, 'bin', 'cli.js'),
    path.join(projectRoot, 'bin', 'springboot-cli.sh'),
    path.join(projectRoot, 'bin', 'orchestrator.sh'),
    path.join(projectRoot, 'bin', 'agent-learning-system.sh'),
    path.join(projectRoot, 'bin', 'orchestrator-wrapper.js'),
    path.join(projectRoot, 'bin', 'learning-wrapper.js'),
    path.join(projectRoot, 'bin', 'validate-wrapper.js'),
  ];

  // Add all command scripts
  const commandsDir = path.join(projectRoot, 'bin', 'commands');
  if (fs.existsSync(commandsDir)) {
    fs.readdirSync(commandsDir)
      .filter(f => f.endsWith('.sh'))
      .forEach(f => {
        scriptsToMakeExecutable.push(path.join(commandsDir, f));
      });
  }

  let successCount = 0;
  scriptsToMakeExecutable.forEach(script => {
    if (fs.existsSync(script) && makeExecutable(script)) {
      successCount++;
    }
  });

  spinner.succeed(`Permissions set for ${successCount} scripts`);
}

// Step 2: Create necessary directories
async function createDirectories() {
  const spinner = ora('Creating directory structure...').start();

  const directories = [
    path.join(projectRoot, 'data'),
    path.join(projectRoot, 'data', 'orchestrator'),
    path.join(projectRoot, 'data', 'learning'),
    path.join(projectRoot, 'data', 'learning', 'feedback'),
  ];

  directories.forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  });

  // Create .gitkeep files to preserve empty directories
  const gitkeepFile = path.join(projectRoot, 'data', '.gitkeep');
  if (!fs.existsSync(gitkeepFile)) {
    fs.writeFileSync(gitkeepFile, '# This file ensures the data directory is tracked by git\n');
  }

  spinner.succeed('Directory structure created');
}

// Step 3: Initialize learning database (if SQLite is available)
async function initializeLearningSystem() {
  const spinner = ora('Initializing learning system...').start();

  if (!commandExists('sqlite3')) {
    spinner.warn('SQLite not found - learning system will initialize on first use');
    console.log(chalk.gray('  To install SQLite:'));
    console.log(chalk.gray('    macOS: brew install sqlite3'));
    console.log(chalk.gray('    Ubuntu/Debian: sudo apt-get install sqlite3'));
    console.log(chalk.gray('    RHEL/CentOS: sudo yum install sqlite'));
    return;
  }

  try {
    const learningScript = path.join(projectRoot, 'bin', 'agent-learning-system.sh');
    if (fs.existsSync(learningScript)) {
      execSync(`bash "${learningScript}" record "system" "INSTALL" "npm" "INFO" "1"`, {
        stdio: 'ignore',
        cwd: projectRoot
      });
      spinner.succeed('Learning system initialized');
    } else {
      spinner.warn('Learning system script not found');
    }
  } catch (e) {
    spinner.warn('Learning system will initialize on first use');
  }
}

// Step 4: Check dependencies
async function checkDependencies() {
  const spinner = ora('Checking system dependencies...').start();

  const dependencies = {
    bash: { required: true, install: 'Required for all scripts' },
    java: { required: false, install: 'Required for Spring Boot projects' },
    mvn: { required: false, install: 'Required for building Spring Boot projects' },
    sqlite3: { required: false, install: 'Required for learning system' },
    git: { required: false, install: 'Recommended for version control' }
  };

  const missing = [];
  const optional = [];

  Object.entries(dependencies).forEach(([cmd, info]) => {
    if (!commandExists(cmd)) {
      if (info.required) {
        missing.push(`${cmd} - ${info.install}`);
      } else {
        optional.push(`${cmd} - ${info.install}`);
      }
    }
  });

  if (missing.length > 0) {
    spinner.fail('Required dependencies missing:');
    missing.forEach(dep => console.log(chalk.red(`  ✗ ${dep}`)));
  } else {
    spinner.succeed('All required dependencies found');
  }

  if (optional.length > 0) {
    console.log(chalk.yellow('\nOptional dependencies not found:'));
    optional.forEach(dep => console.log(chalk.yellow(`  ⚠ ${dep}`)));
  }
}

// Step 5: Display usage instructions
function displayInstructions() {
  console.log(chalk.green('\n✅ Installation Complete!\n'));

  console.log(chalk.cyan('Available Commands:'));
  console.log('  springboot-cli      - Main Spring Boot CLI');
  console.log('  orchestrator        - Architecture orchestration system');
  console.log('  learning-system     - Agent learning and feedback');
  console.log('  validate-arch       - Quick architecture validation\n');

  console.log(chalk.cyan('Quick Start:'));
  console.log('  1. Create a project:  springboot-cli init --name my-service');
  console.log('  2. Validate arch:     validate-arch');
  console.log('  3. Start monitoring:  orchestrator continuous .');
  console.log('  4. View dashboard:    learning-system dashboard\n');

  console.log(chalk.cyan('NPM Scripts:'));
  console.log('  npm run validate        - Run architecture validation');
  console.log('  npm run validate:fix    - Validate and auto-fix');
  console.log('  npm run monitor         - Start continuous monitoring');
  console.log('  npm run learning:dashboard - View learning dashboard\n');

  if (isGlobal) {
    console.log(chalk.green('✨ Globally installed - commands available everywhere'));
  } else {
    console.log(chalk.yellow('📦 Locally installed - use npx or npm scripts'));
    console.log(chalk.gray('  Example: npx springboot-cli init --name my-service'));
  }

  console.log('\n' + chalk.blue('Documentation:'));
  console.log('  README.md                   - Getting started');
  console.log('  CLAUDE_AGENT_QUICK_START.md - For Claude agents');
  console.log('  docs/                       - Full documentation\n');
}

// Main installation flow
async function main() {
  try {
    await setPermissions();
    await createDirectories();
    await initializeLearningSystem();
    await checkDependencies();
    displayInstructions();

    // Create a marker file to indicate successful installation
    const markerFile = path.join(projectRoot, '.installed');
    fs.writeFileSync(markerFile, new Date().toISOString());

  } catch (error) {
    console.error(chalk.red('\n❌ Installation failed:'), error.message);
    console.error(chalk.gray('\nYou can try manual setup:'));
    console.error(chalk.gray('  1. chmod +x bin/*.sh bin/**/*.sh'));
    console.error(chalk.gray('  2. mkdir -p data/learning data/orchestrator'));
    console.error(chalk.gray('  3. Try running: springboot-cli --help'));
    process.exit(1);
  }
}

// Run installation
main().catch(console.error);