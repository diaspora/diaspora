require 'spec_helper'

describe Workers::ResetPassword do
  describe "#perform" do
    it "given a user id it sends the reset password instructions for that user" do
      user = FactoryGirl.create :user
      expect {
        mail = Workers::ResetPassword.new.perform(user.id)
        mail.to.should == [user.email]
        mail.body.should include("change your password")
      }.to change(Devise.mailer.deliveries, :length).by(1)
    end
  end
end
