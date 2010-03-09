require 'deployml/exceptions/invalid_config'
require 'deployml/scm'

require 'addressable/uri'

module DeploYML
  class Project

    # Default SCM to use
    DEFAULT_SCM = :rsync

    # Directory name to store the local copy in
    LOCAL_COPY = '.deploy'

    # Mapping of possible :scm values to their SCM handler classes.
    SCMS = {
      :sub_version => SCM::SubVersion,
      :subversion => SCM::SubVersion,
      :svn => SCM::SubVersion,
      :hg => SCM::Mercurial,
      :mercurial => SCM::Mercurial,
      :git => SCM::Git,
      :rsync => SCM::Rsync
    }

    # Source Code Manager to interact with
    attr_accessor :scm

    # Source of the repository
    attr_accessor :source

    # Destination to deploy to
    attr_accessor :dest

    # Path to the local copy
    attr_reader :local_copy

    # Debugging
    attr_accessor :debug

    # The file-path patterns to exclude from deployment
    attr_reader :exclude

    def initialize(config={})
      config = normalize_hash(config)

      @scm = (config[:scm] || DEFAULT_SCM).to_sym

      unless SCMS.has_key?(@scm)
        raise(InvalidConfig,"Unknown SCM #{@scm} given for the :scm option",caller)
      end

      unless (@source = normalize_uri(config[:source]))
        raise(InvalidConfig,":source option must contain either a Hash or a String",caller)
      end

      unless (@dest = normalize_uri(config[:dest]))
        raise(InvalidConfig,":dest option must contain either a Hash or a String",caller)
      end

      @debug = config[:debug]
      @local_copy = File.join(Dir.pwd,LOCAL_COPY)
      @exclude = Set[]

      extend SCMS[@scm]

      super(config)
    end

    def self.from_yaml(path)
      path = path.to_s
      config = YAML.load_file(path)

      unless config.kind_of?(Hash)
        raise(InvalidConfig,"The YAML Deployr configuration file #{path.dump} must contain a Hash",caller)
      end

      return self.new(config)
    end

    def download!
    end

    def update!
    end

    def upload!
      options = ['-a', '--delete-after']

      # add --exclude options
      @exclude.each { |pattern| options << "--exclude=#{pattern}" }

      sh('rsync',*options,local_copy,@dest)
    end

    def deploy!
      unless File.directory?(local_copy)
        download!
      else
        update!
      end

      upload!
    end

    protected

    def normalize_hash(hash)
      normalized = {}
      hash.each { |name,value| normalized[name.to_sym] = value }

      return normalized
    end

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

    def cd(path,&block)
      if block
        pwd = Dir.pwd
        Dir.chdir(path)

        block.call()

        Dir.chdir(pwd)
      else
        Dir.chdir(path)
      end
    end

    def sh(program,*args)
      debug "#{program} #{args.join(' ')}"

      return system(program,*args)
    end

    def remote_sh(program,*args)
      target = @dest.host

      if target
        target = "#{@dest.user}@#{target}" if @dest.user
        target = "#{target}:#{@dest.port}" if @dest.port

        command = [program,*args].join(' ')

        debug "[#{@dest.host}] #{command}"
        return system('ssh',target,command.dump)
      else
        return sh(program,*args)
      end
    end

    def debug(message)
      STDERR.puts ">>> #{message}" if @debug
    end

  end
end
