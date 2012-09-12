#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AccountDeletion do
  it 'assigns the diaspora_handle from the person object' do
    a = AccountDeletion.new(:person => alice.person)
    a.diaspora_handle.should == alice.person.diaspora_handle
  end

  it 'fires a resque job after creation'do
    Resque.should_receive(:enqueue).with(Jobs::DeleteAccount, anything)

    AccountDeletion.create(:person => alice.person)
  end

  describe "#perform!" do
    before do
      @ad = AccountDeletion.new(:person => alice.person)
    end

    it 'creates a deleter' do
      AccountDeleter.should_receive(:new).with(alice.person.diaspora_handle).and_return(stub(:perform! => true))
      @ad.perform!
    end
    
    it 'dispatches the account deletion if the user exists' do
      @ad.should_receive(:dispatch)
      @ad.perform!
    end

    it 'does not dispatch an account deletion for non-local people' do
      deletion =  AccountDeletion.new(:person => remote_raphael)
      deletion.should_not_receive(:dispatch)
      deletion.perform!
    end
  end

  describe '#dispatch' do
    it "sends the account deletion xml" do
      @ad = AccountDeletion.new(:person => alice.person)
      @ad.send(:dispatch)
    end

    it 'creates a public postzord' do
      Postzord::Dispatcher::Public.should_receive(:new).and_return(stub.as_null_object)
      @ad = AccountDeletion.new(:person => alice.person)
      @ad.send(:dispatch)
    end
  end

  describe "#subscribers" do
    it 'includes all remote contacts' do
      @ad = AccountDeletion.new(:person => alice.person)
      alice.share_with(remote_raphael, alice.aspects.first)

      @ad.subscribers(alice).should == [remote_raphael]
    end

    it 'includes remote resharers' do
      @ad = AccountDeletion.new(:person => alice.person)
      sm = FactoryGirl.create( :status_message, :public => true, :author => alice.person)
      r1 = FactoryGirl.create( :reshare, :author => remote_raphael, :root => sm)
      r2 = FactoryGirl.create( :reshare, :author => local_luke.person, :root => sm)

      @ad.subscribers(alice).should == [remote_raphael]
    end
  end

  describe 'serialization' do
    before do
      account_deletion = AccountDeletion.new(:person => alice.person)
      @xml = account_deletion.to_xml.to_s
    end

    it 'should have a diaspora_handle' do
      @xml.include?(alice.person.diaspora_handle).should == true
    end
    
    it 'marshals the xml' do
      AccountDeletion.from_xml(@xml).should be_valid
    end
  end
end
