require 'deployml/exceptions/invalid_config'

require 'addressable/uri'
require 'set'

module DeploYML
  #
  # The {Configuration} class loads in the settings from a `deploy.yml`
  # file.
  #
  class Configuration

    # Default SCM to use
    DEFAULT_SCM = :rsync

    # Directory name to store the local copy in
    LOCAL_COPY = '.deploy'

    # Source Code Manager to interact with
    attr_accessor :scm

    # Source of the repository
    attr_accessor :source

    # Destination to deploy to
    attr_accessor :dest

    # Debugging
    attr_accessor :debug

    # The file-path patterns to exclude from deployment
    attr_reader :exclude

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
      config = normalize_hash(config)

      @scm = (config[:scm] || DEFAULT_SCM).to_sym

      unless (@source = normalize_uri(config[:source]))
        raise(InvalidConfig,":source option must contain either a Hash or a String",caller)
      end

      unless (@dest = normalize_uri(config[:dest]))
        raise(InvalidConfig,":dest option must contain either a Hash or a String",caller)
      end

      @exclude = Set[]

      case options[:exclude]
      when Array
        @exclude += options[:exclude]
      when String
        @exclude << options[:exclude]
      end

      @debug = config[:debug]
    end

    protected

    #
    # Normalizes the keys of a Hash.
    #
    # @param [Hash] hash
    #   The un-normalized hash.
    #
    # @return [Hash{Symbol => Object}]
    #   The normalized hash.
    #
    def normalize_hash(hash)
      normalized = {}
      hash.each { |name,value| normalized[name.to_sym] = value }

      return normalized
    end

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
        Addressable::URI.new(normalize_hash(uri))
      when String
        Addressable::URI.parse(uri)
      else
        nil
      end
    end

  end
end
