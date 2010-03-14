require 'deployml/project'

namespace :deploy do
  task :project do
    @project = DeploYML::Project.new(Dir.pwd)

    puts "Successfully loaded #{DeploYML::Project::CONFIG_FILE}"
  end

  desc 'Invokes a command on the deploy server'
  task :invoke, [:command] => :project do |t,args|
    @project.invoke args.command
  end

  desc 'Executes a rake task on the deploy server'
  task :task, [:name] => :project do |t,args|
    @project.rake args.name
  end

  desc 'Starts a SSH session with the deploy server'
  task :ssh => :project do
    puts "Starting an SSH session with #{@project.dest_uri.host} ..."

    @project.ssh
  end

  desc 'Synches the project'
  task :sync => :project do
    puts "Syncing project from #{@project.source_uri} ..."

    @project.sync!

    puts "Project synched."
  end

  desc 'Uploads the project'
  task :upload => :project do
    puts "Uploading project to #{@project.dest_uri} ..."

    @project.upload!

    puts "Project uploaded."
  end

  desc 'Installs the project on the deploy server'
  task :install => :project do
    puts "Install project at #{@project.dest_uri} ..."

    @project.install!

    puts "Project installed."
  end

  desc 'Migrates the database for the project'
  task :migrate => :project do
    puts "Migrating database for #{@project.dest_uri} ..."

    @project.migrate!

    puts "Database migrated."
  end

  desc 'Configures the server for the project'
  task :config => :project do
    puts "Configuring project at #{@project.dest_uri} ..."

    @project.config!

    puts "Project configured."
  end

  desc 'Starts the server for the project'
  task :start => :project do
    puts "Starting server for #{@project.dest_uri} ..."

    @project.start!

    puts "Server started."
  end

  desc 'Stops the server for the project'
  task :stop => :project do
    puts "Stopping the server for #{@project.dest_uri} ..."

    @project.stop!

    puts "Server stopped."
  end

  desc 'Restarts the server for the project'
  task :restart => :project do
    puts "Restarting server for #{@project.dest_uri} ..."

    @project.restart!

    puts "Server restarted."
  end

  desc 'Deploys the project'
  task :push => :project do
    puts "Deploying project to #{@project.dest_uri} ..."

    @project.deploy!

    puts "Project deployed."
  end
end
