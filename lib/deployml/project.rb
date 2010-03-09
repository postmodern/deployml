require 'deployml/exceptions/invalid_config'
require 'deployml/scm'

module DeploYML
  class Project

    # Default SCM to use
    DEFAULT_SCM = :rsync

    # Default SSH command to use
    DEFAULT_SSH = 'ssh'

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

    def initialize(config={})
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
      @ssh = (config[:ssh] || DEFAULT_SSH)
      @local_copy = File.join(Dir.pwd,LOCAL_COPY)

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

    def upload!
    end

    def deploy!
    end

    protected

    def normalize_uri(uri)
      case uri
      when Hash
        uri = Addressable::URI.new
        uri.each { |name,value| uri.send("#{name}=",value) }

        return uri
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
        return system(@ssh,target,command.dump)
      else
        return sh(program,*args)
      end
    end

    def debug(message)
      STDERR.puts ">>> #{message}" if @debug
    end

  end
end
