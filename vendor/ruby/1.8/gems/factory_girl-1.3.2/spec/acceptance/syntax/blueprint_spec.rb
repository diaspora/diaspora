require 'spec_helper'

require 'factory_girl/syntax/blueprint'

describe "a blueprint" do
  before do
    Factory.sequence(:email) { |n| "somebody#{n}@example.com" }
    User.blueprint do
      first_name { 'Bill'               }
      last_name  { 'Nye'                }
      email      { Factory.next(:email) }
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

    it "should use attributes from the blueprint" do
      @instance.first_name.should == 'Bill'
    end

    it "should evaluate attribute blocks for each instance" do
      @instance.email.should =~ /somebody\d+@example.com/
      Factory(:user).email.should_not == @instance.email
    end
  end
end
