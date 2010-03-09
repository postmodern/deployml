module DeploYML
  module SCM
    module SubVersion
      #
      # Initializes a {Project} for working with a SubVersion SCM.
      #
      # @param [Hash] config
      #   Configuration information for the project.
      #
      def initialize(config={})
        self.exclude += ['.svn']
      end

      #
      # Makes a clone of the svn source repository as the new local copy
      # of the project.
      #
      def download!
        sh 'svn', 'checkout', source, local_copy
      end

      #
      # Updates the local copy of the project.
      #
      def update!
        cd(local_copy) do
          sh 'svn', 'update'
        end
      end
    end
  end
end
