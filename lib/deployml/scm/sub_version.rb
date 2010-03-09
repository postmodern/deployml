module DeploYML
  module SCM
    module SubVersion
      def initialize(config={})
      end

      def download!
        sh 'svn', 'checkout', source, local_copy
      end

      def update!
        cd(local_copy) do
          sh 'svn', 'update'
        end
      end
    end
  end
end
