require 'deployml/exceptions/missing_option'
require 'deployml/options/mongrel'

module DeploYML
  module Servers
    #
    # Provides methods for configuring, starting, stoping and restarting
    # the [Mongrel](https://github.com/fauna/mongrel) web server.
    #
    module Mongrel
      #
      # Initializes options used when calling `mongrel`.
      #
      def initialize_server
        @mongrel = Options::Mongrel.new(@server_options)
        @mongrel.environment ||= @name
      end

      #
      # Executes a command via the `mongrel_rails` command.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      # @param [Array] args
      #   Additional arguments to call `mongrel_rails` with.
      #
      def mongrel_cluster(shell,*args)
        options = args + ['-c', @mongrel.config]

        shell.run 'mongrel_rails', *options
      end

      #
      # Configures Mongrel by calling `mongrel_rails cluster::configure`.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      # @raise [MissingOption]
      #   No `config` option was listed under the `server` option in the
      #   `deploy.yml` configuration file.
      #
      def server_config(shell)
        unless @mongrel.config
          raise(MissingOption,"No 'config' option specified under server options",caller)
        end

        shell.status "Configuring Mongrel ..."

        options = ['-c', dest.path] + @mongrel.arguments
        shell.run 'mongrel_rails', 'cluster::configure', *options

        shell.status "Mongrel configured."
      end

      #
      # Starts Mongrel by calling `mongrel_rails cluster::start`.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def server_start(shell)
        shell.status "Starting Mongrel(s) ..."

        mongrel_cluster 'cluster::start'

        shell.status "Mongrel(s) started."
      end

      #
      # Stops Mongrel by calling `mongrel_rails cluster::stop`.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def server_stop(shell)
        shell.status "Stopping Mongrel(s) ..."

        mongrel_cluster 'cluster::stop'

        shell.status "Mongrel(s) stopped."
      end

      #
      # Restarts Mongrel by calling `mongrel_rails cluster::restart`.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def server_restart(shell)
        shell.status "Restarting Mongrel(s) ..."

        mongrel_cluster 'cluster::restart'

        shell.status "Mongrel(s) restarted."
      end
    end
  end
end
