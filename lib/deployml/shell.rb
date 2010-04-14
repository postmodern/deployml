module DeploYML
  module Shell

    def initialize(&block)
      block.call(self) if block
    end

    #
    # Place-holder method.
    #
    # @param [String] program
    #   The name or path of the program to run.
    #
    # @param [Array<String>] args
    #   Additional arguments for the program.
    #
    def run(program,*args)
    end

    #
    # Executes a Rake task.
    #
    # @param [Symbol, String] task
    #   Name of the Rake task to run.
    #
    # @param [Array<String>] args
    #   Additional arguments for the Rake task.
    #
    def rake(task,*args)
      run 'rake', rake_task(task,*args)
    end

    protected

    def rake_task(name,*args)
      name = name.to_s

      unless args.empty?
        name += ('[' + args.join(',') + ']')
      end

      return name
    end

  end
end
