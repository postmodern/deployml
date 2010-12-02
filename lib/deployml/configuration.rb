require 'deployml/exceptions/missing_option'

require 'addressable/uri'

module DeploYML
  #
  # The {Configuration} class loads in the settings from a `deploy.yml`
  # file.
  #
  class Configuration

    # Default SCM to use
    DEFAULT_SCM = :rsync

    # The server run the deployed project under
    attr_reader :server_name

    # Options for the server
    attr_reader :server_options

    # The source URI of the project Git repository.
    attr_reader :source

    # The destination URI to upload the project to.
    attr_reader :dest

    # Whether the project uses Bundler.
    attr_reader :bundler

    # The framework used by the project
    attr_reader :framework

    # The ORM used by the project
    attr_reader :orm

    # The environment to run the project in
    attr_reader :environment

    # Specifies whether to enable debugging.
    attr_accessor :debug

    #
    # Creates a new {Configuration} using the given configuration.
    #
    # @param [Hash] config
    #   The configuration for the project.
    #
    # @option config [String] :source
    #   The source URI of the project Git repository.
    #
    # @option config [String, Hash] :dest
    #   The destination URI to upload the project to.
    #
    # @option config [Boolean] :bundler
    #   Specifies whether the projects dependencies are controlled by
    #   [Bundler](http://gembundler.com).
    #
    # @option config [Symbol] :framework
    #   The framework used by the project.
    #
    # @option config [Symbol] :orm
    #   The ORM used by the project.
    #
    # @option config [Symbol] :environment
    #   The environment to run the project in.
    #
    # @option config [Boolean] :debug (false)
    #   Specifies whether to enable debugging.
    #
    # @raise [MissingOption]
    #   The `server` option Hash did not contain a `name` option.
    #
    def initialize(config={})
      @source = nil
      @dest = nil

      @server_name = nil
      @server_options = {}

      @bundler = false
      @framework = nil
      @orm = nil

      @environment = nil
      @debug = false

      config = normalize_hash(config)

      @bundler = config[:bundler]

      if config[:framework]
        @framework = config[:framework].to_sym
      end

      if config[:orm]
        @orm = config[:orm].to_sym
      end

      case config[:server]
      when Symbol, String
        @server_name = config[:server].to_sym
      when Hash
        unless config[:server].has_key?(:name)
          raise(MissingOption,"the 'server' option must contain a 'name' option for which server to use",caller)
        end

        if config[:server].has_key?(:name)
          @server_name = config[:server][:name].to_sym
        end

        if config[:server].has_key?(:options)
          @server_options.merge!(config[:server][:options])
        end
      end

      @source = config[:source]
      @dest = case config[:dest]
              when Hash
                Addressable::URI.new(config[:dest])
              when String
                Addressable::URI.parse(config[:dest])
              end

      if config[:environment]
        @environment = config[:environment].to_sym
      end

      if config[:debug]
        @debug = config[:debug]
      end
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

  end
end
