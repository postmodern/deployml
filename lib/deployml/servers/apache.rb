require 'deployml/exceptions/invalid_config'

module DeploYML
  module Servers
    module Apache
      protected

      def server_start(shell)
        shell.run 'apachectl', 'start'
      end

      def server_restart(shell)
        shell.run 'apachectl', 'restart'
      end

      def server_stop(shell)
        shell.run 'apachectl', 'stop'
      end
    end
  end
end
