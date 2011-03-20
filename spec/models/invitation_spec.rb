#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Invitation do
  let(:user) { alice }
  let(:aspect) { user.aspects.first }
  let(:user2) { eve }
  before do
    user.invites = 20
    user.save
    @email = 'maggie@example.com'
    Devise.mailer.deliveries = []
  end
  describe 'validations' do
    before do
      aspect
      @invitation = Invitation.new(:sender => user, :recipient => user2, :aspect => aspect)
    end
    it 'is valid' do
      @invitation.sender.should == user
      @invitation.recipient.should == user2
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
    @invitation = Invitation.new(:sender => user, :recipient => user2, :aspect => aspect)
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
      inv.persisted?.should be_false
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
    before do
      @users = []
      8.times do
        @users << Factory.create(:user)
      end
      @user_fb_id = 'abc123'
      @user_fb = Factory.create(:user, :invitation_service => "facebook", :invitation_identifier => @user_fb_id)
    end

    context 'send a request to an existing' do
      context 'active user' do
        it 'by email' do
          @identifier = @users[3].email
          @type = 'email'
          inv.should == @users[3]
        end

        it 'by service' do
          uid = '123324234'
          @users[0].services << Services::Facebook.new(:uid => uid)
          @users[0].save

          @type = 'facebook'
          @identifier = uid

          inv.should == @users[0]
        end
      end

      context 'invitated user' do
        it 'by email' do
          @identifier = @users[3].email
          @type = 'email'

          @users[3].invitation_identifier = @identifier
          @users[3].invitation_service = @type
          @users[3].save
          inv.should == @users[3]
        end

        it 'by service' do
          @identifier = @user_fb_id
          @type = 'facebook'
          inv.should == @user_fb
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
      user2
      user.should_receive(:send_contact_request_to) { |a, b|
        a.should == user2.person
        b.should == aspect
      }
      Invitation.invite(:from => user, :service => 'email', :identifier => user2.email, :into => aspect)
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

      it "changes the invitation token" do
        old_token = @invitee.invitation_token
        Invitation.create_invitee(@valid_params)
        @invitee.reload.invitation_token.should_not == old_token
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
        Devise.mailer.deliveries.first.to_s.should include("Welcome #{@email}")
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

  describe '#to_request!' do
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
        @invitation.to_request!
      }.should change(Invitation, :count).by(-1)
    end
    it 'creates a request, and sends it to the new user' do
      lambda {
        @invitation.to_request!
      }.should change(Request, :count).by(1)
    end
    it 'creates a pending contact for the inviter' do
      lambda {
        @invitation.to_request!
      }.should change(Contact.unscoped, :count).by(1)
      @invitation.sender.contact_for(@new_user.person).should be_pending
    end
    describe 'return values' do
      before do
        @request = @invitation.to_request!
      end
      it 'returns the sent request' do
        @request.is_a?(Request).should be_true
      end
      it 'sets the receiving user' do
        @request.recipient.should == @new_user.person
      end
      it 'sets the sending user' do
        @request.sender.should == user.person
      end
      it 'sets the aspect' do
        @request.aspect.should == aspect
      end
    end
  end
end

