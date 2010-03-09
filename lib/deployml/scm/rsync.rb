module DeploYML
  module SCM
    module Rsync
      def initialize(config={})
      end

      def download!
        sh 'rsync', '-a', source, local_copy
      end

      def update!
        sh 'rsync', '-a', '--delete-after', source, local_copy
      end
    end
  end
end
