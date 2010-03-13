require 'deployml/exceptions/config_not_found'
require 'deployml/exceptions/invalid_config'
require 'deployml/exceptions/missing_option'
require 'deployml/exceptions/unknown_server'
require 'deployml/configuration'
require 'deployml/servers'
require 'deployml/orms'
require 'deployml/utils'

require 'pullr'

module DeploYML
  class Project

    include Utils

    # The configuration file name.
    CONFIG_FILE = 'deploy.yml'

    # Directories to search within for the deploy.yml file.
    SEARCH_DIRS = ['config','settings']

    # The name of the directory to stage deployments in.
    STAGING_DIR = '.deploy'

    # Mapping of possible 'server' names to their mixins.
    SERVERS = {
      :apache => Servers::Apache,
      :thin => Servers::Thin
    }

    # Mapping of possible 'orm' names to their mixins.
    ORMS = {
      :active_record => ORMS::ActiveRecord,
      :data_mapper => ORMS::DataMapper
    }

    # The root directory of the project
    attr_reader :root

    # The project configuration
    attr_reader :config

    # The source repository for the project
    attr_reader :source_repository

    # The staging repository for the project
    attr_reader :staging_repository

    # The deployment repository for the project
    attr_reader :dest_repository

    #
    # Creates a new project using the given configuration file.
    #
    # @param [String] root
    #   The root directory of the project.
    #
    # @raise [ConfigNotFound]
    #   The configuration file for the project could not be found
    #   in any of the common directories.
    #
    def initialize(root)
      @root = File.expand_path(root)

      @path = SEARCH_DIRS.map { |dir|
        File.expand_path(File.join(root,dir,CONFIG_FILE))
      }.find { |path| File.file?(path) }

      unless @path
        raise(ConfigNotFound,"could not find #{CONFIG_FILE.dump} in #{root.dump}",caller)
      end

      load_config!

      @source_repository = Pullr::RemoteRepository.new(
        :uri => @config.source,
        :scm => @config.scm
      )

      @staging_repository = Pullr::LocalRepository.new(
        :uri => @config.source,
        :scm => @config.scm,
        :path => File.join(@root,STAGING_DIR)
      )

      @dest_repository = Pullr::RemoteRepository.new(
        :uri => @config.dest,
        :scm => :rsync
      )

      load_orm!

      load_server!
    end

    #
    # The URI of the source repository.
    #
    # @return [Addressable::URI]
    #   The source repository URI.
    #
    def source_uri
      @source_repository.uri
    end

    #
    # The URI of the destination repository.
    #
    # @return [Addressable::URI]
    #   The destination repository URI.
    #
    def dest_uri
      @dest_repository.uri
    end

    #
    # Downloads the projects into the staging directory.
    #
    def download!
      @source_repository.pull(@staging_repository.path)
    end

    #
    # Updates the project staging directory.
    #
    def update!
      @staging_repository.update(@config.source)
    end

    #
    # Downloads or updates the staging directory.
    #
    def sync!
      unless File.directory?(@staging_repository.path)
        download!
      else
        update!
      end
    end

    #
    # Uploads the local copy of the project to the destination URI.
    #
    def upload!
      options = rsync_options('-v', '-a', '--delete-before')
      target = rsync_uri(@dest_repository.uri)

      # add an --exclude option for the SCM directory within
      # the staging repository
      if @staging_repository.scm_dir
        options << "--exclude=#{@staging_repository.scm_dir}"
      end

      # add --exclude options
      config.exclude.each { |pattern| options << "--exclude=#{pattern}" }

      # append the source and destination arguments
      options += [File.join(@staging_repository.path,''), target]

      sh('rsync',*options)
    end

    #
    # Place-holder method for {#migrate!}.
    #
    def migrate!
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
    # Place-holder method for {#restart!}.
    #
    def restart!
    end

    #
    # Deploys the project.
    #
    def deploy!
      sync!

      upload!

      migrate!

      restart!
    end

    protected

    #
    # Loads the project configuration.
    #
    # @raise [InvalidConfig]
    #   The YAML configuration file did not contain a Hash.
    #
    # @raise [MissingOption]
    #   The `source` or `dest` options were not specified.
    #
    def load_config!
      config = YAML.load_file(@path)

      unless config.kind_of?(Hash)
        raise(InvalidConfig,"The DeploYML configuration file #{@path.dump} must contain a Hash",caller)
      end

      @config = Configuration.new(config)

      unless @config.source
        raise(MissingOption,":source option was not given in #{@path.dump}",caller)
      end

      unless @config.dest
        raise(MissingOption,":dest option was not given in #{@path.dump}",caller)
      end
    end

    #
    # Loads the ORM configuration.
    #
    def load_orm!
      if @config.orm
        unless ORMS.has_key?(@config.orm)
          raise(UnknownORM,"Unknown ORM #{@config.orm}",caller)
        end

        extend ORMS[@config.orm]

        initialize_orm() if self.respond_to?(:initialize_orm)
      end
    end

    #
    # Loads the server configuration.
    #
    # @raise [UnknownServer]
    #
    def load_server!
      if @config.server_name
        unless SERVERS.has_key?(@config.server_name)
          raise(UnknownServer,"Unknown server name #{@config.server_name}",caller)
        end

        extend SERVERS[@config.server_name]

        initialize_server() if self.respond_to?(:initialize_server)
      end
    end

  end
end
