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

    # The original configuration Hash
    attr_reader :hash

    # The SCM that the project is stored within.
    attr_reader :scm

    # The server run the deployed project under
    attr_reader :server_name

    # Options for the server
    attr_reader :server_options

    # The source URI of the project SCM.
    attr_reader :source

    # The destination URI to upload the project to.
    attr_reader :dest

    # File-path pattern or list of patterns to exclude from deployment.
    attr_reader :exclude

    # Specifies whether to enable debugging.
    attr_reader :debug

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
    # @option config [Boolean] :debug (false)
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

      @server_name = nil
      @server_options = {}

      case config[:server]
      when Symbol, String
        @server_name = config[:server].to_sym
      when Hash
        unless config[:server].has_key?(:name)
          raise(InvalidConfig,"the :server option must contain a :name option for which server to use",caller)
        end

        @server_name = config[:server][:name]

        if config[:server].has_key?(:options)
          @server_options.merge!(config[:server][:options])
        end
      end

      @source = normalize_uri(config[:source])
      @dest = normalize_uri(config[:dest])

      @exclude = Set[]

      case config[:exclude]
      when Array, Set
        @exclude += config[:exclude]
      when String
        @exclude << config[:exclude]
      end

      @debug = (config[:debug] || false)

      @hash = config
    end

    protected

    #
    # Converts all the keys of a Hash to Symbols.
    #
    # @param [Hash{Object => Object}] hash
    #   The hash to be converted.
    #
    # @return [Hash{Symbol => Object}]
    #   The normalized Hash.
    #
    def normalize_hash(hash)
      new_hash = {}

      hash.each do |key,value|
        new_hash[key.to_sym] = if value.kind_of?(Hash)
                                 normalize_hash(value)
                               else
                                 value
                               end
      end

      return new_hash
    end

    #
    # Normalizes a given URI.
    #
    # @param [Hash, String] uri
    #   The URI to normalize.
    #
    # @return [Addressable::URI]
    #   The normalized URI.
    #
    def normalize_uri(uri)
      case uri
      when Hash
        Addressable::URI.new(uri)
      when String
        Addressable::URI.parse(uri)
      when NilClass
        nil
      else
        raise(InvalidConfig,"invalid URI #{uri.inspect}",caller)
      end
    end

  end
end
