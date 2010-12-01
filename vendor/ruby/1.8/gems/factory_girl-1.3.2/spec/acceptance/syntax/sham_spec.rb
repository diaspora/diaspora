require 'spec_helper'

require 'factory_girl/syntax/sham'

describe "a factory using sham syntax" do
  before do
    Sham.name  { "Name" }
    Sham.email { "somebody#{rand(5)}@example.com" }

    Factory.define :user do |factory|
      factory.first_name { Sham.name }
      factory.last_name  { Sham.name }
      factory.email      { Sham.email }
    end
  end

  after do
    Factory.factories.clear
    Factory.sequences.clear
  end

  describe "after making an instance" do
    before do
      @instance = Factory(:user, :last_name => 'Rye')
    end

    it "should support a sham called 'name'" do
      @instance.first_name.should == 'Name'
    end

    it "should use the sham for the email" do
      @instance.email.should =~ /somebody\d@example.com/
    end
  end
end
