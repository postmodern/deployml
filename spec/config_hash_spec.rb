require 'deployml/config_hash'

require 'spec_helper'

describe ConfigHash do
  before(:each) do
    @config = ConfigHash.new(
      :x => 1,
      'y' => 2,
      'z' => {
        :a => 1,
        'b' => 2,
        'c' => 3
      }
    )
  end

  it "should normalize keys" do
    @config[:x].should == 1
    @config[:y].should == 2
    @config['y'].should be_nil
  end

  it "should normalize sub-hashes within the ConfigHash" do
    @config[:z][:a].should == 1
    @config[:z][:b].should == 2
    @config[:z]['c'].should be_nil
  end

  it "should return a ConfigHash when merging" do
    @config.merge(:a => 1).class.should == ConfigHash
  end

  it "should normalize keys when merging a ConfigHash" do
    new_config = @config.merge(:a => 1, 'b' => 2)

    new_config[:a].should == 1
    new_config[:b].should == 2
  end

  it "should return a ConfigHash when merging into a ConfigHash" do
    @config.merge!(:a => 1)
    
    @config.class.should == ConfigHash
  end

  it "should normalize keys when merging into a ConfigHash" do
    @config.merge!(:a => 1, 'b' => 2)

    @config[:a].should == 1
    @config[:b].should == 2
  end

  it "should provide transparent fetch access to the ConfigHash" do
    @config.x.should == 1
  end

  it "should provide transparent store access to the ConfigHash" do
    @config.x = 2
    @config[:x].should == 2
  end

  it "should provide transparent fetch access to sub-hashes" do
    @config[:z].a.should == 1
  end

  it "should provide transparent store access to sub-hashes" do
    @config[:z].a = 2
    @config[:z].a.should == 2
  end

  it "should raise a NoMethodError exception when calling missing keys" do
    lambda {
      @config.xyz
    }.should raise_error(NoMethodError)
  end
end
