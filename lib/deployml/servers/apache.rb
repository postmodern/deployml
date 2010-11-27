require 'deployml/exceptions/invalid_config'

module DeploYML
  module Servers
    #
    # Provides methods for starting, stoping and restarting the
    # [Apache](http://httpd.apache.org/) web server.
    #
    module Apache
      #
      # Starts Apache using the `apachectl start` command.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def server_start(shell)
        shell.run 'apachectl', 'start'
      end

      #
      # Restarts Apache using the `apachectl restart` command.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def server_restart(shell)
        shell.run 'apachectl', 'restart'
      end

      #
      # Stops Apache using the `apachectl stop` command.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def server_stop(shell)
        shell.run 'apachectl', 'stop'
      end
    end
  end
end
