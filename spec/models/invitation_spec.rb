#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Invitation do
  let(:user) { alice }

  before do
    @email = 'maggie@example.com'
    Devise.mailer.deliveries = []
  end
  describe 'validations' do
    before do
      @invitation = Factory.build(:invitation, :sender => user, :recipient => eve, :aspect => user.aspects.first)
    end

    it 'is valid' do
      @invitation.sender.should == user
      @invitation.recipient.should == eve
      @invitation.aspect.should == user.aspects.first
      @invitation.should be_valid
    end

    it 'ensures the sender is placing the recipient into one of his aspects' do
      @invitation.aspect = Factory(:aspect)
      @invitation.should_not be_valid
    end
  end

  it 'has a message' do
    @invitation = Factory.build(:invitation, :sender => user, :recipient => eve, :aspect => user.aspects.first)
    @invitation.message = "!"
    @invitation.message.should == "!"
  end



  describe 'the invite process' do
    before do
    end

    it 'works for a new user' do
      invite = Invitation.new(:sender => alice, :aspect => alice.aspects.first, :service => 'email', :identifier => 'foo@bar.com')
      lambda {
        invite.save
        invite.send!
      }.should change(User, :count).by(1)
    end

    it 'works for a current user(with the right email)' do
      invite = Invitation.create(:sender => alice, :aspect => alice.aspects.first, :service => 'email', :identifier => bob.email)
      lambda {
        invite.send!
      }.should_not change(User, :count)
    end

    it 'works for a current user(with the same fb id)' do
      bob.services << Factory.build(:service, :type => "Services::Facebook")
      invite = Invitation.create(:sender => alice, :aspect => alice.aspects.first, :service => 'facebook', :identifier => bob.services.first.uid)
      lambda {
        invite.send!
      }.should_not change(User, :count)
    end

    it 'handles the case when that user has an invite but not a user' do
      pending
    end

    it 'handles the case where that user has an invite but has not yet accepted' do
      pending
    end

    it 'generate the invitation token and pass it to the user' do

    end
  end
 
  describe '.resend' do
    before do
      @invitation = Factory(:invitation, :sender => alice, :aspect => alice.aspects.first, :service => 'email', :identifier => 'a@a.com')
    end

    it 'sends another email' do
      lambda {
        @invitation.resend
      }.should change(Devise.mailer.deliveries, :count).by(1)
    end
  end

  describe '#recipient_identifier' do
    it 'calls email if the invitation_service is email' do
      email = 'abc@abc.com'
      invitation = Factory(:invitation, :sender => alice, :service => 'email', :identifier => email, :aspect => alice.aspects.first)
      invitation.recipient_identifier.should == email
    end

    context 'facebook' do
      before do
        @uid = '23526464'
        @service = "facebook"
        alice.services << Services::Facebook.new(:uid => "13234895")
        alice.reload.services(true).first.service_users.create(:uid => @uid, :photo_url => 'url',  :name => "Remote User")
      end

      it 'gets the name if the invitation_service is facebook' do
        invitation = Factory(:invitation, :sender => alice, :identifier => @uid, :service => @service, :aspect => alice.aspects.first)
        invitation.recipient_identifier.should == "Remote User"
      end

      it 'does not error if the facebook user is not recorded' do
        invitation = Factory(:invitation, :sender => alice, :identifier => @uid, :service => @service, :aspect => alice.aspects.first)
        alice.services.first.service_users.delete_all
        invitation.recipient_identifier.should == "A Facebook user"
      end
    end
  end
end

