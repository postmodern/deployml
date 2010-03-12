require 'deployml/exceptions/invalid_config'
require 'deployml/options/thin'

module DeploYML
  module Servers
    module Thin
      def initialize_server
        @thin = Options::Thin.new(config.server_options)
      end

      def config!
        unless @thin.config
          raise(InvalidConfig,"No :config option specified under :thin",caller)
        end

        options = ['-c', dest_uri.path, *(@thin.arguments)]

        remote_sh 'thin', 'config', *options
      end

      def start!
        remote_thin 'start'
      end

      def stop!
        remote_thin 'stop'
      end

      def restart!
        remote_thin 'restart'
      end

      protected

      def remote_thin(*args)
        options = args + ['-C', @thin.config, '-s', @thin.servers]

        remote_sh 'thin', *options
      end
    end
  end
end
