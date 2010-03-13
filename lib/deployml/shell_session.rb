module DeploYML
  class ShellSession

    #
    # Initializes a new shell session.
    #
    # @param [Array] commands
    #   Initial commands for the session.
    #
    # @yield [session]
    #   If a block is given, it will be passed the new shell session.
    #
    # @yieldparam [ShellSession] session
    #   The shell session.
    #
    def initialize(*commands,&block)
      @commands = [*commands]

      block.call(self) if block
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
      @commands << [progra, *args]
    end

    #
    # Enqueues an `echo` command to be ran in the session.
    #
    # @param [String] message
    #   The message to echo.
    #
    def each(message)
      run('echo',message)
    end

    #
    # Enqueues a Rake task to be ran in the session.
    #
    # @param [Symbol, String] task
    #   Name of the Rake task to run.
    #
    # @param [Array<String>] args
    #   Additional arguments for the Rake task.
    #
    def rake(task,*args)
      name = task.to_s

      unless args.empty?
        name << ('[' + args.join(',') + ']')
      end

      run('rake',name)
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
      @commands << ['cd', path]

      if block
        block.call() if block

        @commands << ['cd', '-']
      end
    end

  end
end
