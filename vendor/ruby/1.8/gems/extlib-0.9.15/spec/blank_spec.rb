require 'spec_helper'
require 'extlib/blank'

describe Object do
  it 'should provide blank?' do
    Object.new.should respond_to(:blank?)
  end

  it 'should be blank if it is nil' do
    object = Object.new
    class << object
      def nil?; true end
    end
    object.should be_blank
  end

  it 'should be blank if it is empty' do
    {}.should be_blank
    [].should be_blank
  end

  it 'should not be blank if not nil or empty' do
    Object.new.should_not be_blank
    [nil].should_not be_blank
    { nil => 0 }.should_not be_blank
  end
end

describe Numeric do
  it 'should provide blank?' do
    1.should respond_to(:blank?)
  end

  it 'should never be blank' do
    1.should_not be_blank
  end
end

describe NilClass do
  it 'should provide blank?' do
    nil.should respond_to(:blank?)
  end

  it 'should always be blank' do
    nil.should be_blank
  end
end

describe TrueClass do
  it 'should provide blank?' do
    true.should respond_to(:blank?)
  end

  it 'should never be blank' do
    true.should_not be_blank
  end
end

describe FalseClass do
  it 'should provide blank?' do
    false.should respond_to(:blank?)
  end

  it 'should always be blank' do
    false.should be_blank
  end
end

describe String do
  it 'should provide blank?' do
    'string'.should respond_to(:blank?)
  end

  it 'should be blank if empty' do
    ''.should be_blank
  end

  it 'should be blank if it only contains whitespace' do
    ' '.should be_blank
    " \r \n \t ".should be_blank
  end

  it 'should not be blank if it contains non-whitespace' do
    ' a '.should_not be_blank
  end
end
