require 'spec_helper'
require 'acceptance/acceptance_helper'

require 'factory_girl/syntax/blueprint'

describe "a blueprint" do
  before do
    define_model('User', :first_name => :string, :last_name => :string, :email => :string)

    Factory.sequence(:email) { |n| "somebody#{n}@example.com" }
    User.blueprint do
      first_name { 'Bill'                       }
      last_name  { 'Nye'                        }
      email      { FactoryGirl.generate(:email) }
    end
  end

  describe "after making an instance" do
    before do
      @instance = FactoryGirl.create(:user, :last_name => 'Rye')
    end

    it "should use attributes from the blueprint" do
      @instance.first_name.should == 'Bill'
    end

    it "should evaluate attribute blocks for each instance" do
      @instance.email.should =~ /somebody\d+@example.com/
      FactoryGirl.create(:user).email.should_not == @instance.email
    end
  end
end
