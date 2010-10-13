#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let(:inviter)  {Factory.create :user}
  let!(:invited_user) { create_user_with_invitation("abc", :email => "email@example.com", :inviter => inviter)}

  context "creating invites" do
    it 'should invite the user' do
      pending "weird wrong number of arguments error (0 for 2), which changes if you put in two args"
      #User.should_receive(:invite!).and_return(invited_user)
      inviter.invite_user(:email => "email@example.com")
    end

    it 'should add the inviter to the invited_user' do
      User.should_receive(:invite!).and_return(invited_user)
      invited_user = inviter.invite_user(:email => "email@example.com")
      invited_user.reload
      invited_user.inviters.include?(inviter).should be true
    end
  end

  context "the acceptance of an invitation" do
    it "should create the person with the passed in params" do
      person_count = Person.count
      u = invited_user.accept_invitation!(:invitation_token => "abc",
                              :username => "user",
                              :password => "secret",
                              :password_confirmation => "secret",
                              :person => {:profile => {:first_name => "Bob",
                                :last_name  => "Smith"}} )
      Person.count.should be person_count + 1
      u.person.profile.first_name.should == "Bob"
    end
  end
  

end

def create_user_with_invitation(invitation_token, attributes={})
  inviter = attributes.delete(:inviter)
  user = User.new({:password => nil, :password_confirmation => nil}.update(attributes))
  #user.skip_confirmation!
  user.invitation_token = invitation_token
  user.invitation_sent_at = Time.now.utc
  user.inviters << inviter
  user.save(:validate => false)
  user
end
