require 'deployml/project'

namespace :deploy do
  task :project do
    @project = DeploYML::Project.new(Dir.pwd)
  end

  task :download => :project do
    @project.download!
  end

  task :upload => :project do
    @project.upload!
  end

  task :deploy => :project do
    @project.deploy!
  end
end

task :deploy => 'deploy:deploy'
