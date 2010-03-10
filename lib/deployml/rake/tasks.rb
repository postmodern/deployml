require 'deployml/project'

namespace :deploy do
  task :project do
    @project = DeploYML::Project.new(Dir.pwd)

    puts "Successfully loaded #{DeploYML::Project::CONFIG_FILE}"
  end

  desc 'Downloads the project'
  task :download => :project do
    puts "Downloading project from #{@project.config.source} ..."

    @project.download!

    puts "Project downloaded."
  end

  desc 'Uploads the project'
  task :upload => :project do
    puts "Uploading project to #{@project.config.dest} ..."

    @project.upload!

    puts "Project uploaded."
  end

  task :deploy => :project do
    puts "Deploying project to #{@project.config.dest} ..."

    @project.deploy!

    puts "Project deployed."
  end
end

desc 'Deploys the project'
task :deploy => 'deploy:deploy'
