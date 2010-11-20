require 'deployml/exceptions/missing_option'
require 'deployml/options/thin'

module DeploYML
  module Servers
    module Thin
      def initialize_server
        @thin = Options::Thin.new(@server_options)
        @thin.environment ||= @name
      end

      def thin(shell,*args)
        options = args + ['-C', @thin.config, '-s', @thin.servers]

        shell.run 'thin', *options
      end

      def server_config(shell)
        unless @thin.config
          raise(MissingOption,"No 'config' option specified under the server options",caller)
        end

        options = ['-c', dest.path] + @thin.arguments

        shell.run 'thin', 'config', *options
      end

      def server_start(shell)
        thin shell, 'start'
      end

      def server_stop(shell)
        thin shell, 'stop'
      end

      def server_restart(shell)
        thin shell, 'restart'
      end
    end
  end
end
