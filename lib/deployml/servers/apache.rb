require 'deployml/exceptions/invalid_config'

module DeploYML
  module Servers
    module Apache
      protected

      def start(shell)
        shell.run 'apachectl', 'start'
      end

      def restart(shell)
        shell.run 'apachectl', 'restart'
      end

      def stop(shell)
        shell.run 'apachectl', 'stop'
      end
    end
  end
end
