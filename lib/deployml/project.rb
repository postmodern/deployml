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

    def initialize_scm
      unless SCMS.has_key?(config.scm)
        raise(InvalidConfig,"Unknown SCM #{config.scm} given for the :scm option",caller)
      end

      extend SCMS[config.scm]

      super()
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
