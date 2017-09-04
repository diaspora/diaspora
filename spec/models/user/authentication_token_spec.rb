# frozen_string_literal: true

describe User::AuthenticationToken, type: :model do
  describe "#reset_authentication_token!" do
    it "sets the authentication token" do
      expect(alice.authentication_token).to be_nil
      alice.reset_authentication_token!
      expect(alice.authentication_token).not_to be_nil
    end

    it "resets the authentication token" do
      alice.reset_authentication_token!
      expect { alice.reset_authentication_token! }.to change { alice.authentication_token }
    end
  end

  describe "#ensure_authentication_token!" do
    it "doesn't change the authentication token" do
      alice.reset_authentication_token!
      expect { alice.ensure_authentication_token! }.to_not change { alice.authentication_token }
    end

    it "sets the authentication token if not yet set" do
      expect(alice.authentication_token).to be_nil
      alice.ensure_authentication_token!
      expect(alice.authentication_token).not_to be_nil
    end
  end

  describe ".authentication_token" do
    it "generates an authentication token" do
      expect(User.authentication_token.length).to eq(30)
    end

    it "checks that the authentication token is not yet in use by another user" do
      alice.reset_authentication_token!
      expect(Devise).to receive(:friendly_token).with(30).and_return(alice.authentication_token, "some_unused_token")

      expect(User.authentication_token).to eq("some_unused_token")
    end
  end
end
