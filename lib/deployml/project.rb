require 'deployml/exceptions/config_not_found'
require 'deployml/exceptions/invalid_config'
require 'deployml/exceptions/unknown_environment'
require 'deployml/environment'
require 'deployml/remote_shell'

require 'yaml'

module DeploYML
  class Project

    # The general configuration directory.
    CONFIG_DIR = 'config'

    # The configuration file name.
    CONFIG_FILE = 'deploy.yml'

    # The configuration directory.
    ENVIRONMENTS_DIR = 'deploy'

    # The name of the directory to stage deployments in.
    STAGING_DIR = '.deploy'

    # The root directory of the project
    attr_reader :root

    # The deployment environments of the project
    attr_reader :environments

    #
    # Creates a new project using the given configuration file.
    #
    # @param [String] root
    #   The root directory of the project.
    #
    # @raise [ConfigNotFound]
    #   The configuration file for the project could not be found
    #   in any of the common directories.
    #
    def initialize(root=Dir.pwd)
      @root = File.expand_path(root)
      @config_file = File.join(@root,CONFIG_DIR,CONFIG_FILE)
      @environments_dir = File.join(@root,CONFIG_DIR,ENVIRONMENTS_DIR)

      unless (File.file?(@config_file) || File.directory?(@environments_dir))
        raise(ConfigNotFound,"could not find '#{CONFIG_FILE}' or '#{ENVIRONMENTS_DIR}' in #{root}")
      end

      load_environments!
    end

    #
    # @param [Symbol, String] name
    #   The name of the environment to use.
    #
    # @return [Environment]
    #   The environment with the given name.
    #
    # @raise [UnknownEnvironment]
    #   No environment was configured with the given name.
    #
    # @since 0.3.0
    #
    def environment(name=:production)
      name = name.to_sym

      unless @environments[name]
        raise(UnknownEnvironment,"unknown environment: #{name}")
      end

      return @environments[name]
    end

    #
    # Conveniance method for accessing the development environment.
    #
    # @return [Environment]
    #   The development environment.
    #
    # @since 0.3.0
    #
    def development
      environment(:development)
    end

    #
    # Conveniance method for accessing the staging environment.
    #
    # @return [Environment]
    #   The staging environment.
    #
    # @since 0.3.0
    #
    def staging
      environment(:staging)
    end

    #
    # Conveniance method for accessing the production environment.
    #
    # @return [Environment]
    #   The production environment.
    #
    # @since 0.3.0
    #
    def production
      environment(:production)
    end

    #
    # Deploys the project.
    #
    # @param [Array<Symbol>] tasks
    #   The tasks to run during the deployment.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @return [true]
    #
    # @since 0.2.0
    #
    def invoke(tasks,env=:production)
      env = environment(env)

      env.remote_shell do |shell|
        # setup the deployment repository
        env.setup(shell) if tasks.include?(:setup)

        # cd into the deployment repository
        shell.cd env.dest.path

        # update the deployment repository
        env.update(shell) if tasks.include?(:update)

        # framework tasks
        env.install(shell) if tasks.include?(:install)
        env.migrate(shell) if tasks.include?(:migrate)

        # server tasks
        if tasks.include?(:config)
          env.server_config(shell)
        elsif tasks.include?(:start)
          env.server_start(shell)
        elsif tasks.include?(:stop)
          env.server_stop(shell)
        elsif tasks.include?(:restart)
          env.server_restart(shell)
        end
      end

      return true
    end

    #
    # Sets up the deployment repository for the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    def setup!(env=:production)
      invoke [:setup], env
    end

    #
    # Updates the deployed repository of the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    def update!(env=:production)
      invoke [:update], env
    end

    #
    # Installs the project on the destination server.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    def install!(env=:production)
      invoke [:install], env
    end

    #
    # Migrates the database used by the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    def migrate!(env=:production)
      invoke [:migrate], env
    end

    #
    # Configures the Web server to be ran on the destination server.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    def config!(env=:production)
      invoke [:config], env
    end

    #
    # Starts the Web server for the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    def start!(env=:production)
      invoke [:start], env
    end

    #
    # Stops the Web server for the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    def stop!(env=:production)
      invoke [:stop], env
    end

    #
    # Restarts the Web server for the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    def restart!(env=:production)
      invoke [:restart], env
    end

    #
    # Deploys a new project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @since 0.2.0
    #
    def deploy!(env=:production)
      invoke [:setup, :install, :migrate, :config, :start], env
    end

    #
    # Redeploys a project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @since 0.2.0
    #
    def redeploy!(env=:production)
      invoke [:update, :install, :migrate, :restart], env
    end

    protected

    #
    # Loads the project configuration.
    #
    # @raise [InvalidConfig]
    #   The YAML configuration file did not contain a Hash.
    #
    # @raise [MissingOption]
    #   The `source` or `dest` options were not specified.
    #
    # @since 0.3.0
    #
    def load_environments!
      base_config = {}

      load_config_data = lambda { |path|
        config_data = YAML.load_file(path)

        unless config_data.kind_of?(Hash)
          raise(InvalidConfig,"DeploYML file '#{path}' does not contain a Hash")
        end

        config_data
      }

      if File.file?(@config_file)
        base_config.merge!(load_config_data[@config_file])
      end

      @environments = {}

      if File.directory?(@environments_dir)
        Dir.glob(File.join(@environments_dir,'*.yml')) do |path|
          config_data = base_config.merge(load_config_data[path])
          name = File.basename(path).sub(/\.yml$/,'').to_sym

          @environments[name] = Environment.new(name,config_data)
        end
      else
        @environments[:production] = Environment.new(:production,base_config)
      end
    end

  end
end
