require File.dirname(__FILE__) + '/spec_helper'

describe Culerity::CelerityServer do
  before(:each) do
    @browser = stub 'browser'
    Celerity::Browser.stub!(:new).and_return(@browser)
  end
  
  it "should pass the method call to the celerity browser" do
    @browser.should_receive(:goto).with('/homepage')
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"browser0\", \"goto\", \"/homepage\"]]\n", "[\"_exit_\"]\n")
    _out = stub 'out', :<< => nil
    Culerity::CelerityServer.new(_in, _out)
  end
  
  it "should pass procs" do
    @browser.should_receive(:remove_listener).with(:confirm, instance_of(Proc))
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"browser0\", \"remove_listener\", :confirm, lambda{true}]]\n", "[\"_exit_\"]\n")
    _out = stub 'out', :<< => nil
    Culerity::CelerityServer.new(_in, _out)
  end
  
  it "should pass blocks" do
    def @browser.add_listener(type, &block)
      @type = type
      @block = block
    end
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"browser0\", \"add_listener\", :confirm], lambda{true}]\n", "[\"_exit_\"]\n")
    _out = stub 'out', :<< => nil
    Culerity::CelerityServer.new(_in, _out)
    @browser.instance_variable_get(:@type).should == :confirm
    @browser.instance_variable_get(:@block).call.should == true
  end

  it "should return the browser id when a new browser is requested" do
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"celerity\", \"new_browser\", {}]]\n", "[\"_exit_\"]\n")
    _out = stub 'out'
    _out.should_receive(:<<).with("[:return, \"browser0\"]\n")
    Culerity::CelerityServer.new(_in, _out)
  end

  it "should create a new browser with the provided options" do
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"celerity\", \"new_browser\", {:browser => :firefox}]]\n", "[\"_exit_\"]\n")
    Celerity::Browser.should_receive(:new).with(:browser => :firefox)
    Culerity::CelerityServer.new(_in, stub.as_null_object)
  end

  it "should create multiple browsers and return the appropriate id for each" do
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"celerity\", \"new_browser\", {}]]\n", "[[\"celerity\", \"new_browser\", {}]]\n", "[\"_exit_\"]\n")
    Celerity::Browser.should_receive(:new).twice
    _out = stub 'out'
    _out.should_receive(:<<).with("[:return, \"browser0\"]\n").ordered
    _out.should_receive(:<<).with("[:return, \"browser1\"]\n").ordered
    Culerity::CelerityServer.new(_in, _out)

  end

  
  it "should send back the return value of the call" do
    @browser.stub!(:goto).and_return(true)
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"browser0\", \"goto\", \"/homepage\"]]\n", "[\"_exit_\"]\n")
    _out = stub 'out'
    _out.should_receive(:<<).with("[:return, true]\n")
    Culerity::CelerityServer.new(_in, _out)
  end
  
  it "should ignore empty inputs" do
    _in = stub 'in'
    _in.stub!(:gets).and_return("\n", "[\"_exit_\"]\n")
    _out = stub 'out'
    _out.should_not_receive(:<<)
    Culerity::CelerityServer.new(_in, _out)
  end
  
  it "should send back a symbol" do
    @browser.stub!(:goto).and_return(:ok)
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"browser0\", \"goto\"]]\n", "[\"_exit_\"]\n")
    _out = stub 'out'
    _out.should_receive(:<<).with("[:return, :ok]\n")
    Culerity::CelerityServer.new(_in, _out)
  end
  
  it "should send back a proxy if the return value is not a string, number, nil, symbol or boolean" do
    @browser.stub!(:goto).and_return(stub('123', :object_id => 456))
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"browser0\", \"goto\", \"/homepage\"]]\n", "[\"_exit_\"]\n")
    _out = stub 'out'
    _out.should_receive(:<<).with("[:return, Culerity::RemoteObjectProxy.new(456, @io)]\n")
    Culerity::CelerityServer.new(_in, _out)
  end

  it "should send back arrays" do
    @browser.stub!(:goto).and_return([true, false, "test", 1, 12.3, nil, stub('123', :object_id => 456), ["test2", 32.1, 5000, nil, false, true, stub('789', :object_id => 101)]])
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"browser0\", \"goto\", \"/homepage\"]]\n", "[\"_exit_\"]\n")
    _out = stub 'out'
    _out.should_receive(:<<).with("[:return, [true, false, \"test\", 1, 12.3, nil, Culerity::RemoteObjectProxy.new(456, @io), [\"test2\", 32.1, 5000, nil, false, true, Culerity::RemoteObjectProxy.new(101, @io)]]]\n")
    Culerity::CelerityServer.new(_in, _out)
  end
  
  it "should pass the method call to a proxy" do
    proxy = stub('123', :object_id => 456)
    @browser.stub!(:goto).and_return(proxy)
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"browser0\", \"goto\", \"/homepage\"]]\n", "[[456, \"goto_2\", \"1\"]]", "[\"_exit_\"]\n")
    _out = stub 'out', :<< => nil
    proxy.should_receive(:goto_2).with('1')
    Culerity::CelerityServer.new(_in, _out)
  end

  it "should pass multiple method calls" do
    @browser.should_receive(:goto).with('/homepage')
    @browser.should_receive(:goto).with('/page2')
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"browser0\", \"goto\", \"/homepage\"]]\n", "[[\"browser0\", \"goto\", \"/page2\"]]\n", "[\"_exit_\"]\n")
    _out = stub 'out', :<< => nil
    Culerity::CelerityServer.new(_in, _out)
  end
  
  it "should return an exception" do
    @browser.stub!(:goto).and_raise(RuntimeError.new('test exception with "quotes"'))
    _in = stub 'in'
    _in.stub!(:gets).and_return("[[\"browser0\", \"goto\", \"/homepage\"]]\n", "[\"_exit_\"]\n")
    _out = stub 'out'
    _out.should_receive(:<<).with(/^\[:exception, \"RuntimeError\", \"test exception with \\\"quotes\\\"\", \[.*\]\]\n$/)
    Culerity::CelerityServer.new(_in, _out)
  end
end
