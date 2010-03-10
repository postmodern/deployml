require 'deployml/project'

namespace :deploy do
  task :project do
    @project = DeploYML::Project.new(Dir.pwd)
  end

  desc 'Downloads the project'
  task :download => :project do
    @project.download!
  end

  desc 'Uploads the project'
  task :upload => :project do
    @project.upload!
  end

  desc 'Deploys the project'
  task :deploy => :project do
    @project.deploy!
  end
end

task :deploy => 'deploy:deploy'
