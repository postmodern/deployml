module DeploYML
  module ORMS
    module ActiveRecord
      #
      # Migrates the database on the deploy server.
      #
      def migrate!
        remote_task 'db:migrate'
      end
    end
  end
end
