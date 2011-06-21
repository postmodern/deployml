module DeploYML
  module Frameworks
    #
    # Provides methods for deploying Rails projects.
    #
    module Rails
      #
      # Overrides the default `rake` method to add a `RAILS_ENV`
      # environment variable.
      #
      # @see {Environment#rake}
      #
      def rake(task,*arguments)
        arguments += ["RAILS_ENV=#{@environment}"]

        super(task,*arguments)
      end

      #
      # Migrates the database using the `db:autoupgrade` if
      # [DataMapper](http://datamapper.org) is being used, or the typical
      # `db:migrate` task.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def migrate(shell)
        case @orm
        when :datamapper
          shell.status "Running DataMapper auto-upgrades ..."
          shell.ruby 'db:autoupgrade', "RAILS_ENV=#{@environment}"
        else
          shell.status "Running ActiveRecord migrations ..."
          shell.ruby 'db:migrate', "RAILS_ENV=#{@environment}"
        end

        shell.status "Database migrated."
      end
    end
  end
end
