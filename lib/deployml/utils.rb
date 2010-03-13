module DeploYML
  module Utils
    #
    # Converts a given URI to one compatible with `ssh`.
    #
    # @param [Addressable::URI] uri
    #   The URI to convert.
    #
    # @return [String]
    #   The `ssh` compatible URI.
    #
    def ssh_uri(uri)
      new_uri = uri.host

      new_uri = "#{uri.user}@#{new_uri}" if uri.user

      return new_uri
    end

    #
    # Converts a given URI to one compatible with `rsync`.
    #
    # @param [Addressable::URI] uri
    #   The URI to convert.
    #
    # @return [String]
    #   The `rsync` compatible URI.
    #
    def rsync_uri(uri)
      new_uri = uri.host

      new_uri = "#{uri.user}@#{new_uri}" if uri.user
      new_uri = "#{new_uri}:#{uri.path}" unless uri.path.empty?

      return new_uri
    end

    #
    # Generates options for `ssh`.
    #
    # @param [Array] opts
    #   Specific options to pass to `ssh`.
    #
    # @return [Array]
    #   Options to pass to `ssh`.
    #
    def ssh_options(*opts)
      options = []

      options << '-v' if config.debug

      return options + opts
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
    # Changes directories.
    #
    # @param [String] path
    #   Path to the new directory.
    #
    # @yield []
    #   If a block is given, then the directory will only be changed
    #   temporarily, then changed back after the block has finished.
    #
    def cd(path,&block)
      if block
        pwd = Dir.pwd
        Dir.chdir(path)

        block.call()

        Dir.chdir(pwd)
      else
        Dir.chdir(path)
      end
    end

    #
    # Runs a program locally.
    #
    # @param [String] program
    #   The name or path of the program to run.
    #
    # @param [Array] args
    #   The additional arguments to run with the program.
    #
    def sh(program,*args)
      debug "#{program} #{args.join(' ')}"

      return system(program,*args)
    end

    #
    # Starts a SSH session with the destination server.
    #
    # @param [Array] commands
    #   Commands to run within the SSH session.
    #
    def ssh(*commands)
      if dest_uri.path
        commands = ["cd #{dest_uri.path}"] + commands
      end

      options = ssh_options()

      # Add the -p option if an alternate destination port is given
      if dest_uri.port
        options += ['-p', dest_uri.port.to_s]
      end

      options << ssh_uri(dest_uri)
      options << commands.join(' && ')

      return system('ssh',*options)
    end

    #
    # Runs a program remotely on the destination server.
    #
    # @param [String] program
    #   The name or path of the program to run.
    #
    # @param [Array] args
    #   The additional arguments to run with the program.
    #
    def remote_sh(program,*args)
      if dest_uri.host
        command = [program, *args].join(' ')

        debug "[#{dest_uri.host}] #{command}"
        return ssh(command)
      else
        return sh(program,*args)
      end
    end

    #
    # Executes a Rake task on the deployment server.
    #
    # @param [String, Symbol] name
    #   The rake task to run.
    #
    # @param [Array] args
    #   Additional arguments to pass to the rake task.
    #
    def remote_task(name,*args)
      name = name.to_s

      unless args.empty?
        name << ('[' + args.join(',') + ']')
      end

      options = [name]
      options << '--trace' if config.debug

      remote_ssh('rake',*options)
    end

    #
    # Prints a debugging message, only if {#debug} is enabled.
    #
    # @param [String] message
    #   The message to print.
    #
    def debug(message)
      STDERR.puts "[debug] #{message}" if config.debug
    end
  end
end
