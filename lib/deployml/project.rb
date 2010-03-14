require 'deployml/exceptions/config_not_found'
require 'deployml/exceptions/invalid_config'
require 'deployml/exceptions/missing_option'
require 'deployml/exceptions/unknown_server'
require 'deployml/configuration'
require 'deployml/local_shell'
require 'deployml/remote_shell'
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
    # Downloads or updates the staging directory.
    #
    def sync!
      deploy! [:sync]
    end

    #
    # Uploads the local copy of the project to the destination URI.
    #
    def upload!
      deploy! [:upload]
    end

    #
    # Migrates the database used by the project.
    #
    def migrate!
      deploy! [:migrate]
    end

    #
    # Configures the Web server to be ran on the destination server.
    #
    def config!
      deploy! [:config]
    end

    #
    # Starts the Web server for the project.
    #
    def start!
      deploy! [:start]
    end

    #
    # Stops the Web server for the project.
    #
    def stop!
      deploy! [:stop]
    end

    #
    # Restarts the Web server for the project.
    #
    def restart!
      deploy! [:restart]
    end


    #
    # Deploys the project.
    #
    # @param [Array<Symbol>] tasks
    #   The tasks to run during the deployment.
    #
    def deploy!(tasks=[:sync, :upload, :migrate, :restart])
      LocalShell.new do |shell|
        sync(shell) if tasks.include?(:sync)

        upload(shell) if tasks.include?(:upload)
      end

      session = RemoteShell.new do |shell|
        # orm tasks
        migrate(shell) if tasks.include?(:migrate)

        # server tasks
        if tasks.include?(:config)
          config(shell)
        elsif tasks.include?(:start)
          start(shell)
        elsif tasks.include?(:stop)
          stop(shell)
        elsif tasks.include?(:restart)
          restart(shell)
        end
      end

      unless session.history.empty?
        remote_sh session.join
      end
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

    #
    # Synces the project from the source server into the staging directory.
    #
    def sync(shell)
      unless File.directory?(@staging_repository.path)
        @source_repository.pull(@staging_repository.path)
      else
        @staging_repository.update(@source_repository.uri)
      end
    end

    #
    # Uploads the staged project to the destination server.
    #
    def upload(shell)
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

      shell.run 'rsync', *options
    end

    #
    # Place-holder method.
    #
    def migrate(shell)
    end

    #
    # Place-holder method.
    #
    def config(shell)
    end

    #
    # Place-holder method.
    #
    def start(shell)
    end

    #
    # Place-holder method.
    #
    def stop(shell)
    end

    #
    # Place-holder method.
    #
    def restart(shell)
    end

  end
end
