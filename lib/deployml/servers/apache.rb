require 'deployml/exceptions/invalid_config'

module DeploYML
  module Servers
    module Apache
      def start!
        remote_sh 'apachectl', 'restart'
      end

      def stop!
        remote_sh 'apachectl', 'stop'
      end
    end
  end
end
