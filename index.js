#!/usr/bin/env node

/**
 * Spring Boot CLI Claude Plugin
 * Main entry point for the npm package
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const PLUGIN_VERSION = '1.0.0';

// Export plugin metadata
module.exports = {
  name: 'springboot-cli-claude-plugin',
  version: PLUGIN_VERSION,

  /**
   * Get the path to the .claude directory
   */
  getPluginPath: function() {
    return path.join(__dirname, '.claude');
  },

  /**
   * Check if the plugin is properly installed
   */
  isInstalled: function() {
    const claudePath = path.join(process.cwd(), '.claude');
    return fs.existsSync(claudePath);
  },

  /**
   * Validate the plugin installation
   */
  validate: function() {
    return new Promise((resolve, reject) => {
      const scriptPath = path.join(__dirname, 'scripts', 'init-plugin.sh');
      const child = spawn('bash', [scriptPath, 'validate'], {
        cwd: process.cwd(),
        stdio: 'inherit'
      });

      child.on('exit', (code) => {
        if (code === 0) {
          resolve(true);
        } else {
          reject(new Error('Validation failed'));
        }
      });
    });
  },

  /**
   * Initialize the plugin in the current project
   */
  init: function() {
    return new Promise((resolve, reject) => {
      const scriptPath = path.join(__dirname, 'scripts', 'init-plugin.sh');
      const child = spawn('bash', [scriptPath, 'init'], {
        cwd: process.cwd(),
        stdio: 'inherit'
      });

      child.on('exit', (code) => {
        if (code === 0) {
          resolve(true);
        } else {
          reject(new Error('Initialization failed'));
        }
      });
    });
  },

  /**
   * Get available slash commands
   */
  getCommands: function() {
    const commandsDir = path.join(__dirname, '.claude', 'commands');
    if (!fs.existsSync(commandsDir)) {
      return [];
    }

    return fs.readdirSync(commandsDir)
      .filter(file => file.endsWith('.md'))
      .map(file => '/' + file.replace('.md', ''));
  },

  /**
   * Get available agents
   */
  getAgents: function() {
    const agentsDir = path.join(__dirname, '.claude', 'agents');
    if (!fs.existsSync(agentsDir)) {
      return [];
    }

    return fs.readdirSync(agentsDir)
      .filter(file => file.endsWith('.md'))
      .map(file => file.replace('.md', ''));
  },

  /**
   * Get plugin configuration
   */
  getConfig: function() {
    const configPath = path.join(process.cwd(), '.claude', 'config', 'local.json');
    if (!fs.existsSync(configPath)) {
      return null;
    }

    return JSON.parse(fs.readFileSync(configPath, 'utf8'));
  }
};

// CLI functionality when run directly
if (require.main === module) {
  const args = process.argv.slice(2);
  const command = args[0] || 'help';

  console.log('Spring Boot CLI Claude Plugin v' + PLUGIN_VERSION);
  console.log('');

  switch (command) {
    case 'version':
      console.log(PLUGIN_VERSION);
      break;

    case 'commands':
      console.log('Available slash commands:');
      module.exports.getCommands().forEach(cmd => {
        console.log('  ' + cmd);
      });
      break;

    case 'agents':
      console.log('Available agents:');
      module.exports.getAgents().forEach(agent => {
        console.log('  @' + agent);
      });
      break;

    case 'validate':
      module.exports.validate()
        .then(() => console.log('✅ Validation successful'))
        .catch(err => {
          console.error('❌ Validation failed:', err.message);
          process.exit(1);
        });
      break;

    case 'init':
      module.exports.init()
        .then(() => console.log('✅ Initialization successful'))
        .catch(err => {
          console.error('❌ Initialization failed:', err.message);
          process.exit(1);
        });
      break;

    case 'help':
    default:
      console.log('Usage: springboot-cli-claude-plugin [command]');
      console.log('');
      console.log('Commands:');
      console.log('  version   - Show plugin version');
      console.log('  commands  - List available slash commands');
      console.log('  agents    - List available agents');
      console.log('  validate  - Validate plugin installation');
      console.log('  init      - Initialize plugin in current directory');
      console.log('  help      - Show this help message');
      break;
  }
}