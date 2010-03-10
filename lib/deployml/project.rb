require 'deployml/exceptions/invalid_config'
require 'deployml/exceptions/unknown_scm'
require 'deployml/configuration'
require 'deployml/utils'

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

    # The staging directory for deploying the project
    attr_reader :staging_dir

    # The project configuration
    attr_reader :config

    #
    # Creates a new project using the given configuration file.
    #
    # @param [String] path
    #   The path to the deployment configuration file for the project.
    #
    def initialize(path)
      unless File.file?(path)
        raise(InvalidConfig,"Could not find the DeploYML configuration file #{path.dump}",caller)
      end

      @path = File.expand_path(path)
      @staging_dir = File.join(File.dirname(@path),STAGING_DIR)

      config = YAML.load_file(@path)

      unless config.kind_of?(Hash)
        raise(InvalidConfig,"The DeploYML configuration file #{path.dump} must contain a Hash",caller)
      end

      @config = Configuration.new(config)

      initialize_scm
    end

    #
    # Initializes the SCM used for the project.
    #
    def initialize_scm
      unless SCMS.has_key?(config.scm)
        raise(InvalidConfig,"Unknown SCM #{config.scm} given for the :scm option",caller)
      end

      extend SCMS[config.scm]

      super()
    end

    #
    # Searches for the configuration file within various common directories.
    #
    # @param [String] root
    #   The project root directory to search within.
    #
    # @return [Project]
    #   The project described by the configuration file.
    #
    # @raise [InvalidConfig]
    #   The configuration file could not be found in any of the common
    #   directories.
    #
    def Project.find(root=Dir.pwd)
      path = SEARCH_DIRS.find do |dir|
        File.directory?(File.join(root,dir,CONFIG_FILE))
      end

      unless path
        raise(InvalidConfig,"could not find #{CONFIG_FILE}",caller)
      end

      return Project.new(path)
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
      options = rsync_options('-a', '--delete-before')
      target = rsync_uri(config.dest)

      # add --exclude options
      config.exclude.each { |pattern| options << "--exclude=#{pattern}" }

      sh('rsync',*options,config.@staging_dir,target)
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
