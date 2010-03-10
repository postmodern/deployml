module DeploYML
  module SCM
    module Git
      #
      # Initializes a {Project} for working with a Git SCM.
      #
      # @param [Hash] config
      #   Configuration information for the project.
      #
      def initialize_scm
        self.config.exclude += ['.git', '.gitignore']
      end

      #
      # Makes a clone of the git source repository as the new local copy
      # of the project.
      #
      def download!
        sh 'git', 'clone', source, staging_dir
      end

      #
      # Updates the local copy of the project.
      #
      def update!
        cd(staging_dir) do
          sh 'git', 'reset', '--hard', 'HEAD'
          sh 'git', 'pull'
        end
      end
    end
  end
end
