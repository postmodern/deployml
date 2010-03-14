module DeploYML
  module Frameworks
    module Rails2
      protected

      def migrate(shell)
        shell.run 'rake', 'db:migrate', "ENV=#{config.environment}"
      end
    end
  end
end
