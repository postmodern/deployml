require 'deployml/exceptions/invalid_config'
require 'deployml/config_hash'

require 'addressable/uri'
require 'set'

module DeploYML
  #
  # The {Configuration} class loads in the settings from a `deploy.yml`
  # file.
  #
  class Configuration < ConfigHash

    # Default SCM to use
    DEFAULT_SCM = :rsync

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

      self[:scm] = (self[:scm] || DEFAULT_SCM).to_sym

      unless (self[:source] = normalize_uri(self[:source]))
        raise(InvalidConfig,":source option must contain either a Hash or a String",caller)
      end

      unless (self[:dest] = normalize_uri(self[:dest]))
        raise(InvalidConfig,":dest option must contain either a Hash or a String",caller)
      end

      self[:exclude] = Set[*self[:exclude]]
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
