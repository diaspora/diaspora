require File.dirname(__FILE__) + '/../spec_helper'

describe Profile do
  before do
    @person = Factory.build(:person)
  end

  describe 'requirements' do
    it "should include a first name" do
      @person.profile = Factory.build(:profile,:first_name => nil)
      @person.profile.valid?.should be false
      @person.profile.first_name = "Bob"
      @person.profile.valid?.should be true
    end
   
    it "should include a last name" do
      @person.profile = Factory.build(:profile, :last_name => nil)
      @person.profile.valid?.should be false
      @person.profile.last_name = "Smith"
      @person.profile.valid?.should be true
    end 

  end

end

