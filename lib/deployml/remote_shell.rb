require 'deployml/exceptions/invalid_config'
require 'deployml/shell'

require 'addressable/uri'

module DeploYML
  #
  # Represents a shell running on a remote server.
  #
  class RemoteShell < Shell

    # The history of the Remote Shell
    attr_reader :history

    #
    # Initializes a remote shell session.
    #
    # @param [Addressable::URI, String] uri
    #   The URI of the host to connect to.
    #
    # @param [Environment] environment
    #   The environment the shell is connected to.
    #
    # @yield [session]
    #   If a block is given, it will be passed the new remote shell session.
    #
    # @yieldparam [ShellSession] session
    #   The remote shell session.
    #
    def initialize(uri,environment=nil,&block)
      @history = []

      super(uri,environment,&block)

      replay if block
    end

    #
    # Enqueues a program to be ran in the session.
    #
    # @param [String] program
    #   The name or path of the program to run.
    #
    # @param [Array<String>] arguments
    #   Additional arguments for the program.
    #
    def run(program,*arguments)
      @history << [program, *arguments]
    end

    #
    # Adds a command to be executed.
    #
    # @param [String] command
    #   The command string.
    #
    # @since 0.5.2
    #
    def exec(command)
      @history << [command]
    end

    #
    # Enqueues an `echo` command to be ran in the session.
    #
    # @param [String] message
    #   The message to echo.
    #
    def echo(message)
      run 'echo', message
    end

    #
    # Enqueues a directory change for the session.
    #
    # @param [String] path
    #   The path of the new current working directory to use.
    #
    # @yield []
    #   If a block is given, then the directory will be changed back after
    #   the block has returned.
    #
    def cd(path)
      @history << ['cd', path]

      if block_given?
        yield
        @history << ['cd', '-']
      end
    end

    #
    # Joins the command history together with ` && `, to form a
    # single command.
    #
    # @return [String]
    #   A single command string.
    #
    def join
      commands = []

      @history.each do |command|
        program = command[0]
        arguments = command[1..-1].map { |word| shellescape(word.to_s) }

        commands << [program, *arguments].join(' ')
      end

      return commands.join(' && ')
    end

    #
    # Converts the URI to one compatible with SSH.
    #
    # @return [String]
    #   The SSH compatible URI.
    #
    # @raise [InvalidConfig]
    #   The URI of the shell does not have a host component.
    #
    def ssh_uri
      unless @uri.host
        raise(InvalidConfig,"URI does not have a host: #{@uri}",caller)
      end

      new_uri = @uri.host
      new_uri = "#{@uri.user}@#{new_uri}" if @uri.user

      return new_uri
    end

    #
    # Starts a SSH session with the destination server.
    #
    # @param [Array] arguments
    #   Additional arguments to pass to SSH.
    #
    def ssh(*arguments)
      options = []

      # Add the -p option if an alternate destination port is given
      if @uri.port
        options += ['-p', @uri.port.to_s]
      end

      # append the SSH URI
      options << ssh_uri

      # append the additional arguments
      arguments.each { |arg| options << arg.to_s }

      return system('ssh',*options)
    end

    #
    # Replays the command history on the remote server.
    #
    def replay
      ssh(self.join) unless @history.empty?
    end

  end
end
