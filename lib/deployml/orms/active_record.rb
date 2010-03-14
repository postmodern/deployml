module DeploYML
  module ORMS
    module ActiveRecord
      protected

      #
      # Migrates the database on the deploy server.
      #
      def migrate(shell)
        shell.rake 'db:migrate'
      end
    end
  end
end
