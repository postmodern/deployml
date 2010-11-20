module DeploYML
  module Frameworks
    module Rails2
      def migrate(shell)
        shell.run 'rake', 'db:migrate', "RAILS_ENV=#{@environment}"
      end
    end
  end
end
