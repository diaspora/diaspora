require 'spec_helper'
require 'gherkin/formatter/model'

module Gherkin
  module Formatter
    module Model
      describe Tag do
        it "should be equal when name is equal" do
          tags = [Tag.new('@x', 1), Tag.new('@y', 2), Tag.new('@x', 3)]
          tags.to_a.uniq.length.should == 2
        end
      end
    end
  end
end