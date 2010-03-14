require 'deployml/shell'

module DeploYML
  class LocalShell

    include Shell

    #
    # Runs a program locally.
    #
    # @param [String] program
    #   The name or path of the program to run.
    #
    # @param [Array<String>] args
    #   Additional arguments for the program.
    #
    def run(program,*args)
      system(program,*args)
    end

    #
    # Prints out a message.
    #
    # @param [String] message
    #   The message to print.
    #
    def echo(message)
      puts message
    end

    #
    # Changes the current working directory.
    #
    # @param [String] path
    #   The path of the new current working directory to use.
    #
    # @yield []
    #   If a block is given, then the directory will be changed back after
    #   the block has returned.
    #
    def cd(path,&block)
      if block
        cwd = Dir.pwd

        Dir.chdir(path)
        block.call()
        Dir.chdir(cwd)
      else
        Dir.chdir(path)
      end
    end

  end
end
