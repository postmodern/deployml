require 'spec_helper'

require 'deployml/version'

describe DeploYML do
  it "should have a version" do
    @version = DeploYML.const_get('VERSION')
    @version.should_not be_nil
    @version.should_not be_empty
  end
end
