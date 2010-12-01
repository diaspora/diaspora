require 'sasl'
require 'spec'

describe SASL::Anonymous do
  class MyAnonymousPreferences < SASL::Preferences
    def username
      'bob'
    end
  end
  preferences = MyAnonymousPreferences.new

  it 'should authenticate anonymously' do
    sasl = SASL::Anonymous.new('ANONYMOUS', preferences)
    sasl.start.should == ['auth', 'bob']
    sasl.success?.should == false
    sasl.receive('success', nil).should == nil
    sasl.success?.should == true
  end
end
