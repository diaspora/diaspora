require 'sasl'
require 'spec'

describe SASL::Plain do
  class MyPlainPreferences < SASL::Preferences
    def authzid
      'bob@example.com'
    end
    def username
      'bob'
    end
    def has_password?
      true
    end
    def password
      's3cr3t'
    end
  end
  preferences = MyPlainPreferences.new

  it 'should authenticate' do
    sasl = SASL::Plain.new('PLAIN', preferences)
    sasl.start.should == ['auth', "bob@example.com\000bob\000s3cr3t"]
    sasl.success?.should == false
    sasl.receive('success', nil).should == nil
    sasl.failure?.should == false
    sasl.success?.should == true
  end

  it 'should recognize failure' do
    sasl = SASL::Plain.new('PLAIN', preferences)
    sasl.start.should == ['auth', "bob@example.com\000bob\000s3cr3t"]
    sasl.success?.should == false
    sasl.failure?.should == false
    sasl.receive('failure', 'keep-idiots-out').should == nil
    sasl.failure?.should == true
    sasl.success?.should == false
  end
end
