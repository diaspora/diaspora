#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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
      @invitation = FactoryGirl.build(:invitation, :sender => user, :recipient => nil, :aspect => user.aspects.first, :language => "de")
    end

    it 'is valid' do
      @invitation.sender.should == user
      @invitation.recipient.should == nil
      @invitation.aspect.should == user.aspects.first
      @invitation.language.should == "de"
      @invitation.should be_valid
    end

    it 'ensures the sender is placing the recipient into one of his aspects' do
      @invitation.aspect = FactoryGirl.build(:aspect)
      @invitation.should_not be_valid
    end
  end

  describe '#language' do  
    it 'returns the correct language if the language is set' do
      @invitation = FactoryGirl.build(:invitation, :sender => user, :recipient => eve, :aspect => user.aspects.first, :language => "de")
      @invitation.language.should == "de"
    end  

    it 'returns en if no language is set' do
      @invitation = FactoryGirl.build(:invitation, :sender => user, :recipient => eve, :aspect => user.aspects.first)
      @invitation.language.should == "en"
    end
  end

  it 'has a message' do
    @invitation = FactoryGirl.build(:invitation, :sender => user, :recipient => eve, :aspect => user.aspects.first, :language => user.language)
    @invitation.message = "!"
    @invitation.message.should == "!"
  end

 
  describe '.batch_invite' do
    before do
      @emails = ['max@foo.com', 'bob@mom.com']
      @opts = {:aspect => eve.aspects.first, :sender => eve, :service => 'email', :language => eve.language}
    end

    it 'returns an array of invites based on the emails passed in' do
      invites = Invitation.batch_invite(@emails, @opts)
      invites.count.should be 2
      invites.all?{|x| x.persisted?}.should be_true
    end

    it 'shares with people who are already on the pod' do
      FactoryGirl.create(:user, :email => @emails.first)
      invites = nil
      expect{
        invites = Invitation.batch_invite(@emails, @opts)
      }.to change(eve.contacts, :count).by(1)
      invites.count.should be 2

    end
  end
end
