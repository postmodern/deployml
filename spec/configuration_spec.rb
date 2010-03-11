require 'deployml/configuration'

require 'spec_helper'

describe Configuration do
  it "should accept String keys" do
    config = Configuration.new('scm' => :git)

    config.scm.should == :git
  end

  it "should accept Symbol keys" do
    config = Configuration.new(:scm => :git)

    config.scm.should == :git
  end

  it "should convert the 'scm' option to a Symbol" do
    config = Configuration.new(:scm => 'git')

    config.scm.should == :git
  end

  it "should accept a String for the 'source' option" do
    config = Configuration.new(:source => 'ssh://bla.com')

    config.source.scheme.should == 'ssh'
    config.source.host.should == 'bla.com'
  end

  it "should accept a Hash for the 'source' option" do
    config = Configuration.new(:source => {
      :scheme => 'ssh',
      :host => 'bla.com'
    })

    config.source.scheme.should == 'ssh'
    config.source.host.should == 'bla.com'
  end

  it "should raise InvalidConfig for bad 'source' values" do
    lambda {
      Configuration.new(:source => 1)
    }.should raise_error(InvalidConfig)
  end

  it "should accept a String for the 'dest' option" do
    config = Configuration.new(:dest => 'ssh://bla.com')

    config.dest.scheme.should == 'ssh'
    config.dest.host.should == 'bla.com'
  end

  it "should accept a Hash for the 'dest' option" do
    config = Configuration.new(:dest => {
      :scheme => 'ssh',
      :host => 'bla.com'
    })

    config.dest.scheme.should == 'ssh'
    config.dest.host.should == 'bla.com'
  end

  it "should raise InvalidConfig for bad 'dest' values" do
    lambda {
      Configuration.new(:dest => 1)
    }.should raise_error(InvalidConfig)
  end

  it "should convert the 'exclude' option to a Set" do
    config = Configuration.new(:exclude => ['.git'])

    config.exclude.should == Set['.git']
  end

  it "should default the 'debug' option to false" do
    config = Configuration.new

    config.debug.should == false
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
