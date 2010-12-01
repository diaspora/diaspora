require 'spec_helper'
require 'extlib/byte_array'

describe Extlib::ByteArray do
  it 'should be a String' do
    Extlib::ByteArray.new.should be_kind_of(String)
  end
end
