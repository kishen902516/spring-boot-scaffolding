#!/usr/bin/env node

/**
 * Quick wrapper for architecture validation with auto-fix
 * Convenience command for the most common use case
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const chalk = require('chalk').default || require('chalk');

// Get the orchestrator script path
const orchestratorScript = path.join(__dirname, 'orchestrator.sh');

// Check if script exists
if (!fs.existsSync(orchestratorScript)) {
  console.error(chalk.red('Error: orchestrator.sh not found'));
  console.error('Please ensure the package is properly installed');
  process.exit(1);
}

// Always run with --fix by default
const args = ['validate', '--fix'];

// Allow passing additional arguments
const userArgs = process.argv.slice(2);
if (userArgs.length > 0 && userArgs[0] === '--no-fix') {
  // Remove --fix if user explicitly doesn't want it
  args.pop();
}

console.log(chalk.blue('🔍 Starting Architecture Validation...'));
console.log(chalk.gray('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'));

// Spawn the orchestrator with validate command
const child = spawn('bash', [orchestratorScript, ...args], {
  stdio: 'inherit',
  cwd: process.cwd(),
  env: process.env
});

// Handle process exit
child.on('exit', (code) => {
  if (code === 0) {
    console.log(chalk.green('\n✅ Architecture validation complete!'));
  } else {
    console.log(chalk.red('\n❌ Validation failed. Please review the errors above.'));
  }
  process.exit(code || 0);
});

// Handle errors
child.on('error', (err) => {
  if (err.code === 'ENOENT') {
    console.error(chalk.red('Error: bash is not installed or not in PATH'));
    console.error('The validator requires bash to run');
    console.error('');
    console.error('Installation instructions:');
    console.error('  - macOS: bash is pre-installed');
    console.error('  - Linux: sudo apt-get install bash (or equivalent)');
    console.error('  - Windows: Use WSL, Git Bash, or Cygwin');
  } else {
    console.error(chalk.red('Error executing validator:'), err.message);
  }
  process.exit(1);
});

// Handle termination signals
process.on('SIGINT', () => {
  child.kill('SIGINT');
});

process.on('SIGTERM', () => {
  child.kill('SIGTERM');
});