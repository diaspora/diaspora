require 'spec_helper'

describe UserPreference do

  it 'should only allow valid email types to exist' do
    pref = alice.user_preferences.new(:email_type => 'not_valid')
    pref.should_not be_valid
  end
end
