require 'spec_helper'
describe SplunkLogging do
  def add

  end
  include SplunkLogging
  describe '#format_hash' do
    it 'does not quote keys' do
      format_hash({:key => 'value'}).should =~ /key=/
    end
    it 'quotes strings' do
      format_hash({:key => 'value'}).should =~ /="value"/
    end
    it 'does not quote symbols' do
      format_hash({:key => :value}).should =~ /=value/
    end
    it 'does not quote numbers' do
      format_hash({:key => 500 }).should =~ /=500/
    end
    it 'does not quote floats' do
      format_hash({:key => 2.324}).should =~ /=2.324/
    end
    it 'does not quote classes' do
      format_hash({:key => Class}).should =~ /=Class/
    end
    it 'escapes double quotes in strings' do
      format_hash({:key => 'whaaa " quotes'}).should =~ /="whaaa \\\" quotes"/
    end
  end
end
