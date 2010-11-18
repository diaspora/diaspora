#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Invitation do
  let(:user)   {make_user}
  let!(:aspect) {user.aspects.create(:name => "Invitees")}
  let(:user2)  {make_user}
  before do
    @email = 'maggie@example.com'
    Devise.mailer.deliveries = []
  end
  describe 'validations' do
    before do
      aspect
      @invitation = Invitation.new(:from => user, :to => user2, :into => aspect) 
    end
    it 'is valid' do
      @invitation.should be_valid
      @invitation.from.should == user
      @invitation.to.should   == user2
      @invitation.into.should == aspect
    end
    it 'is from a user' do
      @invitation.from = nil
      @invitation.should_not be_valid
    end
    it 'is to a user' do
      @invitation.to = nil
      @invitation.should_not be_valid
    end
    it 'is into an aspect' do
      @invitation.into = nil
      @invitation.should_not be_valid
    end
  end

  it 'has a message' do
    @invitation = Invitation.new(:from => user, :to => user2, :into => aspect) 
    @invitation.message = "!"
    @invitation.message.should == "!"
  end

  describe '.invite' do
    it 'creates an invitation' do
      lambda {
        Invitation.invite(:email => @email, :from => user, :into => aspect)
      }.should change(Invitation, :count).by(1)
    end
    it 'associates the invitation with the inviter' do
      lambda {
        Invitation.invite(:email => @email, :from => user, :into => aspect)
      }.should change{user.reload.invitations_from_me.count}.by(1)
    end
    it 'associates the invitation with the invitee' do
      new_user = Invitation.invite(:email => @email, :from => user, :into => aspect)
      new_user.invitations_to_me.count.should == 1
    end
    it 'creates a user' do
      lambda {
        Invitation.invite(:from => user, :email => @email, :into => aspect)
      }.should change(User, :count).by(1)
    end
    it 'returns the new user' do
      new_user = Invitation.invite(:from => user, :email => @email, :into => aspect)
      new_user.is_a?(User).should be_true
      new_user.email.should == @email
    end
    it 'adds the inviter to the invited_user' do
      new_user = Invitation.invite(:from => user, :email => @email, :into => aspect)
      new_user.invitations_to_me.first.from.should == user
    end

    it 'adds an optional message' do
      message = "How've you been?"
      new_user = Invitation.invite(:from => user, :email => @email, :into => aspect, :message => message)
      new_user.invitations_to_me.first.message.should == message
    end

    it 'sends a contact request to a user with that email into the aspect' do
      user2
      user.should_receive(:send_contact_request_to){ |a, b| 
        a.should == user2.person
        b.should == aspect
      }
      Invitation.invite(:from => user, :email => user2.email, :into => aspect)
    end
  end

  describe '.create_invitee' do
    context 'with an inviter' do
      it 'sends mail' do
        message = "How've you been?"
        lambda {
          Invitation.create_invitee(:from => user, :email => @email, :into => aspect, :message => message)
        }.should change{Devise.mailer.deliveries.size}.by(1)
      end
      it 'mails the optional message' do
        message = "How've you been?"
        new_user = Invitation.create_invitee(:from => user, :email => @email, :into => aspect, :message => message)
        Devise.mailer.deliveries.first.to_s.include?(message).should be_true
      end
      it 'has no translation missing' do
        message = "How've you been?"
        new_user = Invitation.create_invitee(:from => user, :email => @email, :into => aspect, :message => message)
        Devise.mailer.deliveries.first.body.raw_source.match(/(translation_missing.+)/).should be_nil
      end
    end
    context 'with no inviter' do
      it 'sends an email that includes the right things' do
        Invitation.create_invitee(:email => @email)
        Devise.mailer.deliveries.first.to_s.include?("Welcome #{@email}").should == true
      end
      it 'creates a user' do
        lambda {
          Invitation.create_invitee(:email => @email)
        }.should change(User, :count).by(1)
      end
      it 'sends email to the invited user' do
        lambda {
          Invitation.create_invitee(:email => @email)
        }.should change{Devise.mailer.deliveries.size}.by(1)
      end
      it 'does not render nonsensical emails' do
        Invitation.create_invitee(:email => @email)
        Devise.mailer.deliveries.first.body.raw_source.match(/have invited you to join/i).should be_false
      end
      it 'creates an invitation' do
        pending "Invitations should be more flexible, allowing custom messages to be passed in without an inviter."
        lambda {
          Invitation.create_invitee(:email => @email)
        }.should change(Invitation, :count).by(1)
      end
    end
  end

  describe '#to_request!' do
    before do
      @new_user = Invitation.invite(:from => user, :email => @email, :into => aspect)
      acceptance_params = {:invitation_token => "abc",
                              :username => "user",
                              :password => "secret",
                              :password_confirmation => "secret",
                              :person => {:profile => {:first_name => "Bob",
                                :last_name  => "Smith"}}}
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
      }.should change(Request, :count).by(2)
    end
    describe 'return values' do
      before do
        @request = @invitation.to_request!
      end
      it 'returns the sent request' do
        @request.is_a?(Request).should be_true
      end
      it 'sets the receiving user' do
        @request.to.should == @new_user.person
      end
      it 'sets the sending user' do
        @request.from.should == user.person
      end
      it 'sets the aspect' do
        @request.into.should == aspect
      end
    end
  end
end

