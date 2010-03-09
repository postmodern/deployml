require 'deployml/exceptions/invalid_config'

module DeploYML
  class Project

    # Default SCM to use
    DEFAULT_SCM = :rsync

    # Source Code Manager to interact with
    attr_accessor :scm

    # Source of the repository
    attr_accessor :source

    # Destination to deploy to
    attr_accessor :dest

    def initialize(options={})
      @scm = (options[:scm] || DEFAULT_SCM).to_sym

      unless (@source = normalize_uri(options[:source]))
        raise(InvalidConfig,":source option must contain either a Hash or a String",caller)
      end

      unless (@dest = normalize_uri(options[:dest]))
        raise(InvalidConfig,":dest option must contain either a Hash or a String",caller)
      end
    end

    def self.from_yaml(path)
      path = path.to_s
      options = YAML.load_file(path)

      unless options.kind_of?(Hash)
        raise(InvalidConfig,"The YAML Deployr configuration file #{path.dump} must contain a Hash",caller)
      end

      return self.new(options)
    end

    protected

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
