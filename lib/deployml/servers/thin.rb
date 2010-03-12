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
        remote_sh 'thin', 'start', '-C', @thin.config, '-s', @thin.servers
      end

      def stop!
        remote_sh 'thin', 'stop', '-C', @thin.config, '-s', @thin.servers
      end

      def restart!
        remote_sh 'thin', 'restart', '-C', @thin.config, '-s', @thin.servers
      end
    end
  end
end
