require 'deployml/frameworks/rails'

module DeploYML
  module Frameworks
    module Rails3
      include Rails

      def install(shell)
        shell.run 'bundle', 'install', '--deployment'
      end

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
