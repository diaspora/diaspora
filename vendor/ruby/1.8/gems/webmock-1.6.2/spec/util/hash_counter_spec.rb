require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WebMock::Util::HashCounter do

  it "should return 0 for non existing key" do
    WebMock::Util::HashCounter.new.get(:abc).should == 0
  end

  it "should increase the returned value on every put with the same key" do
    counter = WebMock::Util::HashCounter.new
    counter.put(:abc)
    counter.get(:abc).should == 1
    counter.put(:abc)
    counter.get(:abc).should == 2
  end

  it "should only increase value for given key provided to put" do
    counter = WebMock::Util::HashCounter.new
    counter.put(:abc)
    counter.get(:abc).should == 1
    counter.get(:def).should == 0
  end

  describe "each" do
    it "should provide elements in order of the last modified" do
      counter = WebMock::Util::HashCounter.new
      counter.put(:a)
      counter.put(:b)
      counter.put(:c)
      counter.put(:b)
      counter.put(:a)
      counter.put(:d)

      elements = []
      counter.each {|k,v| elements << [k,v]}
      elements.should == [[:c, 1], [:b, 2], [:a, 2], [:d, 1]]
    end
  end
end
