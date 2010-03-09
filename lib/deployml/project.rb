require 'deployml/exceptions/invalid_config'
require 'deployml/scm'

require 'addressable/uri'
require 'set'

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

    #
    # Creates a new {Project} using the given configuration.
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

      unless SCMS.has_key?(@scm)
        raise(InvalidConfig,"Unknown SCM #{@scm} given for the :scm option",caller)
      end

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
      @local_copy = File.join(Dir.pwd,LOCAL_COPY)

      extend SCMS[@scm]

      super(config)
    end

    #
    # Creates a new {Project} from a YAML configuration file.
    #
    # @param [String] path
    #   The path to the YAML configuration file.
    #
    # @return [Project]
    #   The new project.
    #
    # @raise [InvalidConfig]
    #   The YAML configuration file did not contain a Hash.
    #
    def self.from_yaml(path)
      path = path.to_s
      config = YAML.load_file(path)

      unless config.kind_of?(Hash)
        raise(InvalidConfig,"The YAML Deployr configuration file #{path.dump} must contain a Hash",caller)
      end

      return self.new(config)
    end

    #
    # Place-holder download method.
    #
    def download!
    end

    #
    # Place-holder update method.
    #
    def update!
    end

    #
    # Uploads the local copy of the project to the destination URI.
    #
    def upload!
      options = ['-a', '--delete-before']

      # add --exclude options
      @exclude.each { |pattern| options << "--exclude=#{pattern}" }

      sh('rsync',*options,local_copy,@dest)
    end

    #
    # Deploys the project.
    #
    def deploy!
      unless File.directory?(local_copy)
        download!
      else
        update!
      end

      upload!
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

    #
    # Changes directories.
    #
    # @param [String] path
    #   Path to the new directory.
    #
    # @yield []
    #   If a block is given, then the directory will only be changed
    #   temporarily, then changed back after the block has finished.
    #
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

    #
    # Runs a program locally.
    #
    # @param [String] program
    #   The name or path of the program to run.
    #
    # @param [Array] args
    #   The additional arguments to run with the program.
    #
    def sh(program,*args)
      debug "#{program} #{args.join(' ')}"

      return system(program,*args)
    end

    #
    # Runs a program remotely on the destination server.
    #
    # @param [String] program
    #   The name or path of the program to run.
    #
    # @param [Array] args
    #   The additional arguments to run with the program.
    #
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

    #
    # Prints a debugging message, only if {#debug} is enabled.
    #
    # @param [String] message
    #   The message to print.
    #
    def debug(message)
      STDERR.puts ">>> #{message}" if @debug
    end

  end
end
