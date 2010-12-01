require 'spec_helper'

describe Hashie::Clash do
  before do
    @c = Hashie::Clash.new
  end
  
  it 'should be able to set an attribute via method_missing' do
    @c.foo('bar')
    @c[:foo].should == 'bar'
  end
  
  it 'should be able to set multiple attributes' do
    @c.foo('bar').baz('wok')
    @c.should == {:foo => 'bar', :baz => 'wok'}
  end
  
  it 'should convert multiple arguments into an array' do
    @c.foo(1, 2, 3)
    @c[:foo].should == [1,2,3]
  end
  
  it 'should be able to use bang notation to create a new Clash on a key' do
    @c.foo!
    @c[:foo].should be_kind_of(Hashie::Clash)
  end
  
  it 'should be able to chain onto the new Clash when using bang notation' do
    @c.foo!.bar('abc').baz(123)
    @c.should == {:foo => {:bar => 'abc', :baz => 123}}
  end
  
  it 'should be able to jump back up to the parent in the chain with #_end!' do
    @c.foo!.bar('abc')._end!.baz(123)
    @c.should == {:foo => {:bar => 'abc'}, :baz => 123}
  end
  
  it 'should merge rather than replace existing keys' do
    @c.where(:abc => 'def').where(:hgi => 123)
    @c.should == {:where => {:abc => 'def', :hgi => 123}}
  end
end
