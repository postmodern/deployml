require 'deployml/exceptions/invalid_config'
require 'deployml/exceptions/unknown_scm'
require 'deployml/configuration'
require 'deployml/utils'
require 'deployml/scm'

module DeploYML
  class Project

    include Utils

    # The configuration file name.
    CONFIG_FILE = 'deploy.yml'

    # Directories to search within for the deploy.yml file.
    SEARCH_DIRS = ['config','.']

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

      config = YAML.load_file(@path)

      unless config.kind_of?(Hash)
        raise(InvalidConfig,"The DeploYML configuration file #{path.dump} must contain a Hash",caller)
      end

      @config = Configuration.new(config)

      unless SCMS.has_key?(@config.scm)
        raise(InvalidConfig,"Unknown SCM #{@config.scm} given for the :scm option",caller)
      end

      extend SCMS[@config.scm]

      initialize_scm() if self.respond_to?(:initialize_scm)
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
      options = rsync_options('-v', '-a', '--delete-before')
      target = rsync_uri(config.dest)

      # add --exclude options
      config.exclude.each { |pattern| options << "--exclude=#{pattern}" }

      # append the source and destination arguments
      options += [File.join(@staging_dir,''), target]

      sh('rsync',*options)
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

  end
end
