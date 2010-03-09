module DeploYML
  module SCM
    module Rsync
      #
      # Initializes a {Project} for working with Rsync.
      #
      # @param [Hash] config
      #   Configuration information for the project.
      #
      def initialize(config={})
      end

      #
      # Syncs the local copy of the project with the remote Rsync repository.
      #
      def download!
        sh 'rsync', '-a', source, local_copy
      end

      #
      # Updates the local copy of the project.
      #
      def update!
        sh 'rsync', '-a', '--delete-after', source, local_copy
      end
    end
  end
end
