require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SymbolHash do
  
  it "should allow access to keys as String or Symbol" do
    h = SymbolHash.new(false)
    h['test'] = true
    h[:test].should == true
    h['test'].should == true
  end
    
  it "should #delete by key as String or Symbol" do
    h = SymbolHash.new
    h.keys.length.should == 0

    h['test'] = true
    h.keys.length.should == 1

    h.delete(:test)
    h.keys.length.should == 0

    h[:test] = true
    h.keys.length.should == 1

    h.delete('test')
    h.keys.length.should == 0
  end
  
  it "should return same #has_key? for key as String or Symbol" do
    h = SymbolHash.new
    h[:test] = 1
    h.has_key?(:test).should == true
    h.has_key?('test').should == true
  end
  
  it "should symbolize value if it is a String (and only a string)" do
    class Substring < String; end
      
    h = SymbolHash.new
    h['test1'] = "hello"
    h['test2'] = Substring.new("hello")
    h['test1'].should == :hello
    h['test2'].should == "hello"
  end 
  
  it "should not symbolize value if SymbolHash.new(false) is created" do
    h = SymbolHash.new(false)
    h['test'] = "hello"
    h[:test].should == "hello"
  end
  
  it "should not symbolize value if it is not a String" do
    h = SymbolHash.new
    h['test'] = [1,2,3]
    h['test'].should == [1,2,3]
  end
  
  it "should support symbolization using #update or #merge!" do
    h = SymbolHash.new
    h.update('test' => 'value')
    h[:test].should == :value
    h.merge!('test' => 'value2')
    h[:test].should == :value2
  end

  it "should support symbolization non-destructively using #merge" do
    h = SymbolHash.new
    h.merge('test' => 'value')[:test].should == :value
    h.should == SymbolHash.new
  end
  
  it "should support #initializing of a hash" do
    h = SymbolHash[:test => 1]
    h[:test].should == 1
    h[:somethingelse].should be_nil
  end
  
  it "should support reverse merge syntax" do
    opts = {}
    opts = SymbolHash[
      'default' => 1
    ].update(opts)
    opts.keys.should == [:default]
    opts[:default].should == 1
  end
end
