#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Get the directory where this script is located
const binDir = __dirname;
const bashScript = path.join(binDir, 'springboot-cli.sh');

// Check if bash script exists
if (!fs.existsSync(bashScript)) {
  console.error('Error: springboot-cli.sh not found at', bashScript);
  process.exit(1);
}

// Check if bash is available
const checkBash = spawn('which', ['bash']);
checkBash.on('close', (code) => {
  if (code !== 0) {
    console.error('Error: bash is not available on this system');
    console.error('This CLI requires bash to run');
    process.exit(1);
  }
});

// Get command line arguments (skip 'node' and script name)
const args = process.argv.slice(2);

// If no arguments provided, show help
if (args.length === 0) {
  args.push('--help');
}

// Spawn the bash script with all arguments
const child = spawn('bash', [bashScript, ...args], {
  stdio: 'inherit',
  cwd: process.cwd()
});

// Handle process exit
child.on('exit', (code) => {
  process.exit(code || 0);
});

// Handle errors
child.on('error', (err) => {
  console.error('Error executing springboot-cli:', err.message);
  process.exit(1);
});

// Handle termination signals
process.on('SIGINT', () => {
  child.kill('SIGINT');
});

process.on('SIGTERM', () => {
  child.kill('SIGTERM');
});
