require 'rprogram/task'

module DeploYML
  module Options
    class Mongrel < RProgram::Task

      DEFAULTS = {
        :environment => :production,
        :address => '127.0.0.1',
        :num_servers => 2
      }

      long_option :flag => '--environment'
      long_option :flag => '--port'
      long_option :flag => '--address'
      long_option :flag => '--log'
      long_option :flag => '--pid'
      long_option :flag => '--chdir'
      long_option :flag => '--timeout'
      long_option :flag => '--throttle'
      long_option :flag => '--mime'
      long_option :flag => '--root'
      long_option :flag => '--num-procs'
      long_option :flag => '--debug'
      long_option :flag => '--script'
      long_option :flag => '--num-servers'
      long_option :flag => '--config'
      long_option :flag => '--user'
      long_option :flag => '--group'
      long_option :flag => '--prefix'
      long_option :flag => '--help'
      long_option :flag => '--version'

      #
      # Initialize the Mongrel options.
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
