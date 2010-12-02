require 'deployml/frameworks/rails'

module DeploYML
  module Frameworks
    #
    # Provides methods for deploying Rails 3 projects.
    #
    module Rails3
      include Rails

      #
      # Installs any dependencies using `bundle install --deployment`.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def install(shell)
        shell.status "Bundling dependencies ..."

        shell.run 'bundle', 'install', '--deployment'

        shell.status "Dependencies bundled."
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
          shell.run 'rake', 'db:autoupgrade', "RAILS_ENV=#{@environment}"
        else
          shell.status "Running ActiveRecord migrations ..."
          shell.run 'rake', 'db:migrate', "RAILS_ENV=#{@environment}"
        end

        shell.status "Database migrated."
      end
    end
  end
end
