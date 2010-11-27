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
        shell.run 'bundle', 'install', '--deployment'
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
        task = case @orm
               when :datamapper
                 'db:autoupgrade'
               else
                 'db:migrate'
               end

        shell.run 'rake', task, "RAILS_ENV=#{@environment}"
      end
    end
  end
end
