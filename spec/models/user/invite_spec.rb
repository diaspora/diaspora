#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let(:inviter)  {new_user = eve; new_user.invites = 5; new_user.save; new_user;}
  let(:aspect)   {inviter.aspects.create(:name => "awesome")}
  let(:another_user) {alice}
  let(:wrong_aspect) {another_user.aspects.create(:name => "super")}
  let(:inviter_with_3_invites) { new_user = Factory.create(:user); new_user.invites = 3; new_user.save; new_user;}
  let(:aspect2) {inviter_with_3_invites.aspects.create(:name => "Jersey Girls")}

  before do
    @email = "bob@bob.com"
  end

  context "creating invites" do
    it 'requires your aspect' do
      lambda {
        inviter.invite_user(wrong_aspect.id, "email", "maggie@example.com")
      }.should raise_error ActiveRecord::RecordNotFound
    end
    
    it 'takes a service parameter' do
      @invite_params = {:service => 'email'}
      Invitation.should_receive(:invite).with(hash_including(@invite_params))
      inviter.invite_user(aspect.id, 'email', @email) 
    end

    it 'takes an indentifier parameter' do
      @invite_params = {:identifier => @email}
      Invitation.should_receive(:invite).with(hash_including(@invite_params))
      inviter.invite_user(aspect.id, 'email', @email)
    end

    it 'calls Invitation.invite' do
      Invitation.should_receive(:invite)
      inviter.invite_user(aspect.id, 'email', @email)
    end

    it 'has an invitation' do
      inviter.invite_user(aspect.id, 'email', @email).invitations_to_me.count.should == 1
    end

    it 'creates it with an email' do
      inviter.invite_user(aspect.id, 'email', @email).email.should == @email
    end


    it 'throws if you try to add someone you"re connected to' do
      connect_users(inviter, aspect, another_user, wrong_aspect)
      inviter.reload
      proc{
        inviter.invite_user(aspect.id, 'email', another_user.email)
      }.should raise_error ActiveRecord::RecordInvalid
    end

  end

  context "limit on invites" do

    it 'does not invite people I already invited' do
      inviter_with_3_invites.invite_user(aspect2.id, 'email', "email1@example.com")
      proc{
        inviter_with_3_invites.invite_user(aspect2.id, 'email', "email1@example.com")
      }.should raise_error /You already invited this person/
    end
  end


  describe "#accept_invitation!" do
    let(:invited_user) {@invited_user_pre.accept_invitation!(:invitation_token => "abc",
                              :email    => "a@a.com",
                              :username => "user",
                              :password => "secret",
                              :password_confirmation => "secret",
                              :person => {:profile => {:first_name => "Bob",
                                :last_name  => "Smith"}} )}

    before do
      @invited_user_pre = Invitation.invite(:from => inviter, :service => 'email', :identifier => 'invitee@example.org', :into => aspect).reload
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
        Request.where(:recipient_id => invited_user.person.id).count.should == 1
      end

      context 'after request acceptance' do
        before do
          fantasy_resque do
            invited_user.accept_and_respond(
              Request.where(:recipient_id => invited_user.person.id).first.id,
              invited_user.aspects.create(:name => 'first aspect!').id
            )
          end
          invited_user.reload
          inviter.reload
        end
        it 'successfully connects invited_user to inviter' do
          invited_user.contact_for(inviter.person).should_not be_nil
          invited_user.contact_for(inviter.person).should_not be_pending
          Request.where(:recipient_id => invited_user.person.id).count.should == 0
        end

        it 'successfully connects inviter to invited_user' do
          inviter.contact_for(invited_user.person).should_not be_pending
        end
      end
    end
  end
end

