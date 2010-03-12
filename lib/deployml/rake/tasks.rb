require 'deployml/project'

namespace :deploy do
  task :project do
    @project = DeploYML::Project.new(Dir.pwd)

    puts "Successfully loaded #{DeploYML::Project::CONFIG_FILE}"
  end

  desc 'Invokes a command on the deploy server'
  task :invoke, [:command] => :project do |t,args|
    @project.remote_sh args.command
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

task :deploy => 'deploy:push'
