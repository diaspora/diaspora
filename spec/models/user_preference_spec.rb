# frozen_string_literal: true

describe UserPreference, :type => :model do
  it 'should only allow valid email types to exist' do
    pref = alice.user_preferences.new(:email_type => 'not_valid')
    expect(pref).not_to be_valid
  end
end
