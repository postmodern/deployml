require 'deployml/project'

require 'thor'
require 'pathname'

module DeploYML
  class CLI < Thor

    namespace 'deploy'

    desc 'exec', 'Runs a command on the deploy server'
    method_option :environment, :type => :string, :default => 'production'
    def exec(command)
      environment.exec(command)
    end

    desc 'rake', 'Executes a rake task on the deploy server'
    method_option :environment, :type => :string, :default => 'production'
    method_option :args, :type => :array
    def rake(task)
      environment.rake(task,*(options[:args]))
    end

    desc 'ssh', 'Starts a SSH session with the deploy server'
    method_option :environment, :type => :string, :default => 'production'
    def ssh
      environment.ssh
    end

    desc 'setup', 'Sets up the deployment repository for the project'
    method_option :environment, :type => :string, :default => 'production'
    def setup
      status 'Setting up ...'

      project.setup!(options[:environment])

      status 'Setup'
    end

    desc 'update', 'Updates the deployment repository of the project'
    method_option :environment, :type => :string, :default => 'production'
    def update
      status 'Updating'

      project.update!(options[:environment])

      status 'Updated'
    end

    desc 'install', 'Installs the project on the deploy server'
    method_option :environment, :type => :string, :default => 'production'
    def install
      status 'Installing ...'

      project.install!(options[:environment])

      status 'Installed'
    end

    desc 'migrate', 'Migrates the database for the project'
    method_option :environment, :type => :string, :default => 'production'
    def migrate
      status 'Migrating ...'

      project.migrate!(options[:environment])

      status 'Migrated'
    end

    desc 'config', 'Configures the server for the project'
    method_option :environment, :type => :string, :default => 'production'
    def config
      status 'Configuring ...'

      project.config!(options[:environment])

      status 'Configured'
    end

    desc 'start', 'Starts the server for the project'
    method_option :environment, :type => :string, :default => 'production'

    def start
      status 'Starting ...'

      project.start!(options[:environment])

      status 'Started'
    end

    desc 'stop', 'Stops the server for the project'
    method_option :environment, :type => :string, :default => 'production'

    def stop
      status 'Stopping ...'

      project.stop!(options[:environment])

      status 'Stopped'
    end

    desc 'restart', 'Restarts the server for the project'
    method_option :environment, :type => :string, :default => 'production'

    def restart
      status 'Restarting ...'

      project.restart!(options[:environment])

      status 'Restarted'
    end

    desc 'deploy', 'Cold-Deploys a new project'
    method_option :environment, :type => :string, :default => 'production'

    def deploy
      status 'Deploying ...'

      project.deploy!(options[:environment])

      status 'Deployed'
    end

    desc 'redeploy', 'Redeploys the project'
    method_option :environment, :type => :string, :default => 'production'

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

    def status(message)
      shell.say_status "[#{options[:environment]}]", message
    end

  end
end
