module DeploYML
  module SCM
    module Mercurial
      def initialize(config={})
      end

      def download!
        sh 'hg', 'clone', source, local_copy
      end

      def update!
        cd(local_copy) do
          sh 'hg', 'pull'
          sh 'hg', 'update', '-C'
        end
      end
    end
  end
end
