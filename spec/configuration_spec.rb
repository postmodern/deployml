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
