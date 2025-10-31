/**
 * Spring Boot CLI with Architecture Orchestration
 * Main entry point for programmatic usage
 */

const { spawn, execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// Export paths to main scripts
const PATHS = {
  CLI: path.join(__dirname, 'bin', 'springboot-cli.sh'),
  ORCHESTRATOR: path.join(__dirname, 'bin', 'orchestrator.sh'),
  LEARNING: path.join(__dirname, 'bin', 'agent-learning-system.sh'),
  TEMPLATES: path.join(__dirname, 'templates'),
  CONFIG: path.join(__dirname, 'config'),
  DATA: path.join(__dirname, 'data')
};

/**
 * Execute a CLI command
 * @param {string} command - The command to run
 * @param {array} args - Command arguments
 * @param {object} options - Spawn options
 * @returns {Promise} - Resolves with command output
 */
function execute(command, args = [], options = {}) {
  return new Promise((resolve, reject) => {
    const script = PATHS[command.toUpperCase()] || command;

    if (!fs.existsSync(script)) {
      reject(new Error(`Script not found: ${script}`));
      return;
    }

    const child = spawn('bash', [script, ...args], {
      ...options,
      cwd: options.cwd || process.cwd()
    });

    let stdout = '';
    let stderr = '';

    if (child.stdout) {
      child.stdout.on('data', (data) => {
        stdout += data.toString();
      });
    }

    if (child.stderr) {
      child.stderr.on('data', (data) => {
        stderr += data.toString();
      });
    }

    child.on('exit', (code) => {
      if (code === 0) {
        resolve({ code, stdout, stderr });
      } else {
        reject(new Error(`Command failed with code ${code}: ${stderr || stdout}`));
      }
    });

    child.on('error', reject);
  });
}

/**
 * Synchronous command execution
 */
function executeSync(command, args = [], options = {}) {
  const script = PATHS[command.toUpperCase()] || command;

  if (!fs.existsSync(script)) {
    throw new Error(`Script not found: ${script}`);
  }

  const result = execSync(`bash "${script}" ${args.join(' ')}`, {
    ...options,
    encoding: 'utf8'
  });

  return result;
}

/**
 * Spring Boot CLI wrapper
 */
class SpringBootCLI {
  /**
   * Initialize a new Spring Boot project
   */
  async init(options = {}) {
    const args = [];
    if (options.name) args.push('--name', options.name);
    if (options.package) args.push('--package', options.package);
    if (options.database) args.push('--database', options.database);
    if (options.features) args.push('--features', options.features);

    return execute('CLI', ['init', ...args]);
  }

  /**
   * Add a component to the project
   */
  async add(component, options = {}) {
    const args = [component];
    Object.entries(options).forEach(([key, value]) => {
      args.push(`--${key}`, value);
    });

    return execute('CLI', ['add', ...args]);
  }

  /**
   * Validate architecture
   */
  async validate(aspect = 'architecture') {
    return execute('CLI', ['validate', aspect]);
  }
}

/**
 * Orchestrator wrapper
 */
class Orchestrator {
  /**
   * Validate architecture with optional auto-fix
   */
  async validate(autoFix = false) {
    const args = ['validate'];
    if (autoFix) args.push('--fix');
    return execute('ORCHESTRATOR', args);
  }

  /**
   * Start continuous monitoring
   */
  async continuous(directory = '.') {
    return execute('ORCHESTRATOR', ['continuous', directory], {
      detached: true,
      stdio: 'ignore'
    });
  }

  /**
   * Get learning report
   */
  async report() {
    return execute('ORCHESTRATOR', ['report']);
  }

  /**
   * Check interfaces
   */
  async checkInterfaces(directory = '.') {
    return execute('ORCHESTRATOR', ['check-interfaces', directory]);
  }
}

/**
 * Learning System wrapper
 */
class LearningSystem {
  /**
   * Show dashboard
   */
  async dashboard() {
    return execute('LEARNING', ['dashboard']);
  }

  /**
   * Analyze agent patterns
   */
  async analyze(agent = 'all') {
    return execute('LEARNING', ['analyze', agent]);
  }

  /**
   * Generate feedback
   */
  async feedback(agent) {
    return execute('LEARNING', ['feedback', agent]);
  }

  /**
   * Record violation
   */
  async record(agent, type, file, severity, fixed) {
    return execute('LEARNING', ['record', agent, type, file, severity, fixed]);
  }

  /**
   * Export learning data
   */
  async export() {
    return execute('LEARNING', ['export']);
  }
}

/**
 * Validator - Quick architecture validation
 */
class Validator {
  /**
   * Run validation with auto-fix
   */
  async run(noFix = false) {
    const args = ['validate'];
    if (!noFix) args.push('--fix');
    return execute('ORCHESTRATOR', args);
  }

  /**
   * Check specific aspect
   */
  async check(aspect) {
    return execute('CLI', ['validate', aspect]);
  }
}

// Export main classes and utilities
module.exports = {
  // Main classes
  SpringBootCLI,
  Orchestrator,
  LearningSystem,
  Validator,

  // Factory functions
  cli: () => new SpringBootCLI(),
  orchestrator: () => new Orchestrator(),
  learning: () => new LearningSystem(),
  validator: () => new Validator(),

  // Direct execution
  execute,
  executeSync,

  // Paths
  paths: PATHS,

  // Convenience methods
  validate: async (autoFix = true) => {
    const orc = new Orchestrator();
    return orc.validate(autoFix);
  },

  validateArchitecture: async () => {
    const cli = new SpringBootCLI();
    return cli.validate('architecture');
  },

  init: async (options) => {
    const cli = new SpringBootCLI();
    return cli.init(options);
  },

  // Check if all dependencies are available
  checkDependencies: () => {
    const deps = {
      bash: false,
      java: false,
      maven: false,
      sqlite3: false,
      git: false
    };

    Object.keys(deps).forEach(cmd => {
      try {
        execSync(`which ${cmd}`, { stdio: 'ignore' });
        deps[cmd] = true;
      } catch {
        deps[cmd] = false;
      }
    });

    return deps;
  },

  // Version info
  version: require('./package.json').version
};