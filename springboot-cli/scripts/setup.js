#!/usr/bin/env node

/**
 * Setup script for manual installation or fixing issues
 * Can be run with: npm run setup
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const chalk = require('chalk').default || require('chalk');
const ora = require('ora');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const projectRoot = path.resolve(__dirname, '..');

console.log(chalk.blue('\n╔═══════════════════════════════════════════════════════════════╗'));
console.log(chalk.blue('║     Spring Boot CLI - Manual Setup                            ║'));
console.log(chalk.blue('╚═══════════════════════════════════════════════════════════════╝\n'));

function question(prompt) {
  return new Promise(resolve => {
    rl.question(chalk.cyan(prompt), resolve);
  });
}

async function setupPermissions() {
  console.log(chalk.yellow('\n1. Setting File Permissions'));
  console.log(chalk.gray('   Making all scripts executable...\n'));

  const scripts = [
    'bin/cli.js',
    'bin/springboot-cli.sh',
    'bin/orchestrator.sh',
    'bin/agent-learning-system.sh',
    'bin/orchestrator-wrapper.js',
    'bin/learning-wrapper.js',
    'bin/validate-wrapper.js'
  ];

  // Add command scripts
  const commandsDir = path.join(projectRoot, 'bin', 'commands');
  if (fs.existsSync(commandsDir)) {
    fs.readdirSync(commandsDir)
      .filter(f => f.endsWith('.sh'))
      .forEach(f => scripts.push(`bin/commands/${f}`));
  }

  scripts.forEach(script => {
    const fullPath = path.join(projectRoot, script);
    if (fs.existsSync(fullPath)) {
      try {
        fs.chmodSync(fullPath, '755');
        console.log(chalk.green(`   ✓ ${script}`));
      } catch (e) {
        console.log(chalk.yellow(`   ⚠ ${script} (${e.message})`));
      }
    }
  });
}

async function setupDirectories() {
  console.log(chalk.yellow('\n2. Creating Directory Structure'));

  const dirs = [
    'data',
    'data/orchestrator',
    'data/learning',
    'data/learning/feedback',
    'config'
  ];

  dirs.forEach(dir => {
    const fullPath = path.join(projectRoot, dir);
    if (!fs.existsSync(fullPath)) {
      fs.mkdirSync(fullPath, { recursive: true });
      console.log(chalk.green(`   ✓ Created: ${dir}`));
    } else {
      console.log(chalk.gray(`   • Exists: ${dir}`));
    }
  });
}

async function setupConfiguration() {
  console.log(chalk.yellow('\n3. Configuration Files'));

  // Check for auto-correction rules
  const rulesFile = path.join(projectRoot, 'config', 'auto-correction-rules.yaml');
  if (!fs.existsSync(rulesFile)) {
    console.log(chalk.cyan('   Creating default auto-correction rules...'));
    const defaultRules = `version: "1.0"
auto_fix_config:
  enabled: true
  max_fixes_per_session: 50
  create_backup: true
  validate_after_fix: true
  learning_mode: true

# See full configuration in documentation
`;
    fs.writeFileSync(rulesFile, defaultRules);
    console.log(chalk.green('   ✓ Created auto-correction-rules.yaml'));
  } else {
    console.log(chalk.gray('   • auto-correction-rules.yaml exists'));
  }
}

async function setupLearningDatabase() {
  console.log(chalk.yellow('\n4. Learning System Database'));

  const spinner = ora('Initializing learning database...').start();

  try {
    execSync('which sqlite3', { stdio: 'ignore' });

    // Initialize database
    const learningScript = path.join(projectRoot, 'bin', 'agent-learning-system.sh');
    if (fs.existsSync(learningScript)) {
      execSync(`bash "${learningScript}" record "system" "SETUP" "manual" "INFO" "1"`, {
        stdio: 'ignore',
        cwd: projectRoot
      });
      spinner.succeed('Learning database initialized');
    } else {
      spinner.fail('Learning system script not found');
    }
  } catch (e) {
    spinner.warn('SQLite not installed - database will initialize on first use');
    console.log(chalk.gray('   Install SQLite for learning features:'));
    console.log(chalk.gray('     brew install sqlite3  # macOS'));
    console.log(chalk.gray('     apt install sqlite3   # Ubuntu/Debian'));
  }
}

async function setupGlobalCommands() {
  console.log(chalk.yellow('\n5. Global Command Setup'));

  const answer = await question('Would you like to add commands to PATH? (y/n): ');

  if (answer.toLowerCase() === 'y') {
    const shellRc = process.env.SHELL?.includes('zsh') ? '.zshrc' : '.bashrc';
    const rcPath = path.join(process.env.HOME, shellRc);

    const binPath = path.join(projectRoot, 'bin');
    const exportLine = `export PATH="${binPath}:$PATH"`;

    if (fs.existsSync(rcPath)) {
      const content = fs.readFileSync(rcPath, 'utf8');
      if (!content.includes(binPath)) {
        fs.appendFileSync(rcPath, `\n# Spring Boot CLI with Orchestration\n${exportLine}\n`);
        console.log(chalk.green(`   ✓ Added to ${shellRc}`));
        console.log(chalk.yellow(`   Run: source ~/${shellRc}`));
      } else {
        console.log(chalk.gray('   • Already in PATH'));
      }
    }
  }
}

async function testInstallation() {
  console.log(chalk.yellow('\n6. Testing Installation'));

  const tests = [
    { name: 'Main CLI', cmd: 'node bin/cli.js --version' },
    { name: 'Orchestrator', cmd: 'bash bin/orchestrator.sh help' },
    { name: 'Learning System', cmd: 'bash bin/agent-learning-system.sh help' }
  ];

  for (const test of tests) {
    try {
      execSync(test.cmd, {
        stdio: 'ignore',
        cwd: projectRoot,
        timeout: 5000
      });
      console.log(chalk.green(`   ✓ ${test.name} working`));
    } catch (e) {
      console.log(chalk.red(`   ✗ ${test.name} failed`));
    }
  }
}

async function main() {
  try {
    await setupPermissions();
    await setupDirectories();
    await setupConfiguration();
    await setupLearningDatabase();
    await setupGlobalCommands();
    await testInstallation();

    console.log(chalk.green('\n✅ Setup Complete!\n'));

    console.log(chalk.cyan('Quick Test Commands:'));
    console.log('  npx springboot-cli --help');
    console.log('  npx orchestrator validate');
    console.log('  npx learning-system dashboard\n');

    console.log(chalk.cyan('Or if globally installed:'));
    console.log('  springboot-cli --help');
    console.log('  orchestrator validate');
    console.log('  validate-arch\n');

  } catch (error) {
    console.error(chalk.red('\n❌ Setup failed:'), error.message);
    process.exit(1);
  } finally {
    rl.close();
  }
}

main().catch(console.error);