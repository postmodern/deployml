module DeploYML
  module SCM
    module Rsync
      #
      # Initializes a {Project} for working with Rsync.
      #
      # @param [Hash] config
      #   Configuration information for the project.
      #
      def initialize_scm
      end

      #
      # Syncs the local copy of the project with the remote Rsync repository.
      #
      def download!
        sh 'rsync', '-a', rsync_uri(config.source), staging_dir
      end

      #
      # Updates the local copy of the project.
      #
      def update!
        sh 'rsync', '-a', '--delete-after', rsync_uri(config.source), staging_dir
      end
    end
  end
end
