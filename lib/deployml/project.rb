require 'deployml/exceptions/config_not_found'
require 'deployml/exceptions/invalid_config'
require 'deployml/exceptions/missing_option'
require 'deployml/exceptions/unknown_server'
require 'deployml/exceptions/unknown_framework'
require 'deployml/configuration'
require 'deployml/local_shell'
require 'deployml/remote_shell'
require 'deployml/servers'
require 'deployml/frameworks'

require 'pullr'

module DeploYML
  class Project

    # The configuration file name.
    CONFIG_FILE = 'deploy.yml'

    # Directories to search within for the deploy.yml file.
    SEARCH_DIRS = ['config','settings']

    # The name of the directory to stage deployments in.
    STAGING_DIR = '.deploy'

    # Mapping of possible 'server' names to their mixins.
    SERVERS = {
      :apache => Servers::Apache,
      :mongrel => Servers::Mongrel,
      :thin => Servers::Thin
    }

    # Mapping of possible 'framework' names to their mixins.
    FRAMEWORKS = {
      :rails2 => Frameworks::Rails2,
      :rails3 => Frameworks::Rails3
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

      load_framework!

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
    # Creates a remote shell with the destination server.
    #
    # @yield [session]
    #   If a block is given, it will be passed the new remote shell session.
    #
    # @yieldparam [ShellSession] session
    #   The remote shell session.
    #
    # @return [RemoteShell]
    #   The remote shell session.
    #
    def remote_shell(&block)
      RemoteShell.new(dest_uri,&block)
    end

    #
    # Runs a command on the destination server, in the destination
    # directory.
    #
    # @return [true]
    #
    def exec(command)
      remote_shell { |shell| shell.run command }
      return true
    end

    #
    # Executes a Rake task on the destination server, in the destination
    # directory.
    #
    # @return [true]
    #
    def rake(task,*args)
      remote_shell { |shell| shell.rake task, *args }
      return true
    end

    #
    # Starts an SSH session with the destination server.
    #
    # @param [Array] args
    #   Additional arguments to pass to SSH.
    #
    # @return [true]
    #
    def ssh(*args)
      RemoteShell.new(dest_uri).ssh(*args)
      return true
    end

    #
    # Downloads or updates the staging directory.
    #
    def pull!
      deploy! [:pull]
    end

    #
    # Uploads the local copy of the project to the destination URI.
    #
    def upload!
      deploy! [:upload]
    end

    #
    # Installs the project on the destination server.
    #
    def install!
      deploy! [:install]
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
    # @return [true]
    #
    def deploy!(tasks=[:pull, :upload, :install, :migrate, :restart])
      LocalShell.new do |shell|
        pull(shell) if tasks.include?(:pull)

        upload(shell) if tasks.include?(:upload)
      end

      RemoteShell.new(dest_uri) do |shell|
        # framework tasks
        install(shell) if tasks.include?(:install)

        migrate(shell) if tasks.include?(:migrate)

        # server tasks
        if tasks.include?(:config)
          server_config(shell)
        elsif tasks.include?(:start)
          server_start(shell)
        elsif tasks.include?(:stop)
          server_stop(shell)
        elsif tasks.include?(:restart)
          server_restart(shell)
        end
      end

      return true
    end

    protected

    #
    # Converts a given URI to one compatible with `rsync`.
    #
    # @return [String]
    #   The `rsync` compatible URI.
    #
    def rsync_uri
      new_uri = dest_uri.host

      new_uri = "#{dest_uri.user}@#{new_uri}" if dest_uri.user
      new_uri = "#{new_uri}:#{dest_uri.path}" unless dest_uri.path.empty?

      return new_uri
    end

    #
    # Generates options for `rsync`.
    #
    # @param [Array] opts
    #   Specific options to pass to `rsync`.
    #
    # @return [Array]
    #   Options to pass to `rsync`.
    #
    def rsync_options(*opts)
      options = []

      options << '-v' if config.debug

      return options + opts
    end

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
    # Loads the framework configuration.
    #
    def load_framework!
      if @config.orm
        unless FRAMEWORKS.has_key?(@config.framework)
          raise(UnknownFramework,"Unknown framework #{@config.framework}",caller)
        end

        extend FRAMEWORKS[@config.framework]

        initialize_framework() if self.respond_to?(:initialize_framework)
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
    def pull(shell)
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

      # add an --exclude option for the SCM directory within
      # the staging repository
      if @staging_repository.scm_dir
        options << "--exclude=#{@staging_repository.scm_dir}"
      end

      # add --exclude options
      config.exclude.each { |pattern| options << "--exclude=#{pattern}" }

      src = File.join(@staging_repository.path,'')
      dest = rsync_uri

      # append the source and destination arguments
      options += [src, dest]

      shell.run 'rsync', *options
    end

    #
    # Place-holder method.
    #
    def install(shell)
    end

    #
    # Place-holder method.
    #
    def migrate(shell)
    end

    #
    # Place-holder method.
    #
    def server_config(shell)
    end

    #
    # Place-holder method.
    #
    def server_start(shell)
    end

    #
    # Place-holder method.
    #
    def server_stop(shell)
    end

    #
    # Place-holder method.
    #
    def server_restart(shell)
    end

  end
end
