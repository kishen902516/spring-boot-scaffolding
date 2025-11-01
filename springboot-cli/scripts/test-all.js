#!/usr/bin/env node

/**
 * Test script to verify all components are working
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const chalk = require('chalk').default || require('chalk');

const projectRoot = path.resolve(__dirname, '..');
let testsPass = 0;
let testsFail = 0;

console.log(chalk.blue('\n═══════════════════════════════════════════════'));
console.log(chalk.blue('     Spring Boot CLI - Test Suite              '));
console.log(chalk.blue('═══════════════════════════════════════════════\n'));

function runTest(name, command, cwd = projectRoot) {
  process.stdout.write(chalk.cyan(`Testing ${name}... `));

  try {
    execSync(command, {
      stdio: 'ignore',
      cwd: cwd,
      timeout: 10000 // 10 second timeout
    });
    console.log(chalk.green('✓ PASS'));
    testsPass++;
    return true;
  } catch (error) {
    console.log(chalk.red('✗ FAIL'));
    testsFail++;
    return false;
  }
}

// Test 1: Check main CLI
runTest('Main CLI', 'node bin/cli.js help');

// Test 2: Check bash script directly
if (fs.existsSync(path.join(projectRoot, 'bin', 'springboot-cli.sh'))) {
  runTest('Bash CLI', 'bash bin/springboot-cli.sh help');
}

// Test 3: Check orchestrator
if (fs.existsSync(path.join(projectRoot, 'bin', 'orchestrator.sh'))) {
  runTest('Orchestrator', 'bash bin/orchestrator.sh help');
}

// Test 4: Check learning system
if (fs.existsSync(path.join(projectRoot, 'bin', 'agent-learning-system.sh'))) {
  // Check if SQLite is installed first
  try {
    execSync('which sqlite3', { stdio: 'ignore' });
    runTest('Learning System', 'bash bin/agent-learning-system.sh help');
  } catch {
    console.log(chalk.yellow('⚠ Learning System (SQLite not installed - will work on first use)'));
  }
}

// Test 5: Check Node wrappers
if (fs.existsSync(path.join(projectRoot, 'bin', 'orchestrator-wrapper.js'))) {
  runTest('Orchestrator Wrapper', 'node bin/orchestrator-wrapper.js help');
}

// Test 6: Verify templates directory
if (fs.existsSync(path.join(projectRoot, 'templates'))) {
  const templateCount = fs.readdirSync(path.join(projectRoot, 'templates')).length;
  if (templateCount > 0) {
    console.log(chalk.green(`✓ Templates found: ${templateCount}`));
    testsPass++;
  } else {
    console.log(chalk.red('✗ No templates found'));
    testsFail++;
  }
}

// Test 7: Check configuration files
if (fs.existsSync(path.join(projectRoot, 'config', 'auto-correction-rules.yaml'))) {
  console.log(chalk.green('✓ Auto-correction rules found'));
  testsPass++;
} else {
  console.log(chalk.yellow('⚠ Auto-correction rules not found (will be created on first use)'));
}

// Test 8: Verify data directory structure
const dataDir = path.join(projectRoot, 'data');
if (fs.existsSync(dataDir)) {
  console.log(chalk.green('✓ Data directory exists'));
  testsPass++;
} else {
  console.log(chalk.yellow('⚠ Data directory not found (will be created on first use)'));
}

// Summary
console.log(chalk.blue('\n═══════════════════════════════════════════════'));
console.log(chalk.cyan('Test Results:'));
console.log(chalk.green(`  Passed: ${testsPass}`));
if (testsFail > 0) {
  console.log(chalk.red(`  Failed: ${testsFail}`));
}
console.log(chalk.blue('═══════════════════════════════════════════════\n'));

if (testsFail === 0) {
  console.log(chalk.green('✅ All tests passed!'));
  process.exit(0);
} else {
  console.log(chalk.red(`❌ ${testsFail} tests failed`));
  console.log(chalk.yellow('\nTroubleshooting:'));
  console.log('  1. Run: npm run setup');
  console.log('  2. Ensure bash is installed');
  console.log('  3. Check file permissions');
  process.exit(1);
}