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
        shell.status "Starting Apache ..."

        shell.run 'apachectl', 'start'

        shell.status "Apache started."
      end

      #
      # Restarts Apache using the `apachectl restart` command.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def server_restart(shell)
        shell.status "Restarting Apache ..."

        shell.run 'apachectl', 'restart'

        shell.status "Apache restarted."
      end

      #
      # Stops Apache using the `apachectl stop` command.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def server_stop(shell)
        shell.status "Stopping Apache ..."

        shell.run 'apachectl', 'stop'

        shell.status "Apache stoped."
      end
    end
  end
end
