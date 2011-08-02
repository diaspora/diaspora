require 'spec_helper'

describe OAuth2::Provider.authorization_code_class do
  describe "any instance" do
    subject do
      OAuth2::Provider.authorization_code_class.new(
        :authorization => create_authorization,
        :redirect_uri => "http://redirect.example.com/callback"
      )
    end

    it "is valid with an access grant, expiry time, redirect uri and code" do
      subject.should be_valid
    end

    it "is invalid without a redirect_uri" do
      subject.redirect_uri = nil
      subject.should_not be_valid
    end

    it "is invalid without a code" do
      subject.code = nil
      subject.should_not be_valid
    end

    it "is invalid without an access grant" do
      subject.authorization = nil
      subject.should_not be_valid
    end

    it "is invalid when expires_at isn't set" do
      subject.expires_at = nil
      subject.should_not be_valid
    end

    it "has expired when expires_at is in the past" do
      subject.expires_at = 1.second.ago
      subject.should be_expired
    end

    it "has not expired when expires_at is now or in the future" do
      subject.expires_at = Time.now
      subject.should_not be_expired
    end
  end

  describe "a new instance" do
    subject do
      OAuth2::Provider.authorization_code_class.new
    end

    it "is assigned a randomly generated code" do
      subject.code.should_not be_nil
      OAuth2::Provider.authorization_code_class.new.code.should_not be_nil
      subject.code.should_not == OAuth2::Provider.authorization_code_class.new.code
    end

    it "expires in 1 minute by default" do
      subject.expires_at.should == 1.minute.from_now
    end
  end

  describe "a saved instance" do
    subject do
      OAuth2::Provider.authorization_code_class.create!(
        :authorization => create_authorization,
        :redirect_uri => "https://client.example.com/callback/here"
      )
    end

    it "can be claimed with the correct code and redirect_uri" do
      OAuth2::Provider.authorization_code_class.claim(subject.code, subject.redirect_uri).should_not be_nil
    end

    it "returns an access token when claimed" do
      OAuth2::Provider.authorization_code_class.claim(subject.code, subject.redirect_uri).should be_instance_of(OAuth2::Provider.access_token_class)
    end

    it "can't be claimed twice" do
      OAuth2::Provider.authorization_code_class.claim(subject.code, subject.redirect_uri)
      OAuth2::Provider.authorization_code_class.claim(subject.code, subject.redirect_uri).should be_nil
    end

    it "can't be claimed without a matching code" do
      OAuth2::Provider.authorization_code_class.claim("incorrectCode", subject.redirect_uri).should be_nil
    end

    it "can't be claimed without a matching redirect_uri" do
      OAuth2::Provider.authorization_code_class.claim(subject.code, "https://wrong.example.com").should be_nil
    end

    it "can't be claimed once expired" do
      Timecop.travel subject.expires_at + 1.minute
      OAuth2::Provider.authorization_code_class.claim(subject.code, subject.redirect_uri).should be_nil
    end
  end

  describe "the access token returned when a code is claimed" do
    subject do
      @code = OAuth2::Provider.authorization_code_class.create!(
        :authorization => create_authorization,
        :redirect_uri => "https://client.example.com/callback/here"
      )
      OAuth2::Provider.authorization_code_class.claim(@code.code, @code.redirect_uri)
    end

    it "is saved to the database" do
      subject.should_not be_new_record
    end

    it "has same access grant as claimed code" do
      subject.authorization.should == @code.authorization
    end
  end
end