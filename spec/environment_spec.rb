require 'spec_helper'

require 'deployml/project'

describe Environment do
  let(:name) { :staging }
  subject do
    Environment.new(name, {
      'source' => 'git@github.com:user/project.git',
      'dest' => 'ssh://user@www.example.com/srv/project',
      'framework' => 'rails3',
      'orm' => 'datamapper',
      'server' => {
        'name' => 'thin',
        'options' => {
          'config' => '/etc/thin/project.yml',
          'socket' => '/tmp/thin.project.sock'
        }
      }
    })
  end

  it "should default 'environment' to the name of the environment" do
    subject.environment.should == name
  end

  it "should include the framework mixin" do
    subject.should be_kind_of(Frameworks::Rails3)
  end

  it "should include the server mixin" do
    subject.should be_kind_of(Servers::Thin)
  end
end
