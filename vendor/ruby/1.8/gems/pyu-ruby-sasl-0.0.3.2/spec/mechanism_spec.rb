require 'sasl'
require 'spec'

describe SASL do
  it 'should know DIGEST-MD5' do
    sasl = SASL.new_mechanism('DIGEST-MD5', SASL::Preferences.new)
    sasl.should be_an_instance_of SASL::DigestMD5
  end
  it 'should know PLAIN' do
    sasl = SASL.new_mechanism('PLAIN', SASL::Preferences.new)
    sasl.should be_an_instance_of SASL::Plain
  end
  it 'should know ANONYMOUS' do
    sasl = SASL.new_mechanism('ANONYMOUS', SASL::Preferences.new)
    sasl.should be_an_instance_of SASL::Anonymous
  end
  it 'should choose ANONYMOUS' do
    preferences = SASL::Preferences.new
    class << preferences
      def want_anonymous?
        true
      end
    end
    SASL.new(%w(PLAIN DIGEST-MD5 ANONYMOUS), preferences).should be_an_instance_of SASL::Anonymous
  end
  it 'should choose DIGEST-MD5' do
    preferences = SASL::Preferences.new
    class << preferences
      def has_password?
        true
      end
    end
    SASL.new(%w(PLAIN DIGEST-MD5 ANONYMOUS), preferences).should be_an_instance_of SASL::DigestMD5
  end
  it 'should choose PLAIN' do
    preferences = SASL::Preferences.new
    class << preferences
      def has_password?
        true
      end
      def allow_plaintext?
        true
      end
    end
    SASL.new(%w(PLAIN ANONYMOUS), preferences).should be_an_instance_of SASL::Plain
  end
  it 'should disallow PLAIN by default' do
    preferences = SASL::Preferences.new
    class << preferences
      def has_password?
        true
      end
    end
    lambda { SASL.new(%w(PLAIN ANONYMOUS), preferences) }.should raise_error(SASL::UnknownMechanism)
  end
end
