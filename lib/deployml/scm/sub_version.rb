module DeploYML
  module SCM
    module SubVersion
      #
      # Initializes a {Project} for working with a SubVersion SCM.
      #
      # @param [Hash] config
      #   Configuration information for the project.
      #
      def initialize_scm
        config.exclude += ['.svn']
      end

      #
      # Makes a clone of the svn source repository as the new local copy
      # of the project.
      #
      def download!
        sh 'svn', 'checkout', config.source, staging_dir
      end

      #
      # Updates the local copy of the project.
      #
      def update!
        cd(staging_dir) do
          sh 'svn', 'update'
        end
      end
    end
  end
end
