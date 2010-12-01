require File.dirname(__FILE__) + '/spec_helper'

describe Culerity::RemoteObjectProxy do
  describe "block_to_string method" do
    it "should return block result when result is lambda string" do
      proxy = Culerity::RemoteObjectProxy.new nil, nil
      block = lambda { "lambda { true}" }
      proxy.send(:block_to_string, &block).should == "lambda { true}"
    end
    
    it "should replace newlines in lambda string with semicolons so that the server can parse it as one command" do
      proxy = Culerity::RemoteObjectProxy.new nil, nil
      block = lambda { "lambda { \ntrue\n}" }
      proxy.send(:block_to_string, &block).should == "lambda { ;true;}"
    end

    it "should accept do end in lambda string instead of {}" do
      code = <<-CODE
        lambda do |page, message|
          true
        end
      CODE
      
      proxy = Culerity::RemoteObjectProxy.new nil, nil
      block = lambda { code }
      proxy.send(:block_to_string, &block).should == "lambda do |page, message|;          true;        end"
    end
    
    it "should return lambda string when block result isn't a lambda string" do
      proxy = Culerity::RemoteObjectProxy.new nil, nil
      [true, false, "blah", 5].each do |var|
        block = lambda { var }
        proxy.send(:block_to_string, &block).should == "lambda { #{var} }"
      end
    end
  end
  
  it "should send the serialized method call to the output" do
    io = stub 'io', :gets => '[:return]'
    io.should_receive(:<<).with(%Q{[[345, "goto", "/homepage"]]\n})
    proxy = Culerity::RemoteObjectProxy.new 345, io
    proxy.goto '/homepage'
  end
  
  it "should send the serialized method call with a proc argument to the output" do
    io = stub 'io', :gets => "[:return]"
    io.should_receive(:<<).with(%Q{[[345, "method", true, lambda { true }]]\n})
    proxy = Culerity::RemoteObjectProxy.new 345, io
    
    proxy.send_remote(:method, true, lambda{true})
  end
  
  it "should send the serialized method call and a block to the output" do
    io = stub 'io', :gets => "[:return]"
    io.should_receive(:<<).with(%Q{[[345, "method"], lambda { true }]\n})
    proxy = Culerity::RemoteObjectProxy.new 345, io
    
    proxy.send_remote(:method) { "lambda { true }" }
  end
  
  it "should return the deserialized return value" do
    io = stub 'io', :gets => "[:return, :okay]\n", :<< => nil
    proxy = Culerity::RemoteObjectProxy.new 345, io
    proxy.goto.should == :okay
  end
  
  it "should raise the received exception" do
    io = stub 'io', :gets => %Q{[:exception, "RuntimeError", "test exception", []]}, :<< => nil
    proxy = Culerity::RemoteObjectProxy.new 345, io
    lambda {
      proxy.goto '/home'
    }.should raise_error(Culerity::CulerityException)
  end
  
  it "should send exit" do
    io = stub 'io', :gets => '[:return]'
    io.should_receive(:<<).with('["_exit_"]')
    proxy = Culerity::RemoteObjectProxy.new 345, io
    proxy.exit
  end
end