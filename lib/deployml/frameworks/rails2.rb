module DeploYML
  module Frameworks
    module Rails2
      protected

      def migrate(shell)
        shell.rake 'db:migrate'
      end
    end
  end
end
