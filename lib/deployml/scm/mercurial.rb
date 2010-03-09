module DeploYML
  module SCM
    module Mercurial
      #
      # Initializes a {Project} for working with a Mercurial SCM.
      #
      # @param [Hash] config
      #   Configuration information for the project.
      #
      def initialize(config={})
        self.exclude += ['.hg']
      end

      #
      # Makes a clone of the mercurial source repository as the new
      # local copy of the project.
      #
      def download!
        sh 'hg', 'clone', source, local_copy
      end

      #
      # Updates the local copy of the project.
      #
      def update!
        cd(local_copy) do
          sh 'hg', 'pull'
          sh 'hg', 'update', '-C'
        end
      end
    end
  end
end
