require 'deployml/exceptions/missing_option'
require 'deployml/exceptions/unknown_server'
require 'deployml/exceptions/unknown_framework'
require 'deployml/configuration'
require 'deployml/local_shell'
require 'deployml/remote_shell'
require 'deployml/servers'
require 'deployml/frameworks'

module DeploYML
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
        raise(MissingOption,":source option is missing for the #{@name} environment")
      end

      unless @dest
        raise(MissingOption,":dest option is missing for the #{@name} environment")
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
    # @return [LocalShell]
    #   The local shell.
    #
    # @since 0.3.0
    #
    def local_shell(&block)
      LocalShell.new(&block)
    end

    #
    # Creates a remote shell with the destination server.
    #
    # @yield [shell]
    #   If a block is given, it will be passed the new remote shell.
    #
    # @yieldparam [RemoteShell] shell
    #   The remote shell.
    #
    # @return [RemoteShell, LocalShell]
    #   The remote shell. If the destination is a local `file://` URI,
    #   a local shell will be returned instead.
    #
    # @since 0.3.0
    #
    def remote_shell(&block)
      unless @dest.scheme == 'file'
        RemoteShell.new(@dest,&block)
      else
        LocalShell.new(&block)
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
        shell.cd(@dest.path)
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
        shell.cd(@dest.path)
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
      RemoteShell.new(@dest).ssh(*args)
      return true
    end

    #
    # Sets up the deployment repository for the project.
    #
    # @param [RemoteShell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def setup(shell)
      shell.run 'git', 'clone', '--depth', 1, @source, @dest.path
    end

    #
    # Updates the deployed repository for the project.
    #
    # @param [RemoteShell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def update(shell)
      shell.run 'git', 'reset', '--hard', 'HEAD'
      shell.run 'git', 'pull', '-f'
    end

    #
    # Place-holder method.
    #
    # @param [RemoteShell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def install(shell)
    end

    #
    # Place-holder method.
    #
    # @param [RemoteShell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def migrate(shell)
    end

    #
    # Place-holder method.
    #
    # @param [RemoteShell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def server_config(shell)
    end

    #
    # Place-holder method.
    #
    # @param [RemoteShell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def server_start(shell)
    end

    #
    # Place-holder method.
    #
    # @param [RemoteShell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def server_stop(shell)
    end

    #
    # Place-holder method.
    #
    # @param [RemoteShell] shell
    #   The remote shell to execute commands through.
    #
    # @since 0.3.0
    #
    def server_restart(shell)
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
          raise(UnknownFramework,"Unknown framework #{@framework}")
        end

        extend FRAMEWORKS[@framework]

        initialize_framework() if self.respond_to?(:initialize_framework)
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
          raise(UnknownServer,"Unknown server name #{@server_name}")
        end

        extend SERVERS[@server_name]

        initialize_server() if self.respond_to?(:initialize_server)
      end
    end

  end
end
