require 'deployml/exceptions/missing_option'
require 'deployml/options/mongrel'

module DeploYML
  module Servers
    module Mongrel
      protected

      def initialize_server
        @mongrel = Options::Mongrel.new(config.server_options)
        @mongrel.environment ||= config.environment
      end

      def mongrel_cluster(shell,*args)
        options = args + ['-c', @mongrel.config]

        shell.run 'mongrel_rails', *options
      end

      def server_config(shell)
        unless @mongrel.config
          raise(MissingOption,"No 'config' option specified under server options",caller)
        end

        options = ['-c', dest_uri.path] + @mongrel.arguments

        shell.run 'mongrel_rails', 'cluster::configure', *options
      end

      def server_start(shell)
        mongrel_cluster 'cluster::start'
      end

      def server_stop(shell)
        mongrel_cluster 'cluster::stop'
      end

      def server_restart(shell)
        mongrel_cluster 'cluster::restart'
      end
    end
  end
end
