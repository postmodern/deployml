module DeploYML
  module Frameworks
    module Rails3
      protected

      def install(shell)
        shell.run 'bundle', 'install'
      end

      def migrate(shell)
        task = case config.orm
               when :datamapper
                 'db:autoupgrade'
               else
                 'db:migrate'
               end

        shell.run 'rake', task, "RAILS_ENV=#{config.environment}"
      end
    end
  end
end
