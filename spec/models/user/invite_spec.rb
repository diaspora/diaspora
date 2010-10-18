#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let(:inviter)  {Factory.create :user}
  let(:aspect)   {inviter.aspect(:name => "awesome")}
  let(:another_user) {Factory.create :user}
  let(:wrong_aspect) {another_user.aspect(:name => "super")}
  let(:inviter_with_3_invites) {Factory.create :user, :invites => 3}
  let(:aspect2) {inviter_with_3_invites.aspect(:name => "Jersey Girls")}


  before do
    deliverable = Object.new
    deliverable.stub!(:deliver)
    ::Devise.mailer.stub!(:invitation).and_return(deliverable)
  end

  context "creating invites" do 
    it 'requires an apect' do
      proc{inviter.invite_user(:email => "maggie@example.com")}.should raise_error /Must invite into aspect/
    end

    it 'requires your aspect' do
      proc{inviter.invite_user(:email => "maggie@example.com", :aspect_id => wrong_aspect.id)}.should raise_error /Must invite to your aspect/
    end

    it 'creates a user' do
      inviter
      lambda {
        inviter.invite_user(:email => "joe@example.com", :aspect_id => aspect.id )
      }.should change(User, :count).by(1)
    end

    it 'sends email to the invited user' do
      ::Devise.mailer.should_receive(:invitation).once
      inviter.invite_user(:email => "ian@example.com", :aspect_id => aspect.id)
    end

    it 'adds the inviter to the invited_user' do
      invited_user = inviter.invite_user(:email => "marcy@example.com", :aspect_id => aspect.id)
      invited_user.reload
      invited_user.inviters.include?(inviter).should be_true
    end


    it 'adds a pending request to the invited user' do
      invited_user = inviter.invite_user(:email => "marcy@example.com", :aspect_id => aspect.id)
      invited_user.reload
      invited_user.pending_requests.find_by_callback_url(inviter.receive_url).nil?.should == false
    end

    it 'adds a pending request to the inviter' do
      inviter.invite_user(:email => "marcy@example.com", :aspect_id => aspect.id)
      inviter.reload
      inviter.pending_requests.find_by_callback_url(inviter.receive_url).nil?.should == false
    end

    it 'throws if you try to add someone you"re friends with' do
      friend_users(inviter, aspect, another_user, wrong_aspect)
      inviter.reload
      proc{inviter.invite_user(:email => another_user.email, :aspect_id => aspect.id)}.should raise_error /You are already friends with this person/
    end

    it 'sends a friend request to a user with that email into the aspect' do
      inviter.should_receive(:send_friend_request_to){ |a, b| 
        a.should == another_user.person
        b.should == aspect
      }
      inviter.invite_user(:email => another_user.email, :aspect_id => aspect.id)
    end
  end

  context "limit on invites" do

    it 'does not invite users after 3 invites' do
      inviter_with_3_invites.invite_user(:email => "email1@example.com", :aspect_id => aspect2.id)
      inviter_with_3_invites.invite_user(:email => "email2@example.com", :aspect_id => aspect2.id)
      inviter_with_3_invites.invite_user(:email => "email3@example.com", :aspect_id => aspect2.id)
      proc{inviter_with_3_invites.invite_user(:email => "email4@example.com", :aspect_id => aspect2.id)}.should raise_error /You have no invites/
    end

    it 'does not invite people I already invited' do
      inviter_with_3_invites.invite_user(:email => "email1@example.com", :aspect_id => aspect2.id)
      proc{inviter_with_3_invites.invite_user(:email => "email1@example.com", :aspect_id => aspect2.id)}.should raise_error /You already invited this person/
    end
  end


  context "the acceptance of an invitation" do
    let!(:invited_user1) { create_user_with_invitation("abc", :email => "email@example.com", :inviter => inviter)}
    let!(:invited_user2) { inviter.invite_user(:email => "jane@example.com", :aspect_id => aspect.id) }

    it "should create the person with the passed in params" do
      person_count = Person.count
      u = invited_user1.accept_invitation!(:invitation_token => "abc",
                              :username => "user",
                              :password => "secret",
                              :password_confirmation => "secret",
                              :person => {:profile => {:first_name => "Bob",
                                :last_name  => "Smith"}} )
      Person.count.should be person_count + 1
      u.person.profile.first_name.should == "Bob"
    end

    it 'should auto accept the request for the sender into the right aspect' do
      u = invited_user2.accept_invitation!(:invitation_token => invited_user2.invitation_token,
                              :username => "user",
                              :password => "secret",
                              :password_confirmation => "secret",
                              :person => {:profile => {:first_name => "Bob",
                                :last_name  => "Smith"}} )
      u.pending_requests
      u.pending_requests.count.should == 1
      request = u.pending_requests.first
      aspect2  = u.aspect(:name => "dudes")
      u.reload
      inviter
      inviter.receive_salmon(u.salmon(u.accept_friend_request(request.id, aspect2.id)).xml_for(inviter.person))
      inviter.friends.include?(u.person).should be true
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
