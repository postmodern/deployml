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
        shell.run 'rake', 'db:migrate', "RAILS_ENV=#{@environment}"
      end
    end
  end
end
