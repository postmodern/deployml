require 'deployml/project'

require 'thor'
require 'pathname'

module DeploYML
  #
  # The command-line interface to {DeploYML} using
  # [Thor](http://github.com/wycats/thor#readme).
  #
  class CLI < Thor

    namespace 'deploy'

    desc 'exec', 'Runs a command on the deploy server'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Executes a command in the specified environment.
    #
    # @param [String] command
    #   The full command to execute.
    #
    def exec(command)
      environment.exec(command)
    end

    desc 'rake', 'Executes a rake task on the deploy server'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'
    method_option :args, :type => :array

    #
    # Invokes a rake task in the specified environment.
    #
    # @param [String] task
    #   The name of the rake task.
    #
    def rake(task)
      environment.rake(task,*(options[:args]))
    end

    desc 'ssh', 'Starts a SSH session with the deploy server'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Starts an SSH session with the specified environment.
    #
    def ssh
      environment.ssh
    end

    desc 'setup', 'Sets up the deployment repository for the project'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Sets up the specified environment.
    #
    def setup
      status 'Setting up ...'

      project.setup!(options[:environment])

      status 'Setup'
    end

    desc 'update', 'Updates the deployment repository of the project'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Updates the deployment repository of the specified environment.
    #
    def update
      status 'Updating'

      project.update!(options[:environment])

      status 'Updated'
    end

    desc 'install', 'Installs the project on the deploy server'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Installs any needed dependencies in the specified environment.
    #
    def install
      status 'Installing ...'

      project.install!(options[:environment])

      status 'Installed'
    end

    desc 'migrate', 'Migrates the database for the project'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Migrates the database for the specified environment.
    #
    def migrate
      status 'Migrating ...'

      project.migrate!(options[:environment])

      status 'Migrated'
    end

    desc 'config', 'Configures the server for the project'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Configures the server for the specified environment.
    #
    def config
      status 'Configuring ...'

      project.config!(options[:environment])

      status 'Configured'
    end

    desc 'start', 'Starts the server for the project'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Starts the server in the specified environment.
    #
    def start
      status 'Starting ...'

      project.start!(options[:environment])

      status 'Started'
    end

    desc 'stop', 'Stops the server for the project'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Stops the server in the specified environment.
    #
    def stop
      status 'Stopping ...'

      project.stop!(options[:environment])

      status 'Stopped'
    end

    desc 'restart', 'Restarts the server for the project'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Restarts the server in the specified environment.
    #
    def restart
      status 'Restarting ...'

      project.restart!(options[:environment])

      status 'Restarted'
    end

    desc 'deploy', 'Cold-Deploys a new project'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Cold-deploys into the specified environment.
    #
    def deploy
      status 'Deploying ...'

      project.deploy!(options[:environment])

      status 'Deployed'
    end

    desc 'redeploy', 'Redeploys the project'
    method_option :environment, :type => :string,
                                :default => 'production',
                                :aliases => '-E'

    #
    # Redeploys into the specified environment.
    #
    def redeploy
      status 'Redeploying ...'

      project.redeploy!(options[:environment])

      status 'Redeployed'
    end

    protected

    #
    # Finds the root of the project, starting at the current working
    # directory and ascending upwards.
    #
    # @return [Pathname]
    #   The root of the project.
    #
    # @since 0.3.0
    #
    def find_root
      Pathname.pwd.ascend do |root|
        config_dir = root.join(Project::CONFIG_DIR)

        if config_dir.directory?
          config_file = config_dir.join(Project::CONFIG_FILE)
          return root if config_file.file?

          environments_dir = config_dir.join(Project::ENVIRONMENTS_DIR)
          return root if environments_dir.directory?
        end
      end

      shell.say "Could not find '#{Project::CONFIG_FILE}' in any parent directories", :red
      exit -1
    end

    #
    # The project.
    #
    # @return [Project]
    #   The project object.
    #
    # @since 0.3.0
    #
    def project
      @project ||= Project.new(find_root)
    end

    #
    # The selected environment.
    #
    # @return [Environment]
    #   A deployment environment of the project.
    #
    # @since 0.3.0
    #
    def environment
      project.environment(options[:environment])
    end

    #
    # Prints a status message.
    #
    # @param [String] message
    #   The message to print.
    #
    def status(message)
      shell.say_status "[#{options[:environment]}]", message
    end

  end
end
