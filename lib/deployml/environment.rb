require 'deployml/exceptions/missing_option'
require 'deployml/exceptions/unknown_server'
require 'deployml/exceptions/unknown_framework'
require 'deployml/configuration'
require 'deployml/local_shell'
require 'deployml/remote_shell'
require 'deployml/servers'
require 'deployml/frameworks'

module DeploYML
  #
  # Contains environment specific configuration loaded by {Project}
  # from YAML files within `config/deploy/`.
  #
  class Environment < Configuration

    # Mapping of possible 'server' names to their mixins.
    SERVERS = {
      :apache => Servers::Apache,
      :mongrel => Servers::Mongrel,
      :thin => Servers::Thin
    }

    # Mapping of possible 'framework' names to their mixins.
    FRAMEWORKS = {
      :rails2 => Frameworks::Rails2,
      :rails3 => Frameworks::Rails3
    }

    #
    # Creates a new deployment environment.
    #
    # @param [Symbol, String] name
    #   The name of the deployment environment.
    #
    # @param [Hash{String => Object}] config
    #   Environment specific configuration.
    #
    # @raise [MissingOption]
    #   Either the `source` or `dest` options were not specified in the
    #   confirmation.
    # 
    # @since 0.3.0
    #
    def initialize(name,config={})
      super(config)

      unless @source
        raise(MissingOption,":source option is missing for the #{@name} environment",caller)
      end

      unless @dest
        raise(MissingOption,":dest option is missing for the #{@name} environment",caller)
      end

      @environment ||= name.to_sym

      load_framework!
      load_server!
    end

    #
    # Creates a local shell.
    #
    # @yield [shell]
    #   If a block is given, it will be passed the new local shell.
    #
    # @yieldparam [LocalShell] shell
    #   The remote shell session.
    #
    # @return [Array<LocalShell>]
    #   The local shell.
    #
    # @since 0.3.0
    #
    def local_shell(&block)
      each_dest.map { |dest| LocalShell.new(dest,&block) }
    end

    #
    # Creates a remote shell with the destination server.
    #
    # @yield [shell]
    #   If a block is given, it will be passed the new remote shell.
    #
    # @yieldparam [LocalShell, RemoteShell] shell
    #   The remote shell.
    #
    # @return [Array<RemoteShell, LocalShell>]
    #   The remote shell. If the destination is a local `file://` URI,
    #   a local shell will be returned instead.
    #
    # @since 0.3.0
    #
    def remote_shell(&block)
      each_dest.map do |dest|
        shell = if dest.scheme == 'file'
                  LocalShell
                else
                  RemoteShell
                end

        shell.new(dest,&block)
      end
    end

    #
    # Runs a command on the destination server, in the destination
    # directory.
    #
    # @return [true]
    #
    # @since 0.3.0
    #
    def exec(command)
      remote_shell do |shell|
        shell.cd(shell.uri.path)
        shell.run(command)
      end

      return true
    end

    #
    # Executes a Rake task on the destination server, in the destination
    # directory.
    #
    # @return [true]
    #
    # @since 0.3.0
    #
    def rake(task,*args)
      remote_shell do |shell|
        shell.cd(shell.uri.path)
        shell.rake(task,*args)
      end

      return true
    end

    #
    # Starts an SSH session with the destination server.
    #
    # @param [Array] args
    #   Additional arguments to pass to SSH.
    #
    # @return [true]
    #
    # @since 0.3.0
    #
    def ssh(*args)
      each_dest do |dest|
        RemoteShell.new(dest).ssh(*args)
      end

      return true
    end

    #
    # Sets up the deployment repository for the project.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def setup(shell)
      shell.status "Cloning #{@source} ..."

      shell.run 'git', 'clone', '--depth', 1, @source, shell.uri.path

      shell.status "Cloned #{@source}."
    end

    #
    # Updates the deployed repository for the project.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def update(shell)
      shell.status "Updating ..."

      shell.run 'git', 'reset', '--hard', 'HEAD'
      shell.run 'git', 'pull', '-f'

      shell.status "Updated."
    end

    #
    # Installs any additional dependencies.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def install(shell)
      if @bundler
        shell.status "Bundling dependencies ..."

        shell.run 'bundle', 'install', '--deployment'

        shell.status "Dependencies bundled."
      end
    end

    #
    # Place-holder method.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def migrate(shell)
    end

    #
    # Place-holder method.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def server_config(shell)
    end

    #
    # Place-holder method.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def server_start(shell)
    end

    #
    # Place-holder method.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def server_stop(shell)
    end

    #
    # Place-holder method.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def server_restart(shell)
    end

    #
    # Place-holder method.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.5.0
    #
    def config(shell)
      server_config(shell)
    end

    #
    # Place-holder method.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.5.0
    #
    def start(shell)
      server_start(shell)
    end

    #
    # Place-holder method.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.5.0
    #
    def stop(shell)
      server_stop(shell)
    end

    #
    # Place-holder method.
    #
    # @param [Shell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.5.0
    #
    def restart(shell)
      server_restart(shell)
    end

    #
    # Invokes a task.
    #
    # @param [Symbol] task
    #   The name of the task to run.
    #
    # @param [Shell] shell
    #   The shell to run the task in.
    #
    # @raise [RuntimeError]
    #   The task name was not known.
    #
    # @since 0.5.0
    #
    def invoke_task(task,shell)
      unless TASKS.include?(task)
        raise("invalid task: #{task}")
      end

      if @before.has_key?(task)
        @before[task].each { |command| shell.run(command) }
      end

      send(task,shell) if respond_to?(task)

      if @after.has_key?(task)
        @after[task].each { |command| shell.run(command) }
      end
    end

    #
    # Deploys the project.
    #
    # @param [Array<Symbol>] tasks
    #   The tasks to run during the deployment.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.4.0
    #
    def invoke(tasks)
      remote_shell do |shell|
        # setup the deployment repository
        invoke_task(:setup,shell) if tasks.include?(:setup)

        # cd into the deployment repository
        shell.cd(shell.uri.path)

        # update the deployment repository
        invoke_task(:update,shell) if tasks.include?(:update)

        # framework tasks
        invoke_task(:install,shell) if tasks.include?(:install)
        ivoke_task(:migrate,shell) if tasks.include?(:migrate)

        # server tasks
        if tasks.include?(:config)
          invoke_task(:config,shell)
        elsif tasks.include?(:start)
          invoke_task(:start,shell)
        elsif tasks.include?(:stop)
          invoke_task(:stop,shell)
        elsif tasks.include?(:restart)
          invoke_task(:restart,shell)
        end
      end

      return true
    end

    #
    # Sets up the deployment repository for the project.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.4.0
    #
    def setup!
      invoke [:setup]
    end

    #
    # Updates the deployed repository of the project.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.4.0
    #
    def update!
      invoke [:update]
    end

    #
    # Installs the project on the destination server.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.4.0
    #
    def install!
      invoke [:install]
    end

    #
    # Migrates the database used by the project.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.4.0
    #
    def migrate!
      invoke [:migrate]
    end

    #
    # Configures the Web server to be ran on the destination server.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.4.0
    #
    def config!
      invoke [:config]
    end

    #
    # Starts the Web server for the project.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.4.0
    #
    def start!
      invoke [:start]
    end

    #
    # Stops the Web server for the project.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.4.0
    #
    def stop!
      invoke [:stop]
    end

    #
    # Restarts the Web server for the project.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.4.0
    #
    def restart!
      invoke [:restart]
    end

    #
    # Deploys a new project.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.4.0
    #
    def deploy!
      invoke [:setup, :install, :migrate, :config, :start]
    end

    #
    # Redeploys a project.
    #
    # @return [true]
    #   Indicates that the tasks were successfully completed.
    #
    # @since 0.4.0
    #
    def redeploy!
      invoke [:update, :install, :migrate, :restart]
    end

    protected

    #
    # Loads the framework configuration.
    #
    # @since 0.3.0
    #
    def load_framework!
      if @orm
        unless FRAMEWORKS.has_key?(@framework)
          raise(UnknownFramework,"Unknown framework #{@framework}",caller)
        end

        extend FRAMEWORKS[@framework]

        initialize_framework if respond_to?(:initialize_framework)
      end
    end

    #
    # Loads the server configuration.
    #
    # @raise [UnknownServer]
    #
    # @since 0.3.0
    #
    def load_server!
      if @server_name
        unless SERVERS.has_key?(@server_name)
          raise(UnknownServer,"Unknown server name #{@server_name}",caller)
        end

        extend SERVERS[@server_name]

        initialize_server if respond_to?(:initialize_server)
      end
    end

  end
end
