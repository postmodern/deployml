require 'deployml/project'

namespace :deploy do
  task :project do
    @project = DeploYML::Project.new(Dir.pwd)
  end

  desc 'Invokes a command on the deploy server'
  task :exec, [:command] => :project do |t,args|
    @project.exec args.command
  end

  desc 'Executes a rake task on the deploy server'
  task :task, [:name] => :project do |t,args|
    @project.rake args.name
  end

  desc 'Starts a SSH session with the deploy server'
  task :ssh => :project do
    @project.ssh
  end

  desc 'Pulls the project'
  task :pull => :project do
    puts "Pulling project from #{@project.source_uri} ..."

    @project.pull!

    puts "Project pulled."
  end

  desc 'Pushes the project'
  task :push => :project do
    puts "Pushing project to #{@project.dest_uri} ..."

    @project.push!

    puts "Project pushed."
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

  desc 'Deploys a new project'
  task :deploy => :project do
    puts "Deploying project to #{@project.dest_uri} ..."

    @project.deploy!

    puts "Project deployed."
  end

  desc 'Deploys a new project'
  task :redeploy => :project do
    puts "Redeploying project to #{@project.dest_uri} ..."

    @project.redeploy!

    puts "Project redeployed."
  end
end
