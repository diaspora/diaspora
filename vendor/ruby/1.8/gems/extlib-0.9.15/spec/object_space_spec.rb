require 'spec_helper'
require 'extlib/object_space'

describe ObjectSpace, "#classes" do
  it 'returns only classes, nothing else' do
    ObjectSpace.classes.each do |klass|
      Class.should === klass
    end
  end
end
