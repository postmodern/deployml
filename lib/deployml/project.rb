require 'deployml/exceptions/invalid_config'
require 'deployml/exceptions/unknown_scm'
require 'deployml/configuration'
require 'deployml/utils'
require 'deployml/servers'

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

    # Mapping of possible :server names to their Server handler classes.
    SERVERS = {
      :apache => Servers::Apache,
      :thin => Servers::Thin
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
    def initialize(root)
      @root = File.expand_path(root)

      @path = SEARCH_DIRS.map { |dir|
        File.expand_path(File.join(root,dir,CONFIG_FILE))
      }.find { |path| File.file?(path) }

      unless @path
        raise(InvalidConfig,"could not find #{CONFIG_FILE.dump} in #{root.dump}",caller)
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

      # add --exclude options
      config.exclude.each { |pattern| options << "--exclude=#{pattern}" }

      # append the source and destination arguments
      options += [File.join(@staging_repository.path,''), target]

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
      sync!

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
