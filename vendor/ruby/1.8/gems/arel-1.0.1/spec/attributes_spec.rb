require 'spec_helper'

module Arel
  module Sql
    describe 'Attributes' do
      describe 'for' do
        it 'should return undefined for undefined columns' do
          thing = Struct.new(:type).new(:HELLO)
          check Attributes.for(thing).should == Attributes::Undefined
        end
      end
    end
  end
end
