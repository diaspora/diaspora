require "spec_helper"

describe "a double declaration with a block handed to:" do
  describe "should_receive" do
    it "returns the value of executing the block" do
      obj = Object.new
      obj.should_receive(:foo) { 'bar' }
      obj.foo.should eq('bar')
    end
  end

  describe "stub" do
    it "returns the value of executing the block" do
      obj = Object.new
      obj.stub(:foo) { 'bar' }
      obj.foo.should eq('bar')
    end
  end

  describe "with" do
    it "returns the value of executing the block" do
      obj = Object.new
      obj.stub(:foo).with('baz') { 'bar' }
      obj.foo('baz').should eq('bar')
    end
  end

  %w[once twice any_number_of_times ordered and_return].each do |method|
    describe method do
      it "returns the value of executing the block" do
        obj = Object.new
        obj.stub(:foo).send(method) { 'bar' }
        obj.foo.should eq('bar')
      end
    end
  end

  describe "times" do
    it "returns the value of executing the block" do
      obj = Object.new
      obj.stub(:foo).at_least(1).times { 'bar' }
      obj.foo('baz').should eq('bar')
    end
  end
end
