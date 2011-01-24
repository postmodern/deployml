require 'deployml/exceptions/missing_option'
require 'deployml/options/thin'

module DeploYML
  module Servers
    #
    # Provides methods for configuring, starting, stopping and restarting
    # the [Thin](http://code.macournoyer.com/thin/) web server.
    #
    module Thin
      #
      # Initializes options used when calling `thin`.
      #
      def initialize_server
        @thin = Options::Thin.new(@server_options)
        @thin.environment ||= @name
      end

      #
      # Runs a command via the `thin` command.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      # @param [Array] args
      #   Additional arguments to call `thin` with.
      #
      def thin(shell,*args)
        options = args + ['-C', @thin.config, '-s', @thin.servers]

        shell.run 'thin', *options
      end

      #
      # Configures Thin by calling `thin config`.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      # @raise [MissingOption]
      #   No `config` option was listed under the `server` option in the
      #   `deploy.yml` configuration file.
      #
      def server_config(shell)
        unless @thin.config
          raise(MissingOption,"No 'config' option specified under the server options",caller)
        end

        shell.status "Configuring Thin ..."

        options = ['-c', dest.path] + @thin.arguments
        shell.run 'thin', 'config', *options

        shell.status "Thin configured."
      end

      #
      # Starts Thin by calling `thin start`.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def server_start(shell)
        shell.status "Starting Thin ..."

        thin shell, 'start'

        shell.status "Thin started."
      end

      #
      # Stops Thin by calling `thin stop`.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def server_stop(shell)
        shell.status "Stopping Thin ..."

        thin shell, 'stop'

        shell.status "Thin stopped."
      end

      #
      # Restarts Thin by calling `thin restart`.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def server_restart(shell)
        shell.status "Restarting Thin ..."

        thin shell, 'restart'

        shell.status "Thin restarted."
      end
    end
  end
end
