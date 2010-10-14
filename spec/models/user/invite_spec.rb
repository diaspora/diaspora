#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let(:inviter)  {Factory.create :user}
  let(:inviter_with_3_invites) {Factory.create :user, :invites => 3}
  let!(:invited_user)  { create_user_with_invitation("abc", :email => "email@example.com", :inviter => inviter)}
  let(:invited_user1) { create_user_with_invitation("abc", :email => "email@example.com", :inviter => inviter_with_3_invites)}
  let(:invited_user2) { create_user_with_invitation("abc", :email => "email@example.com", :inviter => inviter_with_3_invites)}
  let(:invited_user3) { create_user_with_invitation("abc", :email => "email@example.com", :inviter => inviter_with_3_invites)}

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

  context "limit on invites" do
    it 'does not invite users after 3 invites' do
      User.stub!(:invite!).and_return(invited_user1,invited_user2,invited_user3)
      inviter_with_3_invites.invite_user(:email => "email1@example.com")
      inviter_with_3_invites.invite_user(:email => "email2@example.com")
      inviter_with_3_invites.invite_user(:email => "email3@example.com")
      proc{inviter_with_3_invites.invite_user(:email => "email4@example.com")}.should raise_error /You have no invites/
    end

    it 'does not invite people I already invited' do
      pending "this is really weird to test without the actual method working"
      User.stub!(:invite!).and_return(invited_user1,invited_user1)
      inviter_with_3_invites.invite_user(:email => "email1@example.com")
      proc{inviter_with_3_invites.invite_user(:email => "email1@example.com")}.should raise_error /You already invited that person/
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
