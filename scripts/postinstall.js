#!/usr/bin/env node

/**
 * Post-installation script for Spring Boot CLI Claude Plugin
 * This script runs automatically after npm install
 * Works on Windows, Mac, and Linux
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const os = require('os');

console.log('═══════════════════════════════════════════════════════════════');
console.log('🚀 Spring Boot CLI Claude Plugin - Post Install');
console.log('═══════════════════════════════════════════════════════════════');
console.log();

// Colors for console output (cross-platform)
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  blue: '\x1b[34m'
};

function success(message) {
  console.log(`${colors.green}✅ ${message}${colors.reset}`);
}

function warning(message) {
  console.log(`${colors.yellow}⚠️  ${message}${colors.reset}`);
}

function error(message) {
  console.log(`${colors.red}❌ ${message}${colors.reset}`);
}

function info(message) {
  console.log(`${colors.blue}📝 ${message}${colors.reset}`);
}

// Cross-platform path handling
function normalizePath(p) {
  return path.resolve(p).replace(/\\/g, '/');
}

// Recursive directory copy (cross-platform)
function copyDirectorySync(source, target) {
  if (!fs.existsSync(target)) {
    fs.mkdirSync(target, { recursive: true });
  }

  const files = fs.readdirSync(source);

  files.forEach(file => {
    const sourcePath = path.join(source, file);
    const targetPath = path.join(target, file);

    if (fs.lstatSync(sourcePath).isDirectory()) {
      copyDirectorySync(sourcePath, targetPath);
    } else {
      fs.copyFileSync(sourcePath, targetPath);
    }
  });
}

// Detect the actual project root (where the user ran npm install)
let projectRoot;
let pluginSourceDir;

// Check if we're in node_modules (npm install) or in development (npm link)
if (__dirname.includes('node_modules')) {
  // We're inside node_modules, so the project root is 2 or 3 levels up
  // node_modules/springboot-cli-claude-plugin/scripts/postinstall.js
  //     OR
  // node_modules/@org/springboot-cli-claude-plugin/scripts/postinstall.js

  let testPath = path.resolve(__dirname, '..', '..', '..');
  if (fs.existsSync(path.join(testPath, 'package.json')) &&
      !testPath.includes('springboot-cli-claude-plugin')) {
    projectRoot = testPath;
  } else {
    projectRoot = path.resolve(__dirname, '..', '..');
  }
  pluginSourceDir = path.resolve(__dirname, '..');
} else {
  // Development mode - installing from source
  projectRoot = process.cwd();
  pluginSourceDir = path.resolve(__dirname, '..');
}

// Normalize paths for Windows
projectRoot = normalizePath(projectRoot);
pluginSourceDir = normalizePath(pluginSourceDir);

console.log(`📍 Project root: ${projectRoot}`);
console.log(`📦 Plugin source: ${pluginSourceDir}`);
console.log(`🖥️  Platform: ${os.platform()}`);
console.log();

const claudeTargetDir = path.join(projectRoot, '.claude');
const claudeSourceDir = path.join(pluginSourceDir, '.claude');

// Step 1: Check if source .claude directory exists
if (!fs.existsSync(claudeSourceDir)) {
  error(`Plugin source files not found at: ${claudeSourceDir}`);
  warning('This might be a development installation issue.');
  info('The plugin files should be in the package.');

  // Check if we can find .claude in other locations
  const possibleLocations = [
    path.join(__dirname, '..', '.claude'),
    path.join(__dirname, '..', '..', '.claude'),
    path.join(process.cwd(), '.claude')
  ];

  info('Searching for .claude directory in possible locations...');
  for (const loc of possibleLocations) {
    if (fs.existsSync(loc)) {
      info(`Found .claude at: ${loc}`);
      // Don't exit, just warn - the files might already be in place
      break;
    }
  }

  // Don't fail completely - the files might already be copied
  console.log();
  warning('Skipping file copy - please ensure .claude directory exists in your project');
  console.log();
  process.exit(0);
}

// Step 2: Check if .claude directory already exists in target
if (fs.existsSync(claudeTargetDir)) {
  warning('.claude directory already exists in project');

  // Create backup
  const backupDir = `${claudeTargetDir}.backup.${Date.now()}`;
  info(`Creating backup at: ${backupDir}`);

  try {
    fs.renameSync(claudeTargetDir, backupDir);
    success('Existing .claude directory backed up');
  } catch (err) {
    error(`Failed to backup existing directory: ${err.message}`);
    warning('Continuing anyway...');
  }
}

// Step 3: Copy .claude directory from package to project
console.log('📂 Copying plugin files...');

try {
  // Use our cross-platform copy function
  copyDirectorySync(claudeSourceDir, claudeTargetDir);
  success('Plugin files copied successfully');

  // List what was copied
  const subdirs = fs.readdirSync(claudeTargetDir).filter(item =>
    fs.statSync(path.join(claudeTargetDir, item)).isDirectory()
  );

  subdirs.forEach(subdir => {
    const files = fs.readdirSync(path.join(claudeTargetDir, subdir));
    success(`Copied ${subdir}/ (${files.length} files)`);
  });

} catch (err) {
  error(`Failed to copy plugin files: ${err.message}`);
  info('You may need to manually copy the .claude directory to your project');
  process.exit(1);
}

// Step 4: Make hook scripts executable (Unix-like systems only)
if (os.platform() !== 'win32') {
  console.log();
  console.log('🔧 Setting up hooks...');

  try {
    const hooksDir = path.join(claudeTargetDir, 'hooks');
    if (fs.existsSync(hooksDir)) {
      const hookFiles = fs.readdirSync(hooksDir).filter(f => f.endsWith('.sh'));

      hookFiles.forEach(hook => {
        const hookPath = path.join(hooksDir, hook);
        fs.chmodSync(hookPath, 0o755);
      });

      success(`Made ${hookFiles.length} hooks executable`);
    }
  } catch (err) {
    warning(`Could not set hook permissions: ${err.message}`);
  }
} else {
  console.log();
  info('Windows detected - hook scripts will need WSL or Git Bash to run');
}

// Step 5: Check for Spring Boot CLI
console.log();
console.log('🔍 Checking Spring Boot CLI installation...');

// Handle Windows vs Unix paths
const isWindows = os.platform() === 'win32';
let defaultCliPath;

if (isWindows) {
  // Windows paths
  defaultCliPath = 'C:\\springboot-cli';

  // Check common Windows locations
  const windowsPaths = [
    'C:\\springboot-cli',
    'C:\\development\\springboot-cli',
    'C:\\tools\\springboot-cli',
    'D:\\springboot-cli',
    path.join(process.env.USERPROFILE || '', 'springboot-cli')
  ];

  for (const winPath of windowsPaths) {
    if (fs.existsSync(path.join(winPath, 'bin', 'springboot-cli.sh')) ||
        fs.existsSync(path.join(winPath, 'bin', 'springboot-cli.bat'))) {
      defaultCliPath = winPath;
      success(`Spring Boot CLI found at: ${winPath}`);
      break;
    }
  }
} else {
  // Unix/Mac paths
  defaultCliPath = '/home/kishen90/java/springboot-cli';

  if (fs.existsSync(path.join(defaultCliPath, 'bin', 'springboot-cli.sh'))) {
    success(`Spring Boot CLI found at: ${defaultCliPath}`);
  }
}

const cliPath = process.env.SPRINGBOOT_CLI_PATH || defaultCliPath;

if (!fs.existsSync(path.join(cliPath, 'bin')) &&
    !fs.existsSync(path.join(cliPath, 'bin', 'springboot-cli.sh')) &&
    !fs.existsSync(path.join(cliPath, 'bin', 'springboot-cli.bat'))) {
  warning('Spring Boot CLI not found at expected location');
  info(`Please set SPRINGBOOT_CLI_PATH environment variable`);
  info(`Expected location: ${cliPath}`);
  if (isWindows) {
    info('On Windows, set it in System Environment Variables or use:');
    info('  set SPRINGBOOT_CLI_PATH=C:\\path\\to\\springboot-cli');
  }
}

// Step 6: Check for GitHub token
console.log();
console.log('🔐 Checking GitHub configuration...');

if (process.env.GITHUB_TOKEN) {
  success('GitHub token is configured');
} else {
  warning('GitHub token not found');
  info('Please set GITHUB_TOKEN environment variable for GitHub integration');
  if (isWindows) {
    info('On Windows: set GITHUB_TOKEN=your-token-here');
  } else {
    info('On Unix/Mac: export GITHUB_TOKEN=your-token-here');
  }
}

// Step 7: Create local configuration file
console.log();
console.log('⚙️  Creating local configuration...');

const localConfig = {
  installed: new Date().toISOString(),
  version: '1.0.0',
  projectRoot: projectRoot,
  springbootCliPath: cliPath,
  platform: os.platform(),
  features: {
    slashCommands: true,
    agents: true,
    hooks: !isWindows, // Hooks need bash
    githubIntegration: !!process.env.GITHUB_TOKEN
  }
};

const configDir = path.join(claudeTargetDir, 'config');
if (!fs.existsSync(configDir)) {
  fs.mkdirSync(configDir, { recursive: true });
}

const configPath = path.join(configDir, 'local.json');

try {
  fs.writeFileSync(configPath, JSON.stringify(localConfig, null, 2));
  success('Created local configuration');
} catch (err) {
  warning(`Could not create local config: ${err.message}`);
}

// Step 8: Platform-specific instructions
console.log();
console.log('═══════════════════════════════════════════════════════════════');
console.log(`${colors.green}✅ Plugin installation complete!${colors.reset}`);
console.log('═══════════════════════════════════════════════════════════════');
console.log();
console.log('📋 Next Steps:');
console.log();

if (isWindows) {
  console.log('1. Set environment variables (Windows):');
  console.log('   Option A - PowerShell:');
  console.log(`   ${colors.blue}$env:SPRINGBOOT_CLI_PATH = "${cliPath}"${colors.reset}`);
  console.log(`   ${colors.blue}$env:GITHUB_TOKEN = "your-github-token"${colors.reset}`);
  console.log();
  console.log('   Option B - Command Prompt:');
  console.log(`   ${colors.blue}set SPRINGBOOT_CLI_PATH=${cliPath}${colors.reset}`);
  console.log(`   ${colors.blue}set GITHUB_TOKEN=your-github-token${colors.reset}`);
  console.log();
  console.log('   Option C - System Environment Variables:');
  console.log('   Open System Properties > Environment Variables');
  console.log();
  info('Note: Hooks require WSL or Git Bash on Windows');
} else {
  console.log('1. Set environment variables (add to ~/.bashrc or ~/.zshrc):');
  console.log(`   ${colors.blue}export SPRINGBOOT_CLI_PATH="${cliPath}"${colors.reset}`);
  console.log(`   ${colors.blue}export GITHUB_TOKEN="your-github-token"${colors.reset}`);
}

console.log();
console.log('2. Configure Claude Code:');
console.log('   - Open Claude Code settings');
console.log('   - Add GitHub MCP server configuration');
console.log(`   - See: ${colors.blue}${path.join(claudeTargetDir, 'README.md')}${colors.reset}`);
console.log();
console.log('3. Test the installation:');
if (isWindows) {
  console.log(`   ${colors.blue}npx springboot-claude-init validate${colors.reset}`);
} else {
  console.log(`   ${colors.blue}npx springboot-claude-init validate${colors.reset}`);
}
console.log();
console.log('4. Start using the plugin in Claude Code:');
console.log(`   ${colors.blue}/springboot-init --name my-service --package com.example${colors.reset}`);
console.log(`   ${colors.blue}@feature-developer: Create your first feature${colors.reset}`);
console.log();
console.log(`📖 Documentation: ${path.join(claudeTargetDir, 'README.md')}`);
console.log(`🚀 Quick Start: ${path.join(claudeTargetDir, 'QUICKSTART.md')}`);
console.log();

if (isWindows) {
  console.log('📝 Windows Users: Consider using WSL2 for full feature support');
  console.log();
}

console.log('Happy coding with Clean Architecture, CQRS, and TDD! 🎉');