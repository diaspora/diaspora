#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let(:inviter)  {new_user = make_user; new_user.invites = 5; new_user.save; new_user;}
  let(:aspect)   {inviter.aspects.create(:name => "awesome")}
  let(:another_user) {make_user}
  let(:wrong_aspect) {another_user.aspects.create(:name => "super")}
  let(:inviter_with_3_invites) { new_user = make_user; new_user.invites = 3; new_user.save; new_user;}
  let(:aspect2) {inviter_with_3_invites.aspects.create(:name => "Jersey Girls")}

  context "creating invites" do 
    it 'requires an apect' do
      proc{
        inviter.invite_user(:email => "maggie@example.com")
      }.should raise_error /Must invite into aspect/
    end

    it 'requires your aspect' do
      proc{
        inviter.invite_user(:email => "maggie@example.com", :aspect_id => wrong_aspect.id)
      }.should raise_error /Must invite to your aspect/
    end

    it 'calls Invitation.invite' do
      Invitation.should_receive(:invite)
      inviter.invite_user(:email => @email, :aspect_id => aspect.id)
    end

    it 'has an invitation' do
      inviter.invite_user(:email => "joe@example.com", :aspect_id => aspect.id).invitations_to_me.count.should == 1
    end

    it 'creates it with an email' do
      inviter.invite_user(:email => "joe@example.com", :aspect_id => aspect.id).email.should == "joe@example.com"
    end


    it 'throws if you try to add someone you"re connected to' do
      connect_users(inviter, aspect, another_user, wrong_aspect)
      inviter.reload
      proc{inviter.invite_user(:email => another_user.email, :aspect_id => aspect.id)}.should raise_error /already connected/
    end

  end

  context "limit on invites" do

    it 'does not invite people I already invited' do
      inviter_with_3_invites.invite_user(:email => "email1@example.com", :aspect_id => aspect2.id)
      proc{inviter_with_3_invites.invite_user(:email => "email1@example.com", :aspect_id => aspect2.id)}.should raise_error /You already invited this person/
    end
  end


  describe "#accept_invitation!" do
    let(:invited_user) {@invited_user_pre.accept_invitation!(:invitation_token => "abc",
                              :username => "user",
                              :password => "secret",
                              :password_confirmation => "secret",
                              :person => {:profile => {:first_name => "Bob",
                                :last_name  => "Smith"}} )}

    before do
      @invited_user_pre = Invitation.invite(:from => inviter, :email => 'invitee@example.org', :into => aspect).reload
      @person_count = Person.count
    end

    context 'after invitation acceptance' do
      before do
        invited_user.reload
      end
      it 'destroys the invitations' do
        invited_user.invitations_to_me.count.should == 0
      end
      it "should create the person with the passed in params" do
        Person.count.should == @person_count + 1
        invited_user.person.profile.first_name.should == "Bob"
      end

      it 'resolves incoming invitations into contact requests' do
        invited_user.reload.pending_requests.count.should == 1
        inviter.reload.pending_requests.count.should == 1
      end

      context 'after request acceptance' do
        before do
          invited_user.accept_and_respond(invited_user.pending_requests.first.id,
                                              invited_user.aspects.create(
                                                :name => 'first aspect!').id)
          invited_user.reload
          inviter.reload
        end
        it 'successfully connects invited_user to inviter' do
          invited_user.contact_for(inviter.person).should_not be_nil
          invited_user.pending_requests.count.should == 0
        end

        it 'successfully connects inviter to invited_user' do
          inviter.contact_for(invited_user.person).should_not be_nil
          inviter.pending_requests.size.should == 0
        end
      end
    end
  end
end

