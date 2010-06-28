require 'spec_helper'

describe Person do

  it 'should require a profile' do 
    person = Factory.build(:person, :profile => nil)
    person.valid?.should be false
    person.profile = Factory.build(:profile)
    person.valid?.should be true
  end

end
