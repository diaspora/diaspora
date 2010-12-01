require File.dirname(__FILE__) + '/spec_helper'

describe Culerity::RemoteBrowserProxy do
  before(:each) do
    @io = stub 'io', :gets => "[:return, \"browser0\"]", :<<  => nil
  end
  
  it "should send the serialized method call to the output" do
    @io.should_receive(:<<).with("[[\"celerity\", \"new_browser\", {}]]\n").ordered
    @io.should_receive(:<<).with("[[\"browser0\", \"goto\", \"/homepage\"]]\n").ordered
    proxy = Culerity::RemoteBrowserProxy.new @io
    proxy.goto '/homepage'
  end
  
  it "should return the deserialized return value" do
    io = stub 'io', :gets => "[:return, :okay]\n", :<< => nil
    proxy = Culerity::RemoteBrowserProxy.new io
    proxy.goto.should == :okay
  end
  
  it "should send the browser options to the remote server" do
    io = stub 'io', :gets => "[:return, \"browser0\"]"
    io.should_receive(:<<).with('[["celerity", "new_browser", {:browser=>:firefox}]]' + "\n")
    proxy = Culerity::RemoteBrowserProxy.new io, {:browser => :firefox}
  end
  
  it "should timeout if wait_until takes too long" do
    proxy = Culerity::RemoteBrowserProxy.new @io
    lambda {
      proxy.wait_until(0.1) { false }
    }.should raise_error(Timeout::Error)
  end
  
  it "should return successfully when wait_until returns true" do
    proxy = Culerity::RemoteBrowserProxy.new @io
    proxy.wait_until(0.1) { true }.should == true
  end
  
  it "should timeout if wait_while takes too long" do
    proxy = Culerity::RemoteBrowserProxy.new @io
    lambda {
      proxy.wait_while(0.1) { true }
    }.should raise_error(Timeout::Error)
  end
  
  it "should return successfully when wait_while returns !true" do
    proxy = Culerity::RemoteBrowserProxy.new @io
    proxy.wait_while(0.1) { false }.should == true
  end

  it "should accept all javascript confirmation dialogs" do
    proxy = Culerity::RemoteBrowserProxy.new @io

    proxy.should_receive(:send_remote).with(:add_listener, :confirm).and_return(true)
    proxy.should_receive(:send_remote).with(:goto, "http://example.com").and_return(true)
    proxy.should_receive(:send_remote).with(:remove_listener, :confirm, an_instance_of(Proc)).and_return(true)

    proxy.confirm(true) do
      proxy.goto "http://example.com"
    end
  end

end
