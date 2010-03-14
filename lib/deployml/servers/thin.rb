require 'deployml/exceptions/invalid_config'
require 'deployml/options/thin'

module DeploYML
  module Servers
    module Thin
      protected

      def initialize_server
        @thin = Options::Thin.new(config.server_options)
      end

      def config(shell)
        unless @thin.config
          raise(InvalidConfig,"No :config option specified under :thin",caller)
        end

        options = ['-c', dest_uri.path, *(@thin.arguments)]

        shell.run 'thin', 'config', *options
      end

      def start(shell)
        thin shell, 'start'
      end

      def stop(shell)
        thin shell, 'stop'
      end

      def restart(shell)
        thin shell, 'restart'
      end

      def thin(shell,*args)
        options = args + ['-C', @thin.config, '-s', @thin.servers]

        shell.run 'thin', *options
      end
    end
  end
end
