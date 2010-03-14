module DeploYML
  module Frameworks
    module Rails3
      protected

      def after_upload(shell)
        shell.run 'bundle', 'install'
      end

      def migrate(shell)
        case config.orm
        when :datamapper
          shell.rake 'db:autoupdate'
        else
          shell.rake 'db:migrate'
        end
      end
    end
  end
end
