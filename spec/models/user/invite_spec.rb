#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  context "creating invites" do
    before do
      @aspect = eve.aspects.first
      @email = "bob@bob.com"
    end

    it 'requires your aspect' do
      lambda {
        eve.invite_user(alice.aspects.first.id, "email", "maggie@example.com")
      }.should raise_error ActiveRecord::RecordNotFound
    end
    
    it 'takes a service parameter' do
      @invite_params = {:service => 'email'}
      Invitation.should_receive(:invite).with(hash_including(@invite_params))
      eve.invite_user(@aspect.id, 'email', @email) 
    end

    it 'takes an indentifier parameter' do
      @invite_params = {:identifier => @email}
      Invitation.should_receive(:invite).with(hash_including(@invite_params))
      eve.invite_user(@aspect.id, 'email', @email)
    end

    it 'calls Invitation.invite' do
      Invitation.should_receive(:invite)
      eve.invite_user(@aspect.id, 'email', @email)
    end

    it 'has an invitation' do
      eve.invite_user(@aspect.id, 'email', @email).invitations_to_me.count.should == 1
    end

    it 'creates it with an email' do
      eve.invite_user(@aspect.id, 'email', @email).email.should == @email
    end

    it "throws if you try to add someone you're connected to" do
      connect_users(eve, @aspect, alice, alice.aspects.first)
      lambda {
        eve.invite_user(@aspect.id, 'email', alice.email)
      }.should raise_error ActiveRecord::RecordNotUnique
    end

    it 'does not invite people I already invited' do
      eve.invite_user(@aspect.id, 'email', "email1@example.com")
      lambda {
        eve.invite_user(@aspect.id, 'email', "email1@example.com")
      }.should raise_error /You already invited this person/
    end
  end

  describe "#accept_invitation!" do
    before do
      invite_pre = Invitation.invite(:from => eve, :service => 'email', :identifier => 'invitee@example.org', :into => eve.aspects.first).reload
      @person_count = Person.count
      @invited_user = invite_pre.accept_invitation!(:invitation_token => "abc",
                            :email    => "a@a.com",
                            :username => "user",
                            :password => "secret",
                            :password_confirmation => "secret",
                            :person => {:profile => {:first_name => "Bob",
                              :last_name  => "Smith"}} )

    end

    context 'after invitation acceptance' do
      it 'destroys the invitations' do
        @invited_user.invitations_to_me.count.should == 0
      end

      it "should create the person with the passed in params" do
        Person.count.should == @person_count + 1
        @invited_user.person.profile.first_name.should == "Bob"
      end

      it 'resolves incoming invitations into contact requests' do
        eve.contacts.where(:person_id => @invited_user.person.id).count.should == 1
      end
    end
  end
end

