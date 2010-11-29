require 'spec_helper'
require 'deployml/remote_shell'

describe RemoteShell do
  let(:uri) { 'ssh://deploy@www.example.com/path' }

  subject { RemoteShell.new(uri) }

  it "should parse the given URI" do
    subject.uri.should be_kind_of(Addressable::URI)

    subject.uri.user.should == 'deploy'
    subject.uri.host.should == 'www.example.com'
    subject.uri.path.should == '/path'
  end

  it "should convert normal URIs to SSH URIs" do
    subject.ssh_uri.should == 'deploy@www.example.com'
  end

  it "should enqueue programs to run" do
    subject.run 'echo', 'one'
    subject.run 'echo', 'two'

    subject.history[0].should == ['echo', 'one']
    subject.history[1].should == ['echo', 'two']
  end

  it "should enqueue echo commands" do
    subject.echo 'one'
    subject.echo 'two'

    subject.history[0].should == ['echo', 'one']
    subject.history[1].should == ['echo', 'two']
  end

  it "should enqueue directory changes" do
    subject.cd '/other'

    subject.history[0].should == ['cd', '/other']
  end

  it "should enqueue temporary directory changes" do
    subject.cd '/other' do
      subject.run 'pwd'
    end

    subject.history[0].should == ['cd', '/other']
    subject.history[1].should == ['pwd']
    subject.history[2].should == ['cd', '-']
  end

  it "should join all commands together into one command" do
    subject.run 'echo', 'one'
    subject.run 'echo', 'two'

    subject.join.should == 'echo one && echo two'
  end

  it "should escape all command arguments" do
    subject.run 'the program'
    subject.run 'echo', '>>> status'

    subject.join.should == "the\\ program && echo \\>\\>\\>\\ status"
  end
end
