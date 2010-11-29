require 'thor/shell/color'

module DeploYML
  #
  # Provides common methods used by both {LocalShell} and {RemoteShell}.
  #
  module Shell

    include Thor::Shell

    def initialize
      yield self if block_given?
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
    # Place-holder method.
    #
    # @param [String] message
    #   Message to echo.
    #
    # @since 0.4.0
    #
    def echo(message)
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

    #
    # Prints a status message.
    #
    # @param [String] message
    #   The message to print.
    #
    # @since 0.4.0
    #
    def status(message)
      echo "#{Color::GREEN}>>> #{message}#{Color::CLEAR}"
    end

    protected

    #
    # Builds a `rake` task name.
    #
    # @param [String, Symbol] name
    #   The name of the `rake` task.
    #
    # @param [Array] args
    #   Additional arguments to pass to the `rake` task.
    #
    # @param [String]
    #   The `rake` task name to be called.
    #
    def rake_task(name,*args)
      name = name.to_s

      unless args.empty?
        name += ('[' + args.join(',') + ']')
      end

      return name
    end

  end
end
