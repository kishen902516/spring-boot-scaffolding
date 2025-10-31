#!/usr/bin/env node

/**
 * Node.js wrapper for the orchestrator bash script
 * Provides cross-platform compatibility
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Get the orchestrator script path
const orchestratorScript = path.join(__dirname, 'orchestrator.sh');

// Check if script exists
if (!fs.existsSync(orchestratorScript)) {
  console.error('Error: orchestrator.sh not found');
  console.error('Please ensure the package is properly installed');
  process.exit(1);
}

// Get command line arguments
const args = process.argv.slice(2);

// If no arguments, show help
if (args.length === 0) {
  args.push('help');
}

// Spawn the bash script
const child = spawn('bash', [orchestratorScript, ...args], {
  stdio: 'inherit',
  cwd: process.cwd(),
  env: {
    ...process.env,
    AGENT_NAME: process.env.AGENT_NAME || 'node-cli'
  }
});

// Handle process exit
child.on('exit', (code) => {
  process.exit(code || 0);
});

// Handle errors
child.on('error', (err) => {
  if (err.code === 'ENOENT') {
    console.error('Error: bash is not installed or not in PATH');
    console.error('The orchestrator requires bash to run');
    console.error('');
    console.error('Installation instructions:');
    console.error('  - macOS: bash is pre-installed');
    console.error('  - Linux: sudo apt-get install bash (or equivalent)');
    console.error('  - Windows: Use WSL, Git Bash, or Cygwin');
  } else {
    console.error('Error executing orchestrator:', err.message);
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