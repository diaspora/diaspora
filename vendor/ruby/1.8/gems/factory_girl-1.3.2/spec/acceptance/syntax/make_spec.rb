require 'spec_helper'

require 'factory_girl/syntax/make'

describe "a factory using make syntax" do
  before do
    Factory.define :user do |factory|
      factory.first_name 'Bill'
      factory.last_name  'Nye'
      factory.email      'science@guys.net'
    end
  end

  after do
    Factory.factories.clear
  end

  describe "after making an instance" do
    before do
      @instance = User.make(:last_name => 'Rye')
    end

    it "should use attributes from the factory" do
      @instance.first_name.should == 'Bill'
    end

    it "should use attributes passed to make" do
      @instance.last_name.should == 'Rye'
    end

    it "should save the record" do
      @instance.should_not be_new_record
    end
  end
end
