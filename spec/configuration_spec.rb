require 'spec_helper'

require 'deployml/configuration'

describe Configuration do
  it "should accept String keys" do
    config = Configuration.new('orm' => :datamapper)

    config.orm.should == :datamapper
  end

  it "should accept Symbol keys" do
    config = Configuration.new(:orm => :datamapper)

    config.orm.should == :datamapper
  end

  it "should parse 'dest' String URIs" do
    config = Configuration.new(
      :dest => 'ssh://user@www.example.com/srv/project'
    )
    dest = config.dest

    dest.scheme.should == 'ssh'
    dest.user.should == 'user'
    dest.host.should == 'www.example.com'
    dest.path.should == '/srv/project'
  end

  it "should parse 'dest' Hash URIs" do
    config = Configuration.new(:dest => {
        'scheme' => 'ssh',
        'user' => 'user',
        'host' => 'www.example.com',
        'path' => '/srv/project'
    })
    dest = config.dest

    dest.scheme.should == 'ssh'
    dest.user.should == 'user'
    dest.host.should == 'www.example.com'
    dest.path.should == '/srv/project'
  end

  it "should parse 'dest' Arrays of URIs" do
    config = Configuration.new(:dest => %w[
      ssh://deploy@dev1.example.com/var/www/project1
      ssh://deploy@dev2.example.com/var/www/project1
      ssh://deploy@dev3.example.com/var/www/project1
    ])
    dest = config.dest

    dest[0].host.should == 'dev1.example.com'
    dest[1].host.should == 'dev2.example.com'
    dest[2].host.should == 'dev3.example.com'
  end

  it "should default the 'debug' option to false" do
    config = Configuration.new

    config.debug.should == false
  end

  it "should default the environment to nil" do
    config = Configuration.new

    config.environment.should be_nil
  end

  it "should accept a Symbol for the 'server' option" do
    config = Configuration.new(:server => :thin)

    config.server_name.should == :thin
    config.server_options.should be_empty
  end

  it "should accept a Hash for the 'server' option" do
    config = Configuration.new(
      :server => {
        :name => :thin,
        :options => {:address => '127.0.0.1'}
      }
    )

    config.server_name.should == :thin
    config.server_options.should == {:address => '127.0.0.1'}
  end
end
