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
        shell.say_status 'pulling', project.source_uri

        project.pull!

        shell.say_status 'pulled', project.source_uri
      end

      desc 'push', 'Uploads the project'
      def push
        shell.say_status 'pushing', project.dest_uri

        project.push!

        shell.say_status 'pushed', project.dest_uri
      end

      desc 'install', 'Installs the project on the deploy server'
      def install
        shell.say_status 'installing', project.dest_uri

        project.install!

        shell.say_status 'installed', project.dest_uri
      end

      desc 'migrate', 'Migrates the database for the project'
      def migrate
        shell.say_status 'migrating', project.dest_uri

        project.migrate!

        shell.say_status 'migrated', project.dest_uri
      end

      desc 'config', 'Configures the server for the project'
      def config
        shell.say_status 'configuring', project.dest_uri

        project.config!

        shell.say_status 'configured', project.dest_uri
      end

      desc 'start', 'Starts the server for the project'
      def start
        shell.say_status 'starting', project.dest_uri

        project.start!

        shell.say_status 'started', project.dest_uri
      end

      desc 'stop', 'Stops the server for the project'
      def stop
        shell.say_status 'stopping', project.dest_uri

        project.stop!

        shell.say_status 'stopped', project.dest_uri
      end

      desc 'restart', 'Restarts the server for the project'
      def restart
        shell.say_status 'restarting', project.dest_uri

        project.restart!

        shell.say_status 'restarted', project.dest_uri
      end

      desc 'deploy', 'Deploys a new project'
      def deploy
        shell.say_status 'deploying', project.source_uri

        project.deploy!

        shell.say_status 'deployed', project.dest_uri
      end

      desc 'redeploy', 'Redeploys the project'
      def redeploy
        shell.say_status 'redeploying', project.source_uri

        project.redeploy!

        shell.say_status 'redeployed', project.dest_uri
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
