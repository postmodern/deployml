require 'deployml/frameworks/rails'

module DeploYML
  module Frameworks
    #
    # Provides methods for deploying Rails 2 projects.
    #
    module Rails2
      include Rails

      #
      # Migrates the database using the `db:migrate` task.
      #
      # @param [LocalShell, RemoteShell] shell
      #   The shell to execute commands in.
      #
      def migrate(shell)
        shell.status "Migrating the ActiveRecord Database ..."

        shell.ruby 'rake', 'db:migrate', "RAILS_ENV=#{@environment}"

        shell.status "ActiveRecord Database migrated."
      end
    end
  end
end
