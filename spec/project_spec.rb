require 'deployml/project'

require 'spec_helper'
require 'helpers/projects'

describe Project do
  include Helpers::Projects

  it "should find deploy.yml at the top-level" do
    lambda {
      Project.new(project_dir(:one))
    }.should_not raise_error(InvalidConfig)
  end

  it "should find deploy.yml in the 'config/' directory" do
    lambda {
      Project.new(project_dir(:two))
    }.should_not raise_error(InvalidConfig)
  end

  it "should raise InvalidConfig when deploy.yml cannot be found" do
    lambda {
      Project.new(project_dir(:missing_config))
    }.should raise_error(InvalidConfig)
  end

  it "should raise InvalidConfig when deploy.yml does not contain a Hash" do
    lambda {
      Project.new(project_dir(:bad_config))
    }.should raise_error(InvalidConfig)
  end

  it "should raise InvalidConfig if :scm is not a known SCM" do
    lambda {
      Project.new(project_dir(:invalid_scm))
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
end
