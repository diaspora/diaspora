# frozen_string_literal: true

describe NotificationSetting, :type => :model do
  it 'should only allow valid notification types to exist' do
    setting = alice.notification_settings.new(:type => 'not_valid')
    expect(setting).not_to be_valid
  end
end
