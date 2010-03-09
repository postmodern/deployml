module DeploYML
  module SCM
    module Git
      def initialize(config={})
        self.exclude += ['.git', '.gitignore']
      end

      def download!
        sh 'git', 'clone', source, local_copy
      end

      def update!
        cd(local_copy) do
          sh 'git', 'reset', '--hard', 'HEAD'
          sh 'git', 'pull'
        end
      end
    end
  end
end
