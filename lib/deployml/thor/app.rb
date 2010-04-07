require 'deployml/project'

require 'thor'
require 'pathname'

module DeploYML
  module Thor
    class App < ::Thor

      namespace 'deploy'

      desc 'exec', 'Runs a command on the deploy server'
      def exec(command)
        project.exec(command)
      end

      desc 'rake', 'Executes a rake task on the deploy server'
      method_options :args => :array
      def rake(task)
        project.rake(task,*(options[:args]))
      end

      desc 'ssh', 'Starts a SSH session with the deploy server'
      def ssh
        project.ssh
      end

      desc 'pull', 'Synches the project'
      def pull
        project.pull!
      end

      desc 'push', 'Uploads the project'
      def push
        project.push!
      end

      desc 'install', 'Installs the project on the deploy server'
      def install
        project.install!
      end

      desc 'migrate', 'Migrates the database for the project'
      def migrate
        project.migrate!
      end

      desc 'config', 'Configures the server for the project'
      def config
        project.config!
      end

      desc 'start', 'Starts the server for the project'
      def start
        project.start!
      end

      desc 'stop', 'Stops the server for the project'
      def stop
        project.stop!
      end

      desc 'restart', 'Restarts the server for the project'
      def restart
        project.restart!
      end

      desc 'deploy', 'Deploys a new project'
      def deploy
        project.deploy!
      end

      desc 'redeploy', 'Redeploys the project'
      def redeploy
        project.redeploy!
      end

      protected

      #
      # Finds the root of the project, starting at the current working
      # directory and ascending upwards.
      #
      # @return [Pathname]
      #   The root of the project.
      #
      # @since 0.2.0
      #
      def find_root
        Pathname.pwd.ascend do |root|
          Project::SEARCH_DIRS.each do |config_dir|
            config_path = root.join(config_dir,Project::CONFIG_FILE)

            return root if config_path.file?
          end
        end

        shell.say "Could not find #{Project::CONFIG_FILE} in any parent directories", :red
        exit -1
      end

      #
      # The project.
      #
      # @return [Project]
      #   The project object.
      #
      # @since 0.2.0
      #
      def project
        @project ||= Project.new(find_root)
      end

    end
  end
end
