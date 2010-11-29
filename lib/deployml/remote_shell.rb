require 'deployml/shell'

require 'addressable/uri'
require 'shellwords'

module DeploYML
  #
  # Represents a shell running on a remote server.
  #
  class RemoteShell

    include Shell
    include Shellwords

    # The URI of the remote shell
    attr_reader :uri

    #
    # Initializes a remote shell session.
    #
    # @param [Addressable::URI, String] uri
    #   The URI of the host to connect to.
    #
    # @yield [session]
    #   If a block is given, it will be passed the new remote shell session.
    #
    # @yieldparam [ShellSession] session
    #   The remote shell session.
    #
    def initialize(uri,&block)
      case uri
      when Addressable::URI
        @uri = uri
      else
        @uri = Addressable::URI.parse(uri.to_s)
      end

      @history = []

      super(&block)

      replay if block
    end

    #
    # Enqueues a program to be ran in the session.
    #
    # @param [String] program
    #   The name or path of the program to run.
    #
    # @param [Array<String>] args
    #   Additional arguments for the program.
    #
    def run(program,*args)
      @history << [program, *args]
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
    def cd(path,&block)
      @history << ['cd', path]

      if block
        block.call() if block

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
      @history.map { |command|
        command.map { |word| shellescape(word) }.join(' ')
      }.join(' && ')
    end

    #
    # Converts the URI to one compatible with SSH.
    #
    # @return [String]
    #   The SSH compatible URI.
    #
    def ssh_uri
      new_uri = @uri.host
      new_uri = "#{@uri.user}@#{new_uri}" if @uri.user

      return new_uri
    end

    #
    # Starts a SSH session with the destination server.
    #
    # @param [Array] args
    #   Additional arguments to pass to SSH.
    #
    def ssh(*args)
      options = []

      # Add the -p option if an alternate destination port is given
      if @uri.port
        options += ['-p', @uri.port.to_s]
      end

      options << ssh_uri
      options += args

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
