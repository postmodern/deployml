require 'deployml/exceptions/invalid_config'
require 'deployml/exceptions/unknown_scm'
require 'deployml/configuration'
require 'deployml/utils'
require 'deployml/scm'
require 'deployml/servers'

module DeploYML
  class Project

    include Utils

    # The configuration file name.
    CONFIG_FILE = 'deploy.yml'

    # Directories to search within for the deploy.yml file.
    SEARCH_DIRS = ['config','settings']

    # The name of the directory to stage deployments in.
    STAGING_DIR = '.deploy'

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

    # Mapping of possible :server names to their Server handler classes.
    SERVERS = {
      :apache => Servers::Apache,
      :thin => Servers::Thin
    }

    # The root directory of the project
    attr_reader :root

    # The staging directory for deploying the project
    attr_reader :staging_dir

    # The project configuration
    attr_reader :config

    #
    # Creates a new project using the given configuration file.
    #
    # @param [String] root
    #   The root directory of the project.
    #
    def initialize(root)
      @root = File.expand_path(root)
      @staging_dir = File.join(@root,STAGING_DIR)

      @path = SEARCH_DIRS.map { |dir|
        File.expand_path(File.join(root,dir,CONFIG_FILE))
      }.find { |path| File.file?(path) }

      unless @path
        raise(InvalidConfig,"could not find #{CONFIG_FILE.dump} in #{root.dump}",caller)
      end

      load_config!

      unless @config.source
        raise(InvalidConfig,"The :source option was not specified in #{@path.dump}",caller)
      end

      unless @config.dest
        raise(InvalidConfig,"The :dest option was not specified in #{@path.dump}",caller)
      end

      load_scm!

      load_server!
    end

    #
    # Place-holder method for {#download!}.
    #
    def download!
    end

    #
    # Place-holder method for {#update!}.
    #
    def update!
    end

    #
    # Uploads the local copy of the project to the destination URI.
    #
    def upload!
      options = rsync_options('-v', '-a', '--delete-before')
      target = rsync_uri(config.dest)

      # add --exclude options
      config.exclude.each { |pattern| options << "--exclude=#{pattern}" }

      # append the source and destination arguments
      options += [File.join(@staging_dir,''), target]

      sh('rsync',*options)
    end

    #
    # Place-holder method for {#config!}.
    #
    def config!
    end

    #
    # Place-holder method for {#start!}.
    #
    def start!
    end

    #
    # Place-holder method for {#stop!}.
    #
    def stop!
    end

    #
    # Deploys the project.
    #
    def deploy!
      unless File.directory?(@staging_dir)
        download!
      else
        update!
      end

      upload!
    end

    protected

    def load_config!
      config = YAML.load_file(@path)

      unless config.kind_of?(Hash)
        raise(InvalidConfig,"The DeploYML configuration file #{@path.dump} must contain a Hash",caller)
      end

      @config = Configuration.new(config)

      unless @config.source
        raise(InvalidConfig,":source option was not given in #{@path.dump}",caller)
      end

      unless @config.dest
        raise(InvalidConfig,":dest option was not given in #{@path.dump}",caller)
      end
    end

    def load_scm!
      unless SCMS.has_key?(@config.scm)
        raise(InvalidConfig,"Unknown SCM #{@config.scm} given for the :scm option in #{@path.dump}",caller)
      end

      extend SCMS[@config.scm]

      initialize_scm() if self.respond_to?(:initialize_scm)
    end

    def load_server!
      if @config.server_name
        unless SERVERS.has_key?(@config.server_name)
          raise(InvalidConfig,"Unknown Server #{@config.server_name} given under the :server option",caller)
        end

        extend SERVERS[@config.server_name]

        initialize_server() if self.respond_to?(:initialize_server)
      end
    end

  end
end
