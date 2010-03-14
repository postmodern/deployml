module DeploYML
  module Frameworks
    module Rails3
      protected

      def install(shell)
        shell.run 'bundle', 'install'
      end

      def migrate(shell)
        case config.orm
        when :datamapper
          shell.rake 'db:autoupgrade'
        else
          shell.rake 'db:migrate'
        end
      end
    end
  end
end
