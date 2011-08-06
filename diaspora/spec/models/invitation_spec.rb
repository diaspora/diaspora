#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Invitation do
  let(:user) { alice }
  let(:aspect) { user.aspects.first }

  before do
    user.invites = 20
    user.save
    @email = 'maggie@example.com'
    Devise.mailer.deliveries = []
  end
  describe 'validations' do
    before do
      aspect
      @invitation = Invitation.new(:sender => user, :recipient => eve, :aspect => aspect)
    end
    it 'is valid' do
      @invitation.sender.should == user
      @invitation.recipient.should == eve
      @invitation.aspect.should == aspect
      @invitation.should be_valid
    end
    it 'is from a user' do
      @invitation.sender = nil
      @invitation.should_not be_valid
    end
    it 'is to a user' do
      @invitation.recipient = nil
      @invitation.should_not be_valid
    end
    it 'is into an aspect' do
      @invitation.aspect = nil
      @invitation.should_not be_valid
    end
  end

  it 'has a message' do
    @invitation = Invitation.new(:sender => user, :recipient => eve, :aspect => aspect)
    @invitation.message = "!"
    @invitation.message.should == "!"
  end

  describe '.new_user_by_service_and_identifier' do
    let(:inv) { Invitation.new_user_by_service_and_identifier(@type, @identifier) }

    it 'returns User.new for a non-existent user for email' do
      @type = "email"
      @identifier = "maggie@example.org"
      inv.invitation_identifier.should == @identifier
      inv.invitation_service.should == 'email'
      inv.should_not be_persisted
      lambda {
        inv.reload
      }.should raise_error ActiveRecord::RecordNotFound
    end

    it 'returns User.new for a non-existent user' do
      @type = "facebook"
      @identifier = "1234892323"
      inv.invitation_identifier.should == @identifier
      inv.invitation_service.should == @type
      inv.persisted?.should be_false
      lambda {
        inv.reload
      }.should raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '.find_existing_user' do
    let(:inv) { Invitation.find_existing_user(@type, @identifier) }

    context 'send a request to an existing' do
      context 'active user' do
        it 'by email' do
          @identifier = alice.email
          @type = 'email'
          inv.should == alice
        end

        it 'by service' do
          uid = '123324234'
          alice.services << Services::Facebook.new(:uid => uid)
          alice.save

          @type = 'facebook'
          @identifier = uid

          inv.should == alice
        end
      end

      context 'invited user' do
        it 'by email' do
          @identifier = alice.email
          @type = 'email'

          alice.invitation_identifier = @identifier
          alice.invitation_service = @type
          alice.save
          inv.should == alice
        end

        it 'by service' do
          fb_id = 'abc123'
          alice.invitation_service = 'facebook'
          alice.invitation_identifier = fb_id
          alice.save

          @identifier = fb_id
          @type = 'facebook'
          inv.should == alice
        end
      end
    end
  end

  describe '.invite' do
    it 'creates an invitation' do
      lambda {
        Invitation.invite(:service => 'email', :identifier => @email, :from => user, :into => aspect)
      }.should change(Invitation, :count).by(1)
    end

    it 'associates the invitation with the inviter' do
      lambda {
        Invitation.invite(:service => 'email', :identifier => @email, :from => user, :into => aspect)
      }.should change { user.reload.invitations_from_me.count }.by(1)
    end

    it 'associates the invitation with the invitee' do
      new_user = Invitation.invite(:service => 'email', :identifier => @email, :from => user, :into => aspect)
      new_user.invitations_to_me.count.should == 1
    end

    it 'creates a user' do
      lambda {
        Invitation.invite(:from => user, :service => 'email', :identifier => @email, :into => aspect)
      }.should change(User, :count).by(1)
    end

    it 'returns the new user' do
      new_user = Invitation.invite(:from => user, :service => 'email', :identifier => @email, :into => aspect)
      new_user.is_a?(User).should be_true
      new_user.email.should == @email
    end

    it 'adds the inviter to the invited_user' do
      new_user = Invitation.invite(:from => user, :service => 'email', :identifier => @email, :into => aspect)
      new_user.invitations_to_me.first.sender.should == user
    end

    it 'adds an optional message' do
      message = "How've you been?"
      new_user = Invitation.invite(:from => user, :service => 'email', :identifier => @email, :into => aspect, :message => message)
      new_user.invitations_to_me.first.message.should == message
    end

    it 'sends a contact request to a user with that email into the aspect' do
      user.should_receive(:share_with).with(eve.person, aspect)
      Invitation.invite(:from => user, :service => 'email', :identifier => eve.email, :into => aspect)
    end

    it 'decrements the invite count of the from user' do
      message = "How've you been?"
      lambda {
        new_user = Invitation.invite(:from => user, :service => 'email', :identifier => @email, :into => aspect, :message => message)
      }.should change(user, :invites).by(-1)
    end

    it "doesn't decrement counter past zero" do
      user.invites = 0
      user.save!
      message = "How've you been?"
      lambda {
        Invitation.invite(:from => user, :service => 'email', :identifier => @email, :into => aspect, :message => message)
      }.should_not change(user, :invites)
    end

    context 'invalid email' do
      it 'return a user with errors' do
        new_user = Invitation.invite(:service => 'email', :identifier => "fkjlsdf", :from => user, :into => aspect)
        new_user.should have(1).errors_on(:email)
        new_user.should_not be_persisted
      end
    end
  end

  describe '.create_invitee' do
    context "when we're resending an invitation" do
      before do
        @valid_params = {:from => user,
                         :service => 'email',
                         :identifier => @email,
                         :into => aspect,
                         :message => @message}
        @invitee = Invitation.create_invitee(:service => 'email', :identifier => @email)
        @valid_params[:existing_user] = @invitee
      end

      it "does not create a user" do
        expect { Invitation.create_invitee(@valid_params) }.should_not change(User, :count)
      end

      it "sends mail" do
        expect {
          Invitation.create_invitee(@valid_params)
        }.should change { Devise.mailer.deliveries.size }.by(1)
      end

      it "does not set the key" do
        expect {
          Invitation.create_invitee(@valid_params)
        }.should_not change { @invitee.reload.serialized_private_key }
      end

      it "does not change the invitation token" do
        old_token = @invitee.invitation_token
        Invitation.create_invitee(@valid_params)
        @invitee.reload.invitation_token.should == old_token
      end
    end
    context 'with an inviter' do
      before do
        @message = "whatever"
        @valid_params = {:from => user, :service => 'email', :identifier => @email, :into => aspect, :message => @message}
      end

      it "sends mail" do
        expect {
          Invitation.create_invitee(@valid_params)
        }.should change { Devise.mailer.deliveries.size }.by(1)
      end

      it "includes the message in the email" do
        Invitation.create_invitee(@valid_params)
        Devise.mailer.deliveries.last.to_s.should include(@message)
      end

      it "has no translation missing" do
        Invitation.create_invitee(@valid_params)
        Devise.mailer.deliveries.last.body.raw_source.should_not match(/(translation_missing.+)/)
      end

      it "doesn't create a user if the email is invalid" do
        new_user = Invitation.create_invitee(@valid_params.merge(:identifier => 'fdfdfdfdf'))
        new_user.should_not be_persisted
        new_user.should have(1).error_on(:email)
      end

      it "does not save a user with an empty string email" do
        @valid_params[:service] = 'facebook'
        @valid_params[:identifier] = '3423423'
        Invitation.create_invitee(@valid_params)
        @valid_params[:identifier] = 'dfadsfdas'
        expect { Invitation.create_invitee(@valid_params) }.should_not raise_error
      end
    end

    context 'with no inviter' do
      it 'sends an email that includes the right things' do
        Invitation.create_invitee(:service => 'email', :identifier => @email)
        Devise.mailer.deliveries.first.to_s.should include("Email not displaying correctly?")
      end
      it 'creates a user' do
        expect {
          Invitation.create_invitee(:service => 'email', :identifier => @email)
        }.should change(User, :count).by(1)
      end
      it 'sends email to the invited user' do
        expect {
          Invitation.create_invitee(:service => 'email', :identifier => @email)
        }.should change { Devise.mailer.deliveries.size }.by(1)
      end
      it 'does not create an invitation' do
        expect {
          Invitation.create_invitee(:service => 'email', :identifier => @email)
        }.should_not change(Invitation, :count)
      end
    end
  end

  describe '.resend' do
    before do
      aspect
      user.invite_user(aspect.id, 'email', "a@a.com", "")
      @invitation = user.reload.invitations_from_me.first
    end

    it 'sends another email' do
      lambda { @invitation.resend }.should change(Devise.mailer.deliveries, :count).by(1)
    end
  end

  describe '#share_with!' do
    before do
      @new_user = Invitation.invite(:from => user, :service => 'email', :identifier => @email, :into => aspect)
      acceptance_params = {:invitation_token => "abc",
                           :username => "user",
                           :email => @email,
                           :password => "secret",
                           :password_confirmation => "secret",
                           :person => {:profile => {:first_name => "Bob", :last_name => "Smith"}}}
      @new_user.setup(acceptance_params)
      @new_user.person.save
      @new_user.save
      @invitation = @new_user.invitations_to_me.first
    end

    it 'destroys the invitation' do
      lambda {
        @invitation.share_with!
      }.should change(Invitation, :count).by(-1)
    end

    it 'creates a contact for the inviter and invitee' do
      lambda {
        @invitation.share_with!
      }.should change(Contact, :count).by(2)
    end
  end

  describe '#recipient_identifier' do
    it 'calls email if the invitation_service is email' do
      alice.invite_user(aspect.id, 'email', "a@a.com", "")
      invitation = alice.reload.invitations_from_me.first
      invitation.recipient_identifier.should == 'a@a.com'
    end
    it 'gets the name if the invitation_service is facebook' do
      alice.services << Services::Facebook.new(:uid => "13234895")
      alice.reload.services(true).first.service_users.create(:uid => "23526464", :photo_url => 'url',  :name => "Remote User")
      alice.invite_user(aspect.id, 'facebook', "23526464", '')
      invitation = alice.reload.invitations_from_me.first
      invitation.recipient_identifier.should == "Remote User"
    end
  end
end

