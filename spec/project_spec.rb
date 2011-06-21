require 'spec_helper'
require 'helpers/projects'

require 'deployml/project'

describe Project do
  include Helpers::Projects

  describe "new" do
    it "should find deploy.yml in the 'config/' directory" do
      lambda {
        Project.new(project_dir(:basic))
      }.should_not raise_error
    end

    it "should raise ConfigNotFound when deploy.yml cannot be found" do
      lambda {
        Project.new(project_dir(:missing_config))
      }.should raise_error(ConfigNotFound)
    end

    it "should raise InvalidConfig when deploy.yml does not contain a Hash" do
      lambda {
        Project.new(project_dir(:bad_config))
      }.should raise_error(InvalidConfig)
    end

    it "should raise InvalidConfig if :source is missing" do
      lambda {
        Project.new(project_dir(:missing_source))
      }.should raise_error(InvalidConfig)
    end

    it "should raise InvalidConfig if :dest is missing" do
      lambda {
        Project.new(project_dir(:missing_dest))
      }.should raise_error(InvalidConfig)
    end

    it "should raise InvalidConfig if :server is unknown" do
      lambda {
        Project.new(project_dir(:invalid_server))
      }.should raise_error(InvalidConfig)
    end

    it "should load the :production environment if thats the only env" do
      project = Project.new(project_dir(:basic))

      project.environments.keys.should == [:production]
    end

    it "should load multiple environments" do
      project = Project.new(project_dir(:rails))

      project.environments.keys.should =~ [:production, :staging]
    end

    it "should load the base config into multiple environments" do
      project = Project.new(project_dir(:rails))

      project.environments.all? { |name,env|
        env.framework == :rails && env.orm == :datamapper
      }.should == true
    end
  end
end
