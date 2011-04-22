require 'deployml/exceptions/missing_option'
require 'deployml/exceptions/invalid_config'

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
    # @option config [Array<String, Hash>, String, Hash] :dest
    #   The destination URI(s) to upload the project to.
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
      config = normalize_hash(config)

      @bundler = config.fetch(:bundler,false)

      @framework = if config[:framework]
                     config[:framework].to_sym
                   end

      @orm = if config[:orm]
               config[:orm].to_sym
             end

      @server_name, @server_options = parse_server(config[:server])

      @source = config[:source]
      @dest = if config[:dest]
                parse_dest(config[:dest])
              end

      @environment = if config[:environment]
                       config[:environment].to_sym
                     end

      @debug = config.fetch(:debug,false)
    end

    #
    # Iterates over each destination.
    #
    # @yield [dest]
    #   The given block will be passed each destination URI.
    #
    # @yieldparam [Addressable::URI] dest
    #   A destination URI.
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator object will be returned.
    #
    # @since 0.5.0
    #
    def each_dest(&block)
      return enum_for(:each_dest) unless block_given?

      if @dest.kind_of?(Array)
        @dest.each(&block)
      elsif @dest
        yield @dest
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

    #
    # Parses the value for the `server` setting.
    #
    # @return [Array<Symbol, Hash>]
    #   The name of the server and additional options.
    #
    # @since 0.5.0
    #
    def parse_server(server)
      name = nil
      options = {}

      case server
      when Symbol, String
        name = server.to_sym
      when Hash
        unless server.has_key?(:name)
          raise(MissingOption,"the 'server' option must contain a 'name' option for which server to use",caller)
        end

        if server.has_key?(:name)
          name = server[:name].to_sym
        end

        if server.has_key?(:options)
          options.merge!(server[:options])
        end
      end

      return [name, options]
    end

    #
    # Parses an address.
    #
    # @param [Hash, String] address
    #   The address to parse.
    #
    # @return [Addressable::URI]
    #   The parsed address.
    #
    # @since 0.5.0
    #
    def parse_address(address)
      case address
      when Hash
        Addressable::URI.new(address)
      when String
        Addressable::URI.parse(address)
      else
        raise(InvalidConfig,"invalid address: #{address.inspect}")
      end
    end

    #
    # Parses the value for the `dest` setting.
    #
    # @param [Array, Hash, String] dest
    #   The value of the `dest` setting.
    #
    # @return [Array<Addressable::URI>, Addressable::URI]
    #   The parsed `dest` value.
    #
    # @since 0.5.0
    #
    def parse_dest(dest)
      case dest
      when Array
        dest.map { |address| parse_address(address) }
      else
        parse_address(dest)
      end
    end

  end
end
