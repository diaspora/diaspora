require 'spec_helper'

describe "should respond_to(:sym)" do
  
  it "passes if target responds to :sym" do
    Object.new.should respond_to(:methods)
  end
  
  it "fails if target does not respond to :sym" do
    lambda {
      "this string".should respond_to(:some_method)
    }.should fail_with(%q|expected "this string" to respond to :some_method|)
  end
  
end

describe "should respond_to(:sym).with(1).argument" do
  it "passes if target responds to :sym with 1 arg" do
    obj = Object.new
    def obj.foo(arg); end
    obj.should respond_to(:foo).with(1).argument
  end

  it "passes if target responds to any number of arguments" do
    obj = Object.new
    def obj.foo(*args); end
    obj.should respond_to(:foo).with(1).argument
  end

  it "passes if target responds to one or more arguments" do
    obj = Object.new
    def obj.foo(a, *args); end
    obj.should respond_to(:foo).with(1).argument
  end
  
  it "fails if target does not respond to :sym" do
    obj = Object.new
    lambda {
      obj.should respond_to(:some_method).with(1).argument
    }.should fail_with(/expected .* to respond to :some_method/)
  end
  
  it "fails if :sym expects 0 args" do
    obj = Object.new
    def obj.foo; end
    lambda {
      obj.should respond_to(:foo).with(1).argument
    }.should fail_with(/expected #<Object.*> to respond to :foo with 1 argument/)
  end
  
  it "fails if :sym expects 2 args" do
    obj = Object.new
    def obj.foo(arg, arg2); end
    lambda {
      obj.should respond_to(:foo).with(1).argument
    }.should fail_with(/expected #<Object.*> to respond to :foo with 1 argument/)
  end

  it "fails if :sym expects 2 or more args" do
    obj = Object.new
    def obj.foo(arg, arg2, *args); end
    lambda {
      obj.should respond_to(:foo).with(1).argument
    }.should fail_with(/expected #<Object.*> to respond to :foo with 1 argument/)
  end
end

describe "should respond_to(message1, message2)" do
  
  it "passes if target responds to both messages" do
    Object.new.should respond_to('methods', 'inspect')
  end
  
  it "fails if target does not respond to first message" do
    lambda {
      Object.new.should respond_to('method_one', 'inspect')
    }.should fail_with(/expected #<Object:.*> to respond to "method_one"/)
  end
  
  it "fails if target does not respond to second message" do
    lambda {
      Object.new.should respond_to('inspect', 'method_one')
    }.should fail_with(/expected #<Object:.*> to respond to "method_one"/)
  end
  
  it "fails if target does not respond to either message" do
    lambda {
      Object.new.should respond_to('method_one', 'method_two')
    }.should fail_with(/expected #<Object:.*> to respond to "method_one", "method_two"/)
  end
end

describe "should respond_to(:sym).with(2).arguments" do
  it "passes if target responds to :sym with 2 args" do
    obj = Object.new
    def obj.foo(a1, a2); end
    obj.should respond_to(:foo).with(2).arguments
  end

  it "passes if target responds to any number of arguments" do
    obj = Object.new
    def obj.foo(*args); end
    obj.should respond_to(:foo).with(2).arguments
  end

  it "passes if target responds to one or more arguments" do
    obj = Object.new
    def obj.foo(a, *args); end
    obj.should respond_to(:foo).with(2).arguments
  end

  it "passes if target responds to two or more arguments" do
    obj = Object.new
    def obj.foo(a, b, *args); end
    obj.should respond_to(:foo).with(2).arguments
  end
  
  it "fails if target does not respond to :sym" do
    obj = Object.new
    lambda {
      obj.should respond_to(:some_method).with(2).arguments
    }.should fail_with(/expected .* to respond to :some_method/)
  end
  
  it "fails if :sym expects 0 args" do
    obj = Object.new
    def obj.foo; end
    lambda {
      obj.should respond_to(:foo).with(2).arguments
    }.should fail_with(/expected #<Object.*> to respond to :foo with 2 arguments/)
  end
  
  it "fails if :sym expects 1 args" do
    obj = Object.new
    def obj.foo(arg); end
    lambda {
      obj.should respond_to(:foo).with(2).arguments
    }.should fail_with(/expected #<Object.*> to respond to :foo with 2 arguments/)
  end

  it "fails if :sym expects 3 or more args" do
    obj = Object.new
    def obj.foo(arg, arg2, arg3, *args); end
    lambda {
      obj.should respond_to(:foo).with(2).arguments
    }.should fail_with(/expected #<Object.*> to respond to :foo with 2 arguments/)
  end
end

describe "should_not respond_to(:sym)" do
  
  it "passes if target does not respond to :sym" do
    Object.new.should_not respond_to(:some_method)
  end
  
  it "fails if target responds to :sym" do
    lambda {
      Object.new.should_not respond_to(:methods)
    }.should fail_with(/expected #<Object:.*> not to respond to :methods/)
  end
  
end

describe "should_not respond_to(:sym).with(1).argument" do
  it "fails if target responds to :sym with 1 arg" do
    obj = Object.new
    def obj.foo(arg); end
    lambda {
      obj.should_not respond_to(:foo).with(1).argument
    }.should fail_with(/expected #<Object:.*> not to respond to :foo with 1 argument/)
  end

  it "fails if target responds to :sym with any number of args" do
    obj = Object.new
    def obj.foo(*args); end
    lambda {
      obj.should_not respond_to(:foo).with(1).argument
    }.should fail_with(/expected #<Object:.*> not to respond to :foo with 1 argument/)
  end

  it "fails if target responds to :sym with one or more args" do
    obj = Object.new
    def obj.foo(a, *args); end
    lambda {
      obj.should_not respond_to(:foo).with(1).argument
    }.should fail_with(/expected #<Object:.*> not to respond to :foo with 1 argument/)
  end

  it "passes if target does not respond to :sym" do
    obj = Object.new
    obj.should_not respond_to(:some_method).with(1).argument
  end

  it "passes if :sym expects 0 args" do
    obj = Object.new
    def obj.foo; end
    obj.should_not respond_to(:foo).with(1).argument
  end

  it "passes if :sym expects 2 args" do
    obj = Object.new
    def obj.foo(arg, arg2); end
    obj.should_not respond_to(:foo).with(1).argument
  end

  it "passes if :sym expects 2 or more args" do
    obj = Object.new
    def obj.foo(arg, arg2, *args); end
    obj.should_not respond_to(:foo).with(1).argument
  end
end

describe "should_not respond_to(message1, message2)" do
  it "passes if target does not respond to either message1 or message2" do
    Object.new.should_not respond_to(:some_method, :some_other_method)
  end

  it "fails if target responds to message1 but not message2" do
    lambda {
      Object.new.should_not respond_to(:object_id, :some_method)
    }.should fail_with(/expected #<Object:.*> not to respond to :object_id/)
  end

  it "fails if target responds to message2 but not message1" do
    lambda {
      Object.new.should_not respond_to(:some_method, :object_id)
    }.should fail_with(/expected #<Object:.*> not to respond to :object_id/)
  end

  it "fails if target responds to both message1 and message2" do
    lambda {
      Object.new.should_not respond_to(:class, :object_id)
    }.should fail_with(/expected #<Object:.*> not to respond to :class, :object_id/)
  end
end

describe "should_not respond_to(:sym).with(2).arguments" do
  it "fails if target responds to :sym with 2 args" do
    obj = Object.new
    def obj.foo(a1, a2); end
    lambda {
      obj.should_not respond_to(:foo).with(2).arguments
    }.should fail_with(/expected .* not to respond to :foo with 2 arguments/)
  end

  it "fails if target responds to :sym with any number args" do
    obj = Object.new
    def obj.foo(*args); end
    lambda {
      obj.should_not respond_to(:foo).with(2).arguments
    }.should fail_with(/expected .* not to respond to :foo with 2 arguments/)
  end

  it "fails if target responds to :sym with one or more args" do
    obj = Object.new
    def obj.foo(a, *args); end
    lambda {
      obj.should_not respond_to(:foo).with(2).arguments
    }.should fail_with(/expected .* not to respond to :foo with 2 arguments/)
  end

  it "fails if target responds to :sym with two or more args" do
    obj = Object.new
    def obj.foo(a, b, *args); end
    lambda {
      obj.should_not respond_to(:foo).with(2).arguments
    }.should fail_with(/expected .* not to respond to :foo with 2 arguments/)
  end

  it "passes if target does not respond to :sym" do
    obj = Object.new
    obj.should_not respond_to(:some_method).with(2).arguments
  end

  it "passes if :sym expects 0 args" do
    obj = Object.new
    def obj.foo; end
    obj.should_not respond_to(:foo).with(2).arguments
  end

  it "passes if :sym expects 2 args" do
    obj = Object.new
    def obj.foo(arg); end
    obj.should_not respond_to(:foo).with(2).arguments
  end

  it "passes if :sym expects 3 or more args" do
    obj = Object.new
    def obj.foo(a, b, c, *arg); end
    obj.should_not respond_to(:foo).with(2).arguments
  end
end
