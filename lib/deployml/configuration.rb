require 'deployml/exceptions/invalid_config'

require 'hashie'
require 'addressable/uri'
require 'set'

module DeploYML
  #
  # The {Configuration} class loads in the settings from a `deploy.yml`
  # file.
  #
  class Configuration < Hashie::Dash

    # Default SCM to use
    DEFAULT_SCM = :rsync

    property :scm, :default => DEFAULT_SCM
    property :source
    property :dest
    property :exclude, :default => Set[]
    property :debug, :default => false

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
      super(config)

      self.scm = self.scm.to_sym

      unless (self.source = normalize_uri(self.source))
        raise(InvalidConfig,":source option must contain either a Hash or a String",caller)
      end

      unless (self.dest = normalize_uri(self.dest))
        raise(InvalidConfig,":dest option must contain either a Hash or a String",caller)
      end

      self.exclude = self.exclude.to_set
    end

    protected

    #
    # Normalizes a given URI.
    #
    # @param [Hash, String] uri
    #   The un-normalized URI.
    #
    # @return [Addressable::URI, nil]
    #   The normalized URI.
    #
    def normalize_uri(uri)
      case uri
      when Hash
        Addressable::URI.new(uri)
      when String
        Addressable::URI.parse(uri)
      else
        nil
      end
    end

  end
end
