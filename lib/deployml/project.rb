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
        raise(ConfigNotFound,"could not find '#{CONFIG_FILE}' or '#{ENVIRONMENTS_DIR}' in #{root}",caller)
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
        raise(UnknownEnvironment,"unknown environment: #{name}",caller)
      end

      return @environments[name]
    end

    #
    # Convenience method for accessing the development environment.
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
    # Convenience method for accessing the staging environment.
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
    # Convenience method for accessing the production environment.
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
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.2.0
    #
    def invoke(tasks,env=:production)
      environment(env).invoke(tasks)
    end

    #
    # Sets up the deployment repository for the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    def setup!(env=:production)
      environment(env).setup!
    end

    #
    # Updates the deployed repository of the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    def update!(env=:production)
      environment(env).update!
    end

    #
    # Installs the project on the destination server.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    def install!(env=:production)
      environment(env).install!
    end

    #
    # Migrates the database used by the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    def migrate!(env=:production)
      environment(env).migrate!
    end

    #
    # Configures the Web server to be ran on the destination server.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    def config!(env=:production)
      environment(env).config!
    end

    #
    # Starts the Web server for the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    def start!(env=:production)
      environment(env).start!
    end

    #
    # Stops the Web server for the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    def stop!(env=:production)
      environment(env).stop!
    end

    #
    # Restarts the Web server for the project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    def restart!(env=:production)
      environment(env).restart!
    end

    #
    # Deploys a new project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.2.0
    #
    def deploy!(env=:production)
      environment(env).deploy!
    end

    #
    # Redeploys a project.
    #
    # @param [Symbol, String] env
    #   The environment to deploy to.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.2.0
    #
    def redeploy!(env=:production)
      environment(env).redeploy!
    end

    protected

    #
    # Infers the configuration from the project root directory.
    #
    # @return [Hash{Symbol => Object}]
    #   The inferred configuration.
    #
    # @since 0.4.1
    #
    def infer_configuration
      config = {}

      # check for Bundler
      if File.file?(File.join(@root,'Gemfile'))
        config[:bundler] = true
      end

      return config
    end

    #
    # Loads configuration from a YAML file.
    #
    # @param [String] path
    #   The path to the configuration file.
    #
    # @return [Hash]
    #   The loaded configuration.
    #
    # @raise [InvalidConfig]
    #   The configuration file did not contain a YAML Hash.
    #
    # @since 0.4.1
    #
    def load_configuration(path)
      config = YAML.load_file(path)

      unless config.kind_of?(Hash)
        raise(InvalidConfig,"DeploYML file #{path.dump} does not contain a Hash",caller)
      end

      return config
    end

    #
    # Loads the project configuration.
    #
    # @since 0.3.0
    #
    def load_environments!
      base_config = infer_configuration

      if File.file?(@config_file)
        base_config.merge!(load_configuration(@config_file))
      end

      @environments = {}

      if File.directory?(@environments_dir)
        Dir.glob(File.join(@environments_dir,'*.yml')) do |path|
          config = base_config.merge(load_configuration(path))
          name = File.basename(path).sub(/\.yml$/,'').to_sym

          @environments[name] = Environment.new(name,config)
        end
      else
        @environments[:production] = Environment.new(:production,base_config)
      end
    end

  end
end
