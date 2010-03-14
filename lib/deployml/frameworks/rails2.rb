module DeploYML
  module Frameworks
    module Rails2
      protected

      def migrate(shell)
        shell.run 'rake', 'db:migrate', "RAILS_ENV=#{config.environment}"
      end
    end
  end
end
