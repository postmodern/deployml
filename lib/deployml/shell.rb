require 'thor/shell/color'
require 'shellwords'

module DeploYML
  #
  # Provides common methods used by both {LocalShell} and {RemoteShell}.
  #
  class Shell

    include Thor::Shell
    include Shellwords

    # The URI of the Shell.
    attr_reader :uri

    #
    # Initializes a shell session.
    #
    # @param [Addressable::URI, String] uri
    #   The URI of the shell.
    #
    # @yield [session]
    #   If a block is given, it will be passed the new shell session.
    #
    # @yieldparam [ShellSession] session
    #   The shell session.
    #
    def initialize(uri)
      @uri = uri

      if block_given?
        status "Entered #{@uri}."
        yield self
        status "Leaving #{@uri} ..."
      end
    end

    #
    # Place holder method.
    #
    # @since 0.5.0
    #
    def run(program,*arguments)
    end

    #
    # Place holder method.
    #
    # @param [String] command
    #   The command to execute.
    #
    # @since 0.5.0
    #
    def exec(command)
    end

    #
    # Place holder method.
    #
    # @since 0.5.0
    #
    def echo(message)
    end

    #
    # Executes a Rake task.
    #
    # @param [Symbol, String] task
    #   Name of the Rake task to run.
    #
    # @param [Array<String>] arguments
    #   Additional arguments for the Rake task.
    #
    def rake(task,*arguments)
      run 'rake', rake_task(task,*arguments)
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
    # @param [Array] arguments
    #   Additional arguments to pass to the `rake` task.
    #
    # @param [String]
    #   The `rake` task name to be called.
    #
    def rake_task(name,*arguments)
      name = name.to_s

      unless arguments.empty?
        name += ('[' + arguments.join(',') + ']')
      end

      return name
    end

  end
end
