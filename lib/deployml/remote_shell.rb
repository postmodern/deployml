require 'deployml/shell'

module DeploYML
  class RemoteShell

    include Shell

    # Command history of the remote shell
    attr_reader :history

    #
    # Initializes a new shell session.
    #
    # @yield [session]
    #   If a block is given, it will be passed the new shell session.
    #
    # @yieldparam [ShellSession] session
    #   The shell session.
    #
    def initialize(&block)
      @history = []

      super(&block)
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
      @history << [progra, *args]
    end

    #
    # Enqueues an `echo` command to be ran in the session.
    #
    # @param [String] message
    #   The message to echo.
    #
    def each(message)
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
    # Joins the command history together with ` && `, to form a single command.
    #
    # @return [String]
    #   A single command string.
    #
    def join
      @history.map { |command| command.join(' ') }.join(' && ')
    end

  end
end
