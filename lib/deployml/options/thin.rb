require 'rprogram/task'

module DeploYML
  module Options
    class Thin < RProgram::Task

      # Default options for Thin
      DEFAULTS = {
        :environment => :production,
        :address => '127.0.0.1',
        :servers => 2
      }

      # Server options:
      long_option :flag => '--address'
      long_option :flag => '--port'
      long_option :flag => '--socket'
      long_option :flag => '--swiftiply'
      long_option :flag => '--adapter'
      long_option :flag => '--rackup'
      long_option :flag => '--chdir'
      long_option :flag => '--stats'

      # Adapter options:
      long_option :flag => '--environment'
      long_option :flag => '--prefix'

      # Daemon options:
      long_option :flag => '--daemonize'
      long_option :flag => '--log'
      long_option :flag => '--pid'
      long_option :flag => '--user'
      long_option :flag => '--group'
      long_option :flag => '--tag'

      # Cluster options:
      long_option :flag => '--servers'
      long_option :flag => '--only'
      long_option :flag => '--config'
      long_option :flag => '--all'
      long_option :flag => '--onebyone', :name => :one_by_one
      long_option :flag => '--wait'

      # Tuning options:
      long_option :flag => '--backend'
      long_option :flag => '--timeout'
      long_option :flag => '--force'
      long_option :flag => '--max-conns', :name => :max_connections
      long_option :flag => '--max-persistent-conns', :name => :max_persistant_connections
      long_option :flag => '--threaded'
      long_option :flag => '--no-epoll'

      # Common options:
      long_option :flag => '--require'
      long_option :flag => '--debug'
      long_option :flag => '--trace'
      long_option :flag => '--help'
      long_option :flag => '--version'

      #
      # Initialize the Thin options.
      #
      # @param [Hash] options
      #   The given options.
      #
      def initialize(options={})
        super(DEFAULTS.merge(options))
      end

    end
  end
end
