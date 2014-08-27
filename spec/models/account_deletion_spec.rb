#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AccountDeletion, :type => :model do
  it 'assigns the diaspora_handle from the person object' do
    a = AccountDeletion.new(:person => alice.person)
    expect(a.diaspora_handle).to eq(alice.person.diaspora_handle)
  end

  it 'fires a job after creation'do
    expect(Workers::DeleteAccount).to receive(:perform_async).with(anything)

    AccountDeletion.create(:person => alice.person)
  end

  describe "#perform!" do
    before do
      @ad = AccountDeletion.new(:person => alice.person)
    end

    it 'creates a deleter' do
      expect(AccountDeleter).to receive(:new).with(alice.person.diaspora_handle).and_return(double(:perform! => true))
      @ad.perform!
    end
    
    it 'dispatches the account deletion if the user exists' do
      expect(@ad).to receive(:dispatch)
      @ad.perform!
    end

    it 'does not dispatch an account deletion for non-local people' do
      deletion = AccountDeletion.new(:person => remote_raphael)
      expect(deletion).not_to receive(:dispatch)
      deletion.perform!
    end

    it 'marks an AccountDeletion as completed when successful' do
      ad = AccountDeletion.create(:person => alice.person)
      ad.perform!
      expect(ad.reload.completed_at).not_to be_nil
    end
  end

  describe '#dispatch' do
    it "sends the account deletion xml" do
      @ad = AccountDeletion.new(:person => alice.person)
      @ad.send(:dispatch)
    end

    it 'creates a public postzord' do
      expect(Postzord::Dispatcher::Public).to receive(:new).and_return(double.as_null_object)
      @ad = AccountDeletion.new(:person => alice.person)
      @ad.send(:dispatch)
    end
  end

  describe "#subscribers" do
    it 'includes all remote contacts' do
      @ad = AccountDeletion.new(:person => alice.person)
      alice.share_with(remote_raphael, alice.aspects.first)

      expect(@ad.subscribers(alice)).to eq([remote_raphael])
    end

    it 'includes remote resharers' do
      @ad = AccountDeletion.new(:person => alice.person)
      sm = FactoryGirl.create( :status_message, :public => true, :author => alice.person)
      r1 = FactoryGirl.create( :reshare, :author => remote_raphael, :root => sm)
      r2 = FactoryGirl.create( :reshare, :author => local_luke.person, :root => sm)

      expect(@ad.subscribers(alice)).to eq([remote_raphael])
    end
  end

  describe 'serialization' do
    before do
      account_deletion = AccountDeletion.new(:person => alice.person)
      @xml = account_deletion.to_xml.to_s
    end

    it 'should have a diaspora_handle' do
      expect(@xml.include?(alice.person.diaspora_handle)).to eq(true)
    end
    
    it 'marshals the xml' do
      expect(AccountDeletion.from_xml(@xml)).to be_valid
    end
  end
end
