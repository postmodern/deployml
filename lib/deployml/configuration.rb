require 'deployml/exceptions/invalid_config'

require 'parameters'
require 'addressable/uri'
require 'set'

module DeploYML
  #
  # The {Configuration} class loads in the settings from a `deploy.yml`
  # file.
  #
  class Configuration

    include Parameters

    # Default SCM to use
    DEFAULT_SCM = :rsync

    # The SCM that the project is stored within.
    parameter :scm, :default => DEFAULT_SCM, :type => Symbol

    # The source URI of the project SCM.
    parameter :source, :type => lambda { |source|
      case source
      when Hash
        Addressable::URI.new(source)
      when String
        Addressable::URI.parse(source)
      else
        raise(InvalidConfig,":source option must contain either a Hash or a String",caller)
      end
    }

    # The destination URI to upload the project to.
    parameter :dest, :type => lambda { |dest|
      case dest
      when Hash
        Addressable::URI.new(dest)
      when String
        Addressable::URI.parse(dest)
      else
        raise(InvalidConfig,":dest option must contain either a Hash or a String",caller)
      end
    }

    # File-path pattern or list of patterns to exclude from deployment.
    parameter :exclude, :type => Set

    # Specifies whether to enable debugging.
    parameter :debug, :default => false, :type => true

    #
    # Creates a new {Configuration} using the given configuration.
    #
    # @param [Hash] config
    #   The configuration for the project.
    #
    # @option config [Symbol, String] :scm (:rsync)
    #   The SCM that the project is stored within.
    #
    # @option config [String, Hash] :source
    #   The source URI of the project SCM.
    #
    # @option config [String, Hash] :dest
    #   The destination URI to upload the project to.
    #
    # @option config [String, Array<String>] :exclude
    #   File-path pattern or list of patterns to exclude from deployment.
    #
    # @option config [Boolean] :debug
    #   Specifies whether to enable debugging.
    #
    # @raise [InvalidConfig]
    #   Either the given `:scm` option was not unrecognized, the `:source`
    #   option was not a String or Hash or the `:dest` option was not a
    #   String or Hash.
    #
    def initialize(config={})
      initialize_params(config)
    end

  end
end
