module DeploYML
  class ConfigHash < Hash

    #
    # Creates a new configuration Hash.
    #
    # @param [Hash] hash
    #   The initial hash to populate the configuration hash with.
    #
    def initialize(hash={})
      super()

      hash.each do |key,value|
        value = if value.kind_of?(Hash)
                  ConfigHash.new(value)
                else
                  value
                end

        self[key.to_sym] = value
      end
    end

    #
    # Merges another hash into the configuration hash.
    #
    # @param [Hash] other_hash
    #   The other hash to merge in.
    #
    # @return [ConfigHash]
    #   The newly merged configuration hash.
    #
    def merge!(other_hash)
      super(ConfigHash.new(other_hash))
    end

    #
    # Merges the configuration hash with another hash.
    #
    # @param [Hash] other_hash
    #   The other hash to merge with.
    #
    # @return [ConfigHash]
    #   The new configuration hash.
    #
    def merge(other_hash)
      super(ConfigHash.new(other_hash))
    end

    protected

    #
    # Provides transparent access to the configuration values.
    #
    # @param [Symbol] name
    #   The name of a possible key within the config hash.
    #
    # @param [Array] arguments
    #   Additional arguments
    #
    # @return [Object]
    #   If the method-name does match a key within the config hash, then
    #   the corresponding value is returned.
    #
    # @raise [NoMethodError]
    #
    # @example
    #   config = ConfigHash.new(
    #     'servers' => 5,
    #     'options' => {'enable' => true}
    #   )
    #   config.servers
    #   # => 5
    #   config.servers = 4
    #   config.options.enable
    #   # => true
    #
    def method_missing(name,*arguments,&block)
      unless block
        name = name.to_s

        if (arguments.length == 1) && (name[-1..-1] == '=')
          return self[name[0..-2].to_sym] = arguments[0]
        elsif arguments.empty? && has_key?(name.to_sym)
          return self[name.to_sym]
        end
      end

      super(name,*arguments,&block)
    end

  end
end
